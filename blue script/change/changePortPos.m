function changePortPos(varargin)
%%
    % 目的: 将输入输出端口排整齐
    % 输入：  
    % 返回： None
    % 范例： 执行changePortPos('isEnableIn',true,'isEnableOut',true)
    % 场景： 整理输入输出端口 
    % 作者： Blue.ge
    % 日期： 20240429
    %%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'stp',30);      % 设置变量名和默认参数
    addParameter(p,'isEnableIn',true);      % 设置变量名和默认参数
    addParameter(p,'isEnableOut',true);      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    stp = p.Results.stp;
    isEnableIn = p.Results.isEnableIn;
    isEnableOut = p.Results.isEnableOut;

        %% 找到输出端口
    [ModelName,PortsIn,PortsOut] = findModPorts(gcs, 'getType', 'Handle', 'FiltUnconnected',true) ;

    cntIn = length(PortsIn);
    cntOut = length(PortsOut);


    %% 移动输入端口
    if cntIn > 1 && isEnableIn
        base = get_param(PortsIn{1},'Position');
        for i=2:cntIn
            pos = base + [0 stp*(i-1) 0 stp*(i-1)];
            set_param(PortsIn{i},'Position', pos);
        end
    end

    %% 移动输出端口
    if cntOut > 1 && isEnableOut
        base = get_param(PortsOut{1},'Position');
        for i=2:cntOut
            pos = base + [0 stp*(i-1) 0 stp*(i-1)];
            set_param(PortsOut{i},'Position', pos);
        end
    end


end