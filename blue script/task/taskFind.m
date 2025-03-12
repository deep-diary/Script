clc

%% 找到当前模型中无效的From
uselessFrom = findUselessFrom();

%% 找到当前模型中无效的 Goto
uselessGoto = findUselessGoto();

%% 目的: 让模型铺满窗口，然后找到窗口对应的坐标并返回。
position = findGcsPos()


%% 找解析的信号
signalHandles = findResolvedSignals(gcs)

%% 找输入输出端口相连接的端口句柄
[hPort, hLine, hBlock] = findPortLineBlock(gcb)

%% 找到有效路径，对于gcs, gcb, bdroot, 或者子模型，或者引用模型，find_system中使用的路径会不一样
[ModelName, validPath] = findValidPath(path)

%% DCM
% 解析DCM文件
paramsArr = findDCMParam('HY11_PCMU_Tm_VP2_V1030311.DCM');


%% 找模型

% 目的: 找到路径中模型的输入输出模块, 返回模块对应句柄
[bkIn, bkOut] = findModBk(gcb)

% find the specific block name
[bkIn, bkOut] = findModBkSpecific(gcb, ...
    'condition', 'useless'); % condition: useless, unconnected

% 找模型端口信息
[ModelName,PortsIn,PortsOut] = findModPorts(gcb, ...
    'getType', 'path') % 可选path 或者端口属性，比如Name, OutDataTypeStr, 默认为path

%% 找名字
% 去掉名字后缀
sigName = findNameInput('yGlHwDrvDiag_B_Sov4SGflgin','in')

% 找到autosar interface 名字对应的信号名
sigName = findNameArxml('yGlHwDrvDiag_B_Sov4SGflgin_yGlHwDrvDiag_B_Sov4SGflgin_read')

% 找到工作空间中是否存在信号别名，如果存在，则找出其对应的数据类型
type = findNameIFType('IDT_AD4CoolReqForBkpUD_Ref')

% 比如当前模型名称是'CurrrentMode', 则如下函数输出为'sCurrrentMode_D_u32AcOffCode'
[dataType, nameOutPort] = findNameMdOut('sTmComprCtrl_D_u32AcOffCode')

% 根据当前名字，找到相关数据类型，PCMU 及 VCU 的storge class
[dataType, ScSigPCMU, ScParamPCMU, ScSigVCU, ScParamVCU] = findNameType('sTmIn_X_s32EexvPosSts')

%% 找sldd
% 到某个路径下所有的sldd文件
excelFiles = findExcelFiles('D:\Thermal\03_对外工作\02_PCMU热管理软件集成\Thermal_PCMU_23N5\SubModel')

% find all the interface info
[data dataComIn dataComOut] = findExcelOfficialInterface('PCMU_23N5_Interface_V12.0.xlsx');

% find sldd: 找到模型中所有的sldd
findSldd(gcs)

% find sldd: 接口模板中的sldd

findSlddDebugTemp('interface template.xlsx',...
    'modeName','TmIn', ...
    'mode','inport', ...
    'sheetName',{'Inports Common','Inports Diag','Inports 2F'})

findSlddDebugTemp('interface template.xlsx',...
    'modeName','TmOut', ...
    'mode','outport', ...
    'sheetName',{'Outports Common','Outports Diag','Outports 2F'})

% find sldd: 合并子模型sldd
outPath = findSlddCombine('D:\Thermal\03_对外工作\02_PCMU热管理软件集成\Thermal_PCMU_23N5\SubModel')

% find sldd: 加载sldd
findSlddLoad('PCMU_SLDD_All.xlsx')

findSlddLoad('TmSwArch_DD_PCMU.xlsx')
findSlddLoad('TmComprCtrlDev_DD_PCMU.xlsx')

%% 解析Interface 相关数据
[data dataComIn dataComOut] = findExcelOfficialInterface('PCMU_23N5&23R3_Interface_V12.0 - base.xlsx')


