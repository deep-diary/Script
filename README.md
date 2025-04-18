# MATLAB Simulink 自动化工具集

## 项目简介

这是一个用于自动化处理 MATLAB Simulink 模型的工具集，主要用于简化模型的创建、配置、查找和管理工作，提高开发效率。

## 功能模块

### 创建模块 (create)

#### 1. createSubMod - 批量创建子模型

根据 Excel 模板批量创建并布局 Simulink 子模型。

##### 使用示例:

```matlab
% 基本使用
createSubMod('模板.xlsx');

% 指定位置和大小
createSubMod('模板.xlsx', 'xIni', 100, 'yIni', 100, 'wid', 200, 'hei', 100);
```

#### 2. createSubmodInfo - 创建子模型信息注释

创建包含子模型信息（端口、标定量等）的注释模块，便于文档化。

##### 使用示例:

```matlab
% 基本使用
[portsIn, portsOut, calibParams] = createSubmodInfo();

% 自定义样式
createSubmodInfo('fontSize', 12, 'fgColor', 'blue', 'bgColor', [0.9 0.9 0.9]);
```

#### 3. createPorts - 端口创建

用于创建模型输入输出端口。

#### 4. createPortsGotoUpdate - 端口和 Goto 更新

更新模型中的端口和 Goto/From 模块。

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

#### 2. changeModSize - 调整模型大小

根据模型类型自动调整单个模型的大小。

### 查找模块 (find)

#### 1. findCalibParams - 查找模型中的标定量

智能查找模型中的各种标定量，支持多种查找方式。

##### 使用示例：

```matlab
% 查找当前系统中的标定量
params = findCalibParams(gcs);

% 查找所有层级的标定量
params = findCalibParams(gcs, 'SearchDepth', 'all');
```

#### 2. findCalibParamsTraditional - 传统方法查找标定量

使用传统方法查找模型中各种类型模块的标定量。

```matlab
% 基本使用
params = findCalibParamsTraditional(gcs);

% 查找所有层级
params = findCalibParamsTraditional(gcs, 'SearchDepth', 'all');
```

#### 3. findMaskParams - 查找 Mask 参数

查找 Mask 模块中参数值引用的标定量。

```matlab
% 查找选中模块的Mask参数
params = findMaskParams(gcb);

% 自定义过滤条件
params = findMaskParams(gcb, 'FilterEditable', true);
```

#### 4. findModPorts - 查找模块端口

查找模块的输入输出端口。

#### 5. findAnnotation - 查找注释

查找模型中的注释模块。

#### 6. findDCMParam - 解析 DCM 文件参数

解析 DCM 标定文件中的各类参数（常量、轴、表格等）。

##### 使用示例：

```matlab
% 解析 DCM 文件
params = findDCMParam('calibration.DCM');

% 获取不同类型的参数
constants = params{1};  % 常量
axes = params{2};       % 轴定义
tables = params{4};     % 一维表
maps = params{5};       % 二维表
```

#### 7. findDCMNames - 提取 DCM 文件参数名称

提取 DCM 标定文件中的所有参数名称。

##### 使用示例：

```matlab
% 获取所有参数名称
names = findDCMNames('calibration.DCM');
```

#### 8. findDCMNamesChanges - 比较 DCM 文件差异

比较两个 DCM 文件，找出参数的添加、删除和修改。

##### 使用示例：

```matlab
% 比较两个版本的 DCM 文件
diff = findDCMNamesChanges('oldVersion.DCM', 'newVersion.DCM');

% 查看添加和删除的参数
added = diff.added;
removed = diff.removed;
```

#### 9. findDCMValuesChanges - 比较 DCM 文件中参数值变化

比较两个 DCM 文件中标定量的具体值变化，找出所有有变化的参数及其变化情况。

##### 使用示例：

```matlab
% 基本比较
changes = findDCMValuesChanges('oldVersion.DCM', 'newVersion.DCM');

% 自定义比较设置
changes = findDCMValuesChanges('old.DCM', 'new.DCM', ...
                              'Tolerance', 1e-4, ...
                              'ShowDetails', true, ...
                              'OnlyCommon', true);

% 忽略某些类型的参数
changes = findDCMValuesChanges('old.DCM', 'new.DCM', ...
                              'IgnoreType', {'GRUPPENKENNFELD'});
```

## 使用前提

1. MATLAB/Simulink 环境（推荐 R2016b 或更高版本）
2. 使用前需要打开目标 Simulink 模型
3. Excel 模板需要包含必要的列（用于 createSubMod）

## 注意事项

1. 使用 createSubMod 前：
   - 确保 Excel 模板包含 FunctionID、RequirementID 和 ModelName 三列
   - 需要先打开目标 Simulink 模型
2. 使用 changeModSizeGcs 前：
   - 确保当前页面有需要调整的子模型
   - 建议在执行布局操作前保存当前工作
3. 使用 findCalibParams 等查找函数时：
   - 对于更高级的查找功能，需要使用 R2016b 或更高版本
   - 可以通过 SearchDepth 参数控制查找深度
4. 使用 DCM 相关函数时：
   - 确保 DCM 文件格式符合标准
   - 对于大型 DCM 文件，处理可能需要较长时间

## 目录结构

```
blue script/
├── create/                    # 创建相关功能
│   ├── createSubMod.m         # 批量创建子模型
│   ├── createSubmodInfo.m     # 创建子模型信息注释
│   ├── createPorts.m          # 端口创建
│   ├── createStoreMem.m       # 存储器创建
│   └── createPortsGotoUpdate.m# 端口和Goto更新
├── change/                    # 修改相关功能
│   ├── changeModSizeGcs.m     # 当前系统模型大小调整
│   └── changeModSize.m        # 单个模型大小调整
└── find/                      # 查找相关功能
    ├── findCalibParams.m      # 查找标定量(主函数)
    ├── findCalibParamsTraditional.m # 传统方法查找标定量
    ├── findMaskParams.m       # 查找Mask参数
    ├── findModPorts.m         # 查找模块端口
    ├── findNameMd.m           # 查找模块名称
    ├── findNameMdOut.m        # 查找输出模块名称
    ├── findAnnotation.m       # 查找注释
    ├── findDCMParam.m         # 解析DCM文件参数
    ├── findDCMNames.m         # 提取DCM文件参数名称
    ├── findDCMNamesChanges.m  # 比较DCM文件参数差异
    └── findDCMValuesChanges.m # 比较DCM文件参数值变化
```

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
- 2025.03.15: 完成查找功能增强
  - 增加 findMaskParams 函数
  - 优化 findCalibParams 性能
  - 改进 findAnnotation 功能
  - 修复各种函数中的错误处理
- 2025.03.20: 添加 DCM 文件处理功能
  - 新增 findDCMParam 函数解析 DCM 文件
  - 新增 findDCMNames 函数提取参数名称
  - 新增 findDCMNamesChanges 函数比较 DCM 文件差异
  - 优化 DCM 解析性能和稳定性
- 2025.03.25: 增强 DCM 文件处理功能
  - 新增 findDCMValuesChanges 函数，用于比较 DCM 文件中参数值的具体变化
  - 改进 DCM 解析函数的错误处理和性能
  - 完善 DCM 相关函数的文档

## 许可说明

仅供内部使用
