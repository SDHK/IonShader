/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16 11:01
*
* 描述： Iris 宏定义规范链接
*
*/

//===[引入参数接口规范]===
#if Link(IrisBase)
#include "Param/IrisParam.hlsl"
#endif
//===[引入核心方法接口规范]===
#if Link(IrisBase)
#include "Method/IrisBase.hlsl"
#endif
//===[引入光照方法接口规范]===
#if Link(IrisLight)
#include "Method/IrisLight.hlsl"
#endif

