# Delete 脚本使用说明

本文件夹包含了用于删除 Simulink 模型各种组件的脚本工具集。这些脚本主要用于模型清理、端口管理、信号线处理、AUTOSAR 配置删除等功能。

## 脚本分类

### 1. 信号线管理类

#### delLinesAttr.m

**功能**: 删除当前路径下的信号线属性

- **输入参数**:
  - `path`: 模型路径（字符串）
  - `varargin`: 可选参数
    - `'Name'`: 信号线名称（字符串，默认''）
    - `'resoveValue'`: 是否解析为信号对象（逻辑值，默认 false）
    - `'logValue'`: 是否启用数据记录（逻辑值，默认 false）
    - `'testValue'`: 是否启用测试点（逻辑值，默认 false）
    - `'attr'`: 要删除的属性类型，可选'resoveValue'、'logValue'、'testValue'（默认'logValue'）
    - `'FindAll'`: 是否查找所有信号线（逻辑值，默认 false）
- **输出参数**: 无
- **示例**:
  ```matlab
  delLinesAttr(gcs, 'attr', 'logValue', 'FindAll', false)
  delLinesAttr(gcs, 'resoveValue', true, 'logValue', true, 'testValue', true)
  ```

#### delUselessLine.m

**功能**: 删除模型中未连接的信号线

- **输入参数**:
  - `path`: 模型路径（字符串）
- **输出参数**: 无
- **示例**:
  ```matlab
  delUselessLine(gcs)
  ```

#### delSigOnLine.m

**功能**: 对模型输入输出端口的信号线进行解析删除

- **输入参数**:
  - `pathMd`: 模型路径（字符串）
  - `varargin`: 可选参数
    - `'isEnableIn'`: 是否启用输入端口处理（逻辑值，默认 true）
    - `'isEnableOut'`: 是否启用输出端口处理（逻辑值，默认 true）
    - `'isPartial'`: 是否部分删除（逻辑值，默认 false）
    - `'sigList'`: 信号列表（元胞数组，默认{}）
- **输出参数**: 无
- **示例**:
  ```matlab
  delSigOnLine(gcs)
  delSigOnLine(gcs, 'isEnableIn', true, 'isEnableOut', false)
  delSigOnLine(gcs, 'isPartial', true, 'sigList', {'signal1', 'signal2'})
  ```

#### delSigOnLineAll.m

**功能**: 删掉被引用模型的所有的信号解析

- **输入参数**:
  - `varargin`: 可选参数
    - `'mode'`: 处理模式，可选'inport'、'outport'、'both'（默认'both'）
- **输出参数**: 无
- **示例**:
  ```matlab
  delSigOnLineAll()
  delSigOnLineAll('mode', 'inport')
  delSigOnLineAll('mode', 'outport')
  delSigOnLineAll('mode', 'both')
  ```

### 2. 端口管理类

#### delUselessPort.m

**功能**: 删除模型中无用的输入输出端口及其相连模块

- **输入参数**:
  - `path`: 模型路径，可以是 gcs 或 bdroot（字符串）
  - `varargin`: 可选参数
    - `'UselessInBlock'`: 要删除的输入端口连接的模块类型（字符串，默认'Terminator'）
    - `'UselessOutBlock'`: 要删除的输出端口连接的模块类型（字符串，默认'Ground'）
- **输出参数**:
  - `validInports`: 保留的有效输入端口列表（元胞数组）
  - `validOutports`: 保留的有效输出端口列表（元胞数组）
- **示例**:
  ```matlab
  [validInports, validOutports] = delUselessPort(gcs)
  [validInports, validOutports] = delUselessPort(gcs, 'UselessInBlock', 'Terminator')
  ```

#### DeletePorts.m

**功能**: 从 excel 模板中提取信息并删除输入输出端口

- **输入参数**:
  - `template`: 路径下的 excel 文件名（字符串）
  - `model`: 模型名称（字符串）
  - `varargin`: 可选参数
    - `'inRecognName'`: 输入端口识别名称（字符串，默认'Inport'）
    - `'outRecognName'`: 输出端口识别名称（字符串，默认'Outport'）
- **输出参数**:
  - `inCnt`: 已删除的输入端口数量（数值）
  - `outCnt`: 已删除的输出端口数量（数值）
- **示例**:
  ```matlab
  [inCnt, outCnt] = DeletePorts('Template_PortsCreate', 'new_model')
  [inCnt, outCnt] = DeletePorts('Template_PortsCreate', 'new_model', 'inRecognName', 'Inport')
  ```

### 3. 模型清理类

#### delGcsAll.m

**功能**: 删除本层内所有东西

- **输入参数**: 无
- **输出参数**: 无
- **示例**:
  ```matlab
  delGcsAll()
  ```

### 4. 目录清理类

#### delGitFolders.m

**功能**: 删除指定目录下所有包含.git 文件夹的目录，优化工程路径加载性能

- **输入参数**:
  - `rootPath`: 要搜索的根目录路径（字符串，必需）
  - `varargin`: 可选参数
    - `'confirm'`: 是否在删除前确认（逻辑值，默认 true）
    - `'verbose'`: 是否显示详细信息（逻辑值，默认 true）
    - `'dryrun'`: 是否只显示将要删除的目录而不实际删除（逻辑值，默认 false）
- **输出参数**: 无
- **示例**:
  ```matlab
  delGitFolders('D:\MyProject')
  delGitFolders('D:\MyProject', 'confirm', false, 'verbose', true)
  delGitFolders('D:\MyProject', 'dryrun', true)  % 只显示不删除
  ```

### 5. AUTOSAR 配置类

#### delAutosar.m

**功能**: 删除 AUTOSAR 配置

- **输入参数**: 无
- **输出参数**: 无
- **示例**:
  ```matlab
  delAutosar()
  ```

## 使用注意事项

1. **备份模型**: 在执行删除操作前，建议先备份模型文件
2. **权限要求**: 某些函数需要模型编辑权限
3. **路径参数**: 建议使用绝对路径以确保准确性
4. **信号线属性**: 删除信号线属性前，请确认不会影响模型功能
5. **端口删除**: 删除端口前，请确认端口确实无用且不会影响模型连接
6. **AUTOSAR 配置**: 删除 AUTOSAR 配置前，请确认不再需要 AUTOSAR 代码生成

## 功能特点

### 信号线管理

- 支持删除信号线的各种属性（解析、记录、测试点）
- 自动清理未连接的信号线
- 支持批量处理多个模型引用

### 端口管理

- 智能识别无用端口
- 支持自定义无用端口类型
- 保留有效端口信息

### 模型清理

- 一键清理当前层所有内容
- 自动清理无用连线
- 支持 AUTOSAR 配置删除

## 作者信息

- **作者**: Blue.ge
- **版本**: 1.0
- **日期**: 2024 年
- **更新日志**:
  - 2024-01-01: 初始版本发布
  - 2024-02-01: 添加端口管理功能
  - 2024-03-01: 优化信号线处理算法
  - 2024-04-01: 增加 AUTOSAR 配置删除功能

## 相关文件

- `change/`: 模型修改相关脚本
- `create/`: 模型创建相关脚本
- `find/`: 模型查找相关脚本
- `utilities/`: 通用工具函数

## 常见问题

### Q: 如何安全地删除信号线属性？

A: 建议先使用`findLinesAttr`函数查看当前信号线属性，确认要删除的属性后再执行删除操作。

### Q: 删除端口后如何恢复？

A: 删除操作不可逆，建议在执行前备份模型文件。

### Q: 如何批量处理多个模型？

A: 可以使用`delSigOnLineAll`函数批量处理所有模型引用的信号线。

### Q: 删除 AUTOSAR 配置后如何重新配置？

A: 可以使用`create`文件夹中的相关脚本重新创建 AUTOSAR 配置。
