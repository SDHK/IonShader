/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16 10:46
*
* 描述： 光照方法接口模板
*
*/

#ifdef Link_IrisLight

#ifndef Def_IrisLight
#define Def_IrisLight


//===[主光源获取]===

//获取光照信息 IrisStruct_Light（无阴影支持版本）
#define IrisLight_MainLight()

//获取光照信息 IrisStruct_Light（带阴影支持版本）
//参数：shadowCoord - 阴影坐标（float4）
#define IrisLight_MainLight(shadowCoord)

//===[阴影坐标转换]===

//将世界空间位置转换为阴影坐标
//参数：positionWS - 世界空间位置（float3）
//参数：shadowCoord - 阴影坐标（float4，用于接口统一）
//返回值：阴影坐标（float4）
#define IrisLight_WorldToShadow(positionWS, shadowCoord)

//===[阴影接收相关方法]===
//这些方法用于在Forward Pass中接收阴影

//计算并返回阴影坐标（在vertex shader中调用）
//参数：positionOS - 物体空间位置（float4）
//参数：positionCS - 裁剪空间位置（float4）
//参数：positionWS - 世界空间位置（float3）
//返回值：阴影坐标（float4）
//使用方式：fragData.ShadowCoord = IrisLight_ShadowCoord(vertData.PositionOS, fragData.pos, fragData.PositionWS)
#define IrisLight_ShadowCoord(positionOS, positionCS, positionWS)

//===[阴影投射相关方法]===
//这些方法用于 ShadowCaster Pass 中投射阴影

//计算阴影投射的裁剪空间位置
//参数：positionOS - 物体空间位置（float4）
//参数：normalOS - 物体空间法线（float3）
//返回值：裁剪空间位置（float4）
#define IrisShadowCaster_PositionCS(positionOS, normalOS)

//计算从光源位置到顶点的向量（用于距离衰减）
//参数：positionOS - 物体空间位置（float4）
//返回值：向量（float3）
#define IrisShadowCaster_Vector(positionOS)

//计算阴影衰减（基于距离）
//参数：vec - 从光源到顶点的向量（float3）
//返回值：阴影衰减值（half）
#define IrisShadowCaster_Fragment(vec)

#endif
#endif

