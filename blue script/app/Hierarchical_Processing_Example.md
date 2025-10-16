# 层次化处理示例

## 新的代码结构

现在代码采用层次化遍历方式，按组合 → 组件的顺序处理，具有更好的层次感和逻辑性。

## 处理流程

### 1. 组合层次遍历

```matlab
% 遍历架构模型中的所有组合
compositions = find(archModel, 'Composition');

for i = 1:length(compositions)
    composition = compositions(i);
    compositionName = get(composition, 'Name');

    % 从组合名称中提取时间周期信息
    periodStr = strrep(compositionName, 'Composition_', '');
    periodStr = strrep(periodStr, 'ms', '');
    period = str2double(periodStr);

    % 计算RunnablePeriod（秒）
    runnablePeriod = period / 1000.0;
```

### 2. 组件层次处理

```matlab
    % 获取组合内的所有组件
    components = find(composition, 'Component');

    for j = 1:length(components)
        component = components(j);
        componentName = get(component, 'Name');

        % 生成模型和代码
        createModel(component, modelPath);
        changeAutosarDict(componentName, 'RunnablePeriod', runnablePeriod);
    end
```

## 输出示例

```
开始按组合层次处理 3 个组合...

=== 处理组合: Composition_5ms (周期: 5ms, RunnablePeriod: 0.005s) ===
  组合内包含 1 个组件

  --- 处理组件: CCMLoad_DiagArch ---
    ✓ 生成AUTOSAR模型: CCMLoad_DiagArch
    ✓ 生成AUTOSAR代码: CCMLoad_DiagArch (周期: 0.005s)
=== 组合 Composition_5ms 处理完成 ===

=== 处理组合: Composition_10ms (周期: 10ms, RunnablePeriod: 0.010s) ===
  组合内包含 3 个组件

  --- 处理组件: CCMAdcMArch ---
    ✓ 生成AUTOSAR模型: CCMAdcMArch
    ✓ 生成AUTOSAR代码: CCMAdcMArch (周期: 0.010s)

  --- 处理组件: CCMBatteryArch ---
    ✓ 生成AUTOSAR模型: CCMBatteryArch
    ✓ 生成AUTOSAR代码: CCMBatteryArch (周期: 0.010s)

  --- 处理组件: CCMMotorArch ---
    ✓ 生成AUTOSAR模型: CCMMotorArch
    ✓ 生成AUTOSAR代码: CCMMotorArch (周期: 0.010s)
=== 组合 Composition_10ms 处理完成 ===

=== 处理组合: Composition_1000ms (周期: 1000ms, RunnablePeriod: 1.000s) ===
  组合内包含 2 个组件

  --- 处理组件: AirPmCtrlArch ---
    ✓ 生成AUTOSAR模型: AirPmCtrlArch
    ✓ 生成AUTOSAR代码: AirPmCtrlArch (周期: 1.000s)

  --- 处理组件: AmbTFilMgrArch ---
    ✓ 生成AUTOSAR模型: AmbTFilMgrArch
    ✓ 生成AUTOSAR代码: AmbTFilMgrArch (周期: 1.000s)
=== 组合 Composition_1000ms 处理完成 ===
```

## 优势

### 1. 层次清晰

- 按组合 → 组件的层次结构处理
- 每个组合的处理过程独立且完整
- 清晰的视觉层次和缩进

### 2. 时间信息传递

- 从组合名称自动提取时间周期
- 正确计算 RunnablePeriod（毫秒转秒）
- 每个组件都获得正确的调度时间

### 3. 错误处理

- 模型创建失败时跳过代码生成
- 每个操作都有独立的错误处理
- 单个组件失败不影响其他组件

### 4. 状态反馈

- 使用符号（✓、-、✗）表示操作状态
- 详细的进度信息
- 清晰的分组和完成标记

## 时间周期映射

| 组合名称           | 周期(ms) | RunnablePeriod(s) | 说明         |
| ------------------ | -------- | ----------------- | ------------ |
| Composition_1ms    | 1        | 0.001             | 1 毫秒周期   |
| Composition_5ms    | 5        | 0.005             | 5 毫秒周期   |
| Composition_10ms   | 10       | 0.010             | 10 毫秒周期  |
| Composition_100ms  | 100      | 0.100             | 100 毫秒周期 |
| Composition_1000ms | 1000     | 1.000             | 1 秒周期     |

## 代码改进

1. **移除冗余变量**：不再需要存储`allComponentObjects`和`allComponentNames`
2. **直接查找**：从架构模型中直接查找组合和组件
3. **自动时间计算**：从组合名称自动提取和计算时间周期
4. **层次化处理**：按逻辑层次组织代码结构
