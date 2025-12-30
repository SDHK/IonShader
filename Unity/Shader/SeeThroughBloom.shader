Shader "Test/SeeThroughBloom"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Tint Color", Color) = (1, 1, 1, 1)
        
        // 泛光参数
        _BloomThreshold ("Bloom Threshold", Range(0, 2)) = 1.0
        _BloomIntensity ("Bloom Intensity", Range(0, 5)) = 1.0
        _BloomBlurSize ("Bloom Blur Size", Range(0, 1)) = 0.01
        
        // 距离缩放参数（用于保持相对于物体的视觉大小不变）
        _ReferenceDistance ("Reference Distance", Float) = 10.0
        
        // 边缘效果
        _EdgeSoftness ("Edge Softness", Range(0, 1)) = 0.2
    }
    
    SubShader
    {
        Tags 
        { 
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        }
        LOD 100
        
        // GrabPass：抓取屏幕内容
        GrabPass
        {
            "_GrabTexture"
        }
        
        Pass
        {
            Name "BLOOM"
            Tags { "LightMode" = "Always" }
            
            Cull Back
            ZWrite Off
            ZTest LEqual
            // 使用Alpha混合，物体本身透明，只显示背景和泛光
            Blend SrcAlpha OneMinusSrcAlpha
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            
            #include "UnityCG.cginc"
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            
            sampler2D _GrabTexture;
            float4 _GrabTexture_TexelSize;
            
            float _BloomThreshold;
            float _BloomIntensity;
            float _BloomBlurSize;
            float _ReferenceDistance;
            float _EdgeSoftness;
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };
            
            struct Varyings
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 grabPos : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float viewDistance : TEXCOORD4;
                UNITY_FOG_COORDS(3)
            };
            
            Varyings vert(Attributes input)
            {
                Varyings output;
                
                // 转换到世界空间
                float4 positionWS = mul(unity_ObjectToWorld, float4(input.positionOS.xyz, 1.0));
                output.positionWS = positionWS.xyz;
                
                output.pos = UnityObjectToClipPos(input.positionOS);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                
                // 计算GrabPass的屏幕空间坐标
                output.grabPos = ComputeGrabScreenPos(output.pos);
                
                // 计算摄像机距离（用于屏幕空间缩放）
                float3 viewDir = _WorldSpaceCameraPos - positionWS.xyz;
                output.viewDistance = length(viewDir);
                
                UNITY_TRANSFER_FOG(output, output.pos);
                
                return output;
            }
            
            // 改进的高斯模糊采样（减少锯齿）
            // 使用真正的2D高斯权重函数
            half3 SampleBloom(float2 uv, float blurSize)
            {
                // 使用屏幕空间的像素大小来确保采样均匀
                float2 texelSize = _GrabTexture_TexelSize.xy;
                float2 pixelOffset = blurSize * texelSize;
                
                // 高斯模糊的标准差（sigma），控制模糊范围
                float sigma = blurSize * 2.0;
                float twoSigmaSq = 2.0 * sigma * sigma;
                
                half3 color = half3(0, 0, 0);
                float totalWeight = 0.0;
                
                // 5x5采样核
                for (int x = -2; x <= 2; x++)
                {
                    for (int y = -2; y <= 2; y++)
                    {
                        // 计算到中心的距离的平方
                        float distSq = float(x * x + y * y);
                        
                        // 使用2D高斯函数计算权重
                        // G(x,y) = (1 / (2πσ²)) * exp(-(x²+y²) / (2σ²))
                        // 简化版：exp(-distSq / twoSigmaSq)
                        float weight = exp(-distSq / twoSigmaSq);
                        
                        // 计算采样偏移
                        float2 offset = float2(x, y) * pixelOffset;
                        half3 sampleColor = tex2D(_GrabTexture, uv + offset).rgb;
                        
                        // 提取高亮区域
                        half brightness = dot(sampleColor, half3(0.299, 0.587, 0.114));
                        half highlight = max(0, brightness - _BloomThreshold);
                        
                        // 加权累加
                        color += sampleColor * highlight * weight;
                        totalWeight += highlight * weight;
                    }
                }
                
                // 归一化
                if (totalWeight > 0.001)
                    color /= totalWeight;
                else
                    color = half3(0, 0, 0);
                
                return color;
            }
            
            half4 frag(Varyings input) : SV_Target
            {
                // 将GrabPass坐标转换为UV坐标（0-1范围）
                float2 grabUV = input.grabPos.xy / input.grabPos.w;
                
                // 计算屏幕空间缩放因子
                // 物体在屏幕上的大小与距离成反比，所以模糊大小也应该与距离成反比
                // 使用参考距离来归一化，使得在参考距离时缩放为1.0
                // 距离越远，物体在屏幕上越小，模糊也应该越小，所以用 referenceDistance / distance
                float screenSpaceScale = _ReferenceDistance / max(input.viewDistance, 0.001);
                
                // 采样原始屏幕内容（背景）
                half3 originalColor = tex2D(_GrabTexture, grabUV).rgb;
                
                // 应用泛光效果（提取高亮并模糊）
                // 根据屏幕空间缩放调整模糊大小，保持相对于物体的视觉大小不变
                half3 bloomColor = SampleBloom(grabUV, _BloomBlurSize * screenSpaceScale);
                
                // 叠加泛光到原始背景，物体本身不添加任何颜色
                // 强度也根据屏幕空间缩放调整，保持视觉一致性
                half3 finalColor = originalColor + bloomColor * _BloomIntensity * screenSpaceScale;
                
                // 采样物体自身的纹理（用于边缘效果和透明度遮罩）
                half4 mainTex = tex2D(_MainTex, input.uv);
                
                // 计算边缘遮罩（基于UV到中心的距离）
                float2 uvCenter = float2(0.5, 0.5);
                float distFromCenter = length(input.uv - uvCenter);
                float edgeFade = smoothstep(0.5 - _EdgeSoftness, 0.5, distFromCenter);
                
                // 计算alpha（边缘透明，物体本身完全透明）
                // 物体中心区域alpha接近0（完全透明），边缘alpha接近1（显示泛光效果）
                half alpha = mainTex.a * _Color.a * (1.0 - edgeFade);
                
                half4 final = half4(finalColor, alpha);
                
                // 应用雾效
                UNITY_APPLY_FOG(input.fogCoord, final);
                
                return final;
            }
            ENDHLSL
        }
    }
    
    Fallback "Transparent/Diffuse"
}

