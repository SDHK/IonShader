/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/XX
*
* 说明： Unity URP 的 Ion 功能设置映射实现
*
* 设计理念：
* - 将 IonSet_XXX 映射到 Unity URP 的编译时宏
* - 只有当 Pass 文件定义了 IonSet_XXX 时才进行映射
* - URP 不使用 BRP 的阴影类型宏，但保留接口以保持一致性
*
*/

#ifndef Def_IonSet
#define Def_IonSet

//===[阴影类型设置]===
// URP 不使用这些阴影类型宏，但保留接口以保持一致性

// 屏幕空间阴影：URP 不支持
#ifdef IonSet_ShadowScreen
#define IonSet_ShadowScreen
#endif

// 深度阴影：URP 不支持
#ifdef IonSet_ShadowDepth
#define IonSet_ShadowDepth
#endif

// 立方体阴影：URP 不支持
#ifdef IonSet_ShadowCube
#define IonSet_ShadowCube
#endif

#endif // Def_IonSet

