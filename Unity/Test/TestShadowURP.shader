Shader "Test/SimpleShadowReceiverURP"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) =  (1, 1, 1, 1)
    }
    SubShader
    {
        // 显式指定渲染队列和类型
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }

        LOD 100

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            // --- 渲染状态强制定义 ---
            Cull Back
            ZWrite On
            ZTest LEqual
            Blend Off            // 强制不混合

            // 重置模板测试，防止被其他Shader的残留值剔除
            Stencil
            {
                Ref 0
                Comp Always
                Pass Replace
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // 必需的编译指令
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // 手动定义兼容性函数
            #ifndef LERPWHITETO_DEFINED
            #define LERPWHITETO_DEFINED
            inline half LerpWhiteTo(half b, half t)
            {
                return lerp(1.0h, b, t);
            }
            #endif

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
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;
            float4 _Color;

            v2f vert(appdata v)
            {
                v2f o;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal);
                o.pos = vertexInput.positionCS;
                o.worldPos = vertexInput.positionWS;
                o.worldNormal = normalInput.normalWS;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _Color;
                //half4 mainTex = tex2D(_MainTex, i.uv);

                float4 shadowCoord = TransformWorldToShadowCoord(i.worldPos);
                Light mainLight = GetMainLight(shadowCoord);

                float3 normalWS = normalize(i.worldNormal);
                float NdotL = saturate(dot(normalWS, mainLight.direction));
                half3 ambient = SampleSH(normalWS);

                // 强制主光至少有一点贡献，或者输出颜色，确保不是全黑
                half3 lighting = ambient + mainLight.color * NdotL * mainLight.shadowAttenuation;
                mainTex.rgb *= lighting;

                // 强制 Alpha 为 1，防止在不透明队列中因为 Alpha 问题被过滤
                return float4(mainTex.rgb, 1.0);
            }
            ENDHLSL
        }

        // ShadowCaster 必须保留，否则没阴影
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            ZWrite On
            ZTest LEqual
            ColorMask  0
            HLSLPROGRAM
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            struct Attributes
            {
                float4 positionOS : POSITION;
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };
            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = vertexInput.positionCS;
                return output;
            }
            half4 ShadowPassFragment(Varyings input) : SV_TARGET
            {
                return 0;
            }
            ENDHLSL
        }
    }
}