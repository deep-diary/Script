function delSigOnLine(pathMd, varargin)
    % V1.0
    % 2023-9-5
    % Blue
    % MATLAB 2022b
    % 目的： 对模型输入输出端口的信号线进行反解析
    % 输入： 
    %   pathMd 模型路径（引用源的模型路径A引用模型B，这里是A的路径）；
    %   mode  输入输出类型，可选【inport outport both partial】
    %   sigList  信号列表
    % 返回： 无
    % 使用示例  delSigOnLine(gcs)

    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'isEnableIn',true);      % 设置变量名和默认参数 可选 in, out
    addParameter(p,'isEnableOut',true);      % 设置变量名和默认参数 可选 in, out
    addParameter(p,'isPartial',false);      % 
    addParameter(p,'sigList',{});      % 

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    isEnableIn = p.Results.isEnableIn;
    isEnableOut = p.Results.isEnableOut;
    isPartial = p.Results.isPartial;
    sigList = p.Results.sigList;


    %% 找到有效路径
    [ModelName, validPath] = findValidPath(pathMd);

    if isEnableIn
        InportCell = find_system(validPath,'SearchDepth',1,'BlockType','Inport');  %获取顶层Inport模块路径
        for i = 1:length(InportCell)  
            InportHandle = get_param(InportCell{i},'Handle');  %信号线句柄
            LineHandleStruct = get(InportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Outport;
            
            if isPartial
                Name=get_param(LineHandle,'Name');  %获得信号线名称
                if ismember(Name,sigList)
                    set(LineHandle,'MustResolveToSignalObject',0)   %设置信号线关联Simulink Signal Object
                end
            else
                set(LineHandle,'MustResolveToSignalObject',0)   %设置信号线关联Simulink Signal Object
                set(LineHandle,'Name','')  %清除信号线名称
            end
        end
    end
    

    if isEnableOut
        OurportCell = find_system(validPath,'SearchDepth',1,'BlockType','Outport');  %获取顶层Outport模块路径
        for i = 1:length(OurportCell)  
            OutportHandle = get_param(OurportCell{i},'Handle');  %信号线句柄
            LineHandleStruct = get(OutportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Inport;

            if isPartial
                Name=get_param(LineHandle,'Name');  %获得信号线名称
                if ismember(Name,sigList)
                    set(LineHandle,'MustResolveToSignalObject',0)   %设置信号线关联Simulink Signal Object
                end
            else
                set(LineHandle,'MustResolveToSignalObject',0)   %设置信号线关联Simulink Signal Object
                set(LineHandle,'Name','')  %清除信号线名称
            end
        end
    end

end