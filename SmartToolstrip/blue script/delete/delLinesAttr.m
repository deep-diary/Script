function delLinesAttr(path, varargin)
% delLinesAttr 删除当前路径下的信号线属性
%   delLinesAttr(path)
%   输入:
%       path - 模型路径（字符串）
%   delLinesAttr(gcs,'attr', 'logValue', 'FindAll',false)
%   作者: Blue.ge
%   日期: 20250522

    p = inputParser;
    addParameter(p, 'Name', '');
    addParameter(p, 'resoveValue', false, @islogical);
    addParameter(p, 'logValue', false, @islogical);
    addParameter(p, 'testValue', false, @islogical);
    addParameter(p, 'attr', 'logValue');  % resoveValue logValue testValue
    addParameter(p, 'FindAll', false, @islogical);

    parse(p, varargin{:});

    attr = p.Results.attr;
    resoveValue = p.Results.resoveValue;
    logValue = p.Results.logValue;
    testValue = p.Results.testValue;
    Name = p.Results.Name;
    FindAll = p.Results.FindAll;

    [resolved, logged, tested, norm] = findLines(path, 'FindAll',FindAll);

    lines = [resolved logged tested norm];

    for i = 1:length(lines)
        h_line = lines(i);
        if strcmp(attr, 'resoveValue')
            set(h_line, 'MustResolveToSignalObject', resoveValue);
        elseif strcmp(attr, 'logValue')
            set(h_line, 'DataLogging', logValue);
        elseif strcmp(attr, 'testValue')
            set(h_line, 'TestPoint', testValue);
        end

        % 如果信号线没有任何属性了，则清空名字
        h_attr = get(h_line);
        if h_attr.MustResolveToSignalObject == 0  && h_attr.DataLogging == 0 && h_attr.TestPoint == 0
            set(h_line, 'Name', Name);
        end
    end
end


