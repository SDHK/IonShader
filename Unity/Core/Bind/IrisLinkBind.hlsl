/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/29 19:55
*
* 描述： Unity 引擎下 Iris Shader 绑定入口 
*
*/
#ifdef IrisShader_URP
#include "URP/IrisLinkURP.hlsl"
#elif defined(IrisShader_BRP)
#include "BRP/IrisLinkBRP.hlsl"
#endif

