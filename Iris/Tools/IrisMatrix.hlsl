/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/9 19:53

* 描述： 矩阵计算集

*/

#ifndef Def_IrisMatrix
#define Def_IrisMatrix

#include "../Macro/IrisParams.hlsl"

// 归一化一个三维向量，避免除以零
float3 MatrixSafeNormalize(float3 inVec)
{
    float dp3 = max(Iris_Float_Min, dot(inVec, inVec));
    return inVec * rsqrt(dp3);
}

// 转换坐标系：从模型坐标转到投影坐标系。顶点着色器常用
float4 MatrixObjectToProjection(float4 pos)
{
    return mul(Iris_Matrix_MVP, pos);
}
// 转换坐标系：从投影坐标系转到模型坐标系。
float4 MatrixProjectionToObject(float4 pos)
{
    return mul(Iris_Matrix_I_MVP, pos);
}

// 转换坐标系：从模型局部坐标转到世界坐标系
float3 MatrixObjectToWorld(float3 pos, bool isNormalize = true)
{
    float3 normalWS = mul(Iris_Matrix_M, float4(pos, 1.0)).xyz;
    if (isNormalize)
        return MatrixSafeNormalize(normalWS);
    return normalWS;
}

// 转换坐标系：从世界坐标系转到模型局部坐标
float3 MatrixWorldToObject(float3 pos, bool isNormalize = true)
{
    float3 normalOS = mul(Iris_Matrix_I_M, float4(pos, 1.0)).xyz;
    if (isNormalize)
        return MatrixSafeNormalize(normalOS);
    return normalOS;
}




#endif