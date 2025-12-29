Shader "Test/Metallic"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Color ("Base Color", Color) = (1, 1, 1, 1)
        
        // PBR属性
        _MetallicTex ("Metallic (R) Smoothness (A)", 2D) = "white" {}
        _Metallic ("Metallic", Range(0, 1)) = 0.5
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        
        // 法线贴图
        [Normal] _NormalTex ("Normal Map", 2D) = "bump" {}
        _NormalScale ("Normal Scale", Range(0, 2)) = 1.0
        
        // 环境反射
        _ReflectionIntensity ("Reflection Intensity", Range(0, 2)) = 1.0
        _FresnelPower ("Fresnel Power", Range(0.1, 5)) = 2.0
        
        // 自发光（可选）
        [HDR] _EmissionColor ("Emission Color", Color) = (0, 0, 0, 1)
        _EmissionTex ("Emission Texture", 2D) = "black" {}
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque" 
            "Queue" = "Geometry"
        }
        LOD 200
        
        HLSLINCLUDE
        #include "UnityCG.cginc"
        #include "Lighting.cginc"
        
        // 材质属性
        sampler2D _MainTex;
        float4 _MainTex_ST;
        float4 _Color;
        
        sampler2D _MetallicTex;
        float4 _MetallicTex_ST;
        float _Metallic;
        float _Smoothness;
        
        sampler2D _NormalTex;
        float4 _NormalTex_ST;
        float _NormalScale;
        
        float _ReflectionIntensity;
        float _FresnelPower;
        
        float4 _EmissionColor;
        sampler2D _EmissionTex;
        float4 _EmissionTex_ST;
        
        // 顶点数据结构
        struct Attributes
        {
            float4 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float2 uv : TEXCOORD0;
        };
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
            
            // 片段数据结构
            struct Varyings
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 tangentWS : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float3 positionWS : TEXCOORD4;
                float3 viewDirWS : TEXCOORD5;
                LIGHTING_COORDS(6, 7)
                UNITY_FOG_COORDS(8)
            };
            
            // PBR光照计算函数
            // 计算Fresnel-Schlick近似
            float3 FresnelSchlick(float cosTheta, float3 F0)
            {
                return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
            }
            
            // 计算法线分布函数（GGX/Trowbridge-Reitz）
            float DistributionGGX(float3 N, float3 H, float roughness)
            {
                float a = roughness * roughness;
                float a2 = a * a;
                float NdotH = max(dot(N, H), 0.0);
                float NdotH2 = NdotH * NdotH;
                float denom = (NdotH2 * (a2 - 1.0) + 1.0);
                denom = 3.14159265359 * denom * denom;
                return a2 / max(denom, 0.0000001);
            }
            
            // 计算几何函数（Schlick-GGX）
            float GeometrySchlickGGX(float NdotV, float roughness)
            {
                float r = (roughness + 1.0);
                float k = (r * r) / 8.0;
                return NdotV / (NdotV * (1.0 - k) + k);
            }
            
            float GeometrySmith(float3 N, float3 V, float3 L, float roughness)
            {
                float NdotV = max(dot(N, V), 0.0);
                float NdotL = max(dot(N, L), 0.0);
                float ggx1 = GeometrySchlickGGX(NdotV, roughness);
                float ggx2 = GeometrySchlickGGX(NdotL, roughness);
                return ggx1 * ggx2;
            }
            
            Varyings vert(Attributes input)
            {
                Varyings output;
                
                float4 positionWS = mul(unity_ObjectToWorld, float4(input.positionOS.xyz, 1.0));
                output.positionWS = positionWS.xyz;
                output.pos = mul(UNITY_MATRIX_VP, positionWS);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                
                // 构建TBN矩阵（切线空间到世界空间）
                float3 normalWS = normalize(mul((float3x3)unity_ObjectToWorld, input.normalOS));
                float3 tangentWS = normalize(mul((float3x3)unity_ObjectToWorld, input.tangentOS.xyz));
                float3 bitangentWS = cross(normalWS, tangentWS) * input.tangentOS.w;
                
                output.normalWS = normalWS;
                output.tangentWS = tangentWS;
                output.bitangentWS = bitangentWS;
                
                // 计算视角方向
                output.viewDirWS = normalize(_WorldSpaceCameraPos - positionWS.xyz);
                
                // 阴影和雾效坐标
                TRANSFER_VERTEX_TO_FRAGMENT(output);
                UNITY_TRANSFER_FOG(output, output.pos);
                
                return output;
            }
            
            half4 frag(Varyings input) : SV_Target
            {
                // 采样基础颜色
                half4 albedo = tex2D(_MainTex, input.uv) * _Color;
                
                // 采样金属度和光滑度
                half4 metallicSmoothness = tex2D(_MetallicTex, TRANSFORM_TEX(input.uv, _MetallicTex));
                half metallic = metallicSmoothness.r * _Metallic;
                half smoothness = metallicSmoothness.a * _Smoothness;
                half roughness = 1.0 - smoothness;
                
                // 采样法线贴图
                half3 normalTS = UnpackNormal(tex2D(_NormalTex, TRANSFORM_TEX(input.uv, _NormalTex)));
                normalTS.xy *= _NormalScale;
                normalTS = normalize(normalTS);
                
                // 构建TBN矩阵
                float3x3 TBN = float3x3(
                    normalize(input.tangentWS),
                    normalize(input.bitangentWS),
                    normalize(input.normalWS)
                );
                
                // 将法线从切线空间转换到世界空间
                float3 N = normalize(mul(normalTS, TBN));
                float3 V = normalize(input.viewDirWS);
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float3 H = normalize(V + L);
                
                // 计算基础光照
                float NdotL = max(dot(N, L), 0.0);
                float NdotV = max(dot(N, V), 0.0);
                
                // 获取阴影衰减
                float atten = LIGHT_ATTENUATION(input);
                
                // 计算F0（基础反射率）
                // 非金属使用albedo，金属使用albedo的亮度
                half3 F0 = lerp(half3(0.04, 0.04, 0.04), albedo.rgb, metallic);
                
                // PBR光照计算
                // 法线分布函数
                float NDF = DistributionGGX(N, H, roughness);
                
                // 几何函数
                float G = GeometrySmith(N, V, L, roughness);
                
                // Fresnel项
                float3 F = FresnelSchlick(max(dot(H, V), 0.0), F0);
                
                // 计算Cook-Torrance BRDF
                float3 numerator = NDF * G * F;
                float denominator = 4.0 * NdotV * max(NdotL, 0.0) + 0.001;
                float3 specular = numerator / denominator;
                
                // 能量守恒：镜面反射 + 漫反射 = 1
                float3 kS = F;
                float3 kD = (1.0 - kS) * (1.0 - metallic);
                
                // 漫反射
                half3 diffuse = kD * albedo.rgb / 3.14159265359;
                
                // 镜面反射
                half3 spec = specular;
                
                // 主光源贡献
                half3 lightColor = _LightColor0.rgb;
                half3 radiance = lightColor * atten;
                half3 Lo = (diffuse + spec) * radiance * NdotL;
                
                // 环境光（简化版）
                half3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo.rgb;
                
                // 环境反射（简化版，使用Fresnel模拟）
                float3 R = reflect(-V, N);
                float fresnel = pow(1.0 - NdotV, _FresnelPower);
                half3 reflection = lerp(half3(0.1, 0.1, 0.1), half3(0.5, 0.5, 0.5), smoothness);
                reflection *= fresnel * _ReflectionIntensity * metallic;
                
                // 自发光
                half3 emission = tex2D(_EmissionTex, TRANSFORM_TEX(input.uv, _EmissionTex)).rgb * _EmissionColor.rgb;
                
                // 最终颜色
                half3 finalColor = ambient + Lo + reflection + emission;
                
                // 应用雾效
                UNITY_APPLY_FOG(input.fogCoord, finalColor);
                
                return half4(finalColor, albedo.a);
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

