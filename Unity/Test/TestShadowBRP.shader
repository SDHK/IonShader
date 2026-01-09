Shader "Test/SimpleShadowBRP"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // 采样贴图
                float4 mainTex = tex2D(_MainTex, i.uv) * _Color;
                
                // 计算光照
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float NdotL = saturate(dot(normalize(i.worldNormal), lightDir));
                
                // 采样阴影
                float shadow = SHADOW_ATTENUATION(i);
                
                // 调试：显示阴影值
                // return float4(shadow, shadow, shadow, 1);
                
                // 最终光照
                half3 directLighting =_LightColor0.rgb * NdotL * shadow;
                float3 lighting = directLighting  + unity_AmbientSky.rgb;
                mainTex.rgb *= lighting;
                return mainTex;
            }
            ENDHLSL
        }
        
        // ForwardAdd Pass - 处理附加光源（多点光照）
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            
            Blend One One  // 叠加模式，用于叠加附加光源的光照
            
            HLSLPROGRAM
            #pragma vertex vertAdd
            #pragma fragment fragAdd
            #pragma multi_compile_fwdadd_fullshadows nolightmap nodirlightmap nodynlightmap novertexlight
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            v2f vertAdd (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o);
                return o;
            }

            float4 fragAdd (v2f i) : SV_Target
            {
                // 采样贴图
                float4 mainTex = tex2D(_MainTex, i.uv) * _Color;
                
                // 计算附加光源方向（点光源或聚光灯）
                float3 lightDir;
                float atten;
                
                #ifdef USING_DIRECTIONAL_LIGHT
                    // 方向光
                    lightDir = _WorldSpaceLightPos0.xyz;
                    atten = 1.0;
                #else
                    // 点光源或聚光灯
                    float3 lightVec = _WorldSpaceLightPos0.xyz - i.worldPos;
                    float dist = length(lightVec);
                    lightDir = normalize(lightVec);
                    
                    // 距离衰减
                    atten = 1.0 / (1.0 + dist * dist * unity_LightAtten[0].z);
                    
                    // 聚光灯角度衰减
                    #ifdef SPOT
                        float3 spotDir = normalize(_WorldSpaceLightPos0.xyz);
                        float spotEffect = dot(lightDir, spotDir);
                        float spotAtten = saturate((spotEffect - unity_LightAtten[0].x) / unity_LightAtten[0].y);
                        atten *= spotAtten;
                    #endif
                #endif
                
                // 计算光照
                float NdotL = saturate(dot(normalize(i.worldNormal), lightDir));
                
                // 采样阴影
                float shadow = SHADOW_ATTENUATION(i);
                
                // 附加光源的光照贡献（只返回光照部分，不包含环境光）
                half3 additionalLighting = _LightColor0.rgb * NdotL * atten * shadow;
                
                return float4(additionalLighting * mainTex.rgb, 0.0);
            }
            ENDHLSL
        }
        
        Pass
        {
            Tags { "LightMode" = "ShadowCaster" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

