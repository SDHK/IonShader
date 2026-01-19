HLSLINCLUDE
#define IonShader
ENDHLSL

Shader "Test/IonPassMain"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
    }

    //===[URP管线]===
    SubShader
    {
        Tags 
        { 
            "RenderPipeline" = "UniversalPipeline" 
            "RenderType" = "Opaque"  
            "Queue" = "Geometry" 
        }
        LOD 100
        
        // ===[主渲染 Pass - 支持多光源]===
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            
            Cull Back
            ZWrite On
            ZTest LEqual
            
            HLSLPROGRAM
            // 定义 Pass 参数
            #define PassVar_MainTex _MainTex
            #define PassVar_MainTex_ST _MainTex_ST
            
            // 链接 IonPassMain
            #define Link_IonPassMain
            
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

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
