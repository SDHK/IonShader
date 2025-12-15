/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/15 20:22

* 描述： Iris Shader Pass入口文件 

*/

#ifndef Def_IrisEntryPass
#define Def_IrisEntryPass


#ifdef Use_IrisOutlineDefaultPass
    #include "Pass/IrisOutlineDefaultPass.hlsl"
#endif

#ifdef Use_IrisOutlineForwardPass
    #include "Pass/IrisOutlineForwardPass.hlsl"
#endif

#endif
