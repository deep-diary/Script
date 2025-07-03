function dictionaryObj = createSldd(modelName, varargin)
%CREATESLDD 创建或打开模型的数据字典
%   dictionaryObj = createSldd(modelName) 根据模型名称创建或打开对应的数据字典，
%   并将其绑定到模型。如果未指定数据字典路径，则数据字典将位于模型同目录下。
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
%       dictionaryObj = createSldd('TmComprCtrl')
%       dictionaryObj = createSldd('TmComprCtrl', 'slddPath', 'path/to/dictionary.sldd')
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
            fprintf('正在加载模型 %s...\n', modelName);
            load_system(modelName);
        end
        
        %% 获取模型路径
        modPath = which(modelName);
        if isempty(modPath)
            error('在项目路径中未找到有效的模型: %s', modelName);
        end
        
        [filepath, ~, ~] = fileparts(modPath);
        fprintf('模型路径: %s\n', filepath);
        
        %% 解除现有数据字典绑定
        try
            set_param(modelName, 'DataDictionary', '');
            fprintf('已解除模型与数据字典的绑定\n');
        catch ME
            error('解除模型与数据字典绑定时发生错误: %s', ME.message);
        end
        
        %% 确定数据字典路径
        if isempty(slddPath)
            dictionaryName = [modelName, '.sldd'];
            slddPath = fullfile(filepath, dictionaryName);
        end
        
        %% 创建或打开数据字典
        try
            % 关闭所有已打开的数据字典
            Simulink.data.dictionary.closeAll();
            
            if ~exist(slddPath, 'file')
                fprintf('正在创建新的数据字典: %s\n', slddPath);
                dictionaryObj = Simulink.data.dictionary.create(slddPath);
            else
                fprintf('正在打开现有的数据字典: %s\n', slddPath);
                dictionaryObj = Simulink.data.dictionary.open(slddPath);
            end
        catch ME
            error('创建/打开数据字典时发生错误: %s', ME.message);
        end
        
        %% 绑定数据字典到模型
        try
            set_param(modelName, 'DataDictionary', dictionaryName);
            fprintf('已将数据字典绑定到模型\n');
        catch ME
            error('绑定数据字典到模型时发生错误: %s', ME.message);
        end
        
        %% 保存更改
        try
            saveChanges(dictionaryObj);
            save_system(modelName);
            fprintf('数据字典和模型已保存\n');
        catch ME
            error('保存更改时发生错误: %s', ME.message);
        end
        
    catch ME
        error('创建数据字典过程中发生错误: %s', ME.message);
    end
end


