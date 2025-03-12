function SetModelConfig
clc;
clear;
try
    load('Configuration_VCU.mat');
catch
    warning(['"Configuration_VCU.mat"' 'is not fund!']);
end
proj = currentProject;
rootPath = proj.RootFolder;
SubmodelPath = rootPath+'\HP_subModels\SVN_HY11subModel\';
DDPath = rootPath+'\HP_subModels\DD\';

modelName={'TEM_VCU1','TmSwArch','TmIn','TmOut','TmSigProces','TmRefriModeMgr',...
    'TmRefriVlvCtrl','TmSovCtrl','TmComprCtrl','TmColtModeMgr','TmColtVlvCtrl',...
    'TmPumpCtrl','TmHvchCtrl','TmAfCtrl','TmEnergyMgr','TmDiag'};

% modelHandle = load_system(modelName);
% a=get(modelHandle);
for idx=1:length(modelName)
    %% 模型Configration配置
    load_system(modelName{idx})
    k=getConfigSet(modelName{idx},'Reference_VCU');%查找模型所以的模型设置引用
    if isempty(k)
        configRef=Simulink.ConfigSetRef;%新建模型设置
        set_param(configRef,'Name','Reference_VCU');%将模型引用命名
        set_param(configRef,'SourceName','Configuration_VCU');%设置模型引用源
        attachConfigSet(modelName{idx},configRef);%将模型引用与模型关联
    else
        set_param(k,'SourceName','Configuration_VCU');%设置模型引用源
    end
    setActiveConfigSet(modelName{idx},'Reference_VCU');%激活模型引用
    disp([modelName{idx} ' 模型 Configration配置完成----------------------------------------------------------------------------------------------']);
    %% 模型CoderMapping配置
    coder.mapping.create(modelName{idx});
    coder.mapping.defaults.set(modelName{idx},'LocalParameters','StorageClass','Default');
    coder.mapping.defaults.set(modelName{idx},'ModelParameters','StorageClass','Default');
    coder.mapping.defaults.set(modelName{idx},'ExternalParameterObjects','StorageClass','Default');
    coder.mapping.defaults.set(modelName{idx},'GlobalParameters','StorageClass','Default');
    coder.mapping.defaults.set(modelName{idx},'InternalData','StorageClass','Default');
    %     coder.mapping.defaults.set(modelName{idx},'InitializeTerminate','FunctionCustomizationTemplate','CODE_INT');
    %     coder.mapping.defaults.set(modelName{idx},'Execution','FunctionCustomizationTemplate','CODE_10MS');
    %     coder.mapping.defaults.set(modelName{idx},'SharedUtility','FunctionCustomizationTemplate','CODE_10MS');
    %     coder.mapping.defaults.set(modelName{idx},'InitializeTerminate','MemorySection','CODE_INI');

    coderDictionaryObj = coder.dictionary.open(modelName{idx});%获取模型代码数据字典
    %     storageClassesSect = getSection(coderDictionaryObj, 'StorageClasses');
    coderDictionaryObj.loadPackage('GeelyPack');%在数据字典中加载GeelyPack包


    mySCCodeMappingObj = coder.mapping.api.get(modelName{idx},'EmbeddedCoderC');%获取模型代码映射配置
    %     value = getFunctionDefault(mySCCodeMappingObj, 'Execution', 'MemorySection');
    setFunctionDefault(mySCCodeMappingObj,'Execution','MemorySection','CODE_10MS');%修改内存段设置
    setFunctionDefault(mySCCodeMappingObj,'InitializeTerminate','MemorySection','CODE_INT');%修改内存段设置
    setFunctionDefault(mySCCodeMappingObj,'SharedUtility','MemorySection','CODE_10MS');%修改内存段设置
    try
        if strcmp(modelName{idx},'TmSwArch')
            setFunction(mySCCodeMappingObj,'ExportedFunction','MemorySection','Model default');%修改内存段设置
        elseif strcmp(modelName{idx},'TEM_VCU1')|| strcmp(modelName{idx},'TmIn') || strcmp(modelName{idx},'TmOut')
            setFunction(mySCCodeMappingObj,'Periodic:D1','MemorySection','Model default');%修改内存段设置
        else
            setFunction(mySCCodeMappingObj,['ExportedFunction:' modelName{idx} '_100'],'MemorySection','Model default');%修改内存段设置
        end
    catch
        warning([modelName{idx} ' No ExportedFuntion or Periodic !']);
    end
    setFunction(mySCCodeMappingObj,'Initialize','MemorySection','Model default');%修改内存段设置
    try
        setFunction(mySCCodeMappingObj,'Initialize','MemorySection','CODE_100MS');%修改内存段设置
    catch
        warning([modelName{idx} ' No Terminate !']);
    end
    disp([modelName{idx} ' 模型 Embedded Coder Mapping配置完成------------------------------------------------------------------------------']);
    save_system(modelName{idx},'SaveDirtyReferencedModels','on');%保存模型，忽略错误

end
disp('所有模型配置完成------------------------------------------------------------------------------');
end
%% 代码生成配置

% dictionaryName = 'AllData_GeelyMap.sldd';
% set_param(modelHandle,'DataDictionary',dictionaryName);
% set_param(modelHandle,'ProdHWDeviceType','Infineon->TriCore');
% %% set_param(modelHandle,'SimCustomHeaderCode',rootPath+'\Include\data_import.h');
% set_param(modelHandle,'PackageName','App_TriCore.zip');
% %% save_system(modelHandle, '..\Models\Controller\PMA2_YlAPP_V5_Auto.slx');
% coder.mapping.defaults.set(modelHandle,'LocalParameters','StorageClass','GEELYCONST');
% coder.mapping.defaults.set(modelHandle,'ModelParameters','StorageClass','GEELYCONST');
% coder.mapping.defaults.set(modelHandle,'ExternalParameterObjects','StorageClass','GEELYCONST');
% coder.mapping.defaults.set(modelHandle,'GlobalParameters','StorageClass','GEELYCONST');
% coder.mapping.defaults.set(modelHandle,'InternalData','StorageClass','GEELYLOCDATA');
% coder.mapping.defaults.set(modelHandle,'InitializeTerminate','FunctionCustomizationTemplate','CODE_INIT');
% coder.mapping.defaults.set(modelHandle,'Execution','FunctionCustomizationTemplate','CODE_STEP');
% coder.mapping.defaults.set(modelHandle,'SharedUtility','FunctionCustomizationTemplate','CODE_LIB');
% 
% %% 生成代码
% slbuild(modelHandle);
% 
% save_system(modelHandle);
% close_system(modelHandle);