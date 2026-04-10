function changeCfgErt(modelName)
%CHANGECFGERT 配置ERT模型的参数设置和代码生成选项
%   CHANGECFGERT(MODELNAME) 配置指定ERT模型的参数设置和代码生成选项
%
%   输入参数:
%      modelName    - 模型名称 (字符串)
%
%   功能描述:
%      1. 打开指定的ERT模型
%      2. 加载VCU配置
%      3. 配置模型参数设置
%      4. 设置代码映射配置
%      5. 配置内存段设置
%      6. 保存模型更改
%
%   示例:
%      % 基本用法
%      changeCfgErt('TmComprCtrl')
%
%   注意事项:
%      1. 使用前需要确保模型文件存在
%      2. 需要确保'Configuration_VCU.mat'文件存在
%      3. 根据模型类型自动配置不同的内存段设置:
%         - TmSwArch: 配置ExportedFunction内存段
%         - TEM_VCU1/TmIn/TmOut: 配置Periodic:D1内存段
%         - 其他模型: 配置ExportedFunction:modelName_100内存段
%      4. 函数会自动保存模型更改
%
%   参见: CODER.MAPPING, CODER.DICTIONARY
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 20240122

    %% 打开模型并加载配置
    open_system(modelName);
    
    % 加载VCU配置
    try
        load('Configuration_VCU.mat');
    catch
        warning('"Configuration_VCU.mat" is not found!');
    end

    %% 配置模型参数设置
    load_system(modelName);
    k = getConfigSet(modelName, 'Reference_VCU');
    
    if isempty(k)
        configRef = Simulink.ConfigSetRef;
        set_param(configRef, 'Name', 'Reference_VCU');
        set_param(configRef, 'SourceName', 'Configuration_VCU');
        attachConfigSet(modelName, configRef);
    else
        set_param(k, 'SourceName', 'Configuration_VCU');
    end
    
    setActiveConfigSet(modelName, 'Reference_VCU');
    disp([modelName ' 模型 Configration配置完成']);

    %% 配置代码映射
    coder.mapping.create(modelName);
    
    % 设置默认存储类
    coder.mapping.defaults.set(modelName, 'LocalParameters', 'StorageClass', 'Default');
    coder.mapping.defaults.set(modelName, 'ModelParameters', 'StorageClass', 'Default');
    coder.mapping.defaults.set(modelName, 'ExternalParameterObjects', 'StorageClass', 'Default');
    coder.mapping.defaults.set(modelName, 'GlobalParameters', 'StorageClass', 'Default');
    coder.mapping.defaults.set(modelName, 'InternalData', 'StorageClass', 'Default');

    %% 配置数据字典和内存段
    coderDictionaryObj = coder.dictionary.open(modelName);
    coderDictionaryObj.loadPackage('GeelyPack');

    % 获取代码映射对象
    mySCCodeMappingObj = coder.mapping.api.get(modelName, 'EmbeddedCoderC');
    
    % 设置默认内存段
    setFunctionDefault(mySCCodeMappingObj, 'Execution', 'MemorySection', 'CODE_100MS');
    setFunctionDefault(mySCCodeMappingObj, 'InitializeTerminate', 'MemorySection', 'CODE_INT');
    setFunctionDefault(mySCCodeMappingObj, 'SharedUtility', 'MemorySection', 'CODE_100MS');

    % 根据模型类型设置特定内存段
    try
        if strcmp(modelName, 'TmSwArch')
            setFunction(mySCCodeMappingObj, 'ExportedFunction', 'MemorySection', 'Model default');
        elseif strcmp(modelName, 'TEM_VCU1') || strcmp(modelName, 'TmIn') || strcmp(modelName, 'TmOut')
            setFunction(mySCCodeMappingObj, 'Periodic:D1', 'MemorySection', 'Model default');
        else
            setFunction(mySCCodeMappingObj, ['ExportedFunction:' modelName '_100'], 'MemorySection', 'Model default');
        end
    catch
        warning([modelName ' No ExportedFunction or Periodic!']);
    end

    % 设置初始化函数内存段
    setFunction(mySCCodeMappingObj, 'Initialize', 'MemorySection', 'Model default');
    
    % 设置终止函数内存段
    try
        setFunction(mySCCodeMappingObj, 'Terminate', 'MemorySection', 'CODE_END');
    catch
        warning([modelName ' No Terminate!']);
    end

    disp([modelName ' 模型 Embedded Coder Mapping配置完成']);
    
    %% 保存更改
    save_system(modelName, 'SaveDirtyReferencedModels', 'on');
    disp('所有模型配置完成');
end
