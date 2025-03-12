function changeModSize(pathMd, varargin)
%%
    % 目的: 根据子模型或者引用模型的最大端口数量，设置模型的长宽
    % 输入：
    %        pathMd： 模型路径  
    % 返回： Null
    % 范例： changeModSize(gcb)
    % 引用： 创建引用模型后，可以设置对应的模型，然后根据该模型的端口数量，设置引用模型大小
    % 作者： Blue.ge
    % 日期： 20231020
    %%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'wid',400);      % 设置变量名和默认参数
    
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    wid = p.Results.wid;

    %%  
    % 得到模型句柄
    stp = 30;
    h = get_param(pathMd, 'Handle');
    [ModelName,PortsIn,PortsOut, PortsSpecial] = findModPorts(pathMd);
    portNum = max(length(PortsIn), length(PortsOut));
    targetWid = max(wid, 300);
    targetHeight = max(portNum*stp,60);
    
    pos = get_param(h,'Position');
    posNew = [pos(1:2), pos(1)+targetWid, pos(2)+targetHeight];
    set_param(h,'Position', posNew);
    %% 整理连线
    changeLineArrange('path',pathMd)
%     changeLineArrange('path',gcb)
end