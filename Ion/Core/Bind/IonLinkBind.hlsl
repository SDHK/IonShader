/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16 11:01
*
* 描述： Ion 宏定义规范链接
*
*/

//===[引入参数接口规范]===
#if Link(IonBase)
#include "Param/IonParam.hlsl"
#endif
//===[引入核心方法接口规范]===
#if Link(IonBase)
#include "Method/IonBase.hlsl"
#endif
//===[引入光照方法接口规范]===
#if Link(IonLight)
#include "Method/IonLight.hlsl"
#endif

