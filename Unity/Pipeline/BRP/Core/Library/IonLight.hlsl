/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16
*
* 描述： BRP 光照库转接层
* 
* 功能：统一管理 BRP 光照相关库的包含
*       包含 Lighting.cginc 和 AutoLight.cginc
*
*/

#if DefPart(IonLight, Library)
#define Def_IonLight_Library

#include "Lighting.cginc"
#include "AutoLight.cginc"

#endif // DefPart(IonLight, Library)

