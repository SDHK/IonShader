Shader "Test/MagnifyingGlass_Inside"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Tint Color", Color) = (1, 1, 1, 1)
        
        // 放大镜参数
        _Magnification ("Magnification", Range(1.0, 5.0)) = 2.0
        _EdgeSoftness ("Edge Softness", Range(0, 1)) = 0.2
        _Distortion ("Distortion", Range(0, 0.1)) = 0.02
        
        // 边缘效果
        _EdgeColor ("Edge Color", Color) = (0.8, 0.8, 0.8, 1)
        _EdgeWidth ("Edge Width", Range(0, 0.1)) = 0.05
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
            Name "MAGNIFY_INSIDE"
            Tags { "LightMode" = "Always" }
            
            // 双面渲染：不剔除任何面（保持双面以便从内部看到）
            Cull Off
            ZWrite Off
            ZTest LEqual
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
            
            float _Magnification;
            float _EdgeSoftness;
            float _Distortion;
            float4 _EdgeColor;
            float _EdgeWidth;
            
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
                float2 screenUV : TEXCOORD2;
                float3 normalWS : TEXCOORD3;
                float3 viewDirWS : TEXCOORD4;
                float3 positionWS : TEXCOORD5;
                UNITY_FOG_COORDS(6)
            };
            
            Varyings vert(Attributes input)
            {
                Varyings output;
                
                float4 positionWS = mul(unity_ObjectToWorld, float4(input.positionOS.xyz, 1.0));
                output.positionWS = positionWS.xyz;
                output.pos = UnityObjectToClipPos(input.positionOS);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                
                // 计算GrabPass的屏幕空间坐标
                output.grabPos = ComputeGrabScreenPos(output.pos);
                
                // 计算屏幕空间UV（用于确定放大中心）
                output.screenUV = output.pos.xy / _ScreenParams.xy;
                
                // 法线转换到世界空间
                float3 normalWS = mul((float3x3)unity_ObjectToWorld, input.normalOS);
                output.normalWS = normalize(normalWS);
                
                // 计算视角方向
                float3 viewDir = _WorldSpaceCameraPos - positionWS.xyz;
                output.viewDirWS = normalize(viewDir);
                
                UNITY_TRANSFER_FOG(output, output.pos);
                
                return output;
            }
            
            half4 frag(Varyings input, float facing : VFACE) : SV_Target
            {
                // 检测是前面还是背面（facing > 0 是前面，< 0 是背面）
                bool isBackFace = facing < 0;
                
                // 将GrabPass坐标转换为UV坐标（0-1范围）
                float2 grabUV = input.grabPos.xy / input.grabPos.w;
                
                // 计算放大镜中心（使用物体UV中心作为视觉中心）
                float2 uvCenter = float2(0.5, 0.5);
                float2 uvOffset = input.uv - uvCenter;
                
                // 计算当前像素到中心的距离和方向（基于UV）
                float2 centerToPixel = uvOffset;
                
                // 计算视角方向（从物体位置指向摄像机）
                // 假设法线永远都朝着摄像机，使用视角方向来计算扭曲
                float3 viewDirWS = normalize(_WorldSpaceCameraPos - input.positionWS);
                
                half4 grabColor;
                
                if (isBackFace)
                {
                    // 背面渲染：应用缩小镜效果
                    // 缩小效果：将屏幕UV向外扩展（与放大相反）
                    // 公式：minifiedUV = center + (pixel - center) * magnification
                    float2 minifiedUV = grabUV - centerToPixel + centerToPixel * _Magnification;
                    
                    // 添加轻微的扭曲效果（使用视角方向，不依赖法线）
                    float2 distortion = viewDirWS.xy * _Distortion;
                    minifiedUV += distortion;
                    
                    // 采样缩小后的屏幕内容
                    grabColor = tex2D(_GrabTexture, minifiedUV);
                }
                else
                {
                    // 正面渲染：应用正常的放大效果
                    // 应用放大效果：将屏幕UV向中心收缩
                    // 公式：magnifiedUV = center + (pixel - center) / magnification
                    float2 magnifiedUV = grabUV - centerToPixel + centerToPixel / _Magnification;
                    
                    // 添加轻微的扭曲效果（使用视角方向，不依赖法线）
                    float2 distortion = viewDirWS.xy * _Distortion;
                    magnifiedUV += distortion;
                    
                    // 采样放大后的屏幕内容
                    grabColor = tex2D(_GrabTexture, magnifiedUV);
                }
                
                // 采样物体自身的纹理（用于边缘效果）
                half4 mainTex = tex2D(_MainTex, input.uv);
                
                // 计算边缘遮罩（基于到中心的距离）
                float distFromCenter = length(centerToPixel);
                float edgeMask = smoothstep(0.5 - _EdgeWidth, 0.5, distFromCenter);
                
                // 边缘软化
                float edgeFade = smoothstep(0.5 - _EdgeSoftness, 0.5, distFromCenter);
                
                // 混合边缘颜色
                half3 finalColor = lerp(grabColor.rgb, _EdgeColor.rgb, edgeMask);
                
                // 应用物体颜色和边缘淡化
                finalColor = lerp(finalColor, grabColor.rgb, edgeFade);
                finalColor *= _Color.rgb;
                
                // 计算alpha（边缘透明）
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

