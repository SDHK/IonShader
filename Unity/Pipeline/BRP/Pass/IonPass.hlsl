/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16
*
* 描述： Ion Shader Pass 统一入口
*
* 设计理念：
* - 本文件是 Pass 文件的统一入口，避免路径写错
* - 通过宏控制按需加载 Pass，减少不必要的代码包含
* - 提供统一的 Pass 管理机制，便于维护和扩展
*
* 功能：
* - 统一包含所有 Pass 文件
* - 根据 Link_IonXXXPass 宏控制是否链接
* - 提供 Def 和 Link 宏定义，供 Pass 文件使用
*
* 使用方法：
* 1. 在 Shader 文件中定义需要的 Pass 宏：
*    #define Link_IonPassOutlineDefault
*    #define Link_IonPassOutlineForward
*    #define Link_IonPassOutlineShadow
*
* 注意：
* - 确保 Pass 在 Core 之前加载
*
*/

#ifndef Def_IonPass
#define Def_IonPass


//===[引入Pass库]===

#include "Main/IonLinkMain.hlsl"
#include "ShadowCaster/IonLinkShadowCaster.hlsl"
#include "Outline/IonLinkOutline.hlsl" 

#endif // Def_IonPass