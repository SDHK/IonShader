HLSLINCLUDE
#define IonShader
ENDHLSL

Shader "Ion/IonObject"
{
    Properties
    {
        [Header(Textures)]
        _MainTex            ("Main Tex",                        2D)     = "white" {}
        _ColorMask          ("Color Mask (RGBA to Color1-4)",   2D)     = "black" {}
        _EmissiveTex        ("Emissive Mask (R=发光亮度)",       2D)     = "black" {}

        [Space(8)]
        [Header(Color System)]
        _Color1             ("Color 1  主色",                   Color)  = (1.00, 1.00, 1.00, 1)
        _Color2             ("Color 2  次色",                   Color)  = (0.80, 0.80, 0.80, 1)
        _Color3             ("Color 3  附加色",                 Color)  = (0.60, 0.60, 0.60, 1)
        _Color4             ("Color 4  高亮色",                 Color)  = (1.00, 1.00, 0.50, 1)

        [Space(8)]
        [Header(Emissive)]
        _EmissiveIntensity  ("Intensity",                       Float)  = 1.0

      
        [Space(8)]
        [Header(Base Ramp  Structural Shading)]
        _BaseRampInfluence  ("附加渐变色权重",                        Range(0,1)) = 0.5
        _BaseRampDir        ("投射位置",                        Vector)     = (0, 1, 0, 0)
        _BaseRampColor0     ("变量色",                     Color)      = (0.20, 0.20, 0.25, 1)
      
        [Space(8)]
        _BaseRampColor1     ("深暗色",                     Color)      = (0.20, 0.20, 0.25, 1)
        _BaseRampColor2     ("偏暗色",                     Color)      = (0.60, 0.60, 0.60, 1)
        _BaseRampColor3     ("基准色",                     Color)      = (0.85, 0.85, 0.85, 1)
        _BaseRampColor4     ("偏亮色",                     Color)      = (1.00, 1.00, 1.00, 1)
        _BaseRampColor5     ("高亮色",                     Color)      = (1.00, 1.00, 1.00, 1)
        
        [Space(8)]
        _BaseRampThreshold1 ("阈值1",                      Range(0,1)) = 0.3
        _BaseRampThreshold2 ("阈值2",                      Range(0,1)) = 0.7
        _BaseRampThreshold3 ("阈值3",                      Range(0,1)) = 0.9
        _BaseRampThreshold4 ("阈值4",                      Range(0,1)) = 0.9
      
        [Space(8)]
        _BaseRampSoftness1  ("过渡1",                       Range(0,0.5)) = 0.05
        _BaseRampSoftness2  ("过渡2",                       Range(0,0.5)) = 0.05
        _BaseRampSoftness3  ("过渡3",                       Range(0,0.5)) = 0.05
        _BaseRampSoftness4  ("过渡4",                       Range(0,0.5)) = 0.05

        [Space(8)]
        [Header(Fixed Rim Light  Ambient Backlight)]
        _FixedRimPower      ("Power",                            Range(1,16)) = 4.0
        _FixedRimIntensity  ("Intensity  Color = BaseRampColor4", Range(0,2)) = 0.0

        [Space(8)]
        [Header(Ramp  Dynamic Light Shading)]
        _LightRampThreshold      ("Threshold",                        Range(0,1)) = 0.5
        _LightRampSoftness       ("Softness",                         Range(0,0.5)) = 0.05

        [Space(8)]
        [Header(Rim Light  Fresnel)]
        _RimColor           ("Color",                            Color)      = (1, 1, 1, 1)
        _RimPower           ("Power",                            Range(1,16)) = 4.0
        _RimIntensity       ("Intensity",                        Range(0,2))  = 0.5

        [Space(8)]
        [Header(Back Rim Light  Backlight)]
        _BackRimColor       ("Color",                            Color)      = (1, 1, 1, 1)
        _BackRimPower       ("Power",                            Range(1,16)) = 4.0
        _BackRimIntensity   ("Intensity",                        Range(0,2))  = 0.5

        [Space(8)]
        [Header(Outline)]
        _Color              ("Color",                           Color)  = (0, 0, 0, 1)
        _Scale              ("Scale",                           Float)  = 0.1
        _Scale123              ("Scale",                           Float)  = 0.1
    }

    //===[URP 管线]===================================================
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }

        // ===[描边]===
        Pass
        {
            Name "OUTLINE"
            Tags { "LightMode" = "SRPDefaultUnlit" }
            Cull Front
            ZWrite On
            ZTest LEqual
            HLSLPROGRAM
            #define PassVar_Color _Color
            #define PassVar_Scale _Scale
            #define Link_IonPassOutline
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
            Blend Off
            HLSLPROGRAM
            #define PassVar_MainTex    _MainTex
            #define PassVar_MainTex_ST _MainTex_ST
            #define Link_IonPassMain
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
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }
    }

    //===[BRP 管线]===================================================
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        LOD 100

        // ===[描边]===
        Pass
        {
            Name "OUTLINE"
            Tags { "LightMode" = "Always" }
            Cull Front
            ZWrite On
            ZTest LEqual
            HLSLPROGRAM
            #define PassVar_Color _Color
            #define PassVar_Scale _Scale
            #define Link_IonPassOutline
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }

        // ===[主光照 ForwardBase]===
        // 不透明版：ZWrite On + 屏幕空间阴影（正确接收方向光阴影）
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }
            Cull Back
            ZWrite On
            ZTest LEqual
            Blend Off
            HLSLPROGRAM
            #define IonSet_ShadowScreen               // 不透明物体使用屏幕空间阴影
            
            #define PassVar_MainTex           _MainTex
            #define PassVar_MainTex_ST        _MainTex_ST
            #define PassVar_ColorMask         _ColorMask
            #define PassVar_Color1            _Color1
            #define PassVar_Color2            _Color2
            #define PassVar_Color3            _Color3
            #define PassVar_Color4            _Color4
            #define PassVar_EmissiveTex        _EmissiveTex
            #define PassVar_EmissiveIntensity  _EmissiveIntensity
            #define PassVar_LightRampThreshold      _LightRampThreshold
            #define PassVar_LightRampSoftness       _LightRampSoftness
            #define PassVar_BaseRampColor1     _BaseRampColor1
            #define PassVar_BaseRampThreshold1 _BaseRampThreshold1
            #define PassVar_BaseRampSoftness1  _BaseRampSoftness1
            #define PassVar_BaseRampColor2     _BaseRampColor2
            #define PassVar_BaseRampThreshold2 _BaseRampThreshold2
            #define PassVar_BaseRampSoftness2  _BaseRampSoftness2
            #define PassVar_BaseRampColor3     _BaseRampColor3
            #define PassVar_BaseRampThreshold3 _BaseRampThreshold3
            #define PassVar_BaseRampSoftness3  _BaseRampSoftness3
            #define PassVar_BaseRampColor4     _BaseRampColor4
            #define PassVar_BaseRampDir        _BaseRampDir
            #define PassVar_BaseRampInfluence  _BaseRampInfluence
            #define PassVar_RimColor           _RimColor
            #define PassVar_RimPower           _RimPower
            #define PassVar_RimIntensity       _RimIntensity
            #define PassVar_BackRimColor        _BackRimColor
            #define PassVar_BackRimPower        _BackRimPower
            #define PassVar_BackRimIntensity    _BackRimIntensity
            #define PassVar_FixedRimPower       _FixedRimPower
            #define PassVar_FixedRimIntensity   _FixedRimIntensity
            #define Link_IonPassMainSimple
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }

        // ===[附加光照 ForwardAdd]===
        Pass
        {
            Name "ADDITIONAL"
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            ZWrite Off
            HLSLPROGRAM
            #define PassVar_MainTex       _MainTex
            #define PassVar_MainTex_ST    _MainTex_ST
            #define PassVar_ColorMask     _ColorMask
            #define PassVar_Color1        _Color1
            #define PassVar_Color2        _Color2
            #define PassVar_Color3        _Color3
            #define PassVar_Color4        _Color4
            #define PassVar_EmissiveTex        _EmissiveTex
            #define PassVar_EmissiveIntensity  _EmissiveIntensity
            #define PassVar_LambertScale       _LambertScale
            #define PassVar_LambertOffset      _LambertOffset
            #define PassVar_LightRampThreshold      _LightRampThreshold
            #define PassVar_LightRampSoftness       _LightRampSoftness
            #define PassVar_BaseRampColor1     _BaseRampColor1
            #define PassVar_BaseRampThreshold1 _BaseRampThreshold1
            #define PassVar_BaseRampSoftness1  _BaseRampSoftness1
            #define PassVar_BaseRampColor2     _BaseRampColor2
            #define PassVar_BaseRampThreshold2 _BaseRampThreshold2
            #define PassVar_BaseRampSoftness2  _BaseRampSoftness2
            #define PassVar_BaseRampColor3     _BaseRampColor3
            #define PassVar_BaseRampThreshold3 _BaseRampThreshold3
            #define PassVar_BaseRampSoftness3  _BaseRampSoftness3
            #define PassVar_BaseRampColor4     _BaseRampColor4
            #define PassVar_BaseRampDir        _BaseRampDir
            #define PassVar_BaseRampInfluence  _BaseRampInfluence
            #define PassVar_BackRimColor        _BackRimColor
            #define PassVar_BackRimPower        _BackRimPower
            #define PassVar_BackRimIntensity    _BackRimIntensity
            #define Link_IonPassMainAdd
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
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }
    }
    //FallBack "Diffuse"
}
