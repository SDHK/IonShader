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
* 缩写说明：
* - OS (Object Space)：物体空间，顶点相对于模型自身的坐标系
* - WS (World Space)：世界空间，顶点相对于整个场景的坐标系
* - VS (View Space)：观察空间，顶点相对于摄像机的坐标系
* - CS (Clip Space)：裁剪空间，用于最终投影到屏幕的坐标系
* 
* 空间转换流程：OS --[M]--> WS --[V]--> VS --[P]--> CS
* 代码实现：
*   float4 positionOS = float4(vertexPosition, 1.0);           // OS
*   float4 positionWS = mul(Iris_Matrix_M, positionOS);       // OS → WS (M)
*   float4 positionVS = mul(Iris_Matrix_V, positionWS);       // WS → VS (V)
*   float4 positionCS = mul(Iris_Matrix_P, positionVS);       // VS → CS (P)
*
* 详细说明：
* OS → WS（对象空间 → 世界空间）
*   使用：Model Matrix (M)
*    作用：将顶点从模型本地坐标系转换到世界坐标系
*    包含：位置、旋转、缩放
* WS → VS（世界空间 → 观察空间）
*    使用：View Matrix (V)
*    作用：将顶点从世界坐标系转换到相机坐标系
*    本质：相机变换（Camera Transform）
* VS → CS（观察空间 → 裁剪空间）
*    使用：Projection Matrix (P)
*    作用：将顶点从观察空间投影到裁剪空间
*    功能：透视/正交投影、视锥裁剪
*/

#ifndef Def_IrisParams
#define Def_IrisParams


//如果没有定义，则提供默认空实现，避免编译错误
#ifndef Inc_IrisParams
   
//===[相机]===

//float3 世界空间中的相机位置。
#define Iris_WorldSpaceCameraPos Iris_Float3_Zero
//float4 投影参数
#define Iris_ProjectionParams Iris_Float4_Zero
//float4 屏幕参数
#define Iris_ScreenParams Iris_Float4_Zero
//float4 Z缓存参数
#define Iris_ZBufferParams Iris_Float4_Zero
//float4 正交参数
#define Iris_OrthoParams Iris_Float4_Zero
//float4 相机投影参数
#define Iris_CameraProjectionParams Iris_Float4_Zero 

//===[矩阵]===

//float4x4 模型视图投影矩阵
#define Iris_Matrix_MVP Iris_Float4x4_Identity
//float4x4 模型视图投影矩阵的逆矩阵
#define Iris_Matrix_I_MVP Iris_Float4x4_Identity
//float4x4 模型视图矩阵
#define Iris_Matrix_MV Iris_Float4x4_Identity
//float4x4 模型视图矩阵的逆矩阵
#define Iris_Matrix_I_MV Iris_Float4x4_Identity
//float4x4 视图投影矩阵
#define Iris_Matrix_VP Iris_Float4x4_Identity
//float4x4 视图投影矩阵的逆矩阵
#define Iris_Matrix_I_VP Iris_Float4x4_Identity
//float4x4 模型矩阵
#define Iris_Matrix_M Iris_Float4x4_Identity
//float4x4 模型矩阵的逆矩阵
#define Iris_Matrix_I_M Iris_Float4x4_Identity
//float4x4 视图矩阵
#define Iris_Matrix_V Iris_Float4x4_Identity
//float4x4 视图矩阵的逆矩阵
#define Iris_Matrix_I_V Iris_Float4x4_Identity
//float4x4 投影矩阵
#define Iris_Matrix_P Iris_Float4x4_Identity
//float4x4 投影矩阵的逆矩阵
#define Iris_Matrix_I_P Iris_Float4x4_Identity

//float4x4 模型视图矩阵的转置
#define Iris_Matrix_T_MV Iris_Float4x4_Identity
//float4x4 模型视图矩阵的逆转置
#define Iris_Matrix_IT_MV Iris_Float4x4_Identity
//float4x4 对象到世界矩阵
#define Iris_ObjectToWorld Iris_Float4x4_Identity
//float4x4 世界到对象矩阵
#define Iris_WorldToObject Iris_Float4x4_Identity

//===[时间]===

//float4 当前时间。x:时间/20，y:时间，z:时间x2，w:时间x3
#define Iris_Time Iris_Float4_Zero 
//float4 正弦时间。x:sin(时间)，y:sin(时间/20)，z:sin(时间/200)，w:sin(时间x2)
#define Iris_SinTime Iris_Float4_Zero
//float4 余弦时间。x:cos(时间)，y:cos(时间/20)，z:cos(时间/200)，w:cos(时间x2)
#define Iris_CosTime Iris_Float4_Zero
//float4 上一帧的时间间隔。x:帧间隔时间，y:帧间隔时间/20，z:帧间隔时间/200，w:帧间隔时间x2
#define Iris_DeltaTime Iris_Float4_Zero

//===[光照]===

//float4 天空环境光颜色（RGB）和强度（A）
#define Iris_AmbientSky Iris_Float4_Zero
//float4 赤道环境光颜色（RGB）和强度（A）
#define Iris_AmbientEquator Iris_Float4_Zero
//float4 地面环境光颜色（RGB）和强度（A）
#define Iris_AmbientGround Iris_Float4_Zero
//float4 主光源位置/方向（世界空间）。xyz:位置/方向，w:0=方向光，1=点光源
#define Iris_WorldSpaceLightPos0 Iris_Float4_Zero
//float4 主光源颜色（RGB）和强度（A）
#define Iris_LightColor0 Iris_Float4_Zero

//===[多光源]===

//float4 4个光源的X坐标
#define Iris_4LightPosX0 Iris_Float4_Zero
//float4 4个光源的Y坐标
#define Iris_4LightPosY0 Iris_Float4_Zero
//float4 4个光源的Z坐标
#define Iris_4LightPosZ0 Iris_Float4_Zero
//float4 4个光源的衰减系数
#define Iris_4LightAtten0 Iris_Float4_Zero

//===[球谐光照]===

//float4 球谐函数 R 通道系数（常数项）
#define Iris_SHAr Iris_Float4_Zero
//float4 球谐函数 G 通道系数（常数项）
#define Iris_SHAg Iris_Float4_Zero
//float4 球谐函数 B 通道系数（常数项）
#define Iris_SHAb Iris_Float4_Zero
//float4 球谐函数 R 通道系数（线性项）
#define Iris_SHBr Iris_Float4_Zero
//float4 球谐函数 G 通道系数（线性项）
#define Iris_SHBg Iris_Float4_Zero
//float4 球谐函数 B 通道系数（线性项）
#define Iris_SHBb Iris_Float4_Zero
//float4 球谐函数系数（二次项）
#define Iris_SHC Iris_Float4_Zero

//===[阴影]===

//float4 级联阴影分割半径的平方
#define Iris_ShadowSplitSqRadii Iris_Float4_Zero
//float4 光源阴影偏移
#define Iris_LightShadowBias Iris_Float4_Zero

//===[雾效]===

//float4 雾的颜色（RGB）和强度（A）
#define Iris_FogColor Iris_Float4_Zero
//float4 雾的参数。x:密度，y:起始距离，z:结束距离，w:其他参数
#define Iris_FogParams Iris_Float4_Zero



#endif

#endif
