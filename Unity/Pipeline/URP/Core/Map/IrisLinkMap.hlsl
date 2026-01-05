/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/XX
*
* 描述： Unity URP 的 Iris 映射系统统一入口
*
* 功能：统一包含所有映射文件
*       - IrisSet.hlsl：编译时功能设置映射
*       - IrisKey.hlsl：运行时变体关键字映射
*
*/

//===[引入功能设置映射]===
#include "IrisSet.hlsl"

//===[引入变体键映射]===
#include "IrisKey.hlsl"

