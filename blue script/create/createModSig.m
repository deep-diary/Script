function createModSig(pathMd, varargin)
%%
% 目的: 对模型输入输出端口的信号线进行解析
% 输入：
%       pathMd 模型路径；
%       mode  输入输出类型，可选【inport  outport  both】
% 返回：Null
% 范例： 
% createModSig(gcs,'skipTrig',true,'isEnableIn',true,'isEnableOut',true,...
% 'resoveValue',false,'logValue',false,'testValue',false)
% 作者： Blue.ge
% 日期： 2023-9-5
%%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'skipTrig',true);      % 设置变量名和默认参数
    addParameter(p,'isEnableIn',true);      % 设置变量名和默认参数 可选 true, false
    addParameter(p,'isEnableOut',true);      % 设置变量名和默认参数 可选  true, false
    addParameter(p,'resoveValue',false);      % 设置变量名和默认参数 可选  true, false
    addParameter(p,'logValue',false);      % 设置变量名和默认参数 可选  true, false
    addParameter(p,'testValue',false);      % 设置变量名和默认参数 可选  true, false
    addParameter(p,'dispName',true);      % 设置变量名和默认参数 可选  true, false
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值


    skipTrig = p.Results.skipTrig;
    isEnableIn = p.Results.isEnableIn;
    isEnableOut = p.Results.isEnableOut;
    resoveValue = p.Results.resoveValue;
    logValue = p.Results.logValue;
    testValue = p.Results.testValue;
    dispName = p.Results.dispName;

    % 信号解析，测试等，都需要显示解析信号名
    if logValue || testValue || resoveValue
        dispName = true;
    end

    %% 找到模型端口
    PortHandles = get_param(pathMd, 'PortHandles');
    inports = PortHandles.Inport;
    outports = PortHandles.Outport;
    %% 找到有效路径
    [ModelName, validPath] = findValidPath(pathMd);
    InportCell = find_system(validPath,'SearchDepth',1,'BlockType','Inport');  %获取顶层Inport模块路径
    OutportCell = find_system(validPath,'SearchDepth',1,'BlockType','Outport');  %获取顶层Outport模块路径
    %% 解析信号
    if isEnableIn
        for i = 1:length(inports)  % 跳过trig 端口
            InportName = get_param(InportCell{i},'Name');  %输入模块名称;  %输入模块名称
            hLine = get_param(inports(i), 'Line');
            if dispName
                set(hLine,'Name',InportName)  %设置信号线名称为输入模块名称
            else
                set(hLine,'Name','')  %设置信号线名称为输入模块名称
            end
            set(hLine,'MustResolveToSignalObject',resoveValue)   %设置信号线关联Simulink Signal Object
            set(hLine,'DataLogging',logValue) 
            set(hLine,'TestPoint',testValue)
        end
    end
        
    if isEnableOut
        for i = 1:length(outports)  
            OutportName = get_param(OutportCell{i},'Name');  %输入模块名称
            hLine = get_param(outports(i), 'Line');
            if dispName
                set(hLine,'Name',OutportName)  %设置信号线名称为输入模块名称
            else
                set(hLine,'Name','')  %设置信号线名称为输入模块名称
            end
            set(hLine,'MustResolveToSignalObject',resoveValue)   %设置信号线关联Simulink Signal Object
            set(hLine,'DataLogging',logValue) 
            set(hLine,'TestPoint',testValue)
        end
    end
end

