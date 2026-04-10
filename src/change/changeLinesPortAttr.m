function changeLinesPortAttr(path, varargin)
%CHANGELINESPORTATTR 改变当前路径下的信号线属性
%   CHANGELINESPORTATTR(PATH) 改变指定路径下的信号线属性
%   CHANGELINESPORTATTR(PATH, 'Parameter', Value, ...) 使用指定参数配置信号线属性
%
%   输入参数:
%      path        - 模型路径 (字符串)
%
%   可选参数（名值对）:
%      'resoveValue'   - 设置解析属性 (逻辑值), 默认值: false
%      'logValue'      - 设置记录属性 (逻辑值), 默认值: false
%      'testValue'     - 设置测试属性 (逻辑值), 默认值: false
%      'dispName'      - 设置显示名称 (逻辑值), 默认值: false
%      'enableIn'      - 启用输入端口处理 (逻辑值), 默认值: true
%      'enableOut'     - 启用输出端口处理 (逻辑值), 默认值: true
%      'FindAll'       - 查找所有信号线 (逻辑值), 默认值: false
%      'autosarMode'   - AUTOSAR信号名解析模式 (字符串), 默认值: ''
%                        可选值: 'deleteTail', 'halfTail', 'justHalf', 'modelHalf', 'prefixHalf'
%      'prefixName'    - 前缀名称，用于 'prefixHalf' 模式 (字符串), 默认值: 'CcmIF'
%
%   功能描述:
%      改变指定路径下的信号线属性，支持AUTOSAR信号名解析。
%      可以设置信号对象解析、数据记录、测试点等属性。
%
%   示例:
%      changeLinesPortAttr(gcs)
%      changeLinesPortAttr(gcs, 'resoveValue', true, 'logValue', true)
%      changeLinesPortAttr(gcs, 'autosarMode', 'deleteTail', 'dispName', true)
%
%   作者: Blue.ge
%   日期: 20250522
%   版本: 2.0

    %% 输入参数验证
    narginchk(1, inf);
    validateattributes(path, {'char', 'string'}, {'scalartext'}, mfilename, 'path', 1);
    
    % 确保输入为字符向量
    path = char(path);
    
    %% 解析输入参数
    p = inputParser;
    p.FunctionName = mfilename;
    
    addParameter(p, 'resoveValue', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'logValue', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'testValue', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'dispName', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'enableIn', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'enableOut', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'FindAll', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'autosarMode', '', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'prefixName', 'CcmIF', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    
    parse(p, varargin{:});

    % 获取参数值
    resoveValue = p.Results.resoveValue;
    logValue = p.Results.logValue;
    testValue = p.Results.testValue;
    dispName = p.Results.dispName;
    enableIn = p.Results.enableIn;
    enableOut = p.Results.enableOut;
    FindAll = p.Results.FindAll;
    autosarMode = char(p.Results.autosarMode);
    prefixName = char(p.Results.prefixName);
    
    % 信号解析等属性需要显示信号名称
    if logValue || testValue || resoveValue
        dispName = true;
    end
    
    % 确定是否截断信号名
    if ~isempty(autosarMode)
        truncateSignal = true;
    else
        truncateSignal = false;
    end

    %% 找到输入输出线的句柄
    [lineIn, lineOut] = findLinesPorts(path,'FindAll',FindAll);

    %% Deal with inport
    if enableIn
        for i = 1:length(lineIn)
            h_line = lineIn(i);
            srcBlockHandle = get_param(h_line, 'SrcBlockHandle');
            % 判断端口的输出函数调用是否为on
            if strcmp(get_param(srcBlockHandle, 'OutputFunctionCall'), 'on')
                continue;
            end
            % 获取端口名称
            originalName = get_param(srcBlockHandle, 'Name');
            blockType = get_param(srcBlockHandle, 'BlockType');
            
            % 根据truncateSignal参数决定是否截断信号名
            if truncateSignal
                Name = findNameAutosar(originalName, 'nameMd', bdroot, 'type', blockType, 'mode', autosarMode, 'prefixName', prefixName);
            else
                Name = originalName;
            end
            
            if dispName
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
            originalName = get(get(h_line).DstBlockHandle).Name;
            blockType = get(get(h_line).DstBlockHandle).BlockType;
            
            % 根据truncateSignal参数决定是否截断信号名
            if truncateSignal
                Name = findNameAutosar(originalName, 'nameMd', bdroot, 'type', blockType, 'mode', autosarMode, 'prefixName', prefixName);
            else
                Name = originalName;
            end
            
            if dispName
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



