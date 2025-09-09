# Change 脚本使用说明

本文件夹包含了用于修改 Simulink 模型各种属性的脚本工具集。这些脚本主要用于模型配置、端口管理、信号处理、数据字典更新等功能。

## 脚本分类

### 1. 端口管理类

#### changePortAttr.m

**功能**: 修改端口模块的属性

- **输入参数**:
  - `path`: 模块路径（可以是模块路径、'gcs'或'bdroot'）
  - `varargin`: 名称-值对参数
    - `'Type'`: 端口类型（'in'/'out'/'both'，默认'both'）
    - `'wid'`: 模块宽度
    - `'height'`: 模块高度
    - 其他属性名-值对
- **示例**:
  ```matlab
  changePortAttr(gcs, 'ShowName', 'off')
  changePortAttr(gcs, 'Type', 'in', 'wid', 30, 'height', 14)
  ```

#### changeModPortType.m

**功能**: 根据信号名称自动更改端口数据类型

- **输入参数**:
  - `path`: 模型路径（字符串）
- **输出参数**:
  - `portsChanged`: 已更改的端口名称列表（元胞数组）
- **示例**:
  ```matlab
  portsChanged = changeModPortType(gcs)
  ```

#### changeModPortName.m

**功能**: 批量改变模型的端口名称

- **输入参数**:
  - `path`: 模型路径（字符串）
  - `old`: 需要替换的旧名称（字符串）
  - `new`: 替换后的新名称（字符串）
  - `varargin`: 可选参数
    - `'changeIn'`: 是否改变输入端口名称（默认 true）
    - `'changeOut'`: 是否改变输出端口名称（默认 true）
- **输出参数**:
  - `portsChanged`: 已更改的端口名称列表（元胞数组）
- **示例**:
  ```matlab
  portsChanged = changeModPortName(gcb, 'TmComprCtrl', 'SM123')
  ```

### 2. 信号线管理类

#### changeLinesSelectedAttr.m

**功能**: 删除当前路径下的信号线属性

- **输入参数**:
  - `path`: 模型路径（字符串）
  - `varargin`: 可选参数
    - `'Name'`: 信号线名称
    - `'resoveValue'`: 设置解析属性（默认 false）
    - `'logValue'`: 设置记录属性（默认 false）
    - `'testValue'`: 设置测试属性（默认 false）
    - `'FindAll'`: 是否查找所有信号线（默认 false）
    - `'deleteName'`: 是否删除名称（默认 true）
- **示例**:
  ```matlab
  changeLinesSelectedAttr(gcs, 'logValue', true)
  ```

#### changeLinesPortAttr.m

**功能**: 改变当前路径下的信号线属性

- **输入参数**:
  - `path`: 模型路径（字符串）
  - `varargin`: 可选参数
    - `'resoveValue'`: 设置解析属性（默认 false）
    - `'logValue'`: 设置记录属性（默认 false）
    - `'testValue'`: 设置测试属性（默认 false）
    - `'Name'`: 信号线名称
    - `'FindAll'`: 是否查找所有信号线（默认 false）
    - `'enableIn'`: 是否处理输入端口（默认 false）
    - `'enableOut'`: 是否处理输出端口（默认 false）
- **示例**:
  ```matlab
  changeLinesPortAttr(gcs, 'resoveValue', true, 'logValue', true)
  ```

### 3. 模块管理类

#### changeModName.m

**功能**: 为模型增加层级关系数字

- **输入参数**:
  - `pathMd`: 模型路径（字符串）
  - `varargin`: 可选参数
    - `'prefix'`: 编号前缀（字符串，默认为空）
    - `'UseLastName'`: 是否只使用模型名称中最后一个下划线后的部分（默认 false）
- **示例**:
  ```matlab
  changeModName('myModel')
  changeModName('myModel', 'prefix', 'MOD_', 'UseLastName', true)
  ```

#### changeModSize.m

**功能**: 根据端口数量调整 Simulink 模型的大小

- **输入参数**:
  - `pathMd`: 模型路径或句柄（字符串或数值）
  - `varargin`: 可选参数
    - `'wid'`: 模型最小宽度（默认 400）
    - `'minHeight'`: 模型最小高度（默认 60）
    - `'portStep'`: 端口间距（默认 30）
- **示例**:
  ```matlab
  changeModSize(gcb)
  changeModSize(gcb, 'wid', 600, 'minHeight', 100)
  ```

#### changeModSizeGcs.m

**功能**: 调整当前 Simulink 页面中子模型的大小和布局

- **输入参数**:
  - `varargin`: 可选参数
    - `'wid'`: 子模型宽度（默认 400）
    - `'xStp'`: 水平间距（默认 800）
    - `'yStp'`: 垂直间距（默认 60）
    - `'rows'`: 布局行数（默认 0，不进行行列布局）
- **示例**:
  ```matlab
  changeModSizeGcs()
  changeModSizeGcs('rows', 2, 'wid', 500)
  ```

#### changeModPos.m

**功能**: 改变模型到特定的位置

- **输入参数**:
  - `pathMd`: 模型路径
  - `pos`: 新位置起始点 [x y]
- **输出参数**:
  - `posNew`: 模型新位置
- **示例**:
  ```matlab
  posNew = changeModPos(gcb, [1500 0])
  ```

### 4. Goto/From 管理类

#### changeGotoAttr.m

**功能**: 修改 Goto/From 模块的属性

- **输入参数**:
  - `path`: 模块路径（可以是模块路径、'gcs'或'bdroot'）
  - `varargin`: 名称-值对参数
    - `'Type'`: 模块类型（'goto'/'from'/'both'，默认'both'）
    - `'wid'`: 模块宽度
    - `'height'`: 模块高度
    - 其他属性名-值对
- **示例**:
  ```matlab
  changeGotoAttr(gcs, 'ShowName', 'off')
  changeGotoAttr(gcs, 'Type', 'goto', 'wid', 30, 'height', 14)
  ```

#### changeGotoSize.m

**功能**: 根据 gotoTag 改变 goto 尺寸

- **输入参数**:
  - `pathMd`: 模型路径或句柄（字符串或数值）
  - `varargin`: 可选参数
    - `'wid'`: goto 高度（默认 14）
    - `'font'`: 每个字符占据的像素（默认 7）
- **示例**:
  ```matlab
  changeGotoSize(gcb)
  changeGotoSize(gcs, 'wid', 20, 'font', 8)
  ```

### 5. 端口位置管理类

#### changePortPos.m

**功能**: 将输入输出端口排整齐

- **输入参数**:
  - `varargin`: 可选参数
    - `'stp'`: 端口间距（默认 30）
    - `'isEnableIn'`: 是否处理输入端口（默认 true）
    - `'isEnableOut'`: 是否处理输出端口（默认 true）
- **示例**:
  ```matlab
  changePortPos('isEnableIn', true, 'isEnableOut', true)
  ```

#### changePortBlockPos.m

**功能**: 改变输入输出端口及其对应连线 block 的位置

- **输入参数**:
  - `portPath`: 端口路径（字符串）
  - `newPos`: 新位置的起始坐标 [x y]
  - `varargin`: 可选参数
    - `'portSize'`: 端口模块尺寸 [width height]（默认保持原尺寸）
    - `'blockSize'`: 连接模块尺寸 [width height]（默认保持原尺寸）
- **输出参数**:
  - `hPort`: 端口句柄
  - `hLine`: 对应线的句柄
  - `hBlock`: 连接的模块句柄
- **示例**:
  ```matlab
  [hPort, hLine, hBlock] = changePortBlockPos(gcb, [-2825 200])
  ```

#### changePortBlockPosAll.m

**功能**: 重新整理当前模型所有的输入输出端口及其对应连线 block 的位置

- **输入参数**:
  - `path`: 目标系统路径（字符串，默认 gcs）
  - `varargin`: 可选参数
    - `'newPosin'`: 新输入端口位置 [x y]（默认[0 0]）
    - `'newPosout'`: 新输出端口位置 [x y]（默认[1000 0]）
    - `'portSize'`: 端口模块尺寸 [width height]（默认[30 14]）
    - `'blockSize'`: 连接模块尺寸 [width height]（默认[150 14]）
- **示例**:
  ```matlab
  changePortBlockPosAll(gcs)
  changePortBlockPosAll(gcs, 'portSize', [30 14], 'blockSize', [30 14])
  ```

### 6. 信号管理类

#### changeSigType.m

**功能**: 更改指定信号的端口数据类型

- **输入参数**:
  - `sigName`: 信号名称（字符串）
  - `type`: 目标数据类型（字符串）
  - `varargin`: 可选参数
    - `'allLev'`: 是否在全局范围内搜索（默认 true）
    - `'fromSigName'`: 是否根据信号名称自动判断类型（默认 true）
- **示例**:
  ```matlab
  changeSigType('rTmComprCtrl_n_s32CompRpmReqModeOut')
  changeSigType('rTmComprCtrl_n_s32CompRpmReqModeOut', 'uint16', 'allLev', true)
  ```

#### changeSigName.m

**功能**: 改变端口的信号类型

- **输入参数**:
  - `template`: 模板路径（字符串）
  - `varargin`: 可选参数
    - `'all'`: 是否在全局进行改变（默认 true）
    - `'sheet'`: 表格名称（'Signals'/'Parameters'/'All'，默认'All'）
    - `'keepPrefix'`: 是否保持前缀（默认 true）
- **示例**:
  ```matlab
  changeSigName('Template_ChangeName.xlsx', 'keepPrefix', false)
  ```

### 7. 数据字典管理类

#### changeSlddInitValueByName.m

**功能**: 根据信号名称，改变 sldd 初始值

- **输入参数**:
  - `slddTable`: sldd 表格
  - `name`: 信号名（字符串）
  - `value`: 信号值
- **输出参数**:
  - `updatedTable`: 更新后的表格
- **示例**:
  ```matlab
  updatedTable = changeSlddInitValueByName(slddTable, 'signalName', 100)
  ```

#### changeSlddInitValue.m

**功能**: 根据信号名称，改变 sldd 初始值

- **输入参数**:
  - `slddTable`: sldd 表格
  - `paramArrs`: 参数数组
  - `varargin`: 可选参数
    - `'types'`: 参数类型（默认{'const','axis','wert','tab','map'}）
- **输出参数**:
  - `updatedTable`: 更新后的表格
- **示例**:
  ```matlab
  updatedTable = changeSlddInitValue(slddTable, paramArrs, 'type', {'const'})
  ```

#### changeSlddTableByInitValue.m

**功能**: 根据 SLDD 初始值更新 Excel 表格

- **输入参数**:
  - `slddPath`: SLDD Excel 文件路径（字符串）
- **示例**:
  ```matlab
  changeSlddTableByInitValue('TmRefriVlvCtrl_DD_PCMU.xlsx')
  ```

#### changeSlddInitValueByTable.m

**功能**: 根据 Excel 表格更新 SLDD 数据字典的初始值

- **输入参数**:
  - `slddPath`: SLDD Excel 文件路径（字符串）
- **示例**:
  ```matlab
  changeSlddInitValueByTable('TmRefriVlvCtrl_DD_PCMU.xlsx')
  ```

#### changeArchSldd.m

**功能**: 根据 DCM 数据更新 SLDD 文件中的参数值

- **输入参数**:
  - `dcmPath`: DCM 文件路径（字符串）
  - `slddPath`: SLDD 文件路径（字符串）
  - `varargin`: 可选参数
    - `'Sheet'`: Excel 表格名称（默认'Parameters'）
- **输出参数**:
  - `outPath`: 更新后的 SLDD 文件路径（字符串）
- **示例**:
  ```matlab
  outPath = changeArchSldd('HY11_PCMU_Tm_OTA3_V6050327_All.DCM', 'PCMU_SLDD_All.xlsx')
  ```

### 8. 配置管理类

#### changeCfgAutosar.m

**功能**: 配置 AUTOSAR 模型的参数设置

- **输入参数**:
  - `modelName`: 模型名称（字符串）
- **示例**:
  ```matlab
  changeCfgAutosar('TmComprCtrl')
  ```

#### changeCfgErt.m

**功能**: 配置 ERT 模型的参数设置和代码生成选项

- **输入参数**:
  - `modelName`: 模型名称（字符串）
- **示例**:
  ```matlab
  changeCfgErt('TmComprCtrl')
  ```

#### changeCfgRef.m

**功能**: 更改模型的配置引用设置

- **输入参数**:
  - `mdName`: 模型名称（字符串）
  - `cfg`: 配置文件名称（字符串）
- **示例**:
  ```matlab
  changeCfgRef('TmComprCtrl', 'TmVcThermal_Configuration_sub')
  ```

#### changeCfgRefAll.m

**功能**: 批量更改所有子模型的配置引用

- **示例**:
  ```matlab
  changeCfgRefAll()
  ```

### 9. 模型引用管理类

#### changeRefModUpdate.m

**功能**: 如果子模型进行了变更，比如端口数量等，需要重新加载下

- **输入参数**:
  - `varargin`: 可选参数
    - `'model'`: 模型列表（元胞数组）
- **示例**:
  ```matlab
  changeRefModUpdate()
  ```

#### changeRefModStat.m

**功能**: 刷新当前路径下的所有子模型

- **示例**:
  ```matlab
  changeRefModStat()
  ```

### 10. 其他工具类

#### changeRepositionXaxisWithYaxis.m

**功能**: 修改 A2L 文件中的 X, Y 轴顺序

- **输入参数**:
  - `filePath`: A2L 文件所在目录（字符串）
- **示例**:
  ```matlab
  changeRepositionXaxisWithYaxis('C:\A2L_Files')
  ```

#### changeUselessGFComment.m

**功能**: 改变无用的 goto from 的注释状态

- **输入参数**:
  - `stat`: 注释状态（'on'/'off'）
- **示例**:
  ```matlab
  changeUselessGFComment('on')
  ```

#### changeDelayStat.m

**功能**: 改变模型或者子模型 delay 属性

- **输入参数**:
  - `pathMd`: 模型路径（字符串）
  - `type`: 注释属性（'on'/'off'/'through'）
- **示例**:
  ```matlab
  changeDelayStat(bdroot, 'through')
  ```

#### changeDelayStatAll.m

**功能**: 改变模型或者子模型 delay 属性（批量处理）

- **输入参数**:
  - `path`: 模型路径（字符串）
  - `type`: 注释属性（'on'/'off'/'through'）
- **示例**:
  ```matlab
  changeDelayStatAll(bdroot, 'through')
  ```

#### changeConstantType.m

**功能**: 根据常量路径，改变常量的数据类型

- **输入参数**:
  - `constantPath`: 对应常量的路径（元胞数组）
  - `typeOrg`: 对应常量源类型（字符串）
  - `typeTarget`: 对应常量的目标类型（字符串）
- **输出参数**:
  - `changedPath`: 变更过的路径列表（元胞数组）
- **示例**:
  ```matlab
  changedPath = changeConstantType(constantPath, "Inherit: Inherit from 'Constant value'", 'single')
  ```

## 使用注意事项

1. **模型状态**: 使用前请确保目标 Simulink 模型已打开
2. **备份**: 重要操作前请备份模型文件
3. **参数验证**: 请确保输入参数符合函数要求
4. **错误处理**: 函数包含错误处理机制，会显示警告信息
5. **依赖关系**: 某些函数依赖其他工具函数，请确保相关函数在路径中

## 作者信息

- **作者**: Blue.ge
- **版本**: 1.0
- **日期**: 2023-2024

## 更新日志

- 2024-08-02: 更新数据字典相关函数
- 2024-06-03: 添加信号名称修改功能
- 2024-01-24: 添加 A2L 文件处理功能
- 2023-12-07: 完善端口管理功能
- 2023-10-20: 初始版本发布
