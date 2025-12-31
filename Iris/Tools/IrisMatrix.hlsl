/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/9 19:53

* 描述： 矩阵计算集

* 缩写说明：
* - OS (Object Space)：物体空间，顶点相对于模型自身的坐标系
* - WS (World Space)：世界空间，顶点相对于整个场景的坐标系
* - VS (View Space)：观察空间，顶点相对于摄像机的坐标系
* - CS (Clip Space)：裁剪空间，用于最终投影到屏幕的坐标系
* 
* 空间转换流程：OS --[M]--> WS --[V]--> VS --[P]--> CS
* 代码实现：
*   float4 positionOS = float4(vertexPosition, 1.0);           // OS
*   float4 positionWS = mul(IrisParam_Matrix_M, positionOS);       // OS → WS (M)
*   float4 positionVS = mul(IrisParam_Matrix_V, positionWS);       // WS → VS (V)
*   float4 positionCS = mul(IrisParam_Matrix_P, positionVS);       // VS → CS (P)
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

#ifdef Use_IrisMatrix

#ifndef Def_IrisMatrix
#define Def_IrisMatrix

#include "../Bind/IrisParam.hlsl"

// 归一化一个三维向量，避免除以零
float3 IrisMatrix_SafeNormalize(float3 inVec)
{
    float dp3 = max(IrisConst_Float_Min, dot(inVec, inVec));
    return inVec * rsqrt(dp3);
}

//===[Object Space (OS) 转换]===

// 转换坐标系：从模型空间转到裁剪空间（Clip Space）。顶点着色器常用，用于输出 PositionCS
float4 IrisMatrix_ObjectToClip(float4 pos)
{
    return mul(IrisParam_Matrix_MVP, pos);
}

// 转换坐标系：从模型空间转到观察空间（View Space / Camera Space）
float4 IrisMatrix_ObjectToView(float4 pos)
{
    return mul(IrisParam_Matrix_MV, pos);
}

// 转换坐标系：从模型空间转到世界空间
float4 IrisMatrix_ObjectToWorld(float4 pos)
{
    return mul(IrisParam_Matrix_M, pos);
}

// 转换坐标系：从模型空间转到世界空间（float3版本，常用于方向向量）
// 注意：对于法线向量，请使用 IrisMatrix_ObjectToWorldNormal
// 如需归一化，请手动调用 IrisMatrix_SafeNormalize()
float3 IrisMatrix_ObjectToWorld(float3 pos)
{
    return mul(IrisParam_Matrix_M, float4(pos, 1.0)).xyz;
}

// 转换坐标系：从模型空间转到世界空间（法线专用，使用逆转置矩阵）
// 用于法线向量转换，正确处理非均匀缩放
float3 IrisMatrix_ObjectToWorldNormal(float3 normal)
{
    // 使用模型矩阵的逆转置来转换法线到世界空间
    // 注意：IrisParam_Matrix_IT_MV 会将法线转换到观察空间，而不是世界空间
    return normalize(mul((float3x3)IrisParam_Matrix_IT_M, normal));
}

//===[World Space (WS) 转换]===

// 转换坐标系：从世界空间转到裁剪空间
float4 IrisMatrix_WorldToClip(float4 pos)
{
    return mul(IrisParam_Matrix_VP, pos);
}

// 转换坐标系：从世界空间转到观察空间
float4 IrisMatrix_WorldToView(float4 pos)
{
    return mul(IrisParam_Matrix_V, pos);
}

// 转换坐标系：从世界空间转到模型空间
float4 IrisMatrix_WorldToObject(float4 pos)
{
    return mul(IrisParam_Matrix_I_M, pos);
}

// 转换坐标系：从世界空间转到模型空间（float3版本，常用于方向向量）
// 注意：对于法线向量，请使用 IrisMatrix_WorldToObjectNormal
// 如需归一化，请手动调用 IrisMatrix_SafeNormalize()
float3 IrisMatrix_WorldToObject(float3 pos)
{
    return mul(IrisParam_Matrix_I_M, float4(pos, 1.0)).xyz;
}

// 转换坐标系：从世界空间转到模型空间（法线专用）
// 用于法线向量转换，正确处理非均匀缩放
float3 IrisMatrix_WorldToObjectNormal(float3 normal)
{
    return normalize(mul((float3x3)IrisParam_Matrix_I_M, normal));
}

//===[View Space (VS) 转换]===

// 转换坐标系：从观察空间转到裁剪空间
float4 IrisMatrix_ViewToClip(float4 pos)
{
    return mul(IrisParam_Matrix_P, pos);
}

// 转换坐标系：从观察空间转到世界空间
float4 IrisMatrix_ViewToWorld(float4 pos)
{
    return mul(IrisParam_Matrix_I_V, pos);
}

// 转换坐标系：从观察空间转到模型空间
float4 IrisMatrix_ViewToObject(float4 pos)
{
    return mul(IrisParam_Matrix_I_MV, pos);
}

//===[Clip Space (CS) 转换]===

// 转换坐标系：从裁剪空间转到模型空间
float4 IrisMatrix_ClipToObject(float4 pos)
{
    return mul(IrisParam_Matrix_I_MVP, pos);
}

// 转换坐标系：从裁剪空间转到世界空间
float4 IrisMatrix_ClipToWorld(float4 pos)
{
    return mul(IrisParam_Matrix_I_VP, pos);
}

// 转换坐标系：从裁剪空间转到观察空间
float4 IrisMatrix_ClipToView(float4 pos)
{
    return mul(IrisParam_Matrix_I_P, pos);
}

#endif

#endif // Use_IrisMatrix