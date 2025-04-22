function [createdInputAll, createdOutputAll] = createModGotoAll(varargin)
%CREATEMODGOTOALL 为当前模型层级中的所有模块创建输入输出Goto/From模块
%   [createdInputAll, createdOutputAll] = createModGotoAll() 为当前模型层级中的
%   所有模块或引用模型创建输入输出Goto/From模块。
%
%   可选参数:
%       'mode' - 创建模式，可选值为'both'（默认）、'input'或'output'
%       'inList' - 限制创建的输入信号列表，默认为空
%       'outList' - 限制创建的输出信号列表，默认为空
%
%   输出参数:
%       createdInputAll - 成功创建的输入信号列表
%       createdOutputAll - 成功创建的输出信号列表
%
%   示例:
%       [in, out] = createModGotoAll()
%       [in, out] = createModGotoAll('mode', 'input', 'inList', {'signal1'})
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-05-17
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        
        % 添加参数及其验证
        addParameter(p, 'mode', 'both', @(x) any(strcmp(x, {'both', 'input', 'output'})));
        addParameter(p, 'inList', {}, @iscell);
        addParameter(p, 'outList', {}, @iscell);
        
        parse(p, varargin{:});
        
        mode = p.Results.mode;
        inList = p.Results.inList;
        outList = p.Results.outList;
        
        %% 查找模型和子系统
        modRef = find_system(gcs, 'SearchDepth', 1, 'BlockType', 'ModelReference');
        modSub = find_system(gcs, 'SearchDepth', 1, 'BlockType', 'SubSystem');
        models = [modRef; modSub];
        
        %% 初始化输出变量
        createdInputAll = {};
        createdOutputAll = {};
        
        %% 处理每个模型
        for i = 1:length(models)
            % 跳过当前模型
            if strcmp(models{i}, gcs)
                continue;
            end
            
            fprintf('-----------------开始处理: %s -----------------\n', models{i});
            
            % 创建Goto/From模块
            [createdInput, createdOutput] = createModGoto(models{i}, ...
                'inList', inList, ...
                'outList', outList, ...
                'mode', mode);
            
            % 更新输出列表
            createdInputAll = [createdInputAll, createdInput];
            createdOutputAll = [createdOutputAll, createdOutput];
            
            fprintf('-----------------完成处理: %s -----------------\n', models{i});
        end
        
        %% 去除重复项
        createdInputAll = unique(createdInputAll);
        createdOutputAll = unique(createdOutputAll);
        
        fprintf('成功创建了%d个输入信号和%d个输出信号\n', ...
            length(createdInputAll), length(createdOutputAll));
        
    catch ME
        error('创建Goto/From模块时发生错误: %s', ME.message);
    end
end

  