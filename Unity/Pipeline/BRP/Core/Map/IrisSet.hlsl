/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/XX
*
* 说明： Unity BRP 的 Iris 功能设置映射实现
*
* 设计理念：
* - 将 IrisSet_XXX 映射到 Unity BRP 的编译时宏
* - 只有当 Pass 文件定义了 IrisSet_XXX 时才进行映射
*
*/

#ifndef Def_IrisSet
#define Def_IrisSet

//===[阴影类型设置]===

// 屏幕空间阴影：IrisSet_ShadowScreen -> SHADOWS_SCREEN
#ifdef IrisSet_ShadowScreen
#define SHADOWS_SCREEN
#define IrisSet_ShadowScreen
#endif

// 深度阴影：IrisSet_ShadowDepth -> SHADOWS_DEPTH
#ifdef IrisSet_ShadowDepth
#define SHADOWS_DEPTH
#define IrisSet_ShadowDepth
#endif

// 立方体阴影：IrisSet_ShadowCube -> SHADOWS_CUBE
#ifdef IrisSet_ShadowCube
#define SHADOWS_CUBE
#define IrisSet_ShadowCube
#endif

#endif // Def_IrisSet

