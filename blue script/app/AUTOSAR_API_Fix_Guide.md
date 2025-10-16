# AUTOSAR API 修复指南

## 问题描述

在使用 AUTOSAR API 时遇到了以下错误：

```
错误使用 autosar.arch.Composition/find
输入参数太多。

出错 autosar.arch.Composition/getPropertyGroups
```

## 问题分析

### 错误的 API 使用方式

```matlab
% 错误：使用find函数
compositions = find(archModel, 'Composition');
components = find(composition, 'Component');

% 错误：使用get函数
compositionName = get(composition, 'Name');
componentName = get(component, 'Name');
```

### 正确的 API 使用方式

```matlab
% 正确：直接属性访问
compositions = archModel.Compositions;
components = composition.Components;

% 正确：直接属性访问
compositionName = composition.Name;
componentName = component.Name;
```

## 修复方案

### 1. 组合访问修复

```matlab
% 修复前
compositions = find(archModel, 'Composition');
for i = 1:length(compositions)
    composition = compositions(i);
    compositionName = get(composition, 'Name');
end

% 修复后
compositions = archModel.Compositions;
for i = 1:length(compositions)
    composition = compositions(i);
    compositionName = composition.Name;
end
```

### 2. 组件访问修复

```matlab
% 修复前
components = find(composition, 'Component');
for j = 1:length(components)
    component = components(j);
    componentName = get(component, 'Name');
end

% 修复后
components = composition.Components;
for j = 1:length(components)
    component = components(j);
    componentName = component.Name;
end
```

## AUTOSAR API 正确使用方式

### 架构模型属性

```matlab
archModel = autosar.arch.loadModel('ModelName');

% 访问各种属性
compositions = archModel.Compositions;    % 组合列表
components = archModel.Components;        % 组件列表
ports = archModel.Ports;                  % 端口列表
connectors = archModel.Connectors;        % 连接器列表
interfaces = archModel.Interfaces;        % 接口列表
```

### 组合属性

```matlab
composition = archModel.Compositions(1);

% 访问组合属性
name = composition.Name;                  % 组合名称
components = composition.Components;      % 组合内的组件
```

### 组件属性

```matlab
component = composition.Components(1);

% 访问组件属性
name = component.Name;                    % 组件名称
kind = component.Kind;                    % 组件类型
```

## 测试脚本

创建了 `test_autosar_api.m` 脚本来验证 API 使用方式：

```matlab
%% 测试AUTOSAR API使用方式
modelName = 'CcmArch';
archModel = autosar.arch.loadModel(modelName);

% 显示模型信息
fprintf('模型名称: %s\n', archModel.Name);
fprintf('组合数量: %d\n', length(archModel.Compositions));

% 遍历组合
compositions = archModel.Compositions;
for i = 1:length(compositions)
    composition = compositions(i);
    fprintf('组合: %s\n', composition.Name);

    % 遍历组件
    components = composition.Components;
    for j = 1:length(components)
        component = components(j);
        fprintf('  组件: %s\n', component.Name);
    end
end
```

## 关键要点

1. **直接属性访问**：使用 `object.Property` 而不是 `get(object, 'Property')`
2. **避免 find 函数**：使用 `archModel.Compositions` 而不是 `find(archModel, 'Composition')`
3. **对象层次结构**：`archModel.Compositions[i].Components[j]`
4. **类型安全**：确保对象类型正确后再访问属性

## 修复后的代码结构

```matlab
%% 按组合层次遍历，生成模型和代码
compositions = archModel.Compositions;
fprintf('\n开始按组合层次处理 %d 个组合...\n', length(compositions));

for i = 1:length(compositions)
    composition = compositions(i);
    compositionName = composition.Name;

    % 从组合名称中提取时间周期信息
    periodStr = strrep(compositionName, 'Composition_', '');
    periodStr = strrep(periodStr, 'ms', '');
    period = str2double(periodStr);
    runnablePeriod = period / 1000.0;

    % 获取组合内的所有组件
    components = composition.Components;

    for j = 1:length(components)
        component = components(j);
        componentName = component.Name;

        % 生成模型和代码
        createModel(component, modelPath);
        changeAutosarDict(componentName, 'RunnablePeriod', runnablePeriod);
    end
end
```

## 验证方法

运行测试脚本验证修复：

```matlab
run('test_autosar_api.m');
```

这将显示所有可用的属性和正确的访问方式。
