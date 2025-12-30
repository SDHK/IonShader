# 泛光效果实现方案说明

## 问题分析

对于**变身时的均匀泛光效果**，模型复杂时会出现重叠导致：
- 颜色叠加增亮（Additive混合）
- 反色（Screen混合）
- 不均匀（Alpha混合）

## 方案对比

### 方案1：后处理 + Stencil Buffer（推荐）

**这是行业标准做法**，用于实现局部泛光效果。

#### 优点：
- ✅ 效果最均匀，不会出现重叠问题
- ✅ 自动处理所有重叠情况
- ✅ 性能好（GPU后处理优化）
- ✅ 可以精确控制哪些物体泛光

#### 实现步骤：

1. **Shader中标记需要泛光的物体**
```hlsl
// 在主Pass中添加Stencil标记
Stencil
{
    Ref 1
    Comp Always
    Pass Replace
}
```

2. **后处理脚本中提取高亮区域**
```csharp
// 使用Graphics.Blit提取Stencil标记的区域
Graphics.Blit(source, destination, bloomMaterial);
```

3. **后处理Shader中只处理标记区域**
```hlsl
// 检查Stencil值
if (stencilValue != 1) discard;
```

#### Unity实现示例：

**后处理脚本（C#）**：
```csharp
using UnityEngine;

[ExecuteInEditMode]
public class LocalBloom : MonoBehaviour
{
    public Material bloomMaterial;
    public float threshold = 1.0f;
    public float intensity = 1.0f;
    
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // 提取高亮区域（只处理Stencil标记的区域）
        RenderTexture temp = RenderTexture.GetTemporary(source.width, source.height);
        Graphics.Blit(source, temp, bloomMaterial, 0); // Extract pass
        
        // 模糊处理
        RenderTexture blurred = RenderTexture.GetTemporary(source.width, source.height);
        Graphics.Blit(temp, blurred, bloomMaterial, 1); // Blur pass
        
        // 混合
        bloomMaterial.SetTexture("_BloomTex", blurred);
        Graphics.Blit(source, destination, bloomMaterial, 2); // Composite pass
        
        RenderTexture.ReleaseTemporary(temp);
        RenderTexture.ReleaseTemporary(blurred);
    }
}
```

**后处理Shader**：
```hlsl
Shader "Custom/LocalBloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BloomTex ("Bloom Texture", 2D) = "black" {}
        _Threshold ("Threshold", Float) = 1.0
        _Intensity ("Intensity", Float) = 1.0
    }
    
    SubShader
    {
        // Pass 0: 提取高亮区域（只处理Stencil=1的区域）
        Pass
        {
            Stencil
            {
                Ref 1
                Comp Equal
            }
            // ... 提取逻辑
        }
        
        // Pass 1: 模糊
        // Pass 2: 混合
    }
}
```

### 方案2：Shader多Pass + Stencil Buffer（当前EmissionBloom4）

#### 优点：
- ✅ 不需要后处理管线
- ✅ 只影响特定材质
- ✅ 实现相对简单

#### 缺点：
- ⚠️ 如果模型自身有重叠（如手臂交叉），仍可能有问题
- ⚠️ 需要每个物体单独处理

#### 工作原理：
- 主Pass：标记Stencil = 1
- 光晕Pass：只渲染Stencil = 1的区域，使用Additive混合
- 由于Stencil限制，每个像素只渲染一次，避免重叠

## 推荐方案

对于**变身效果的均匀泛光**，推荐使用：

### **后处理 + Stencil Buffer**

原因：
1. 变身效果通常是全屏或大范围的
2. 需要均匀、无重叠的泛光
3. 后处理可以完美处理所有重叠情况
4. 这是游戏行业的标准做法

### 实现建议

1. **使用Unity Post Processing Stack v2**（BRP）
   - 安装：Window > Package Manager > Post Processing Stack v2
   - 创建Bloom效果
   - 使用Stencil Buffer标记需要泛光的物体

2. **或者自定义后处理**
   - 参考上面的代码示例
   - 使用Graphics.Blit实现提取、模糊、混合

## 当前Shader版本说明

- **EmissionBloom**：Additive混合，重叠会增亮
- **EmissionBloom2**：Screen混合，可能出现反色
- **EmissionBloom3**：Alpha混合 + 亮度自适应，效果一般
- **EmissionBloom4**：Stencil + Additive，避免重叠，但模型自身重叠仍有问题

**建议**：对于变身效果，使用后处理方案。

