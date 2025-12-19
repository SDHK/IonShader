Shader "Iris/IrisOutline"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _Color ("Pass 1 Color", Color) =  (1, 0, 0, 1)
        _Scale ("Outline Scale", Float) = 0.1
    }
    HLSLINCLUDE
    sampler2D _MainTex;
    float4 _MainTex_ST;
    ENDHLSL
    //===[URP管线]===
    SubShader
    {
        Tags {"RenderPipeline" = "UniversalPipeline"  "Queue" = "Transparent" "RenderType" = "Transparent"   }
        // ===[描边]====
        Pass
        {
            Name "OUTLINE"
            Tags { "LightMode" = "SRPDefaultUnlit"  }
            Cull Front
            HLSLPROGRAM
            #define Use_IrisOutlineDefaultPass
            #include "../IrisEntryUnity.hlsl"
            ENDHLSL

        }
        // ===[简单渲染]===
        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            Cull Back
            ZWrite On
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            #define Use_IrisOutlineForwardPass
            #include "../IrisEntryUnity.hlsl"
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
            #define Use_IrisOutlineShadowPass
            #include "../IrisEntryUnity.hlsl"
            ENDHLSL
        }
    }
    //===[BRP管线]===
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent"  }
        // ===[描边]====
        Pass
        {
            Name "OUTLINE"
            Tags { "LightMode" = "Always" }
            Cull Front
            HLSLPROGRAM
            #define Use_IrisOutlineDefaultPass
            #include "../IrisEntryUnity.hlsl"
            ENDHLSL
        }
        // ===[简单渲染]===
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }
            Cull Back
            ZWrite On
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            #define Use_IrisOutlineForwardPass
            #include "../IrisEntryUnity.hlsl"
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
            #define Use_IrisOutlineShadowPass
            #include "../IrisEntryUnity.hlsl"
            ENDHLSL
        }
    }
    // Fallback "Universal Render Pipeline/Lit"
}