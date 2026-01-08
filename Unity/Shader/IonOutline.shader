HLSLINCLUDE
#define IonShader
ENDHLSL

Shader "Ion/IonOutline"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _Color ("Pass 1 Color", Color) =  (1, 0, 0, 1)
        _Scale ("Outline Scale", Float) = 0.1
    }

    //===[URP管线]===
    SubShader
    {
        Tags {"RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque"  "Queue" = "Geometry" }
        
        // ===[描边]====
        Pass
        {

            Name "OUTLINE"
            Tags { "LightMode" = "UniversalForwardOnly"  }
            Cull Front
            ZWrite On  // 透明队列通常关闭深度写入
            ZTest LEqual
            HLSLPROGRAM

            #define Link_IonPassOutline
            #define PassVar_Color _Color
            #define PassVar_Scale _Scale
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }
        // ===[简单渲染]===
        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            Cull Back
            ZWrite On
            ZTest LEqual
            Blend Off            // 强制不混合
            //Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            #define PassVar_MainTex _MainTex
            #define PassVar_MainTex_ST _MainTex_ST
            #define Link_IonPassMainSimple
            #include "../IonCoreUnity.hlsl"
            ENDHLSL

        }

        // ===[阴影投射]===
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
            // #define PassVar_Scale _Scale
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }
    }
    //===[BRP管线]===
    SubShader
    {
        Tags {"RenderType" = "Opaque"  }
        LOD 100
        // ===[描边]====
        Pass
        {
            Name "OUTLINE"
            Tags { "LightMode" = "Always" }
            Cull Front
            HLSLPROGRAM
            #define Link_IonPassOutline
            #define PassVar_Color _Color
            #define PassVar_Scale _Scale
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }

        // ===[简单渲染]===
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }
            // Cull Back
            // ZWrite On
            // ZTest LEqual
            // Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            #define PassVar_MainTex _MainTex
            #define PassVar_MainTex_ST _MainTex_ST
            #define Link_IonPassMainSimple
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }
        // ===[阴影投射]===
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
            // #define PassVar_Scale _Scale
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }

    }
    //FallBack "Diffuse"
}