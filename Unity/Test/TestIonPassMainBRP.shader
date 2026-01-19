HLSLINCLUDE
#define IonShader
ENDHLSL

Shader "Test/IonPassMainBRP"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
    }

    //===[BRP管线]===
    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque"  
        }
        LOD 100
        
        // ===[ForwardBase Pass - 主光源 + 环境光]===
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }
            
            Cull Back
            ZWrite On
            ZTest LEqual
            
            HLSLPROGRAM
            // 定义 Pass 参数
            #define PassVar_MainTex _MainTex
            #define PassVar_MainTex_ST _MainTex_ST
            
            // 链接 IonPassMainSimple（ForwardBase）
            #define Link_IonPassMainSimple
            
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }

        // ===[ForwardAdd Pass - 附加光源（点光、聚光）]===
        Pass
        {
            Name "FORWARD_ADD"
            Tags { "LightMode" = "ForwardAdd" }
            
            // 叠加混合模式（光照累加）
            Blend One One
            ZWrite Off
            ZTest LEqual
            Cull Back
            
            HLSLPROGRAM
            // 定义 Pass 参数
            #define PassVar_MainTex _MainTex
            #define PassVar_MainTex_ST _MainTex_ST
            
            // 链接 IonPassMainAdd（ForwardAdd）
            #define Link_IonPassMainAdd
            
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }

        // ===[阴影投射 Pass]===
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            
            Cull Back
            ZWrite On
            ZTest LEqual
            ColorMask 0
            
            HLSLPROGRAM
            #define Link_IonPassShadowCaster
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }
    }

    FallBack "Diffuse"
}
