/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/XX
*
* 说明： Ion 功能设置宏接口规范/模板
*
* 设计理念：
* - 本文件定义了统一的功能设置宏接口规范
* - 不同引擎需要按照此规范实现对应的设置映射文件
* - 所有设置使用 IonSet_ 前缀，保持命名空间统一
* - 与 IonKey 的区别：IonKey 管理运行时变体，IonSet 管理编译时设置
*
* 实现要求：
* 1. 每个 IonSet_XXX 必须映射到对应引擎的编译时宏
* 2. 如果引擎不支持某个设置，可以不映射（保持未定义状态）
* 3. 设置映射应在 Pass 文件声明后、代码使用前完成
*
* 使用方式：
* 1. Pass 文件中：#define IonSet_XXX 声明需要的功能设置
* 2. 包含本文件：将 IonSet_XXX 映射到引擎宏
* 3. 代码中使用：#ifdef IonSet_XXX 检查设置
*
*/

#ifndef Def_IonSet
#define Def_IonSet

//===[阴影类型设置接口]===

// 屏幕空间阴影
// 说明：使用屏幕空间坐标采样阴影（BRP）
// 引擎实现：BRP -> SHADOWS_SCREEN
#ifdef IonSet_ShadowScreen
#define IonSet_ShadowScreen
#endif

// 深度阴影（聚光灯）
// 说明：使用深度贴图采样阴影（BRP SPOT）
// 引擎实现：BRP -> SHADOWS_DEPTH
#ifdef IonSet_ShadowDepth
#define IonSet_ShadowDepth
#endif

// 立方体阴影（点光源）
// 说明：使用立方体贴图采样阴影（BRP POINT）
// 引擎实现：BRP -> SHADOWS_CUBE
#ifdef IonSet_ShadowCube
#define IonSet_ShadowCube
#endif

//===[其他功能设置接口]===
// 可以继续添加其他编译时配置宏...

#endif // Def_IonSet

