HLSLINCLUDE
#define IonShader
ENDHLSL

Shader "Ion/IonObjectTransparent"
{
    Properties
    {
        _MainTex            ("材质",                        2D)     = "white" {}
        _ColorMask          ("颜色遮罩",   2D)     = "white" {}

        [Space(20)]
        _Color1             ("主色",                   Color)  = (1.00, 1.00, 1.00, 1)
        _Color2             ("次色",                   Color)  = (0.80, 0.80, 0.80, 1)
        _Color3             ("附加色",                 Color)  = (0.60, 0.60, 0.60, 1)
        _Color4             ("高亮色",                 Color)  = (1.00, 1.00, 0.50, 1)

        [Space(20)]
        _BaseRampInfluence  ("颜色偏移",                        Range(0,1)) = 0.5
        _BaseRampDir        ("照射位置",                        Vector)     = (0, 1, 0, 0)
        _BaseRampColor1     ("深暗色",                     Color)      = (0.20, 0.20, 0.25, 1)
        _BaseRampColor2     ("偏暗色",                     Color)      = (0.60, 0.60, 0.60, 1)
        _BaseRampColor3     ("基准色",                     Color)      = (0.85, 0.85, 0.85, 1)
        _BaseRampColor4     ("偏亮色",                     Color)      = (1.00, 1.00, 1.00, 1)
        _BaseRampColor5     ("高亮色",                     Color)      = (1.00, 1.00, 1.00, 1)
        [Space(10)]
        _BaseRampThreshold1 ("阈值1",                      Range(0,1)) = 0.3
        _BaseRampThreshold2 ("阈值2",                      Range(0,1)) = 0.7
        _BaseRampThreshold3 ("阈值3",                      Range(0,1)) = 0.9
        _BaseRampThreshold4 ("阈值4",                      Range(0,1)) = 0.9
        [Space(10)]
        _BaseRampSoftness1  ("过渡1",                       Range(0,0.5)) = 0.05
        _BaseRampSoftness2  ("过渡2",                       Range(0,0.5)) = 0.05
        _BaseRampSoftness3  ("过渡3",                       Range(0,0.5)) = 0.05
        _BaseRampSoftness4  ("过渡4",                       Range(0,0.5)) = 0.05

        [Space(20)]
        _EmissiveIntensity  ("自发光",                       Range(0,1))  = 0
        _EmissiveTex        ("自发光遮罩",       2D)     = "white" {}

        [Space(20)]
        _LightInfluence      ("光照色影响",                        Range(0,1))  = 0.2
        _LightMax 	    ("光照最大值",                       Range(0,1))  = 1.0
        _LightMin 	    ("光照最小值",                       Range(0,1))  = 0
        _LightRampThreshold      ("光照阈值",                        Range(0,1)) = 0.5
        _LightRampSoftness       ("光照过渡",                         Range(0,0.5)) = 0.05

        [Space(20)]
        _RimIntensity       ("透光强度",                        Range(0,1))  = 0.5
        _RimPower           ("透光阈值",                            Range(0,1)) = 0.5

        [Space(20)]
        _BackRimIntensity   ("背光强度",                        Range(0,1))  = 0.5
        _BackRimPower       ("背光阈值",                            Range(0,1)) = 0.5
        
        [Space(20)]
        _Color              ("描边颜色",                           Color)  = (0, 0, 0, 1)
        _Scale              ("描边大小",                           Float)  = 0.1

        [Space(20)]
        _Cutoff             ("透明度裁剪",                    Range(0,1)) = 0.5
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
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 100

        // ===[描边]===
        Pass
        {
            Name "OUTLINE"
            Tags { "LightMode" = "Always" }
            Cull Front
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            #define PassVar_Color _Color
            #define PassVar_Scale _Scale
            #define Link_IonPassOutline
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }

        // ===[深度预写 Pass]===
        // 先把前面深度写入缓冲区，内部面 ZTest 时失败，不会错误覆盖外面。
        Pass
        {
            Name "DEPTH_PREPASS"
            Tags { "LightMode" = "Always" }
            Cull Back
            ZWrite On
            ColorMask 0
            HLSLPROGRAM
            #define PassVar_MainTex    _MainTex
            #define PassVar_MainTex_ST _MainTex_ST
            #define PassVar_Cutoff     _Cutoff
            #define Link_IonPassDepthPre
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }

        // ===[主光照 ForwardBase]===
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }
            Cull Back
            ZWrite Off
            ZTest LEqual
            Offset 0, -1    // 固定单位偏移（不含斜率项），轻推深度避免 Z-Fighting
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM

            #define PassVar_MainTex           _MainTex
            #define PassVar_MainTex_ST        _MainTex_ST

            #define PassVar_ColorMask         _ColorMask
            #define PassVar_Color1            _Color1
            #define PassVar_Color2            _Color2
            #define PassVar_Color3            _Color3
            #define PassVar_Color4            _Color4

            #define PassVar_LightInfluence   _LightInfluence
            #define PassVar_LightMax        _LightMax
            #define PassVar_LightMin        _LightMin

            #define PassVar_EmissiveTex        _EmissiveTex
            #define PassVar_EmissiveIntensity  _EmissiveIntensity

            #define PassVar_BaseRampInfluence  _BaseRampInfluence
            #define PassVar_BaseRampDir        _BaseRampDir

            #define PassVar_BaseRampColor1     _BaseRampColor1
            #define PassVar_BaseRampColor2     _BaseRampColor2
            #define PassVar_BaseRampColor3     _BaseRampColor3
            #define PassVar_BaseRampColor4     _BaseRampColor4
            #define PassVar_BaseRampColor5     _BaseRampColor5

            #define PassVar_BaseRampThreshold1 _BaseRampThreshold1
            #define PassVar_BaseRampThreshold2 _BaseRampThreshold2
            #define PassVar_BaseRampThreshold3 _BaseRampThreshold3
            #define PassVar_BaseRampThreshold4 _BaseRampThreshold4

            #define PassVar_BaseRampSoftness1  _BaseRampSoftness1
            #define PassVar_BaseRampSoftness2  _BaseRampSoftness2
            #define PassVar_BaseRampSoftness3  _BaseRampSoftness3
            #define PassVar_BaseRampSoftness4  _BaseRampSoftness4

            #define PassVar_LightRampThreshold  _LightRampThreshold
            #define PassVar_LightRampSoftness   _LightRampSoftness

            #define PassVar_RimPower           _RimPower
            #define PassVar_RimIntensity       _RimIntensity

            #define PassVar_BackRimPower        _BackRimPower
            #define PassVar_BackRimIntensity    _BackRimIntensity

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
