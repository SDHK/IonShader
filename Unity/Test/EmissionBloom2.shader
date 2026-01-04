Shader "Test/EmissionBloom2"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Base Color", Color) = (1, 1, 1, 1)
        
        // 自发光相关属性
        [HDR] _EmissionColor ("Emission Color", Color) = (0, 0, 0, 1)
        _EmissionIntensity ("Emission Intensity", Float) = 1.0
        _EmissionTex ("Emission Texture", 2D) = "black" {}
        _EmissionPower ("Emission Power", Range(0.1, 5.0)) = 2.0
        
        // 光晕参数
        _GlowSize ("Glow Size", Range(0, 0.1)) = 0.01
        _GlowIntensity ("Glow Intensity", Range(0, 5)) = 1.0
        _GlowEdgeFade ("Glow Edge Fade", Range(0, 5)) = 2.0
        _GlowMaxBrightness ("Glow Max Brightness", Range(0.5, 3.0)) = 1.5
        [Toggle] _EnableGlowPass ("Enable Glow Pass", Float) = 1
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque" 
            "Queue" = "Geometry"
        }
        LOD 100
        
        HLSLINCLUDE
        #include "UnityCG.cginc"
        
        // 材质属性
        sampler2D _MainTex;
        float4 _MainTex_ST;
        float4 _Color;
        
        // 自发光属性
        float4 _EmissionColor;
        float _EmissionIntensity;
        sampler2D _EmissionTex;
        float4 _EmissionTex_ST;
        float _EmissionPower;
        
        // 光晕属性
        float _GlowSize;
        float _GlowIntensity;
        float _GlowEdgeFade;
        float _GlowMaxBrightness;
        float _EnableGlowPass;
        
        // 顶点数据结构
        struct Attributes
        {
            float4 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float2 uv : TEXCOORD0;
        };
        
        // 基础片段数据结构
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float2 uv : TEXCOORD0;
            float3 normalWS : TEXCOORD1;
            float3 positionWS : TEXCOORD2;
            float3 viewDirWS : TEXCOORD3;
        };
        
        // 顶点着色器基础函数
        Varyings vertBase(Attributes input)
        {
            Varyings output;
            
            float4 positionWS = mul(unity_ObjectToWorld, float4(input.positionOS.xyz, 1.0));
            output.positionWS = positionWS.xyz;
            output.positionCS = mul(UNITY_MATRIX_VP, positionWS);
            output.uv = TRANSFORM_TEX(input.uv, _MainTex);
            
            // 法线转换到世界空间
            float3 normalWS = mul((float3x3)unity_ObjectToWorld, input.normalOS);
            output.normalWS = normalize(normalWS);
            
            // 计算视角方向
            output.viewDirWS = normalize(_WorldSpaceCameraPos - positionWS.xyz);
            
            return output;
        }
        ENDHLSL
        
        // ===[主渲染Pass]===
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }
            
            Cull Back
            ZWrite On
            ZTest LEqual
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            #pragma multi_compile_fog
            
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            
            struct VaryingsForward
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float3 viewDirWS : TEXCOORD3;
                LIGHTING_COORDS(4, 5)
                UNITY_FOG_COORDS(6)
            };
            
            VaryingsForward vert(Attributes input)
            {
                VaryingsForward output;
                
                float4 positionWS = mul(unity_ObjectToWorld, float4(input.positionOS.xyz, 1.0));
                output.positionWS = positionWS.xyz;
                output.pos = mul(UNITY_MATRIX_VP, positionWS);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                
                // 法线转换到世界空间
                float3 normalWS = mul((float3x3)unity_ObjectToWorld, input.normalOS);
                output.normalWS = normalize(normalWS);
                
                // 计算视角方向
                output.viewDirWS = normalize(_WorldSpaceCameraPos - positionWS.xyz);
                
                // 阴影和雾效坐标
                TRANSFER_VERTEX_TO_FRAGMENT(output);
                UNITY_TRANSFER_FOG(output, output.pos);
                
                return output;
            }
            
            half4 frag(VaryingsForward input) : SV_Target
            {
                // 采样主贴图
                half4 mainTex = tex2D(_MainTex, input.uv);
                half4 baseColor = mainTex * _Color;
                
                // 采样自发光贴图
                half4 emissionTex = tex2D(_EmissionTex, TRANSFORM_TEX(input.uv, _EmissionTex));
                
                // 计算自发光（HDR）
                half3 emission = emissionTex.rgb * _EmissionColor.rgb * _EmissionIntensity;
                emission = pow(max(emission, 0.0001), 1.0 / _EmissionPower); // 使用倒数实现power效果
                
                // 基础光照计算
                float3 normalWS = normalize(input.normalWS);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float NdotL = saturate(dot(normalWS, lightDir));
                
                // 获取阴影衰减
                float atten = LIGHT_ATTENUATION(input);
                
                // 计算光照
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                half3 diffuse = _LightColor0.rgb * NdotL * atten;
                half3 lighting = ambient + diffuse;
                
                // 应用光照到基础颜色
                half3 finalColor = baseColor.rgb * lighting;
                
                // 添加自发光（不受光照影响）
                finalColor += emission;
                
                // 应用雾效
                UNITY_APPLY_FOG(input.fogCoord, finalColor);
                
                return half4(finalColor, baseColor.a);
            }
            ENDHLSL
        }
        
        // ===[发光光晕Pass - 使用Screen混合避免重叠增亮]===
        Pass
        {
            Name "EMISSION_GLOW"
            Tags { "LightMode" = "Always" }
            
            Cull Back
            ZWrite Off
            ZTest LEqual
            // Screen混合模式：result = 1 - (1 - src) * (1 - dst)
            // 这样可以避免重叠区域过度增亮，保持整体均匀
            Blend OneMinusDstColor One
            
            HLSLPROGRAM
            #pragma vertex vertGlow
            #pragma fragment fragGlow
            #pragma multi_compile_fog
            
            struct VaryingsGlow
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 viewDirWS : TEXCOORD2;
                UNITY_FOG_COORDS(3)
            };
            
            VaryingsGlow vertGlow(Attributes input)
            {
                VaryingsGlow output;
                
                // 沿法线方向外扩，模拟光晕效果
                float3 positionOS = input.positionOS.xyz;
                float3 normalOS = normalize(input.normalOS);
                positionOS += normalOS * _GlowSize;
                
                float4 positionWS = mul(unity_ObjectToWorld, float4(positionOS, 1.0));
                output.positionCS = mul(UNITY_MATRIX_VP, positionWS);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                
                // 法线转换到世界空间
                float3 normalWS = mul((float3x3)unity_ObjectToWorld, normalOS);
                output.normalWS = normalize(normalWS);
                
                // 计算视角方向
                output.viewDirWS = normalize(_WorldSpaceCameraPos - positionWS.xyz);
                
                UNITY_TRANSFER_FOG(output, output.positionCS);
                
                return output;
            }
            
            half4 fragGlow(VaryingsGlow input) : SV_Target
            {
                // 采样自发光贴图
                half4 emissionTex = tex2D(_EmissionTex, TRANSFORM_TEX(input.uv, _EmissionTex));
                
                // 如果没有发光区域，则丢弃此片段
                half emissionMask = dot(emissionTex.rgb, half3(1, 1, 1));
                if (emissionMask < 0.01)
                    discard;
                
                // 计算自发光颜色（HDR）
                half3 emission = emissionTex.rgb * _EmissionColor.rgb * _EmissionIntensity;
                emission = pow(max(emission, 0.0001), 1.0 / _EmissionPower);
                
                // 基于视角的法线衰减（Fresnel效果）
                // dot值越大（面向视角），fresnel越小；dot值越小（边缘），fresnel越大
                float3 normalWS = normalize(input.normalWS);
                float3 viewDirWS = normalize(input.viewDirWS);
                float NdotV = saturate(dot(normalWS, viewDirWS));
                
                // 反转Fresnel：边缘（NdotV小）更透明，中心（NdotV大）更不透明
                // 使用power函数控制边缘渐变曲线
                float edgeFade = pow(NdotV, _GlowEdgeFade);
                
                // 应用光晕强度
                emission *= _GlowIntensity;
                
                // 将边缘渐变应用到颜色
                // Screen混合模式下，边缘渐变直接应用到颜色，保持整体均匀
                emission *= edgeFade;
                
                // Screen混合模式下，alpha主要用于控制混合强度
                half alpha = emissionTex.a * _EmissionColor.a * emissionMask;
                
                half4 finalColor = half4(emission, alpha);
                
                // 应用雾效
                UNITY_APPLY_FOG_COLOR(input.fogCoord, finalColor, half4(0, 0, 0, 0));
                
                return finalColor;
            }
            ENDHLSL
        }
        
        // ===[阴影投射Pass]===
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            
            Cull Back
            ZWrite On
            ZTest LEqual
            ColorMask 0
            
            HLSLPROGRAM
            #pragma vertex vertShadow
            #pragma fragment fragShadow
            #pragma multi_compile_shadowcaster
            
            #include "UnityCG.cginc"
            
            struct appdata_shadow
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            
            struct VaryingsShadow
            {
                V2F_SHADOW_CASTER;
                float2 uv : TEXCOORD1;
            };
            
            VaryingsShadow vertShadow(appdata_shadow v)
            {
                VaryingsShadow o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }
            
            half4 fragShadow(VaryingsShadow v) : SV_Target
            {
                // 采样主贴图alpha，用于透明裁剪
                half4 mainTex = tex2D(_MainTex, v.uv);
                clip(mainTex.a - 0.5);
                SHADOW_CASTER_FRAGMENT(v)
            }
            ENDHLSL
        }
    }
    
    Fallback "Diffuse"
}

