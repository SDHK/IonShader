/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16
*
* 描述： Iris Shader Pass 统一入口
* 
* 功能：统一包含所有 Pass 文件
*       根据 Use_IrisXXXPass 宏控制是否生效
*
*/

//===[Outline Pass]===
#include "IrisOutlineDefaultPass.hlsl"   // 默认轮廓 Pass
#include "IrisOutlineForwardPass.hlsl"   // 前向渲染 Pass
#include "IrisOutlineShadowPass.hlsl"    // 阴影投射 Pass

