
%% change 模型布线
changeLineArrange()

%% 整理输入输出端口的位置
changePortBlockPosAll([-730 3600], [0 3600])

%% 改变模型
% 目的: 改变模型尺寸大小
changeModSize(gcb,'wid',500)

% 目的: 改变gcs下模型尺寸大小
changeModSizeGcs()

% 目的: 改变模型到特定的位置
posNew = changeModPos(gcb, [1500 0])

% 目的: 改变端口类型
portsChanged = changeModPortType(gcs);

% 目的: 为模型增加层级关系数字。
changeModName(pathMd, prefix)

% 目的: 批量改变path对应模型的端口名称
changeModPortName(gcb, 'SM123', 'Filter')

%% 改变数据类型
% 目的: 改单个选中的常量数据类型
changedPath = changeConstantType({gcb}, "Inherit: Inherit from 'Constant value'", 'single');

% 目的: 批量改常量数据类型
[constantPath, undefinedParam] = findParamConstant(bdroot);
changedPath = changeConstantType(constantPath, "Inherit: Inherit from 'Constant value'", 'single');

% 目的: 全局改变信号类型
changeSigType('yTmSovCtrl_B_HpmSov3ActvCmdPre', 'boolean', 'all', true)

%% 目的: 刷新当前路径下的所有子模型
changeRefModStat()

%% 整理连线
changeLineArrange('path',gcb)

%% 改变引用模型
changeRefModUpdate('model',{'TmRefriVlvCtrl'})

%% 刷新引用模型
changeRefModStat()

%% 改变模型配置
changeCfgAutosar('TmSovCtrl')
changeCfgErt('TmSovCtrl')
changeCfgRef('TmRefriVlvCtrl', 'ConfigFile', 'TmVcThermal_Configuration_sub') % 改变单个模型配置， 需要提前加载好相关配置文件
changeCfgRefAll() % changeModSize 改变所有模型配置



%% 目的: 改变无用的goto from的注释状态
changeUselessGFComment(stat)



%% 目的: 调换A2L文件中的X, Y的顺序
changeRepositionXaxisWithYaxis(filePath)

%% 目的: 该表信号名称及类型
changeSigName('Template_ChangeName.xlsx','keepPrefix',true)

%% 目的: 根据DCM数据，改变模型sldd
outPath = changeArchSldd('HY11_PCMU_Tm_Job1_V2020802_ALL.DCM', 'TmComprCtrl_DD_PCMU_EXPORT.xlsx')
%% sldd 和1D 2D 相互转换， 便于更好的可视化
changeSlddInitValueByTable('TmComprCtrl_DD_PCMU_EXPORT.xlsx')
changeSlddTableByInitValue('TmComprCtrl_DD_PCMU_EXPORT.xlsx')

%% 目的: 根据信号名称，改变sldd初始值
updatedTable = changeIniValueByName(slddTable, signalName, newValue)