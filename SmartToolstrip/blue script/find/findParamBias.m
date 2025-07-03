function [PathBias, ParamBias] = findParamBias(path)
% findParamBias 查找模型中所有的Bias模块
%   [PathBias, ParamBias] = findParamBias(path) 查找指定路径下模型中所有的Bias模块，
%   并返回模块路径及变量。
%
%   输入参数:
%       path - 模型路径，可以是模型名称或路径字符串
%
%   输出参数:
%       PathBias - 所有Bias模块的路径
%       ParamBias - 所有Bias模块的变量
%
%   示例:
%       [PathBias, ParamBias] = findParamBias(bdroot)
%       [PathBias, ParamBias] = findParamBias(gcs)
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2023-10-27
%   版本: 1.0

    % 初始化输出变量
    PathBias = {};
    ParamBias = {};
    
    try
        % 检查输入参数
        if nargin < 1
            error('必须提供模型路径作为输入参数');
        end
        
        % 查找所有Bias模块
        biasBlocks = find_system(path, 'BlockType', 'Bias');
        
        % 遍历所有Bias模块
        for i = 1:length(biasBlocks)
            blockPath = biasBlocks{i};
            blockParam = get_param(blockPath, 'Bias');
            
            % 检查模块参数是否为变量
            if isvarname(blockParam)
                PathBias{end+1} = blockPath;
                ParamBias{end+1} = blockParam;
            end
        end
        
    catch ME
        % 错误处理
        error('查找Bias模块时发生错误: %s', ME.message);
    end
end 