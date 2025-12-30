Shader "Test/MagnifyingGlass"
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
            Name "MAGNIFY"
            Tags { "LightMode" = "Always" }
            
            Cull Back
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
                output.viewDirWS = normalize(_WorldSpaceCameraPos - positionWS.xyz);
                
                UNITY_TRANSFER_FOG(output, output.pos);
                
                return output;
            }
            
            half4 frag(Varyings input) : SV_Target
            {
                // 将GrabPass坐标转换为UV坐标（0-1范围）
                float2 grabUV = input.grabPos.xy / input.grabPos.w;
                
                // 计算放大镜中心（使用物体UV中心作为视觉中心）
                // 假设UV中心(0.5, 0.5)是放大镜的视觉中心
                float2 uvCenter = float2(0.5, 0.5);
                float2 uvOffset = input.uv - uvCenter;
                
                // 计算当前像素到中心的距离和方向（基于UV）
                // 这个偏移量表示从放大镜中心到当前像素的方向
                float2 centerToPixel = uvOffset;
                
                // 应用放大效果：将屏幕UV向中心收缩
                // 放大倍数越大，UV收缩越多，看到的区域越小（放大效果）
                // 公式：magnifiedUV = center + (pixel - center) / magnification
                float2 magnifiedUV = grabUV - centerToPixel + centerToPixel / _Magnification;
                
                // 可选：添加轻微的扭曲效果（模拟真实放大镜）
                float2 distortion = input.normalWS.xy * _Distortion;
                magnifiedUV += distortion;
                
                // 采样放大后的屏幕内容
                half4 grabColor = tex2D(_GrabTexture, magnifiedUV);
                
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

