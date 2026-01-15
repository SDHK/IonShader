
//===[引入核心宏定义]===
#include "../../../Ion/IonMacro.hlsl"

//===[注入映射系统]===
#define Inc_IonMap "../../Unity/Pipeline/URP/Core/Map/IonLinkMap.hlsl"
//===[注入基础库]===
#define Inc_IonLibrary "../../Unity/Pipeline/URP/Core/Library/IonLinkLibrary.hlsl"
//===[注入 Unity 绑定]===
#define Inc_IonBind "../../Unity/Pipeline/URP/Core/Bind/IonLinkBind.hlsl"

#include "Pass/IonPass.hlsl"


