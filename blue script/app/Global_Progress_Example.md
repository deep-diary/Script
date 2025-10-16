# 全局进度显示示例

## 新增的全局组件进度功能

现在代码增加了全局组件进度显示，让您能同时看到当前组合内的组件进度和相对于所有组件的全局进度。

## 进度显示格式

### 1. 开始信息

```
开始按组合层次处理 N 个组合，共 M 个组件...
```

### 2. 组合级别进度

```
=== [N/总数] 处理组合: 组合名称 (周期: Xms, RunnablePeriod: X.XXXs) ===
```

### 3. 组件级别进度（双重进度）

```
--- [组合内进度] 处理组件: 组件名称 (全局: 全局进度) ---
```

### 4. 完成进度

```
=== 组合 组合名称 处理完成 [N/总数] ===
🎉 所有组合处理完成！共处理了 N 个组合，M 个组件
```

## 完整输出示例

```
开始按组合层次处理 3 个组合，共 6 个组件...

=== [1/3] 处理组合: Composition_5ms (周期: 5ms, RunnablePeriod: 0.005s) ===
  组合内包含 1 个组件

  --- [1/1] 处理组件: CCMLoad_DiagArch (全局: 1/6) ---
    ✓ 生成AUTOSAR模型: CCMLoad_DiagArch
    ✓ 生成AUTOSAR代码: CCMLoad_DiagArch (周期: 0.005s)
=== 组合 Composition_5ms 处理完成 [1/3] ===

=== [2/3] 处理组合: Composition_10ms (周期: 10ms, RunnablePeriod: 0.010s) ===
  组合内包含 3 个组件

  --- [1/3] 处理组件: CCMAdcMArch (全局: 2/6) ---
    ✓ 生成AUTOSAR模型: CCMAdcMArch
    ✓ 生成AUTOSAR代码: CCMAdcMArch (周期: 0.010s)

  --- [2/3] 处理组件: CCMBatteryArch (全局: 3/6) ---
    ✓ 生成AUTOSAR模型: CCMBatteryArch
    ✓ 生成AUTOSAR代码: CCMBatteryArch (周期: 0.010s)

  --- [3/3] 处理组件: CCMMotorArch (全局: 4/6) ---
    ✓ 生成AUTOSAR模型: CCMMotorArch
    ✓ 生成AUTOSAR代码: CCMMotorArch (周期: 0.010s)
=== 组合 Composition_10ms 处理完成 [2/3] ===

=== [3/3] 处理组合: Composition_1000ms (周期: 1000ms, RunnablePeriod: 1.000s) ===
  组合内包含 2 个组件

  --- [1/2] 处理组件: AirPmCtrlArch (全局: 5/6) ---
    ✓ 生成AUTOSAR模型: AirPmCtrlArch
    ✓ 生成AUTOSAR代码: AirPmCtrlArch (周期: 1.000s)

  --- [2/2] 处理组件: AmbTFilMgrArch (全局: 6/6) ---
    ✓ 生成AUTOSAR模型: AmbTFilMgrArch
    ✓ 生成AUTOSAR代码: AmbTFilMgrArch (周期: 1.000s)
=== 组合 Composition_1000ms 处理完成 [3/3] ===

🎉 所有组合处理完成！共处理了 3 个组合，6 个组件
```

## 进度信息说明

### 开始信息

- 显示总组合数和总组件数
- 例如：`开始按组合层次处理 3 个组合，共 6 个组件...`

### 组合进度

- `[1/3]` 表示当前处理第 1 个组合，总共 3 个组合
- 显示组合名称、周期信息和 RunnablePeriod
- 显示组合内包含的组件数量

### 组件进度（双重显示）

- `[1/3]` 表示当前组合内第 1 个组件，该组合内总共 3 个组件
- `(全局: 2/6)` 表示这是全局第 2 个组件，总共 6 个组件
- 同时显示组合内进度和全局进度

### 完成进度

- 每个组合完成后显示组合进度
- 所有组合完成后显示总结信息，包括组合数和组件数

## 代码实现

### 统计总组件数

```matlab
% 统计所有组件的总数
totalComponents = 0;
for i = 1:totalCompositions
    totalComponents = totalComponents + length(compositions(i).Components);
end
```

### 全局组件计数器

```matlab
% 全局组件计数器
globalComponentCounter = 0;

% 在处理每个组件时增加计数器
globalComponentCounter = globalComponentCounter + 1;
```

### 双重进度显示

```matlab
% 显示组件处理进度（组合内进度 + 全局进度）
fprintf('\n  --- [%d/%d] 处理组件: %s (全局: %d/%d) ---\n', ...
    j, totalComponents, componentName, globalComponentCounter, totalComponents);
```

## 优势

1. **双重进度指示**：同时显示组合内进度和全局进度
2. **总体概览**：开始时就显示总组件数
3. **精确位置**：随时知道当前组件在全局中的位置
4. **完成统计**：最终显示处理的组合数和组件数
5. **层次清晰**：保持组合 → 组件的层次结构

## 适用场景

- 大量组合和组件的处理
- 需要同时了解局部和全局进度
- 长时间运行的批处理任务
- 进度监控和性能分析
- 调试和问题排查

## 进度解读示例

假设有 80 个组合，总共 200 个组件：

```
开始按组合层次处理 80 个组合，共 200 个组件...

=== [15/80] 处理组合: Composition_100ms (周期: 100ms, RunnablePeriod: 0.100s) ===
  组合内包含 3 个组件

  --- [2/3] 处理组件: SomeComponentArch (全局: 45/200) ---
```

这表示：

- 正在处理第 15 个组合（共 80 个）
- 该组合内第 2 个组件（共 3 个）
- 这是全局第 45 个组件（共 200 个）
- 整体进度约为 45/200 = 22.5%
