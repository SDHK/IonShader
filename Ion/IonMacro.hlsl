
/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/19
*
* 描述： Ion Shader 框架核心宏定义
*
* 功能：定义框架使用的核心宏系统
*       - Def 宏：模块包装宏，用于防止重复定义
*       - Link 宏：模块链接宏，用于控制模块加载
*
* 设计理念：
* - 统一管理框架的核心宏定义，避免重复定义
* - 所有需要 Def/Link 宏的文件都应包含本文件
* - 通过宏系统实现按需加载和防止重复包含
*
*/

#ifndef Def_IonMacro
#define Def_IonMacro


// 模块包装宏（单参数版本 - 完整模块）
// 用于判断是否应该定义某个完整模块，防止重复定义
// 使用场景：Pass 文件、Tool 文件等完整模块
#define Def(name) (defined(Link_##name) && !defined(Def_##name) || !defined(IonShader))

// 模块包装宏（双参数版本 - 部分模块）
// 用于判断是否应该定义某个模块的特定部分，防止重复定义
// 使用场景：统一链接文件中控制不同部分的加载
// part 可以是：Library, Bind, Tool 等
#define DefPart(name,part) (defined(Link_##name) && !defined(Def_##name##_##part) || !defined(IonShader))


// 模块链接宏（单行版本）
// 用于判断是否应该链接某个模块，控制按需加载
#define Link(name) (defined(Link_##name) || !defined(IonShader))




// Pass 参数检查宏
#define PassVar1(name, param0) (!defined(name##_##param0))
// Pass 参数检查宏
#define PassVar2(name, param0, param1) (PassVar1(name,param0) || PassVar1(name,param1))
// Pass 参数检查宏
#define PassVar4(name, param0, param1,param2, param3) (PassVar2(name,param0,param1) || PassVar2(name,param2,param3))
// Pass 参数检查宏
#define PassVar8(name, param0, param1,param2, param3,param4, param5,param6, param7) (PassVar4(name,param0,param1,param2,param3) || PassVar4(name,param4,param5,param6,param7))

//#define PassVar(name, ...) CONCATENATE(PassVar,NUM_ARGS(__VA_ARGS__))(name, __VA_ARGS__)



#define PassVarDef(name)  (!defined(name))


// 定义循环展开
#define FE_1(ACT, x1) ACT(x1)
#define FE_2(ACT, x1, x2) ACT(x1) FE_1(ACT, x2)
#define FE_3(ACT, x1, x2, x3) ACT(x1) FE_2(x2, x3)
#define FE_4(ACT, x1, x2, x3, x4) ACT(x1) FE_3(ACT, x2, x3, x4)
#define FE_5(ACT, x1, x2, x3, x4, x5) ACT(x1) FE_4(ACT, x2, x3, x4, x5)
#define FE_6(ACT, x1, x2, x3, x4, x5, x6) ACT(x1) FE_5(ACT, x2, x3, x4, x5, x6)
#define FE_7(ACT, x1, x2, x3, x4, x5, x6, x7) ACT(x1) FE_6(ACT, x2, x3, x4, x5, x6, x7)
#define FE_8(ACT, x1, x2, x3, x4, x5, x6, x7, x8) ACT(x1) FE_7(ACT, x2, x3, x4, x5, x6, x7, x8)
#define FE_9(ACT, x1, x2, x3, x4, x5, x6, x7, x8, x9) ACT(x1) FE_8(ACT, x2, x3, x4, x5, x6, x7, x8, x9)
#define FE_10(ACT, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10) ACT(x1) FE_9(ACT, x2, x3, x4, x5, x6, x7, x8, x9, x10)




// 3. 拼接辅助宏 (关键！)
// 用来把 FE_ 和 数字 拼起来
#define GET_FE(n) FE_##n

#define PassVar(num,name ) GET_FE(num) (PassVarDef
//使用
 //PassVar(2,IonPassMainSimple) ,MainTex, MainTexA)





#endif