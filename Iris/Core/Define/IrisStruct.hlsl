/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/10 14:18
*
* 描述： 结构体定义
* 

*/

#ifndef Def_IrisStruct
#define Def_IrisStruct

//=== [光照阴影数据结构] ===

//光照阴影数据
struct IrisStruct_Light
{
    // 光源方向
    half3   Direction;
    // 光源颜色
    half3   Color;
    // 光源衰减
    float   DistanceAttenuation; 
    // 阴影衰减
    half    ShadowAttenuation;
    // 阴影层级
    uint    LayerMask;
};

//===[数据结构字段映射]===
// 顶点位置
#define IrisVar_PositionOS float4 PositionOS : POSITION;
// 顶点颜色
#define IrisVar_Color float4 Color : COLOR;
// 顶点法线
#define IrisVar_Normal float3 Normal : NORMAL;
// 顶点切线
#define IrisVar_Tangent float4 Tangent : TANGENT;
// 顶点ID
#define IrisVar_VertexID uint VertexID : SV_VertexID;
// 实例ID
#define IrisVar_InstanceID uint InstanceID : SV_InstanceID;
// 顶点在屏幕空间位置
#define IrisVar_PositionCS float4 PositionCS : SV_POSITION;
// 正面检测（双面渲染）
#define IrisVar_IsFrontFace bool IsFrontFace : SV_IsFrontFace;

// ===[传值通道字段映射]===
#define IrisVar_T0(type,name) type name : TEXCOORD0;
#define IrisVar_T1(type,name) type name : TEXCOORD1;
#define IrisVar_T2(type,name) type name : TEXCOORD2;
#define IrisVar_T3(type,name) type name : TEXCOORD3;
#define IrisVar_T4(type,name) type name : TEXCOORD4;
#define IrisVar_T5(type,name) type name : TEXCOORD5;
#define IrisVar_T6(type,name) type name : TEXCOORD6;
#define IrisVar_T7(type,name) type name : TEXCOORD7;


#endif
