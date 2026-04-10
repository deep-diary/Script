function [lineIn, lineOut] = findLinesPorts(pathMd, varargin)
% findLinesPorts 找到当前模型下的输入输出信号线
%   [lineIn, lineOut] = findLinesPorts(pathMd)
%   输入:
%       pathMd - 模型路径（字符串）
%   输出:
%       lineIn   - 跟输入端口相连接的信号线
%       lineOut  - 跟输出端口相连接的信号线
%
%   例子:
%       [lineIn, lineOut] = findLinesPorts(gcs)
%
%   作者: Blue.ge
%   日期: 20250522

    %% Params
    p = inputParser;
    addParameter(p, 'FindAll', false, @islogical);
    parse(p, varargin{:});

    FindAll = p.Results.FindAll;
    
    %% 查找模型中所有的信号线
    if FindAll
        lines = find_system(pathMd, 'FindAll', 'on', 'Type', 'Line');
    else
        lines = find_system(pathMd, 'SearchDepth',1, 'FindAll', 'on', 'Type', 'Line');
    end

    % 初始化句柄数组
    lineIn = [];
    lineOut = [];

    % 遍历所有找到的线条
    for i = 1:length(lines)
%         disp(i)
        h = lines(i);
        h_attr = get(h);

        % 判断信号线连接的端口类型
        if isfield(h_attr, 'SrcPortHandle') && h_attr.SrcPortHandle ~= -1
            BlockType = get_param(h_attr.SrcBlockHandle, 'BlockType');
            if strcmp(BlockType, 'Inport')
                lineIn(end+1) = h;
            end
        end
        
        if isfield(h_attr, 'DstPortHandle') && any(h_attr.DstPortHandle~= -1) 
            BlockType = get_param(h_attr.DstBlockHandle, 'BlockType');
            if strcmp(BlockType, 'Outport')
                lineOut(end+1) = h;
            end
        end
    end
end
