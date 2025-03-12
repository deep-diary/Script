function createSigOnLine(pathMd, varargin)
%%
% 目的: 对模型输入输出端口的信号线进行解析，将其定义成全局变量
% 输入：
%       pathMd 模型路径；
%       mode  输入输出类型，可选【inport  outport  both】
% 返回：Null
% 范例： 
% createSigOnLine(gcs,'skipTrig',true,'isEnableIn',true,'isEnableOut',true,...
% 'resoveValue',false,'logValue',false,'testValue',false)
% 作者： Blue.ge
% 日期： 2023-9-5
%%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'skipTrig',false);      % 设置变量名和默认参数
    addParameter(p,'isEnableIn',true);      % 设置变量名和默认参数 可选 true, false
    addParameter(p,'isEnableOut',true);      % 设置变量名和默认参数 可选  true, false
    addParameter(p,'resoveValue',false);      % 设置变量名和默认参数 可选  true, false
    addParameter(p,'logValue',false);      % 设置变量名和默认参数 可选  true, false
    addParameter(p,'testValue',false);      % 设置变量名和默认参数 可选  true, false
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值


    skipTrig = p.Results.skipTrig;
    isEnableIn = p.Results.isEnableIn;
    isEnableOut = p.Results.isEnableOut;
    resoveValue = p.Results.resoveValue;
    logValue = p.Results.logValue;
    testValue = p.Results.testValue;

        %% 找到有效路径
    [ModelName, validPath] = findValidPath(pathMd);

    if isEnableIn
        start=1;
        if skipTrig
            start = 2; % 跳过trig信号
        end
        InportCell = find_system(validPath,'SearchDepth',1,'BlockType','Inport');  %获取顶层Inport模块路径
        for i = start:length(InportCell)  % 跳过trig 端口
            InportName = get_param(InportCell{i},'Name');  %输入模块名称
            InportHandle = get_param(InportCell{i},'Handle');  %信号线句柄
            LineHandleStruct = get(InportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Outport;
            set(LineHandle,'Name',InportName)  %设置信号线名称为输入模块名称
            set(LineHandle,'MustResolveToSignalObject',resoveValue)   %设置信号线关联Simulink Signal Object
            set(LineHandle,'DataLogging',logValue) 
            set(LineHandle,'TestPoint',testValue)
        end
    end
        
    if isEnableOut
        OurportCell = find_system(validPath,'SearchDepth',1,'BlockType','Outport');  %获取顶层Outport模块路径
        for i = 1:length(OurportCell)  
            OutportName = get_param(OurportCell{i},'Name');  %输入模块名称
            OutportHandle = get_param(OurportCell{i},'Handle');  %信号线句柄
            LineHandleStruct = get(OutportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Inport;
            set(LineHandle,'Name',OutportName)  %设置信号线名称为输入模块名称
            set(LineHandle,'MustResolveToSignalObject',resoveValue)   %设置信号线关联Simulink Signal Object
            set(LineHandle,'DataLogging',logValue) 
            set(LineHandle,'TestPoint',testValue)
        end
    end
end