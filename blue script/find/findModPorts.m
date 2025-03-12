function [ModelName,PortsIn,PortsOut,PortsSpecial] = findModPorts(pathMd, varargin)
%%
% 目的: 找到路径中模型的输入输出端口
% 输入：
%       Null
% 返回：ModelName: 模型名称，PortsIn: 输入端口列表，PortsOut: 输出端口列表
% 范例：[ModelName,PortsIn,PortsOut] = findModPorts(gcs, 'getType', 'path', 'FiltUnconnected',true) 
% 范例：[ModelName,PortsIn,PortsOut] = findModPorts(gcb, 'getType', 'Name') 
% 说明：找到路径中模型的输入输出端口
% 作者： Blue.ge
% 日期： 20231020
%%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'getType','path');      % 设置变量名和默认参数
    addParameter(p,'skipTrig',false);      % 设置变量名和默认参数
    addParameter(p,'FiltUnconnected',false);      % 设置变量名和默认参数
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值


    getType = p.Results.getType;
    skipTrig = p.Results.skipTrig;
    FiltUnconnected = p.Results.FiltUnconnected;

    %% 找到所有端口
    [ModelName, validPath] = findValidPath(pathMd);
    PortsInAll = find_system(validPath,'SearchDepth',1,'BlockType','Inport');
    PortsOutAll = find_system(validPath,'SearchDepth',1,'BlockType','Outport');

    PortsSpecial = -1;
    if ~strcmp(validPath, bdroot(validPath))  % 如果不是root, 则尝试获取特殊端口
        portCn = get_param(validPath,'PortConnectivity')
        ports = get_param(validPath,'Ports')
        if sum(ports(3:end))  % 存在特殊端口
            PortsSpecialT = portCn(length(PortsInAll) + 1);  % 比输入端口数量 + 1
            PortsSpecial = PortsSpecialT.SrcBlock;
        end
    end


    %% 过滤端口
    PortsIn = {};
    PortsOut = {};

    if FiltUnconnected
        for i=1:length(PortsInAll)
            LineHandles = get_param(PortsInAll{i},'LineHandles');
            if LineHandles.Outport == -1
                PortsIn{end+1} = PortsInAll{i};
            end
        end
        for i=1:length(PortsOutAll)
            LineHandles = get_param(PortsOutAll{i},'LineHandles');
            if LineHandles.Inport == -1
                PortsOut{end+1} = PortsOutAll{i};
            end
        end
    else
        PortsIn = PortsInAll;
        PortsOut = PortsOutAll;
    end
    
    % 忽略function call
    if length(PortsIn)>=2&&(skipTrig || strcmp(get_param(PortsIn{1},'OutputFunctionCall'),'on'))
        PortsIn = PortsIn(2:end);
    end

    if strcmp(getType, 'path')
        
    else
        for i=1:length(PortsIn)
            PortsIn{i} = get_param(PortsIn{i}, getType);
        end

        for i=1:length(PortsOut)
            PortsOut{i} = get_param(PortsOut{i}, getType);
        end
    end


end
