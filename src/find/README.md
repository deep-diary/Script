# Find 脚本使用说明

本文件夹包含了用于查找和分析 Simulink 模型各种组件的脚本工具集。这些脚本主要用于模型分析、数据字典管理、参数查找、DCM 文件处理、信号分析等功能。

## 脚本分类

### 1. 数据字典管理类

#### findSlddLoadGee.m

**功能**: 导入 sldd 表格中的 Signal 和 Parameter 数据到工作空间

- **输入参数**:
  - `path`: sldd 文件路径（字符串）
  - `varargin`: 可选参数
    - `'SheetName'`: 工作表名称（默认'Signal'）
    - `'Verbose'`: 是否显示详细信息（默认 true）
- **输出参数**:
  - `sigTable`: Signal 数据表格
  - `paraTable`: Parameter 数据表格
  - `loadedCnt`: 成功导入的数据条数
- **示例**:
  ```matlab
  [sigTable, paraTable, loadedCnt] = findSlddLoadGee('PrkgClimaEgyMgr_Element_Management_AddPort.xlsm')
  ```

#### findSlddCombine.m

**功能**: 合并所有子模型的 sldd 文件

- **输入参数**:
  - `subPath`: 子模型路径（字符串）
  - `fileName`: 输出文件名（字符串）
- **输出参数**:
  - `outPath`: 合并后的 excel 路径（字符串）
- **示例**:
  ```matlab
  outPath = findSlddCombine('SubModel', 'PCMU_SLDD_All.xlsx')
  ```

#### findSlddSigPortData.m

**功能**: 构建端口信号表格数据，用于保存到 Excel

- **输入参数**:
  - `ModelName`: 模型名称（字符串）
  - `portsPath`: 模型中所有端口的路径（元胞数组）
  - `varargin`: 可选参数
    - `'project'`: 项目类型，可选值'XCU', 'PCMU', 'VCU', 'CUSTOM'（默认'XCU'）
- **输出参数**:
  - `Data`: 满足 sldd 格式的端口信号数据矩阵
- **示例**:
  ```matlab
  Data = findSlddSigPortData('ModelName', portsPath, 'project', 'XCU')
  ```

#### findSlddSig.m

**功能**: 获取模型的信号数据并保存到 Excel 文件中

- **输入参数**:
  - `pathMd`: 模型路径（字符串）
  - `varargin`: 可选参数
    - `'overwrite'`: 是否覆盖现有文件（默认 false）
    - `'projectList'`: 项目列表，可选值{'PCMU','VCU','XCU'}的子集（默认{'PCMU','VCU','XCU'}）
- **输出参数**:
  - `fSlddList`: 保存的文件路径列表（元胞数组）
  - `DataList`: 信号数据列表（元胞数组）
- **示例**:
  ```matlab
  [fSlddList, DataList] = findSlddSig('TmComprCtrlDev', 'projectList', {'XCU'})
  ```

#### findSlddParamData.m

**功能**: 构建参数表格数据，用于保存到 Excel

- **输入参数**:
  - `ModelName`: 模型名称（字符串）
  - `parameters`: 模型中所有参数的列表（元胞数组）
  - `varargin`: 可选参数
    - `'project'`: 项目类型，可选值'XCU', 'PCMU', 'VCU', 'CUSTOM'（默认'XCU'）
- **输出参数**:
  - `Data`: 满足 sldd 格式的参数数据矩阵
- **示例**:
  ```matlab
  Data = findSlddParamData('ModelName', parameters, 'project', 'XCU')
  ```

#### findSlddLoad.m

**功能**: 导入 SLDD 数据到工作空间

- **输入参数**:
  - `path`: SLDD 文件路径或模型名称（字符串）
  - `varargin`: 可选参数
    - `'mode'`: 模式选择，'PCMU'或'VCU'，默认为'PCMU'
    - `'exclude'`: 需要排除的模块类型，默认为空
- **输出参数**:
  - `sigCnts`: 成功导入的信号数量
  - `paramCnts`: 成功导入的参数数量
- **示例**:
  ```matlab
  [sigCnts, paramCnts] = findSlddLoad('TmComprCtrl_DD_PCMU.xlsx')
  [sigCnts, paramCnts] = findSlddLoad('TmComprCtrl', 'mode', 'PCMU')
  ```

### 2. 端口和模块查找类

#### findModPorts.m

**功能**: 查找模型中的输入输出端口

- **输入参数**:
  - `pathMd`: 模型路径或句柄（字符串或数值）
  - `varargin`: 可选参数
    - `'getType'`: 返回端口的属性类型，默认值'Path'
    - `'FiltUnconnected'`: 是否只返回未连接的端口（默认 false）
- **输出参数**:
  - `ModelName`: 模型名称（字符串）
  - `PortsIn`: 输入端口列表（元胞数组）
  - `PortsOut`: 输出端口列表（元胞数组）
  - `PortsSpecial`: 特殊端口信息（变量）
- **示例**:
  ```matlab
  [name, inPorts, outPorts] = findModPorts(gcb, 'getType', 'Path')
  [name, inPorts, outPorts] = findModPorts(gcs, 'FiltUnconnected', true)
  ```

#### findValidPath.m

**功能**: 根据输入路径类型，返回有效的路径，便于 find_system 函数使用

- **输入参数**:
  - `path`: 模型或子系统的路径（字符串）
- **输出参数**:
  - `ModelName`: 模型名称（字符串）
  - `validPath`: 可以用于 find_system 的有效路径（字符串）
- **示例**:
  ```matlab
  [ModelName, validPath] = findValidPath(path)
  ```

#### findUselessFrom.m

**功能**: 找到没有用的 From 模块

- **输入参数**:
  - `varargin`: 可选参数
    - `'path'`: 模型路径（默认 gcs）
- **输出参数**:
  - `uselessFrom`: 无用 from 的路径（元胞数组）
- **示例**:
  ```matlab
  uselessFrom = findUselessFrom()
  uselessFrom = findUselessFrom('path', gcs)
  ```

#### findUselessGoto.m

**功能**: 找到没有用的 Goto 模块

- **输入参数**:
  - `varargin`: 可选参数
    - `'path'`: 模型路径（默认 gcs）
- **输出参数**:
  - `uselessGoto`: 无用 goto 的路径（元胞数组）
- **示例**:
  ```matlab
  uselessGoto = findUselessGoto()
  ```

### 3. DCM 文件处理类

#### findDCMValuesChanges.m

**功能**: 比较两个 DCM 文件中参数值的差异

- **输入参数**:
  - `filepath1`: 基准 DCM 文件的完整路径（字符串）
  - `filepath2`: 比较 DCM 文件的完整路径（字符串）
  - `varargin`: 可选参数
    - `'Tolerance'`: 浮点数比较容差（默认 1e-6）
    - `'ShowDetails'`: 是否显示详细变化信息（默认 true）
    - `'OnlyCommon'`: 是否只比较共有参数（默认 true）
    - `'IgnoreType'`: 要忽略的参数类型（默认{}）
- **输出参数**:
  - `changes`: 包含参数值变化的结构体数组
- **示例**:
  ```matlab
  diff = findDCMValuesChanges('HY11_PCMU_Tm_OTA3_V6050327_All.DCM', 'HY11_PCMU_Tm_OTA3_V6060416_All.DCM')
  ```

#### findDCMParam.m

**功能**: 解析 DCM 文件并提取参数

- **输入参数**:
  - `filepath`: DCM 文件的完整路径（字符串）
- **输出参数**:
  - `paramsArr`: 包含 5 种参数类型的元胞数组
- **示例**:
  ```matlab
  params = findDCMParam('HY11_PCMU_Tm_OTA3_V6030303_Change.DCM')
  constValues = params{1}  % 获取所有常量
  maps = params{5}         % 获取所有二维表
  ```

### 4. 参数查找类

#### findCalibParams.m

**功能**: 查找模型中的标定量

- **输入参数**:
  - `path`: 模型路径或句柄（字符串或数值）
  - `varargin`: 可选参数
    - `'SearchDepth'`: 搜索深度，默认值 1
    - `'SkipMask'`: 是否跳过 Mask 子系统内部（默认 true）
    - `'SkipLib'`: 是否跳过库链接（默认 true）
- **输出参数**:
  - `calibParams`: 找到的标定量列表（元胞数组）
- **示例**:
  ```matlab
  params = findCalibParams(gcs)
  params = findCalibParams(gcs, 'SearchDepth', 'all')
  ```

#### findMaskParams.m

**功能**: 查找 Mask 模块中的参数

- **输入参数**:
  - `blockPath`: 模块路径或句柄（字符串或数值）
  - `varargin`: 可选参数
    - `'IncludeValues'`: 是否包含参数值中的变量（默认 true）
    - `'FilterEditable'`: 是否只返回可编辑参数（默认 true）
    - `'FilterTunable'`: 是否只返回可调参数（默认 true）
    - `'FilterEnabled'`: 是否只返回启用的参数（默认 true）
    - `'FilterVisible'`: 是否只返回可见参数（默认 true）
    - `'FilterEvaluate'`: 是否只返回可求值参数（默认 true）
- **输出参数**:
  - `maskParams`: 找到的 Mask 参数列表（元胞数组）
- **示例**:
  ```matlab
  params = findMaskParams(gcb)
  params = findMaskParams(gcs, 'FilterEditable', false)
  ```

### 5. 名称解析类

#### findNameMd.m

**功能**: 从模型名称中解析出模型名、功能 ID 和需求 ID

- **输入参数**:
  - `Name`: 模型完整名称（字符串）
  - `varargin`: 可选参数
    - `'FunPrefix'`: 功能 ID 前缀（默认'Fun'）
    - `'ReqPrefix'`: 需求 ID 前缀（默认'Req'）
    - `'IDPrefix'`: 单 ID 前缀（默认'ID'）
- **输出参数**:
  - `ModelName`: 模型名称（字符串）
  - `FunctionID`: 功能 ID（数值）
  - `RequirementID`: 需求 ID（数值）
- **示例**:
  ```matlab
  [modelName, funID, reqID] = findNameMd('Fun666666_Req26245_DemoSub1')
  [modelName, funID, reqID] = findNameMd('ID26245_DemoSub1')
  ```

### 6. 信号线管理类

#### findLines.m

**功能**: 查找模型中的信号线

- **输入参数**:
  - `path`: 模型路径（字符串）
- **输出参数**:
  - `lines`: 信号线句柄列表（数组）
- **示例**:
  ```matlab
  lines = findLines(gcs)
  ```

#### findLineName.m

**功能**: 查找信号线的名称

- **输入参数**:
  - `path`: 模型路径（字符串）
- **输出参数**:
  - `lineNames`: 信号线名称列表（元胞数组）
- **示例**:
  ```matlab
  lineNames = findLineName(gcs)
  ```

### 7. 其他工具类

#### findParameters.m

**功能**: 查找模型中的参数

- **输入参数**:
  - `path`: 模型路径（字符串）
- **输出参数**:
  - `parameters`: 参数列表（元胞数组）
- **示例**:
  ```matlab
  parameters = findParameters(gcs)
  ```

#### findEnumTypes.m

**功能**: 查找模型中的枚举类型

- **输入参数**:
  - `path`: 模型路径（字符串）
- **输出参数**:
  - `enumTypes`: 枚举类型列表（元胞数组）
- **示例**:
  ```matlab
  enumTypes = findEnumTypes(gcs)
  ```

#### findAlgebraicLoops.m

**功能**: 查找模型中的代数环

- **输入参数**:
  - `path`: 模型路径（字符串）
- **输出参数**:
  - `loops`: 代数环信息（结构体）
- **示例**:
  ```matlab
  loops = findAlgebraicLoops(gcs)
  ```

## 使用注意事项

1. **路径参数**: 大多数函数支持相对路径和绝对路径，建议使用绝对路径以确保准确性
2. **模型加载**: 使用前确保相关模型已加载到工作空间
3. **权限要求**: 某些函数需要模型编辑权限
4. **版本兼容**: 部分函数需要特定 MATLAB 版本支持
5. **错误处理**: 建议在调用函数时使用 try-catch 语句进行错误处理

## 作者信息

- **作者**: Blue.ge
- **版本**: 1.0
- **日期**: 2024 年
- **更新日志**:
  - 2024-01-01: 初始版本发布
  - 2024-02-01: 添加 DCM 文件处理功能
  - 2024-03-01: 优化参数查找算法
  - 2024-04-01: 增加信号线管理功能

## 相关文件

- `change/`: 模型修改相关脚本
- `create/`: 模型创建相关脚本
- `utilities/`: 通用工具函数
