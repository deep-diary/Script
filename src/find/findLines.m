function [resolved, logged, tested, norm, selected] = findLines(pathMd, varargin)
% findLines 分类Simulink模型中的信号线
%   [resolved, logged, tested, norm, selected] = findLines(pathMd)
%   输入:
%       pathMd - 模型路径（字符串）
%   输出:
%       resolved - 解析过的信号线句柄
%       logged   - 记录过的信号线句柄
%       tested   - 测试过的信号线句柄
%       norm     - 正常的信号线句柄
%
%   例子:
%       [resolved, logged, tested, norm, selected] = findLines(gcs)
%       [resolved, logged, tested, norm] = findLines(gcs)
%
%   作者: Blue.ge
%   日期: 20250522

    %% Params
    p = inputParser;
    addParameter(p, 'FindAll', false, @islogical);
    parse(p, varargin{:});

    FindAll = p.Results.FindAll;
    
    % 查找模型中所有的信号线
    if FindAll
        lines = find_system(pathMd, 'FindAll', 'on', 'Type', 'Line');
    else
        lines = find_system(pathMd, 'SearchDepth',1, 'FindAll', 'on', 'Type', 'Line');
    end

    % 初始化句柄数组
    resolved = [];
    logged = [];
    tested = [];
    norm = [];
    selected = [];

    % 遍历所有找到的线条
    for i = 1:length(lines)
        h = lines(i);
        h_attr = get(h);

        isResolved = isfield(h_attr, 'MustResolveToSignalObject') && h_attr.MustResolveToSignalObject;
        isLogged   = isfield(h_attr, 'DataLogging') && h_attr.DataLogging;
        isTested   = isfield(h_attr, 'TestPoint') && h_attr.TestPoint;
        isselected   = isfield(h_attr, 'Selected') && strcmp(h_attr.Selected, 'on');

        if isResolved
            resolved(end+1) = h;
        end
        if isLogged
            logged(end+1) = h;
        end
        if isTested
            tested(end+1) = h;
        end
        if isselected
            selected(end+1) = h
        end
        if ~isResolved && ~isLogged && ~isTested && ~isselected
            norm(end+1) = h;
        end

        name = findLineName(h)
    end
end
