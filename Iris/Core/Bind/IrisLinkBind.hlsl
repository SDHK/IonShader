/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16 11:01
*
* 描述： Iris 宏定义规范集，给内部工具文件使用
*
*/

//===[引入参数接口规范]===
#if Link(IrisBase)
#include "IrisParam.hlsl"
#endif
//===[引入核心方法接口规范]===
#if Link(IrisBase)
#include "IrisBase.hlsl"
#endif
//===[引入光照方法接口规范]===
#if Link(IrisLight)
#include "IrisLight.hlsl"
#endif

