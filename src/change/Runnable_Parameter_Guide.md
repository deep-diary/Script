# Runnable 参数使用指南

## 新增的 Runnable 参数功能

`changeAutosarDict`函数现在支持直接传入 Runnable 名称，而不需要通过规则替换生成。

## 参数说明

### Runnable 参数

- **类型**: 字符串、字符串数组或字符串元胞数组
- **默认值**: 空字符串（使用规则替换）
- **功能**: 直接指定 Runnable 名称，避免规则替换

## 使用方式

### 1. 使用规则替换（默认方式）

```matlab
% 不提供Runnable参数，使用规则替换
changeAutosarDict('PrkgClimaActvMgrArch');
changeAutosarDict('PrkgClimaActvMgrArch', 'RunnablePeriod', 0.1);
```

**规则替换逻辑**：

- 去掉模型后缀（如'Arch'）
- 将'\_Step'改为'\_Runnable'
- 例如：`PrkgClimaActvMgrArch_Step` → `PrkgClimaActvMgr_Runnable`

### 2. 单个 Runnable 名称

```matlab
% 提供单个Runnable名称
changeAutosarDict('PrkgClimaActvMgrArch', 'Runnable', 'CustomRunnableName');
changeAutosarDict('PrkgClimaActvMgrArch', 'Runnable', 'CCMLoad_DiagRunnable');
```

### 3. 多个 Runnable 名称

```matlab
% 提供多个Runnable名称（元胞数组）
changeAutosarDict('PrkgClimaActvMgrArch', 'Runnable', {'InitRunnable', 'MainRunnable'});
changeAutosarDict('PrkgClimaActvMgrArch', 'Runnable', {'CCMSysServ_Init', 'CCMLoad_DiagRunnable'});
```

### 4. 组合使用

```matlab
% 与其他参数组合使用
changeAutosarDict('PrkgClimaActvMgrArch', ...
    'Runnable', 'CustomRunnableName', ...
    'RunnablePeriod', 0.05, ...
    'Suffix', 'Model');
```

## 处理逻辑

### 智能处理机制

1. **空参数**: 使用规则替换
2. **指定了 Runnable 参数**:
   - 如果 Runnable 包含 `_Step`，将其替换为指定的名称
   - 如果 Runnable 不包含 `_Step`，使用规则替换
3. **多个名称**:
   - 按顺序分配给包含 `_Step` 的 Runnable
   - 如果名称数量不足，剩余的使用规则替换

### 示例场景

#### 场景 1：包含 \_Step 的 Runnable

```matlab
% 原始Runnable: PrkgClimaActvMgrArch_Step
changeAutosarDict('PrkgClimaActvMgrArch', 'Runnable', 'CCMLoad_DiagRunnable');
% 结果：PrkgClimaActvMgrArch_Step → CCMLoad_DiagRunnable
```

#### 场景 2：不包含 \_Step 的 Runnable

```matlab
% 原始Runnable: PrkgClimaActvMgrArch_Init (不包含_Step)
changeAutosarDict('PrkgClimaActvMgrArch', 'Runnable', 'CustomName');
% 结果：PrkgClimaActvMgrArch_Init → PrkgClimaActvMgr_Init (使用规则替换)
```

#### 场景 3：多个 Runnable，部分包含 \_Step

```matlab
% 原始Runnables:
% - PrkgClimaActvMgrArch_Init (不包含_Step)
% - PrkgClimaActvMgrArch_Step (包含_Step)
changeAutosarDict('PrkgClimaActvMgrArch', 'Runnable', 'CCMLoad_DiagRunnable');
% 结果：
% - PrkgClimaActvMgrArch_Init → PrkgClimaActvMgr_Init (规则替换)
% - PrkgClimaActvMgrArch_Step → CCMLoad_DiagRunnable (指定名称)
```

#### 场景 4：多个包含 \_Step 的 Runnable

```matlab
% 原始Runnables:
% - PrkgClimaActvMgrArch_Step1
% - PrkgClimaActvMgrArch_Step2
changeAutosarDict('PrkgClimaActvMgrArch', 'Runnable', {'MainRunnable', 'DiagRunnable'});
% 结果：
% - PrkgClimaActvMgrArch_Step1 → MainRunnable
% - PrkgClimaActvMgrArch_Step2 → DiagRunnable
```

## 实际应用示例

### 从 Excel 任务列表生成

```matlab
% 从Excel读取的任务名称
taskNames = {'CCMLoad_DiagRunnable', 'CCMAdcM_Runnable', 'CCMBattery_Runnable'};

% 为每个组件生成代码
for i = 1:length(componentNames)
    componentName = componentNames{i};
    if i <= length(taskNames)
        % 使用指定的任务名称
        changeAutosarDict(componentName, 'Runnable', taskNames{i}, 'RunnablePeriod', runnablePeriod);
    else
        % 使用规则替换
        changeAutosarDict(componentName, 'RunnablePeriod', runnablePeriod);
    end
end
```

### 批量处理不同组件

```matlab
% 不同组件的Runnable配置
runnableConfigs = {
    'CCMLoadArch', {'CCMLoad_DiagRunnable'};
    'CCMAdcMArch', {'CCMAdcM_Runnable'};
    'CCMBatteryArch', {'CCMBattery_Runnable'};
    'CCMMotorArch', {'CCMMotor_Runnable'};
};

for i = 1:size(runnableConfigs, 1)
    modelName = runnableConfigs{i, 1};
    runnableName = runnableConfigs{i, 2};

    changeAutosarDict(modelName, 'Runnable', runnableName, 'RunnablePeriod', 0.01);
end
```

## 输出示例

### 使用规则替换

```
Runnable 1: PrkgClimaActvMgr_Init
Runnable 2: PrkgClimaActvMgr_Runnable
已修改 2 个Runnable属性
```

### 使用指定名称

```
Runnable 1: CCMLoad_DiagRunnable
已修改 1 个Runnable属性
```

### 混合使用

```
Runnable 1: CustomInitName
Runnable 2: CustomMainName
Runnable 3: PrkgClimaActvMgr_Runnable
已修改 3 个Runnable属性
```

## 优势

1. **灵活性**: 支持直接指定 Runnable 名称
2. **兼容性**: 保持向后兼容，默认使用规则替换
3. **智能处理**: 自动处理不同数量的 Runnable
4. **易于使用**: 简单的参数接口
5. **批量处理**: 支持批量指定多个 Runnable 名称

## 注意事项

1. **名称数量**: 确保提供的名称数量与模型中的 Runnable 数量匹配
2. **名称格式**: Runnable 名称应符合 AUTOSAR 命名规范
3. **向后兼容**: 不提供 Runnable 参数时，行为与之前版本完全一致
4. **错误处理**: 如果名称数量不足，会自动使用规则替换补充
