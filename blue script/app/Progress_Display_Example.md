# 进度显示示例

## 新增的进度提示功能

现在代码增加了详细的进度提示，让您能清楚地看到处理进度。

## 进度显示格式

### 1. 组合级别进度

```
=== [N/总数] 处理组合: 组合名称 (周期: Xms, RunnablePeriod: X.XXXs) ===
```

### 2. 组件级别进度

```
--- [N/总数] 处理组件: 组件名称 ---
```

### 3. 完成进度

```
=== 组合 组合名称 处理完成 [N/总数] ===
```

## 完整输出示例

```
开始按组合层次处理 3 个组合...

=== [1/3] 处理组合: Composition_5ms (周期: 5ms, RunnablePeriod: 0.005s) ===
  组合内包含 1 个组件

  --- [1/1] 处理组件: CCMLoad_DiagArch ---
    ✓ 生成AUTOSAR模型: CCMLoad_DiagArch
    ✓ 生成AUTOSAR代码: CCMLoad_DiagArch (周期: 0.005s)
=== 组合 Composition_5ms 处理完成 [1/3] ===

=== [2/3] 处理组合: Composition_10ms (周期: 10ms, RunnablePeriod: 0.010s) ===
  组合内包含 3 个组件

  --- [1/3] 处理组件: CCMAdcMArch ---
    ✓ 生成AUTOSAR模型: CCMAdcMArch
    ✓ 生成AUTOSAR代码: CCMAdcMArch (周期: 0.010s)

  --- [2/3] 处理组件: CCMBatteryArch ---
    ✓ 生成AUTOSAR模型: CCMBatteryArch
    ✓ 生成AUTOSAR代码: CCMBatteryArch (周期: 0.010s)

  --- [3/3] 处理组件: CCMMotorArch ---
    ✓ 生成AUTOSAR模型: CCMMotorArch
    ✓ 生成AUTOSAR代码: CCMMotorArch (周期: 0.010s)
=== 组合 Composition_10ms 处理完成 [2/3] ===

=== [3/3] 处理组合: Composition_1000ms (周期: 1000ms, RunnablePeriod: 1.000s) ===
  组合内包含 2 个组件

  --- [1/2] 处理组件: AirPmCtrlArch ---
    ✓ 生成AUTOSAR模型: AirPmCtrlArch
    ✓ 生成AUTOSAR代码: AirPmCtrlArch (周期: 1.000s)

  --- [2/2] 处理组件: AmbTFilMgrArch ---
    ✓ 生成AUTOSAR模型: AmbTFilMgrArch
    ✓ 生成AUTOSAR代码: AmbTFilMgrArch (周期: 1.000s)
=== 组合 Composition_1000ms 处理完成 [3/3] ===

🎉 所有组合处理完成！共处理了 3 个组合
```

## 进度信息说明

### 组合进度

- `[1/3]` 表示当前处理第 1 个组合，总共 3 个组合
- 显示组合名称、周期信息和 RunnablePeriod
- 显示组合内包含的组件数量

### 组件进度

- `[1/3]` 表示当前处理第 1 个组件，该组合内总共 3 个组件
- 显示组件名称
- 显示模型生成和代码生成状态

### 完成进度

- 每个组合完成后显示 `[N/总数]` 进度
- 所有组合完成后显示总结信息

## 代码实现

### 组合进度显示

```matlab
% 显示组合处理进度
fprintf('\n=== [%d/%d] 处理组合: %s (周期: %dms, RunnablePeriod: %.3fs) ===\n', ...
    i, totalCompositions, compositionName, period, runnablePeriod);
```

### 组件进度显示

```matlab
% 显示组件处理进度
fprintf('\n  --- [%d/%d] 处理组件: %s ---\n', j, totalComponents, componentName);
```

### 完成进度显示

```matlab
% 显示组合完成进度
fprintf('=== 组合 %s 处理完成 [%d/%d] ===\n', compositionName, i, totalCompositions);

% 显示整体完成信息
fprintf('\n🎉 所有组合处理完成！共处理了 %d 个组合\n', totalCompositions);
```

## 优势

1. **清晰的进度指示**：随时知道当前处理进度
2. **层次化显示**：组合和组件两个层次的进度
3. **完成状态**：每个组合和整体完成状态
4. **易于监控**：便于长时间运行的进度监控
5. **错误定位**：出现错误时能快速定位到具体组合和组件

## 适用场景

- 大量组合和组件的处理
- 长时间运行的批处理任务
- 需要监控进度的自动化脚本
- 调试和问题排查
