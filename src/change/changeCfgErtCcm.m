function changeCfgErtCcm(modelName)
%CHANGECFGERTCCM 配置ERT和CCM模型的参数设置和代码生成选项
%   CHANGECFGERTCCM(MODELNAME) 配置指定ERT和CCM模型的参数设置和代码生成选项
%
%   输入参数:
%      modelName    - 模型名称 (字符串标量或字符向量)
%
%   功能描述:
%      1. 打开或加载指定的ERT模型
%      2. 加载AUTOSAR4 包
%      3. 设置代码映射配置
%      4. 配置内存段设置
%      5. 保存模型更改
%
%   示例:
%      % 基本用法
%      changeCfgErtCcm('TmComprCtrl')
%
%   参见: CODER.MAPPING, CODER.DICTIONARY
%
%   作者: Blue.ge
%   版本: 2.0
%   日期: 20251126

    %% 输入验证
    arguments
        modelName (1,1) string {mustBeNonempty}
    end
    
    % 转换为字符向量（兼容旧版本MATLAB）
    modelName = char(modelName);
    
    %% 打开模型并加载配置
    try
        % 检查模型是否存在
        if ~bdIsLoaded(modelName)
            load_system(modelName);
        end
        
        % 打开代码字典并加载AUTOSAR4包
        coderDictionaryObj = coder.dictionary.open(modelName);
        coderDictionaryObj.refreshPackage();
        coderDictionaryObj.loadPackage('AUTOSAR4');
        
    catch ME
        error('changeCfgErtCcm:LoadModelError', ...
            '无法加载模型或代码字典: %s', ME.message);
    end
    
    %% 配置代码映射
    try
        % 创建代码映射
        coder.mapping.create(modelName);
        cm = coder.mapping.api.get(modelName);
        
        % 配置数据内存段设置
        configureDataMemorySections(modelName);
        
        % 配置函数内存段设置
        configureFunctionMemorySections(modelName);
        
        % 配置函数名称和内存段
        configureFunctionMappings(cm, modelName);
        
    catch ME
        error('changeCfgErtCcm:MappingError', ...
            '代码映射配置失败: %s', ME.message);
    end
    
    %% 保存更改
    try
        save_system(modelName, 'SaveDirtyReferencedModels', 'on');
        fprintf('模型 "%s" 配置完成并已保存。\n', modelName);
    catch ME
        warning('changeCfgErtCcm:SaveError', ...
            '保存模型失败: %s', ME.message);
        rethrow(ME);
    end
end

%% 辅助函数：配置数据内存段
function configureDataMemorySections(modelName)
    % 配置端口内存段
    coder.mapping.defaults.set(modelName, 'Inports', 'MemorySection', 'None');
    coder.mapping.defaults.set(modelName, 'Outports', 'MemorySection', 'None');
    
    % 配置数据存储内存段
    coder.mapping.defaults.set(modelName, 'InternalData', 'MemorySection', 'VAR');
    coder.mapping.defaults.set(modelName, 'SharedLocalDataStores', 'MemorySection', 'VAR');
    coder.mapping.defaults.set(modelName, 'GlobalDataStores', 'MemorySection', 'VAR');
    
    % 配置参数内存段
    coder.mapping.defaults.set(modelName, 'ModelParameters', 'MemorySection', 'VAR');
    coder.mapping.defaults.set(modelName, 'ExternalParameters', 'MemorySection', 'VAR');
    coder.mapping.defaults.set(modelName, 'Constants', 'MemorySection', 'VOLATILE');
end

%% 辅助函数：配置函数内存段
function configureFunctionMemorySections(modelName)
    coder.mapping.defaults.set(modelName, 'InitializeTerminate', 'MemorySection', 'CODE');
    coder.mapping.defaults.set(modelName, 'Execution', 'MemorySection', 'CODE');
    coder.mapping.defaults.set(modelName, 'SharedUtility', 'MemorySection', 'CODE');
end

%% 辅助函数：配置函数映射
function configureFunctionMappings(cm, modelName)
    % 构建导出函数名称
    expFunName = sprintf('ExportedFunction:%s_Runnable', modelName);
    
    % 设置函数名称
    setFunction(cm, expFunName, 'FunctionName', sprintf('%s_Runnable', modelName));
    setFunction(cm, 'Initialize', 'FunctionName', sprintf('%s_Init', modelName));
    setFunction(cm, 'Terminate', 'FunctionName', sprintf('%s_terminate', modelName));
    
    % 设置函数内存段
    setFunction(cm, expFunName, 'MemorySection', 'CODE');
    setFunction(cm, 'Initialize', 'MemorySection', 'CODE');
    setFunction(cm, 'Terminate', 'MemorySection', 'CODE');
end
