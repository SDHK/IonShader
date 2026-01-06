/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/XX
*
* 说明： Unity BRP 的 Ion 功能设置映射实现
*
* 设计理念：
* - 将 IonSet_XXX 映射到 Unity BRP 的编译时宏
* - 只有当 Pass 文件定义了 IonSet_XXX 时才进行映射
*
*/

#ifndef Def_IonSet
#define Def_IonSet

//===[阴影类型设置]===

// 屏幕空间阴影：IonSet_ShadowScreen -> SHADOWS_SCREEN
#ifdef IonSet_ShadowScreen
#define SHADOWS_SCREEN
#define IonSet_ShadowScreen
#endif

// 深度阴影：IonSet_ShadowDepth -> SHADOWS_DEPTH
#ifdef IonSet_ShadowDepth
#define SHADOWS_DEPTH
#define IonSet_ShadowDepth
#endif

// 立方体阴影：IonSet_ShadowCube -> SHADOWS_CUBE
#ifdef IonSet_ShadowCube
#define SHADOWS_CUBE
#define IonSet_ShadowCube
#endif

#endif // Def_IonSet

