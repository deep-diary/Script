function [createdInput, createdOutput] = createModGoto(path, varargin)
%CREATEMODGOTO 为模型或子系统创建对应的Goto/From模块并进行连线
%   [CREATEDINPUT, CREATEDOUTPUT] = CREATEMODGOTO(PATH) 使用默认参数创建Goto/From模块
%   [CREATEDINPUT, CREATEDOUTPUT] = CREATEMODGOTO(PATH, 'Parameter', Value, ...) 使用指定参数创建
%
%   输入参数:
%      path        - 模型或子系统路径 (字符向量或字符串标量)
%
%   可选参数（名值对）:
%      'mode'      - 创建模式，可选值: 'inport', 'outport', 'both' (默认值: 'both')
%      'inList'    - 限制创建的输入信号列表 (元胞数组)
%      'outList'   - 限制创建的输出信号列表 (元胞数组)
%      'suffixStr' - 要删除的信号名后缀 (默认值: 'NoTail')
%      'bkHalfLength' - 模块半长度 (默认值: 25)
%      'isCreateMatch' - 是否为输出创建匹配的From模块 (默认值: false)
%      'autosarMode' - AUTOSAR信号名解析模式，可选值: 'deleteTail', 'halfTail', 'justHalf', 'modelHalf' (默认值: '')
%      'prefixName' - 前缀名称，用于AUTOSAR模式 (默认值: 'CcmIF')
%
%   输出参数:
%      createdInput  - 成功创建的输入信号列表 (元胞数组)
%      createdOutput - 成功创建的输出信号列表 (元胞数组)
%
%   功能描述:
%      为指定模型或子系统创建对应的Goto/From模块，支持AUTOSAR信号名截断功能。
%      可以限制创建特定信号，支持选择性创建输入或输出模块。
%
%   示例:
%      [in, out] = createModGoto(gcb);
%      [in, out] = createModGoto(gcb, 'mode', 'inport');
%      [in, out] = createModGoto(gcb, 'autosarMode', 'halfTail');
%      [in, out] = createModGoto(gcb, 'inList', {'Signal1', 'Signal2'});
%
%   作者: Blue.ge
%   日期: 2025-01-27
%   版本: 2.0
    %% 输入参数验证
    narginchk(1, inf);
    validateattributes(path, {'char', 'string'}, {'scalartext'}, mfilename, 'path', 1);
    
    % 确保输入为字符向量
    path = char(path);

    %% 参数解析
    p = inputParser;
    p.FunctionName = mfilename;
    
    addRequired(p, 'path', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'mode', 'both', @(x) any(validatestring(x, {'inport', 'outport', 'both'})));
    addParameter(p, 'inList', {}, @iscell);
    addParameter(p, 'outList', {}, @iscell);
    addParameter(p, 'suffixStr', 'NoTail', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'bkHalfLength', 25, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
    addParameter(p, 'isCreateMatch', false, @islogical);
    addParameter(p, 'autosarMode', '', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'prefixName', 'CcmIF', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    
    parse(p, path, varargin{:});


    % 获取解析后的参数
    mode = p.Results.mode;
    inList = p.Results.inList;
    outList = p.Results.outList;
    suffixStr = char(p.Results.suffixStr);
    bkHalfLength = p.Results.bkHalfLength;
    isCreateMatch = p.Results.isCreateMatch;
    autosarMode = char(p.Results.autosarMode);
    prefixName = char(p.Results.prefixName);

    %% 当前路径验证
    try
        get_param(path, 'Name');
    catch ME
        error('createModGoto:invalidPath', '无效的路径 "%s": %s', path, ME.message);
    end
    
    if ~strcmp(get_param(path, 'Parent'), gcs)
        open_system(get_param(path, 'Parent')); % 需要返回上一层执行
    end

    %% 根据模式设置启用标志
    switch mode
        case 'inport'
            isEnableIn = true;
            isEnableOut = false;
        case 'outport'
            isEnableIn = false;
            isEnableOut = true;
        case 'both'
            isEnableIn = true;
            isEnableOut = true;
        otherwise
            error('createModGoto:invalidMode', '无效的模式: %s', mode);
    end

    %% 确定是否截断信号名
    if ~isempty(autosarMode)
        truncateSignal = true;
        fprintf('AUTOSAR模式: %s (将截断信号名)\n', autosarMode);
    else
        truncateSignal = false;
        fprintf('AUTOSAR模式: 关闭 (不截断信号名)\n');
    end

    %% 获取模型信息
    modelHandle = get_param(path, 'Handle');
    inports = get_param(modelHandle, 'InputPorts');
    outports = get_param(modelHandle, 'OutputPorts');
    PortConnectivity = get_param(modelHandle, 'PortConnectivity');
    parent = get_param(modelHandle, 'Parent');
    PortHandles = get_param(modelHandle, 'PortHandles');
    Outport = PortHandles.Outport;

    [modelName, PortsIn, PortsOut] = findModPorts(path, 'skipTrig', false);

    %% 设置模块尺寸
    bkSize = [-bkHalfLength -7 bkHalfLength 7];

    %% 输入处理逻辑
    createdInput = {};
    if isEnableIn
        fprintf('-----------------开始创建输入From模块-----------------\n');
        
        % 创建输入端口并连接
        sz = size(PortsIn);
        for i = 1:sz(1)  % inports 是个cell，不能用length
            % 判断这个端口是否有连接相关的模块，如果有，则跳过此循环
            if PortConnectivity(i).SrcBlock ~= -1
                continue
            end
    
            inPos = inports(i,:);
            % 根据模型内部名称，得到端口名称
            if isempty(PortsIn)
                break
            end
            inportName = get_param(PortsIn{i}, 'Name');
            
            % 如果有后缀，去掉后缀
            if endsWith(inportName, suffixStr)
                inportName = extractBefore(inportName, length(inportName) - length(suffixStr) + 1);
            end

            % 根据AUTOSAR模式，截断信号名
            if truncateSignal
                inportName = findNameAutosar(inportName, 'nameMd', modelName, 'type', 'Inport', 'mode', autosarMode, 'prefixName', prefixName);
            end
            
            % 确定模块位置
            posBase = [inPos(1)-200, inPos(2), inPos(1)-200, inPos(2)];
            posFrom = posBase + bkSize;

            % 如果inList不为空，则判断端口是否在其中
            if ~isempty(inList) && ~ismember(inportName, inList)
                fprintf('%s不在输入端口列表中，创建Ground模块\n', inportName);

                % 创建Ground模块
                fromBlock = add_block('built-in/Ground', [parent '/' inportName], ...
                          'Position', posFrom);
        
                % 创建连线
                creatLines([fromBlock, modelHandle]);
                continue
            end
    
            % 信号属于接口信号，创建From模块
            inputBlock = add_block('built-in/From', [parent '/From'], 'MakeNameUnique', 'on', ...
                      'Position', posFrom);
            set_param(inputBlock, 'GotoTag', inportName);
    
            % 创建连线
            creatLines([inputBlock, modelHandle]);

            % 记录创建好的端口名
            createdInput = [createdInput, inportName];
        end
        fprintf('-----------------输入From模块创建完成-----------------\n');
    end
    
    %% 输出处理逻辑
    createdOutput = {};
    if isEnableOut
        fprintf('-----------------开始创建输出Goto模块-----------------\n');
        
        % 创建输出端口并连接
        for j = 1:length(Outport)
            % 判断这个端口是否有连接相关的模块，如果有，则跳过此循环
            if get(Outport(j)).Line ~= -1
                continue
            end

            outPos = outports(j,:);
            % 根据模型内部名称，得到端口名称，如果对于无端口的子模型，跳出循环
            if isempty(PortsOut)
                break
            end
            outportName = get_param(PortsOut{j}, 'Name');
            
            % 如果有后缀，去掉后缀
            if endsWith(outportName, suffixStr)
                outportName = extractBefore(outportName, length(outportName) - length(suffixStr) + 1);
            end
            
            % 根据AUTOSAR模式，截断信号名
            if truncateSignal
                outportName = findNameAutosar(outportName, 'nameMd', modelName, 'type', 'Outport', 'mode', autosarMode, 'prefixName', prefixName);
            end

            % 如果outList不为空，则判断端口是否在其中
            if ~isempty(outList) && ~ismember(outportName, outList)
                fprintf('%s不在输出端口列表中\n', outportName);
                continue
            end
    
            % 确定模块位置
            posBase = [outPos(1)+200, outPos(2), outPos(1)+200, outPos(2)];
            posGoto = posBase + bkSize;
            posMatch = posGoto + [200 0 200 0] + [-75 0 75 0];

            % 创建Goto模块
            outputBlock = add_block('built-in/Goto', [parent '/Goto'], 'MakeNameUnique', 'on', ...
                      'Position', posGoto);
            set_param(outputBlock, 'GotoTag', outportName);

            % 如果需要，创建匹配的From模块
            if isCreateMatch
                bkMatch = add_block('built-in/From', [parent '/From'], 'MakeNameUnique', 'on', ...
                          'Position', posMatch);
                set_param(bkMatch, 'GotoTag', outportName);
            end

            % 创建连线
            creatLines([modelHandle, outputBlock]);
    
            % 记录创建好的端口名
            createdOutput = [createdOutput, outportName];
        end
        fprintf('-----------------输出Goto模块创建完成-----------------\n');
    end

    %% 调整模型尺寸
    changeModSize(path, 'wid', 400);
    
    %% 显示创建结果
    fprintf('\n创建结果:\n');
    fprintf('输入信号: %d 个\n', length(createdInput));
    fprintf('输出信号: %d 个\n', length(createdOutput));
    if truncateSignal
        fprintf('AUTOSAR信号名截断模式: %s\n', autosarMode);
    end
end

  