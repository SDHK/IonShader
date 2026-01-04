/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16
*
* 描述： Iris 工具函数统一入口
* 
* 功能：统一包含所有工具函数文件
*       根据 Use_IrisXXX 宏控制是否链接
*
* 注意：文件包含顺序考虑了依赖关系
*       - IrisHash 是基础库，先包含
*       - IrisNoise 依赖 IrisHash，后包含
*
*/

//===[基础工具]===
#if Link(IrisHash)
#include "IrisHash.hlsl"      // 哈希函数（基础库，其他库可能依赖）
#endif

//===[数学工具]===
#if Link(IrisMath)
#include "IrisMath.hlsl"      // 数学函数
#endif
#if Link(IrisMatrix)
#include "IrisMatrix.hlsl"   // 矩阵计算
#endif
//===[高级工具]===
#if Link(IrisNoise)
#include "IrisNoise.hlsl"     // 噪声函数（依赖 IrisHash）
#endif
#if Link(IrisDistort)
#include "IrisDistort.hlsl"   // 扭曲函数
#endif
#if Link(IrisVertex)
#include "IrisVertex.hlsl"   // 顶点工具
#endif

