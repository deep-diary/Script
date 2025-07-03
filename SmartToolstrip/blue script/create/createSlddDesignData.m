function dictionaryObj = createSlddDesignData(modelName, varargin)
%CREATESLDDDESIGNDATA 创建或更新模型的数据字典
%   dictionaryObj = createSlddDesignData(modelName) 根据模型名称创建或更新
%   对应的数据字典，将工作空间中的变量导入到数据字典中。
%
%   输入参数:
%       modelName - 模型名称
%
%   可选参数:
%       'slddPath' - 数据字典路径，默认为空
%
%   输出参数:
%       dictionaryObj - 数据字典对象
%
%   示例:
%       dictionaryObj = createSlddDesignData('TmComprCtrl')
%       dictionaryObj = createSlddDesignData('TmComprCtrl', 'slddPath', 'path/to/dictionary.sldd')
%
%   说明:
%       1. 需要先成功编译模型
%       2. 所有需要导入的变量必须已加载到工作空间中
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-06-28
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        
        % 添加参数及其验证
        addParameter(p, 'slddPath', '', @ischar);
        
        parse(p, varargin{:});
        
        % 获取参数值
        slddPath = p.Results.slddPath;
        
        %% 验证模型
        if ~bdIsLoaded(modelName)
            error('模型 %s 未加载', modelName);
        end
        
        fprintf('开始处理模型 %s 的数据字典\n', modelName);
        
        %% 解除模型与数据字典的绑定
        try
            set_param(modelName, 'DataDictionary', '');
            fprintf('已解除模型与数据字典的绑定\n');
        catch ME
            error('解除模型与数据字典绑定时发生错误: %s', ME.message);
        end
        
        %% 获取模型使用的变量
        try
            % 查找所有变量和枚举类型
            usedTypesVars = Simulink.findVars(modelName, 'IncludeEnumTypes', true);
            
            % 识别动态类和基础工作空间中的变量
            enumTypesDynamic = strcmp({usedTypesVars.SourceType}, 'dynamic class');
            sigParams = strcmp({usedTypesVars.SourceType}, 'base workspace');
            varsToImportIndex = sigParams | enumTypesDynamic;
            
            % 获取需要导入的变量名
            varNames = {usedTypesVars(varsToImportIndex).Name}';
            
            if isempty(varNames)
                warning('未找到需要导入的变量');
            else
                fprintf('找到 %d 个需要导入的变量\n', length(varNames));
            end
        catch ME
            error('获取模型变量时发生错误: %s', ME.message);
        end
        
        %% 创建或打开数据字典
        try
            if isempty(slddPath)
                slddPath = [modelName, '.sldd'];
            end
            
            dictionaryObj = createSldd(modelName);
            fprintf('已创建/打开数据字典: %s\n', slddPath);
        catch ME
            error('创建/打开数据字典时发生错误: %s', ME.message);
        end
        
        %% 导入变量到数据字典
        try
            [importSuccess, importFailure] = importFromBaseWorkspace(dictionaryObj, ...
                'varList', varNames, 'clearWorkspaceVars', true);
            
            if ~isempty(importFailure)
                warning('以下变量导入失败: %s', strjoin(importFailure, ', '));
            end
            
            fprintf('成功导入 %d 个变量\n', length(importSuccess));
        catch ME
            error('导入变量到数据字典时发生错误: %s', ME.message);
        end
        
        %% 保存更改
        try
            % 将数据字典绑定到模型
            set_param(modelName, 'DataDictionary', slddPath);
            
            % 保存数据字典
            saveChanges(dictionaryObj);
            
            % 保存模型
            save_system(modelName);
            
            fprintf('数据字典和模型已保存\n');
        catch ME
            error('保存更改时发生错误: %s', ME.message);
        end
        
    catch ME
        error('创建数据字典过程中发生错误: %s', ME.message);
    end
end


