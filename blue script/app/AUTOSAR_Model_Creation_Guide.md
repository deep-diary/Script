# AUTOSAR 模型创建指南

## 问题描述

之前的代码存在一个重要问题：创建的是普通的 Simulink 模型，而不是 AUTOSAR 架构模型。这会导致后续的关联和代码生成出现问题。

## 问题分析

### 原始错误方式

```matlab
% 错误：创建普通Simulink模型
new_system(componentName);
save_system(componentName, modelPath);
close_system(componentName);
```

### 正确方式

```matlab
% 正确：使用AUTOSAR API创建架构模型
createModel(component, modelPath);
```

## 修复方案

### 1. 保存组件对象引用

```matlab
% 存储所有创建的组件对象和名称
allComponentObjects = {};
allComponentNames = {};

% 在创建组件时保存引用
components = addComponent(composition, componentNames, 'Kind', 'Application');
allComponentObjects = [allComponentObjects, components];
allComponentNames = [allComponentNames, componentNames];
```

### 2. 使用正确的 API 创建模型

```matlab
% 使用保存的组件对象引用
for i = 1:length(allComponentObjects)
    component = allComponentObjects{i};
    componentName = allComponentNames{i};
    modelPath = fullfile(subModelDir, [componentName '.slx']);

    % 使用AUTOSAR API创建实现模型
    createModel(component, modelPath);
end
```

## 关键差异

| 方面     | 错误方式           | 正确方式                       |
| -------- | ------------------ | ------------------------------ |
| 模型类型 | 普通 Simulink 模型 | AUTOSAR 架构模型               |
| 创建方法 | `new_system()`     | `createModel(component, path)` |
| 组件关联 | 无关联             | 自动关联到架构组件             |
| 接口继承 | 不支持             | 支持 AUTOSAR 接口              |
| 代码生成 | 可能失败           | 正确生成 AUTOSAR 代码          |

## 工作流程

1. **创建架构模型** → `autosar.arch.createModel()`
2. **创建组合** → `addComposition()`
3. **创建组件** → `addComponent()`
4. **保存组件引用** → 存储对象和名称
5. **生成实现模型** → `createModel(component, path)`
6. **生成代码** → `changeAutosarDict()`

## 优势

- ✅ 正确的 AUTOSAR 架构模型
- ✅ 自动组件关联
- ✅ 支持接口继承
- ✅ 正确的代码生成
- ✅ 完整的 AUTOSAR 工作流

## 注意事项

1. 必须保存组件对象引用，不能只保存名称
2. 使用`createModel(component, path)`而不是`new_system()`
3. 确保组件在创建后立即保存引用
4. 模型路径应该使用`.slx`扩展名

## 示例输出

```
开始生成 4 个组件的AUTOSAR实现模型...
  生成AUTOSAR模型: CCMLoad_DiagArch
  生成AUTOSAR模型: CCMAdcMArch
  生成AUTOSAR模型: CCMBatteryArch
  生成AUTOSAR模型: CCMMotorArch

开始为 4 个组件生成AUTOSAR代码...
  生成代码: CCMLoad_DiagArch
  生成代码: CCMAdcMArch
  生成代码: CCMBatteryArch
  生成代码: CCMMotorArch
```
