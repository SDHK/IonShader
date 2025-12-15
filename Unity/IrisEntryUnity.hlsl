/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/4 14:16
*
* 说明： Unity 引擎的 Iris Shader 库统一入口
*
* 功能：
* - 加载 Unity 环境参数映射
* - 加载 Iris 库入口（IrisEntry.hlsl）
* - 可选加载 Unity URP/CG 库
*
*/

#ifndef Def_IrisEntryUnity
#define Def_IrisEntryUnity

#define IrisShader_URP

#ifdef IrisShader_URP
    #define Inc_ShaderCore #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #define Inc_ShaderLighting #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#elif IrisShader_BRP
    #define Inc_ShaderCore #include "UnityCG.cginc"
#endif

#define Inc_IrisParams #include "../../Unity/IrisParamsUnity.hlsl"

#include "../Iris/IrisEntryPass.hlsl"
#include "../Iris/IrisEntry.hlsl"

#endif