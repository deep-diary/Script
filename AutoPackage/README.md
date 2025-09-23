# appAutosar2Ert 独立运行包

这是一个包含appAutosar2Ert函数及其所有依赖的独立运行包。

## 使用方法

### 方法1: 使用启动脚本（推荐）
```matlab
start_package();
appAutosar2Ert(参数);
```

### 方法2: 手动添加路径
```matlab
addpath(genpath(pwd));
appAutosar2Ert(参数);
```

## 包含的文件

### 成功复制的文件 (15个):
- blue script\app\appAutosar2Ert.m
- blue script\change\changeCfgRef.m
- blue script\change\changeHeaderFile.m
- blue script\change\changeLinesPortAttr.m
- blue script\create\createCodeMod.m
- blue script\create\createParamObjAutosar4.m
- blue script\create\createSigObjAutosar4.m
- blue script\create\createSlddSigGee.m
- blue script\delete\delFileTargetLine.m
- blue script\find\findCodeFiles.m
- blue script\find\findLinesPorts.m
- blue script\find\findModPorts.m
- blue script\find\findNameAutosar.m
- blue script\find\findSlddLoadGee.m
- blue script\find\findValidPath.m

## 需要的工具箱

- MATLAB
- HDL Verifier
- Fixed-Point Designer
- IEC Certification Kit
- Image Acquisition Toolbox
- MATLAB Coder
- Deep Learning Toolbox
- Polyspace Bug Finder
- Polyspace Bug Finder Server
- Signal Processing Toolbox
- SimBiology
- Simulink
- Requirements Toolbox
- Simulink Real-Time
- Stateflow
- Computer Vision Toolbox
- Vision HDL Toolbox
- Vehicle Network Toolbox

## 注意事项

1. 确保MATLAB版本兼容
2. 确保所需的工具箱已安装
3. 确保所有依赖文件存在
4. 确保有足够的磁盘空间

