function [maxInPos, maxOutPos] = findPortPos(varargin)
%%
% 目的: 找到当前系统中最大输入输出端口的位置坐标。
% 输入：
%       Null
% 返回：模型4个点的坐标
% 范例： [maxInPos, maxOutPos] = findPortPos()
% 作者： Blue.ge
% 日期： 20231114
%%
    clc

    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'path',gcs);      % 默认参数为当前路径
    
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    path = p.Results.path;
    
    %%
    shift = 500;
    [ModelName,PortsIn,PortsOut] = findModPorts(path);
    pos = findGcsPos();

    if isempty(PortsIn)
        posX = pos(1)-shift;
        posY = pos(2);
        maxInPos = [posX, posY, posX + 30, posY+14 ];
    else
        maxInPos = get_param(PortsIn{end}, 'Position');
    end

    if isempty(PortsOut)
        posX = pos(3)+shift;
        posY = pos(2);
        maxOutPos = [posX, posY, posX + 30, posY+14 ];
    else
        maxOutPos = get_param(PortsOut{end}, 'Position');
    end
    
    

end
