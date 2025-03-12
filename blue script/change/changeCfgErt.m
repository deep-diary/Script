function changeCfgErt(modelName)
%%
% 目的: 改变autosar 配置
% 输入：
%       path: 模型名称
%   
% 返回：无
% 范例：changeCfgErt('TmSovCtrl')
% 说明：
% 作者： Blue.ge
% 日期： 20240122
%%

    clc
    %% 载入 ERT 模型
%     modelName = 'subModRefPCMU'; % 替换为您的模型名称
    open_system(modelName);
    %% 载入配置
    try
        load('Configuration_VCU.mat');
    catch
        warning(['"Configuration_VCU.mat"' 'is not fund!']);
    end
    %% 改配置参数
    %% 模型Configration配置
    load_system(modelName)
    k=getConfigSet(modelName,'Reference_VCU');%查找模型所以的模型设置引用
    if isempty(k)
        configRef=Simulink.ConfigSetRef;%新建模型设置
        set_param(configRef,'Name','Reference_VCU');%将模型引用命名
        set_param(configRef,'SourceName','Configuration_VCU');%设置模型引用源
        attachConfigSet(modelName,configRef);%将模型引用与模型关联
    else
        set_param(k,'SourceName','Configuration_VCU');%设置模型引用源
    end
    setActiveConfigSet(modelName,'Reference_VCU');%激活模型引用
    disp([modelName ' 模型 Configration配置完成----------------------------------------------------------------------------------------------']);
    %% 模型CoderMapping配置
    coder.mapping.create(modelName);
    coder.mapping.defaults.set(modelName,'LocalParameters','StorageClass','Default');
    coder.mapping.defaults.set(modelName,'ModelParameters','StorageClass','Default');
    coder.mapping.defaults.set(modelName,'ExternalParameterObjects','StorageClass','Default');
    coder.mapping.defaults.set(modelName,'GlobalParameters','StorageClass','Default');
    coder.mapping.defaults.set(modelName,'InternalData','StorageClass','Default');
    %     coder.mapping.defaults.set(modelName,'InitializeTerminate','FunctionCustomizationTemplate','CODE_INT');
    %     coder.mapping.defaults.set(modelName,'Execution','FunctionCustomizationTemplate','CODE_10MS');
    %     coder.mapping.defaults.set(modelName,'SharedUtility','FunctionCustomizationTemplate','CODE_10MS');
    %     coder.mapping.defaults.set(modelName,'InitializeTerminate','MemorySection','CODE_INI');

    coderDictionaryObj = coder.dictionary.open(modelName);%获取模型代码数据字典
    %     storageClassesSect = getSection(coderDictionaryObj, 'StorageClasses');
    coderDictionaryObj.loadPackage('GeelyPack');%在数据字典中加载GeelyPack包


    mySCCodeMappingObj = coder.mapping.api.get(modelName,'EmbeddedCoderC');%获取模型代码映射配置
    %     value = getFunctionDefault(mySCCodeMappingObj, 'Execution', 'MemorySection');
    setFunctionDefault(mySCCodeMappingObj,'Execution','MemorySection','CODE_100MS');%修改Function Defaults内存段设置
    setFunctionDefault(mySCCodeMappingObj,'InitializeTerminate','MemorySection','CODE_INT');%修改Function Defaults内存段设置
    setFunctionDefault(mySCCodeMappingObj,'SharedUtility','MemorySection','CODE_100MS');%修改Function Defaults内存段设置                                                                                                                                                                                                                                                                                                                                                                                       
    try
        if strcmp(modelName,'TmSwArch')
            setFunction(mySCCodeMappingObj,'ExportedFunction','MemorySection','Model default');%修改架构模型Functions ExportedFunction内存段设置
        elseif strcmp(modelName,'TEM_VCU1')|| strcmp(modelName,'TmIn') || strcmp(modelName,'TmOut')
            setFunction(mySCCodeMappingObj,'Periodic:D1','MemorySection','Model default');%修改输入输出模块周期函数Functions ExportedFunction内存段设置
        else
            setFunction(mySCCodeMappingObj,['ExportedFunction:' modelName '_100'],'MemorySection','Model default');%修改子模型导出函数Functions ExportedFunction内存段设置
        end
    catch
        warning([modelName ' No ExportedFuntion or Periodic !']);
    end
    setFunction(mySCCodeMappingObj,'Initialize','MemorySection','Model default');%修改Functions Initialize内存段设置
    try
        setFunction(mySCCodeMappingObj,'Terminate','MemorySection','CODE_END');%修改Functions Terminate内存段设置
    catch
        warning([modelName ' No Terminate !']);
    end
    disp([modelName ' 模型 Embedded Coder Mapping配置完成------------------------------------------------------------------------------']);
    save_system(modelName,'SaveDirtyReferencedModels','on');%保存模型，忽略错误

    %%
    % 可选：保存更改
    disp('所有模型配置完成------------------------------------------------------------------------------');


end
