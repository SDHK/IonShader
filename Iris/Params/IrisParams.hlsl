/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/4 19:42
*
* 说明： Iris Shader环境参数接口规范/模板
* 
* 设计理念：
* - 本文件定义了统一的参数接口规范
* - 不同引擎需要按照此规范实现对应的参数映射文件
* - 所有环境参数使用 Iris_ 前缀，保持命名空间统一
* 
* 实现要求：
* 1. 每个 #define 必须映射到对应引擎的内置变量
* 2. 变量类型必须匹配（float3/float4/float4x4等）
* 3. 参数语义需保持一致
*
*/
#ifndef Def_IrisParams
#define Def_IrisParams

#include "IrisStructFields.hlsl"
//===[常量]===

#define float_Zero 0.0
#define float2_Zero float2(0.0,0.0)
#define float3_Zero float3(0.0,0.0,0.0)
#define float4_Zero float4(0.0,0.0,0.0,0.0)

#define float4x4_Zero  float4x4( 0.0, 0.0, 0.0, 0.0,  0.0, 0.0, 0.0, 0.0,  0.0, 0.0, 0.0, 0.0,  0.0, 0.0, 0.0, 0.0)
#define float4x4_Identity  float4x4( 1.0, 0.0, 0.0, 0.0,  0.0, 1.0, 0.0, 0.0,  0.0, 0.0, 1.0, 0.0,  0.0, 0.0, 0.0, 1.0)


//如果没有定义 IrisShader，则提供默认空实现，避免编译错误
#ifndef IrisShader
   
//===[相机]===

//float3 世界空间中的相机位置。
#define Iris_WorldSpaceCameraPos float3_Zero
//float4 投影参数
#define Iris_ProjectionParams float4_Zero
//float4 屏幕参数
#define Iris_ScreenParams float4_Zero
//float4 Z缓存参数
#define Iris_ZBufferParams float4_Zero
//float4 正交参数
#define Iris_OrthoParams float4_Zero
//float4x4 相机投影矩阵
#define Iris_CameraProjection float4x4_Identity
//float4x4 相机投影矩阵的逆矩阵
#define Iris_CameraInvProjection float4x4_Identity 
//float4 相机投影参数
#define Iris_CameraProjectionParams float4_Zero 

//===[矩阵]===

//float4x4 模型视图投影矩阵
#define Iris_Matrix_MVP float4x4_Identity
//float4x4 模型视图矩阵
#define Iris_Matrix_MV float4x4_Identity
//float4x4 视图投影矩阵
#define Iris_Matrix_VP float4x4_Identity
//float4x4 模型矩阵
#define Iris_Matrix_M float4x4_Identity
//float4x4 视图矩阵
#define Iris_Matrix_V float4x4_Identity
//float4x4 投影矩阵
#define Iris_Matrix_P float4x4_Identity

//float4x4 模型视图矩阵的转置
#define Iris_Matrix_T_MV float4x4_Identity
//float4x4 模型视图矩阵的逆转置
#define Iris_Matrix_IT_MV float4x4_Identity
//float4x4 对象到世界矩阵
#define Iris_ObjectToWorld float4x4_Identity
//float4x4 世界到对象矩阵
#define Iris_WorldToObject float4x4_Identity

//===[时间]===

//float4 当前时间。x:时间/20，y:时间，z:时间x2，w:时间x3
#define Iris_Time float4_Zero 
//float4 正弦时间。x:sin(时间)，y:sin(时间/20)，z:sin(时间/200)，w:sin(时间x2)
#define Iris_SinTime float4_Zero
//float4 余弦时间。x:cos(时间)，y:cos(时间/20)，z:cos(时间/200)，w:cos(时间x2)
#define Iris_CosTime float4_Zero
//float4 上一帧的时间间隔。x:帧间隔时间，y:帧间隔时间/20，z:帧间隔时间/200，w:帧间隔时间x2
#define Iris_DeltaTime float4_Zero

//===[光照]===

//float4 天空环境光颜色（RGB）和强度（A）
#define Iris_AmbientSky float4_Zero
//float4 赤道环境光颜色（RGB）和强度（A）
#define Iris_AmbientEquator float4_Zero
//float4 地面环境光颜色（RGB）和强度（A）
#define Iris_AmbientGround float4_Zero
//float4 主光源位置/方向（世界空间）。xyz:位置/方向，w:0=方向光，1=点光源
#define Iris_WorldSpaceLightPos0 float4_Zero
//float4 主光源颜色（RGB）和强度（A）
#define Iris_LightColor0 float4_Zero

//===[多光源]===

//float4 4个光源的X坐标
#define Iris_4LightPosX0 float4_Zero
//float4 4个光源的Y坐标
#define Iris_4LightPosY0 float4_Zero
//float4 4个光源的Z坐标
#define Iris_4LightPosZ0 float4_Zero
//float4 4个光源的衰减系数
#define Iris_4LightAtten0 float4_Zero

//===[球谐光照]===

//float4 球谐函数 R 通道系数（常数项）
#define Iris_SHAr float4_Zero
//float4 球谐函数 G 通道系数（常数项）
#define Iris_SHAg float4_Zero
//float4 球谐函数 B 通道系数（常数项）
#define Iris_SHAb float4_Zero
//float4 球谐函数 R 通道系数（线性项）
#define Iris_SHBr float4_Zero
//float4 球谐函数 G 通道系数（线性项）
#define Iris_SHBg float4_Zero
//float4 球谐函数 B 通道系数（线性项）
#define Iris_SHBb float4_Zero
//float4 球谐函数系数（二次项）
#define Iris_SHC float4_Zero

//===[阴影]===

//float4 级联阴影分割半径的平方
#define Iris_ShadowSplitSqRadii float4_Zero
//float4 光源阴影偏移
#define Iris_LightShadowBias float4_Zero

//===[雾效]===

//float4 雾的颜色（RGB）和强度（A）
#define Iris_FogColor float4_Zero
//float4 雾的参数。x:密度，y:起始距离，z:结束距离，w:其他参数
#define Iris_FogParams float4_Zero

#endif

#endif
