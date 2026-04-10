function changeLinesSelectedAttr(path, varargin)
% changeLinesSelectedAttr 删除当前路径下的信号线属性
%   changeLinesSelectedAttr(path)
%   输入:
%       path - 模型路径（字符串）
%   changeLinesSelectedAttr(gcs, 'logValue', true)
%   作者: Blue.ge
%   日期: 20250522

    p = inputParser;
    addParameter(p, 'Name', '');
    addParameter(p, 'resoveValue', false, @islogical);
    addParameter(p, 'logValue', false, @islogical);
    addParameter(p, 'testValue', false, @islogical);
    addParameter(p, 'FindAll', false, @islogical);
    addParameter(p, 'deleteName', true, @islogical);

    parse(p, varargin{:});

    resoveValue = p.Results.resoveValue;
    logValue = p.Results.logValue;
    testValue = p.Results.testValue;
    Name = p.Results.Name;
    FindAll = p.Results.FindAll;
    deleteName = p.Results.deleteName;

    [resolved, logged, tested, norm, selected] = findLines(path, 'FindAll',FindAll);

    lines = selected;

    for i = 1:length(selected)
        h_line = lines(i);

        % 如果信号线没有任何属性了，则清空名字

        if resoveValue ==0 && logValue == 0 && testValue == 0
            
        else
            name = findLineName(h_line);
            set(h_line, 'Name', name);
        end


        set(h_line, 'MustResolveToSignalObject', resoveValue);
        set(h_line, 'DataLogging', logValue);
        set(h_line, 'TestPoint', testValue);

        % 如果信号线没有任何属性了，则清空名字
        h_attr = get(h_line);
        if deleteName && h_attr.MustResolveToSignalObject == 0  && h_attr.DataLogging == 0 && h_attr.TestPoint == 0
            set(h_line, 'Name', Name);
        end
    end
end


