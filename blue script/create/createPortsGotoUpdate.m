function [inList, outList] = createPortsGotoUpdate(varargin)
%CREATEPORTSGOTOUPDATE 为无效的From/Goto信号创建对应的端口和信号
%   [INLIST, OUTLIST] = CREATEPORTSGOTOUPDATE() 使用默认参数创建端口和信号
%   [INLIST, OUTLIST] = CREATEPORTSGOTOUPDATE('Parameter', Value, ...) 使用指定参数创建
%
%   输入参数（名值对）:
%      'path'        - 目标系统路径 (字符串), 默认值: gcs (当前系统)
%      'wid'         - 模型宽度 (正整数), 默认值: 400
%      'mode'        - 信号名称处理模式 (字符串), 默认值: 'keep'
%                      可选值: 'pre'(保留前缀), 'tail'(保留后缀), 'keep'(保持原样)
%
%   输出参数:
%      inList        - 创建的输入信号名称列表 (元胞数组)
%      outList       - 创建的输出信号名称列表 (元胞数组)
%
%   功能描述:
%      1. 查找系统中无效的From块（没有对应的Goto）
%      2. 为这些From块创建对应的输入端口和Goto块
%      3. 查找系统中无效的Goto块（没有对应的From）
%      4. 为这些Goto块创建对应的输出端口
%      5. 调整模型大小以适应新创建的端口
%
%   示例:
%      [inSignals, outSignals] = createPortsGotoUpdate()
%      [inSignals, outSignals] = createPortsGotoUpdate('path', 'myModel/subsystem1')
%      [inSignals, outSignals] = createPortsGotoUpdate('wid', 800, 'mode', 'pre')
%
%   注意事项:
%      1. 使用前需要打开目标Simulink模型
%      2. 函数会自动调整模型大小以适应新创建的端口
%
%   参见: CREATEPORTSGOTO, FINDUSELESSFROM, FINDUSELESSGOTO, CHANGEMODSIZE
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 20231114

    %% 输入参数处理
    p = inputParser;
    addParameter(p, 'resoveValue', false, @islogical);
    addParameter(p, 'logValue', false, @islogical);
    addParameter(p, 'testValue', false, @islogical);
    addParameter(p, 'enableIn', false, @islogical);
    addParameter(p, 'enableOut', false, @islogical);

    addParameter(p, 'path', gcs, @ischar);
    addParameter(p, 'wid', 400, @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
    addParameter(p, 'mode', 'keep', @(x)ismember(x,{'pre','tail','keep'}));

    parse(p, varargin{:}); 
    
    resoveValue = p.Results.resoveValue;
    logValue = p.Results.logValue;
    testValue = p.Results.testValue;
    enableIn = p.Results.enableIn;
    enableOut = p.Results.enableOut;

    path = p.Results.path;
    wid = p.Results.wid;
    mode = p.Results.mode;

    %% 为没有连线的子模型创建goto from
    createModGotoAll();

    %% 找到当前模型中无效的From
    uselessFrom = findUselessFrom('path', path);

    %% 找到输入输出端口的位置
    [maxInPos, maxOutPos] = findPortPos('path', path);

    maxInPos = maxInPos + [0 30 0 30];
    maxOutPos = maxOutPos + [0 30 0 30];
    
    %% 根据无效的From收集需要创建的输入信号
    inList = {};
    if ~isempty(uselessFrom)
        for i = 1:length(uselessFrom)
            name = get_param(uselessFrom{i}, 'GotoTag');
            inList = [inList name];
        end
        inList = unique(inList);
    end

    %% 找到当前模型中无效的Goto
    uselessGoto = findUselessGoto();
    
    %% 根据无效的Goto收集需要创建的输出信号
    outList = {};
    if ~isempty(uselessGoto)
        for i = 1:length(uselessGoto)
            name = get_param(uselessGoto{i}, 'GotoTag');
            outList = [outList name];
        end
        outList = unique(outList);
    end
    
    %% 创建端口和Goto/From块
    if ~isempty(inList) || ~isempty(outList)
        % 计算端口位置
        inPortPos = maxInPos(1:2);
        outPortPos = maxOutPos(1:2);
        
        % 创建端口和信号
        createPortsGoto(...
            'inList', inList, ...
            'outList', outList, ...
            'posIn', inPortPos, ...
            'posOut', outPortPos, ...
            'mode', mode);
        
        % 调整模型大小
        changeModSize(gcs, 'wid', wid);
        
        % 为子模型创建Goto/From连接,前提是内部两层以下的子模型，第二层就需要直接创建端口了
        if(length(split(path,'/'))>2)
            createModGoto(path, 'mode', 'both');
        end
    else
        disp('没有找到需要更新的信号。');
    end

    % 是否对输入输出信号进行解析
    changeLinesPortAttr(path, ...
            "resoveValue",resoveValue, ...
            "logValue",logValue, ...
            "testValue",testValue, ...
            "enableIn",enableIn, ...
            "enableOut",enableOut ...
            )
end

