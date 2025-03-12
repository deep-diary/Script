% function SetModelConfig
clc;
% clear;
try
    load('Configuration_VCU.mat');
catch
    warning(['"Configuration_VCU.mat"' 'is not fund!']);
end
% 此处填写模型路径
SubmodelPath = 'D:\Model\HY11_Model\20231106_HY11_E4\HY11_TEM_VCU1\HP_subModels\SVN_HY11subModel\09_TmPumpCtrl\';
% 此处填写模型名
modelName={'TmPumpCtrl'};

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
    setFunctionDefault(mySCCodeMappingObj,'Execution','MemorySection','CODE_100MS');%修改Function Defaults内存段设置
    setFunctionDefault(mySCCodeMappingObj,'InitializeTerminate','MemorySection','CODE_INT');%修改Function Defaults内存段设置
    setFunctionDefault(mySCCodeMappingObj,'SharedUtility','MemorySection','CODE_100MS');%修改Function Defaults内存段设置                                                                                                                                                                                                                                                                                                                                                                                       
    try
        if strcmp(modelName{idx},'TmSwArch')
            setFunction(mySCCodeMappingObj,'ExportedFunction','MemorySection','Model default');%修改架构模型Functions ExportedFunction内存段设置
        elseif strcmp(modelName{idx},'TEM_VCU1')|| strcmp(modelName{idx},'TmIn') || strcmp(modelName{idx},'TmOut')
            setFunction(mySCCodeMappingObj,'Periodic:D1','MemorySection','Model default');%修改输入输出模块周期函数Functions ExportedFunction内存段设置
        else
            setFunction(mySCCodeMappingObj,['ExportedFunction:' modelName{idx} '_100'],'MemorySection','Model default');%修改子模型导出函数Functions ExportedFunction内存段设置
        end
    catch
        warning([modelName{idx} ' No ExportedFuntion or Periodic !']);
    end
    setFunction(mySCCodeMappingObj,'Initialize','MemorySection','Model default');%修改Functions Initialize内存段设置
    try
        setFunction(mySCCodeMappingObj,'Terminate','MemorySection','CODE_END');%修改Functions Terminate内存段设置
    catch
        warning([modelName{idx} ' No Terminate !']);
    end
    disp([modelName{idx} ' 模型 Embedded Coder Mapping配置完成------------------------------------------------------------------------------']);
    save_system(modelName{idx},'SaveDirtyReferencedModels','on');%保存模型，忽略错误

end
disp('所有模型配置完成------------------------------------------------------------------------------');
% end
