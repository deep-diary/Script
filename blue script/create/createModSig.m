function createModSig(pathMd, varargin)
%%
% 功能: 对模型输入输出端口的信号线进行命名和配置
% 输入:
%       pathMd - 模型路径
%       varargin - 可选参数对
%           'skipTrig' - 是否跳过触发器端口，默认true
%           'isEnableIn' - 是否启用输入端口处理，默认true
%           'isEnableOut' - 是否启用输出端口处理，默认true
%           'resoveValue' - 是否解析为信号对象，默认false
%           'logValue' - 是否启用数据记录，默认false
%           'testValue' - 是否启用测试点，默认false
%           'dispName' - 是否显示信号名称，默认true
%           'truncateSignal' - 是否截断AUTOSAR信号名，默认false
% 返回: 无
% 示例: 
% createModSig(gcs,'skipTrig',true,'isEnableIn',true,'isEnableOut',true,...
% 'resoveValue',false,'logValue',false,'testValue',false,'truncateSignal',true)
% 作者: Blue.ge
% 日期: 2023-9-5
%%
    clc
    
    %% 解析输入参数
    p = inputParser;            % 创建输入参数解析器
    addParameter(p,'skipTrig',true);      % 设置触发器端口参数，默认跳过
    addParameter(p,'isEnableIn',true);      % 设置输入端口参数，默认启用，可选 true, false
    addParameter(p,'isEnableOut',true);      % 设置输出端口参数，默认启用，可选 true, false
    addParameter(p,'resoveValue',false);      % 设置信号对象参数，默认不解析，可选 true, false
    addParameter(p,'logValue',false);      % 设置数据记录参数，默认不记录，可选 true, false
    addParameter(p,'testValue',false);      % 设置测试点参数，默认不启用，可选 true, false
    addParameter(p,'dispName',true);      % 设置显示名称参数，默认显示，可选 true, false
    addParameter(p,'truncateSignal',false);      % 设置截断信号名参数，默认不截断，可选 true, false
    parse(p,varargin{:});       % 解析输入参数并将解析结果存储到当前工作区的变量中，然后从变量中取值

    % skipTrig = p.Results.skipTrig;  % 当前未使用，保留以备将来扩展
    isEnableIn = p.Results.isEnableIn;
    isEnableOut = p.Results.isEnableOut;
    resoveValue = p.Results.resoveValue;
    logValue = p.Results.logValue;
    testValue = p.Results.testValue;
    dispName = p.Results.dispName;
    truncateSignal = p.Results.truncateSignal;

    % 信号解析等属性需要显示信号名称
    if logValue || testValue || resoveValue
        dispName = true;
    end

    %% 找到模型端口
    PortHandles = get_param(pathMd, 'PortHandles');
    inports = PortHandles.Inport;
    outports = PortHandles.Outport;
    
    %% 找到有效路径
    [~, validPath] = findValidPath(pathMd);
    InportCell = find_system(validPath,'SearchDepth',1,'BlockType','Inport');  % 获取所有Inport模块路径
    OutportCell = find_system(validPath,'SearchDepth',1,'BlockType','Outport');  % 获取所有Outport模块路径
    
    %% 处理信号
    if isEnableIn
        for i = 1:length(inports)  % 遍历输入端口
            InportName = get_param(InportCell{i},'Name');  % 获取模块名称
            
            % 根据truncateSignal参数决定是否截断信号名
            if truncateSignal
                InportName = truncateSignalName(InportName);
            end
            
            hLine = get_param(inports(i), 'Line');
            if dispName
                set(hLine,'Name',InportName)  % 设置信号线名称为模块名称
            else
                set(hLine,'Name','')  % 清空信号线名称
            end
            set(hLine,'MustResolveToSignalObject',resoveValue)   % 设置信号线关联Simulink Signal Object
            set(hLine,'DataLogging',logValue) 
            set(hLine,'TestPoint',testValue)
        end
    end
        
    if isEnableOut
        for i = 1:length(outports)  
            OutportName = get_param(OutportCell{i},'Name');  % 获取模块名称
            
            % 根据truncateSignal参数决定是否截断信号名
            if truncateSignal
                OutportName = truncateSignalName(OutportName);
            end
            
            hLine = get_param(outports(i), 'Line');
            if dispName
                set(hLine,'Name',OutportName)  % 设置信号线名称为模块名称
            else
                set(hLine,'Name','')  % 清空信号线名称
            end
            set(hLine,'MustResolveToSignalObject',resoveValue)   % 设置信号线关联Simulink Signal Object
            set(hLine,'DataLogging',logValue) 
            set(hLine,'TestPoint',testValue)
        end
    end
end

%% 辅助函数：截断信号名
function truncatedName = truncateSignalName(originalName)
    % 截断AUTOSAR信号名，提取第一个下划线后面的部分
    % 例如: 'NetReqFromPrkgClimaEveMgr_NetReqFromPrkgClimaEveMgr' -> 'NetReqFromPrkgClimaEveMgr'
    % 如果结果以_read或_write结尾，则去掉该后缀

    % 查找第一个下划线的位置
    underscorePos = strfind(originalName, '_');
    
    if ~isempty(underscorePos) && underscorePos(1) > 1
        % 提取第一个下划线后面的部分
        truncatedName = originalName(underscorePos(1)+1:end);
    else
        % 如果没有找到下划线或下划线在开头，返回原名
        truncatedName = originalName;
    end

    % 检查并去除_read或_write后缀
    if endsWith(truncatedName, '_read')
        truncatedName = truncatedName(1:end-5);
    elseif endsWith(truncatedName, '_write')
        truncatedName = truncatedName(1:end-6);
    end
end