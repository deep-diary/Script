function changeLinesPortAttr(path, varargin)
% changeLinesPortAttr 改变当前路径下的信号线属性
%   changeLinesPortAttr(path, 'resoveValue', true/false, 'logValue', true/false, 'testValue', true/false, 'dispName', true/false)
%   输入:
%       path - 模型路径（字符串）
%       varargin - 可选参数:
%           'resoveValue' - 设置解析属性（默认false）
%           'logValue' - 设置记录属性（默认false）
%           'testValue' - 设置测试属性（默认false）
%           'dispName' - 设置显示名称（默认false）
%   范例：changeLinesPortAttr(gcs)
%   作者: Blue.ge
%   日期: 20250522

    %% 参数
    p = inputParser;
    addParameter(p, 'resoveValue', false, @islogical);
    addParameter(p, 'logValue', false, @islogical);
    addParameter(p, 'testValue', false, @islogical);
    addParameter(p, 'Name', '');
    addParameter(p, 'FindAll', false, @islogical);
    addParameter(p, 'enableIn', false, @islogical);
    addParameter(p, 'enableOut', false, @islogical);
    parse(p, varargin{:});

    resoveValue = p.Results.resoveValue;
    logValue = p.Results.logValue;
    testValue = p.Results.testValue;
    Name = p.Results.Name;
    FindAll = p.Results.FindAll;
    enableIn = p.Results.enableIn;
    enableOut = p.Results.enableOut;

    %% 找到输入输出线的句柄
    [lineIn, lineOut] = findLinesPorts(path,'FindAll',FindAll);

    %% Deal with inport
    if enableIn
        for i = 1:length(lineIn)
            h_line = lineIn(i);
            Name = get(get(h_line).SrcBlockHandle).Name;
            if resoveValue || logValue || testValue
                set(h_line, 'Name', Name);
            else
                set(h_line, 'Name', '');
            end
    
            set(h_line, 'MustResolveToSignalObject', resoveValue);
            set(h_line, 'DataLogging', logValue);
            set(h_line, 'TestPoint', testValue);
        end
    end

    %% Deal with outport
    if enableOut
        for i = 1:length(lineOut)
            h_line = lineOut(i);
            Name = get(get(h_line).DstBlockHandle).Name;
            if resoveValue || logValue || testValue
                set(h_line, 'Name', Name);
            else
                set(h_line, 'Name', '');
            end
    
            set(h_line, 'MustResolveToSignalObject', resoveValue);
            set(h_line, 'DataLogging', logValue);
            set(h_line, 'TestPoint', testValue);
        end
    end
end



