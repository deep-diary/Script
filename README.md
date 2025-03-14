# MATLAB Simulink 自动化工具集

## 项目简介

这是一个用于自动化处理 MATLAB Simulink 模型的工具集，主要用于简化模型的创建、配置和管理工作。

## 功能模块

### 创建模块 (create)

#### 1. createSubMod - 批量创建子模型

根据 Excel 模板批量创建并布局 Simulink 子模型。

## 使用前提

1. MATLAB/Simulink 环境
2. 使用前需要打开目标 Simulink 模型
3. Excel 模板需要包含必要的列（用于 createSubMod）

## 注意事项

1. 使用 createSubMod 前：
   - 确保 Excel 模板包含 FunctionID、RequirementID 和 ModelName 三列
   - 需要先打开目标 Simulink 模型
2. 使用 changeModSizeGcs 前：
   - 确保当前页面有需要调整的子模型
   - 建议在执行布局操作前保存当前工作
3. 部分功能可能需要特定的 Simulink 版本支持

## 作者

Blue.ge

## 更新日志

- 2023.10.20: 完成 changeModSizeGcs 模块优化
  - 添加参数验证
  - 优化布局算法
  - 改进代码结构
- 2025.03.12: 完成 createSubMod 模块优化
  - 支持自定义布局参数
  - 添加多行布局功能
  - 完善错误处理

## 许可说明

仅供内部使用

### 2. createPorts - 端口创建

用于创建模型端口。（待完善）

### 3. createStoreMem - 存储器创建

用于创建数据存储器。（待完善）

### 修改模块 (change)

#### 1. changeModSizeGcs - 模型大小与布局调整

调整当前 Simulink 页面中子模型的大小和布局。

##### 功能特点：

- 批量调整子模型大小
- 支持多行自动布局
- 自动整理连线
- 可自定义布局参数

##### 使用示例：

```matlab
% 基本使用
changeModSizeGcs();

% 指定行数布局
changeModSizeGcs('rows', 2);

% 完整配置示例
changeModSizeGcs('wid', 500, ...     % 模块宽度
                'rows', 2, ...       % 布局行数
                'xStp', 300, ...     % 水平间距
                'yStp', 100);        % 垂直间距
```

## 目录结构

```
blue script/
├── create/
│   ├── createSubMod.m     # 批量创建子模型
│   ├── createPorts.m      # 端口创建
│   └── createStoreMem.m   # 存储器创建
└── change/
    └── changeModSizeGcs.m # 模型大小调整
```
