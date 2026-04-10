# Create 脚本使用说明

本文件夹包含了用于创建 Simulink 模型各种组件和结构的脚本工具集。这些脚本主要用于模型创建、端口管理、信号处理、数据字典生成、测试用例创建等功能。

## 脚本分类

### 1. 模型信号管理类

#### createModSig.m

**功能**: 对模型输入输出端口的信号线进行命名和配置

- **输入参数**:
  - `pathMd`: 模型路径
  - `varargin`: 可选参数对
    - `'skipTrig'`: 是否跳过触发器端口（默认 true）
    - `'isEnableIn'`: 是否启用输入端口处理（默认 true）
    - `'isEnableOut'`: 是否启用输出端口处理（默认 true）
    - `'resoveValue'`: 是否解析为信号对象（默认 false）
    - `'logValue'`: 是否启用数据记录（默认 false）
    - `'testValue'`: 是否启用测试点（默认 false）
    - `'dispName'`: 是否显示信号名称（默认 true）
    - `'truncateSignal'`: 是否截断 AUTOSAR 信号名（默认 false）
- **示例**:
  ```matlab
  createModSig(gcs,'skipTrig',true,'isEnableIn',true,'isEnableOut',true)
  createModSig(gcs,'resoveValue',false,'logValue',false,'testValue',false,'truncateSignal',true)
  ```

#### createSigOut.m

**功能**: 创建内部信号到基础模块的输出信号转换

- **输入参数**:
  - `varargin`: 可选参数
    - `'template'`: Excel 模板文件名（默认'Template.xlsx'）
    - `'sheetNames'`: 工作表名称列表（默认{'IF_OutportsCommon','IF_OutportsDiag','IF_Outports2F'}）
    - `'posBase'`: 基础位置坐标（默认[0,0]）
    - `'posMod'`: 模块位置坐标（默认[10500,0,11000,5000]）
    - `'step'`: 信号间隔步长（默认 30）
- **输出参数**:
  - `nums`: 成功创建的信号数量
- **示例**:
  ```matlab
  nums = createSigOut()
  nums = createSigOut('posBase', [1000,0], 'step', 40)
  ```

### 2. 数据字典管理类

#### createSlddSigGee.m

**功能**: 获取模型根目录下输入输出端口，按模板格式，保存到 Excel 表格

- **输入参数**:
  - `ModelName`: 模型名称（字符向量或字符串标量）
- **可选参数**:
  - `'overwrite'`: 是否覆盖现有文件（默认 true）
  - `'verbose'`: 是否显示详细信息（默认 true）
  - `'outputDir'`: 输出目录路径（默认模型所在目录）
  - `'ignoreInput'`: 是否忽略输入端口（默认 true）
  - `'ignoreOutput'`: 是否忽略输出端口（默认 false）
  - `'truncateSignal'`: 是否截断信号名（默认 false）
- **输出参数**:
  - `sigTable`: 生成的信号数据表格
  - `outputFile`: 输出文件路径
- **示例**:
  ```matlab
  [sigTable, outputFile] = createSlddSigGee('PrkgClimaEgyMgr')
  [sigTable, outputFile] = createSlddSigGee('PrkgClimaEgyMgr', 'verbose', false)
  ```

#### createSldd.m

**功能**: 创建或打开模型的数据字典

- **输入参数**:
  - `modelName`: 模型名称
- **可选参数**:
  - `'slddPath'`: 数据字典路径（默认为空）
- **输出参数**:
  - `dictionaryObj`: 数据字典对象
- **示例**:
  ```matlab
  dictionaryObj = createSldd('TmComprCtrl')
  dictionaryObj = createSldd('TmComprCtrl', 'slddPath', 'path/to/dictionary.sldd')
  ```

#### createModSlddFromArxml.m

**功能**: 从 ARXML 文件批量导入组件并生成 SLDD 数据字典

- **输入参数**:
  - `arxml_name`: ARXML 文件名（字符串，必填）
- **示例**:
  ```matlab
  createModSlddFromArxml('CDM ARMXL CCM SMART 25N1 V3C 20250619.arxml')
  ```

### 3. 端口管理类

#### createModPorts.m

**功能**: 为未连线的子模型端口自动添加输入输出端口，并将其自动连线

- **输入参数**:
  - `path`: 模型路径
- **可选参数**:
  - `'mode'`: 端口模式（'inport'/'outport'/'both'，默认'both'）
  - `'isDelSuffix'`: 是否删除后缀（默认 true）
  - `'suffixStr'`: 后缀字符串（默认''）
  - `'findType'`: 查找类型（'base'/'interface'/'None'，默认'base'）
  - `'add'`: 添加模块类型（'None'或 blockType，默认'None'）
  - `'enFirstTrig'`: 是否启用第一个触发器（默认 false）
- **输出参数**:
  - `createdInport`: 已创建的输入端口列表
  - `createdOutport`: 已创建的输出端口列表
- **示例**:
  ```matlab
  [createdInport, createdOutport] = createModPorts(gcb)
  [createdInport, createdOutport] = createModPorts(gcb,'mode','inport')
  ```

#### createPortsGoto.m

**功能**: 创建输入输出端口及其相连接的 Goto/From 模块

- **可选参数**:
  - `'posIn'`: 输入端口起始位置（默认[-500 0]）
  - `'posOut'`: 输出端口起始位置（默认[500 0]）
  - `'step'`: 端口间距（默认 30）
  - `'gotoLength'`: Goto/From 模块宽度（默认 180）
  - `'inList'`: 输入信号列表（默认{}）
  - `'outList'`: 输出信号列表（默认{}）
  - `'NAStr'`: 忽略的字段标识（默认'NA'）
  - `'mode'`: 命名模式（'pre'/'tail'/'keep'，默认'keep'）
  - `'fromTemplate'`: 是否使用模板文件（默认 false）
  - `'template'`: 模板文件名（默认'Template'）
  - `'sheet'`: 模板工作表名（默认'Signals'）
- **输出参数**:
  - `numInputPorts`: 创建的输入端口数量
  - `numOutputPorts`: 创建的输出端口数量
- **示例**:
  ```matlab
  [in, out] = createPortsGoto('fromTemplate', true)
  [in, out] = createPortsGoto('inList', {'a','b'}, 'outList', {'c','d'})
  ```

#### createPortsBySheet.m

**功能**: 从一行元组包中提取属性并创建端口

- **输入参数**:
  - `path`: 端口所在的路径（字符串）
  - `pos`: 端口在模型中的位置（[x y width height]格式的数组）
  - `data`: 包含端口属性的表格或结构体
- **可选参数**:
  - `'type'`: 端口类型（'Inport'/'Outport'，默认'Inport'）
- **输出参数**:
  - `bk`: 创建的端口句柄
- **示例**:
  ```matlab
  result = createPortsBySheet('model/Subsystem', [100 100 30 30], dataTable)
  result = createPortsBySheet('model/Subsystem', [200 100 30 30], dataTable, 'type', 'Outport')
  ```

### 4. Goto/From 管理类

#### createGotoUseless.m

**功能**: 为无用的 Goto 和 From 模块创建匹配模块

- **可选参数**:
  - `'posGotoBase'`: Goto 模块的起始位置（默认[2500,0]）
  - `'posFromBase'`: From 模块的起始位置（默认[2000,0]）
  - `'step'`: 模块之间的垂直间距（默认 30）
  - `'createGoto'`: 是否创建 Goto 模块（默认 true）
  - `'createFrom'`: 是否创建 From 模块（默认 true）
  - `'path'`: 目标路径（默认 gcs）
  - `'type'`: 模块类型（默认'constant'）
- **输出参数**:
  - `numGoto`: 创建的 Goto 模块数量
  - `numFrom`: 创建的 From 模块数量
- **示例**:
  ```matlab
  [numGoto, numFrom] = createGotoUseless()
  [numGoto, numFrom] = createGotoUseless('posGotoBase', [14000,0], 'step', 40)
  ```

#### createModGoto.m

**功能**: 给定一个模型或者子模型，创建对应的 goto 或者 from 模块，并进行连线

- **输入参数**:
  - `path`: 模型路径
- **可选参数**:
  - `'mode'`: 模式（'inport'/'outport'/'both'，默认'both'）
  - `'isCreateMatch'`: 是否创建匹配模块（默认 false）
  - `'suffixStr'`: 后缀字符串（默认'NoTail'）
  - `'inList'`: 输入信号列表（默认{}）
  - `'outList'`: 输出信号列表（默认{}）
  - `'bkHalfLength'`: 模块半长度（默认 25）
- **输出参数**:
  - `createdInput`: 创建的输入模块列表
  - `createdOutput`: 创建的输出模块列表
- **示例**:
  ```matlab
  createModGoto(gcb, 'mode','both')
  createModGoto(gcb, 'mode','both','suffixStr','In')
  ```

### 5. 数据存储管理类

#### createDataStore.m

**功能**: 根据 Excel 模板批量创建 Data Store Memory

- **可选参数**:
  - `'step'`: 模块之间的垂直间距（默认 40）
  - `'posIn'`: 起始位置坐标（默认[0, 0]）
  - `'path'`: 模型路径（默认 gcs）
  - `'template'`: Excel 模板文件名（默认'Template.xlsx'）
  - `'sheet'`: Excel 工作表名称（默认'DataStore'）
  - `'createType'`: 创建的类型（默认{'Memory'}）
  - `'createEnum'`: 是否创建枚举（默认 true）
  - `'gap'`: 模块间距（默认 300）
  - `'EnableIndexing'`: 是否启用索引（默认'on'）
  - `'IndexMode'`: 索引模式（默认'Zero-based'）
- **输出参数**:
  - `cnt`: 创建的模块数量
- **示例**:
  ```matlab
  cnt = createDataStore('template', 'TemplateCDD.xlsx','createType', {'Memory'})
  cnt = createDataStore('template', 'Template.xlsx', 'createType', {'Memory', 'Write', 'Read', 'Display', 'MultiPortSwitch'})
  ```

### 6. 子模型信息管理类

#### createSubmodInfo.m

**功能**: 创建包含子模型信息的注释模块并返回收集的信息

- **可选参数**:
  - `'path'`: 目标系统路径（默认 gcs）
  - `'position'`: 注释模块位置（默认自动计算）
  - `'fontSize'`: 字体大小（默认 12）
  - `'fgColor'`: 前景颜色（默认'blue'）
  - `'bgColor'`: 背景颜色（默认[0.9 0.9 0.9]）
  - `'includeCnt'`: 是否包含序号（默认 false）
  - `'createNote'`: 是否创建注释模块（默认 true）
  - `'annotationName'`: 注释模块名称（默认'SubmodInfo'）
  - `'userData'`: 用户数据（默认'modInfo'）
  - `'DCMfileName'`: DCM 文件名（默认'HY11_PCMU_Tm_OTA3_V6070519_All.DCM'）
  - `'ExcelfileName'`: Excel 文件名（默认'TmSovCtrl_DD_XCU.xlsx'）
  - `'SearchDepth'`: 搜索深度（默认 1）
- **输出参数**:
  - `portsInNames`: 输入端口名称列表
  - `portsOutNames`: 输出端口名称列表
  - `calibParams`: 标定量列表
  - `infoText`: 信息文本
- **示例**:
  ```matlab
  [inPortNames, outPortNames, params] = createSubmodInfo()
  [inPortNames, outPortNames, params] = createSubmodInfo('DCMfileName','HY11_PCMU_Tm_OTA3_V6050327_All.DCM')
  ```

### 7. 总线管理类

#### createBusFromExcel.m

**功能**: 从 Excel 模板批量创建 Simulink.Bus 对象

- **可选参数**:
  - `'template'`: Excel 文件名（默认'Template'）
  - `'sheet'`: 工作表名（默认'BusDefinition'）
- **输出参数**:
  - `createdBuses`: 创建的 Bus 对象列表
- **示例**:
  ```matlab
  createdBuses = createBusFromExcel()
  createdBuses = createBusFromExcel('template', 'TemplateCCMSensor.xlsx')
  ```

#### createEnumFromExcel.m

**功能**: 从 Excel 模板批量创建 Simulink 枚举类型

- **可选参数**:
  - `'template'`: Excel 文件名（默认'Template'）
  - `'sheet'`: 工作表名（默认'EnumDefinition'）
- **输出参数**:
  - `createdEnums`: 创建的枚举类型列表
- **示例**:
  ```matlab
  createdEnums = createEnumFromExcel()
  ```

### 8. 调试和测试类

#### createDebugIn.m

**功能**: 为输出端口创建 debug 及对应的输入模块

- **输入参数**:
  - `path`: 模型路径
- **可选参数**:
  - `'step'`: 端口间距（默认 30）
  - `'suffixStr'`: 后缀字符串（默认'DbgOut'）
- **输出参数**:
  - `portsOutNames`: 创建的端口名称
- **示例**:
  ```matlab
  portsOutNames = createDebugIn(gcs)
  ```

#### createHarness.m

**功能**: 为模块创建测试用例

- **输入参数**:
  - `path`: 模型路径
- **可选参数**:
  - `'lev1'`: 第一层级模块名称（默认{'SM123','SM456'}）
  - `'lev2'`: 第二层级模块名称（默认{{'SM1','SM2'},{'SM4','SM5','SM6'}}）
  - `'inName'`: 输入端口名称（默认{{'SM11','SM12'},{'SM14','SM15','SM16'}}）
  - `'inValue'`: 输入值（默认{{{10, 5},{8, 3, 2}},{6, 4},{4, 5, 8}}）
  - `'rstName'`: 结果端口名称（默认{{'SM1','SM2'},{'SM4','SM5','SM6'}}）
  - `'rstValue'`: 结果值（默认{{{10,20},{10,20,20}},{{10,20},{10,20,20}}}）
  - `'mask'`: 掩码值（默认 0）
  - `'lastStep'`: 上一步操作（默认'Initialize'）
  - `'nextStep'`: 下一步操作（默认'None'）
  - `'tolerance'`: 容差值（默认 0.01）
  - `'waitTime'`: 等待时间（默认 0.05）
  - `'usingAllPorts'`: 是否使用所有端口（默认 false）
  - `'logValue'`: 是否记录值（默认 true）
- **示例**:
  ```matlab
  createHarness(gcb)
  createHarness(gcb, 'lev1', {'SM123'}, 'tolerance', 0.02)
  ```

### 9. 代码生成类

#### createCodeSubMod.m

**功能**: 创建子模型代码包

- **输入参数**:
  - `mdName`: 模型名称
- **可选参数**:
  - `'type'`: 控制器类型（'VCU'/'PCMU'/'XCU'，默认'VCU'）
- **示例**:
  ```matlab
  createCodeSubMod('TmSovCtrl')
  createCodeSubMod('TmSovCtrl', 'type', 'PCMU')
  ```

### 10. 控制结构类

#### createSwitchCase.m

**功能**: 为当前路径下的模块创建 Switch Case 结构

- **可选参数**:
  - `'caseList'`: Case 的输入值（默认'{1,2,3,[4 5 6]}'）
  - `'caseIn'`: Case 输入信号（默认'Demo'）
  - `'caseNames'`: Case 具体名称列表（默认压缩机控制信号组）
  - `'sigNames'`: Switch 的输出信号（默认{'demo1','demo2'}）
  - `'actionPosYShift'`: 每个 case 的垂直偏移值（默认 50）
  - `'caseGap'`: Switch case 的间距（默认 30）
  - `'caseStp'`: Switch case 间距放大系数（默认 1）
  - `'resovleSig'`: 是否需要解析 merge 后的信号（默认 true）
- **示例**:
  ```matlab
  createSwitchCase()
  createSwitchCase('caseIn', 'Demo', 'caseList', '{1,2,3,[4 5 6]}', 'caseNames', {'A','B','C','D'}, 'sigNames', {'demo1','demo2'})
  ```

#### createMerge.m

**功能**: 为当前路径下的使能子系统或 switch case 输出信号自动生成 Merge 模块

- **可选参数**:
  - `'sigList'`: 需要创建 Merge 的信号列表（默认压缩机控制信号组）
  - `'resovleSig'`: 是否需要解析 merge 的信号（默认 true）
  - `'pos'`: 位置坐标（默认[]）
- **示例**:
  ```matlab
  createMerge()
  createMerge('sigList', {'rTmComprCtrl_B_RdyToChange'})
  createMerge('sigList', {'rTmComprCtrl_B_RdyToChange'}, 'resovleSig', false)
  ```

### 11. 集成管理类

#### createIntegration.m

**功能**: 创建并配置 Thermal PCMU 集成环境

- **输入参数**:
  - `softversion`: 软件版本号（字符串）
- **可选参数**:
  - `'STAGE'`: 项目阶段（默认'23N7'）
  - `'INTERFACE_VERISON'`: 接口版本（默认'V136'）
  - `'CAL_VERSION'`: 标定版本（默认'666666'）
  - `'DCM_NAME'`: DCM 文件名（默认'HY11_PCMU_Tm_OTA3_V6060416_All.DCM'）
  - `'SLDD_NAME'`: SLDD 文件名（默认'PCMU_SLDD_All.xlsx'）
  - `'ARCH_NAME'`: 架构模型名称（默认'TmSwArch'）
- **示例**:
  ```matlab
  createIntegration('7070416')
  createIntegration('7070416', 'STAGE', '23N7', 'INTERFACE_VERISON', 'V136')
  ```

### 12. 其他工具类

#### createFromBasedOnUselessGoto.m

**功能**: 基于无用的 Goto 模块创建 From 模块

- **输入参数**:
  - `varargin`: 可选参数
    - `'path'`: 目标路径（默认 gcs）
    - `'posBase'`: 基础位置（默认[2000,0]）
    - `'step'`: 间距（默认 30）
    - `'type'`: 模块类型（默认'constant'）
- **输出参数**:
  - `numFrom`: 创建的 From 模块数量
- **示例**:
  ```matlab
  numFrom = createFromBasedOnUselessGoto()
  ```

#### createGotoBasedOnUselessFrom.m

**功能**: 基于无用的 From 模块创建 Goto 模块

- **输入参数**:
  - `varargin`: 可选参数
    - `'path'`: 目标路径（默认 gcs）
    - `'posBase'`: 基础位置（默认[2500,0]）
    - `'step'`: 间距（默认 30）
    - `'type'`: 模块类型（默认'constant'）
- **输出参数**:
  - `numGoto`: 创建的 Goto 模块数量
- **示例**:
  ```matlab
  numGoto = createGotoBasedOnUselessFrom()
  ```

## 使用注意事项

1. **模型状态**: 使用前请确保目标 Simulink 模型已打开
2. **备份**: 重要操作前请备份模型文件
3. **参数验证**: 请确保输入参数符合函数要求
4. **错误处理**: 函数包含错误处理机制，会显示警告信息
5. **依赖关系**: 某些函数依赖其他工具函数，请确保相关函数在路径中
6. **Excel 模板**: 使用 Excel 相关功能时，请确保模板文件格式正确
7. **权限**: 确保有足够的权限访问相关文件和目录

## 作者信息

- **作者**: Blue.ge
- **版本**: 1.0
- **日期**: 2023-2024

## 更新日志

- 2024-08-04: 更新信号输出转换功能
- 2024-07-04: 完善数据存储管理功能
- 2024-06-28: 添加数据字典管理功能
- 2024-05-17: 添加 Switch Case 结构创建功能
- 2024-03-29: 完善测试用例创建功能
- 2023-09-28: 初始版本发布
