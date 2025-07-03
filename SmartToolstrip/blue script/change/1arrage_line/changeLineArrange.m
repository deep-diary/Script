function changeLineArrange(varargin)
%%
% 目的: 让模型对应连线对齐
% 输入：
%       Null
% 返回： Null
% 范例： changeLineArrange(varargin)
% 作者： 原创： 前人； 修改： Blue.ge
% 日期： 20231114
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'path',gcb);      % 默认参数为当前路径
    addParameter(p,'distIn',200);      % 默认参数为当前路径
    addParameter(p,'distOut',200);      % 默认参数为当前路径
    
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    path = p.Results.path;
    blkDistance_inport = p.Results.distIn; %位置
    blkDistance_outport = p.Results.distOut; %位置

    lineh = get_param(path, 'LineHandles');
    porth = get_param(path, 'PortHandles');

 
%% 设置输入接口模块
for i = 1:1:length(porth.Inport)
    % 如果当前port口上悬空，没有连线，则跳过
    if isequal(lineh.Inport(i), -1)
        continue;
    end
    
    % 获取当前port口的位置
    [portx, porty, ~, ~] = lgetpos(porth.Inport(i));
    % 获取当前port口连线的源模块的句柄
    curtLineSrcBlkH = get_param(lineh.Inport(i), 'SrcBlockHandle');
    
    % 如果源模块是subsystem，则不对该subsystem的位置进行设置
    if isequal('SubSystem', get_param(curtLineSrcBlkH, 'BlockType'))
        continue;
    end
    % 获取源模块的宽度和高度值
    [~, ~, width, height] = lgetpos(curtLineSrcBlkH);
    % 重新设置源模块的位置，保持其宽度和高度值不变
%     get(get(lineh.Inport(i)).SrcBlockHandle).Position
    newx = portx - blkDistance_inport - width/2;
    newy = porty - height / 2;
    lsetpos(curtLineSrcBlkH, newx, newy, width, height);
end
 
%% 设置输出接口模块
for i = 1:1:length(porth.Outport)
    % 如果当前port口上悬空，没有连线，则跳过
    if isequal(lineh.Outport(i), -1)
        continue;
    end
 
    % curtPortPos = get_param(porth.Outport(i), 'Position');
    % 获取当前port口的位置
    [portx, porty, ~, ~] = lgetpos(porth.Outport(i));
    % 获取当前port口连线的目标模块的句柄
    curtLineDstBlkH = get_param(lineh.Outport(i), 'DstBlockHandle');
    
    % 如果目标模块是subsystem，则不对该subsystem的位置进行设置
    if isequal('SubSystem', get_param(curtLineDstBlkH, 'BlockType'))
        continue;
    end
    % 如果目标模块是 swithc, 则不对该subsystem的位置进行设置
    if isequal('Switch', get_param(curtLineDstBlkH, 'BlockType'))
        continue;
    end
    
    % 当前port连线的目标模块可能有多个模块，因此挨个处理
    for j = 1:1:length(curtLineDstBlkH)
        % 获取源模块的宽度和高度值
        [~, ~, width, height] = lgetpos(curtLineDstBlkH(j));
        % newx = curtPortPos(1) + blkDistance;
        % newy = curtPortPos(2) - height / 2 + height * (j - 1);
        newx = portx + blkDistance_outport - width/2;
        newy = porty - height / 2 + height * (j - 1);
        lsetpos(curtLineDstBlkH(j), newx, newy, width, height);
    end
end
 
%% 设置 enable 或 trigger 接口，两种类型的port合并后处理
EnableTriggerPortH = -1;
EnableTriggerLineH = -1;
if (~isequal(lineh.Enable, -1)) && (~isempty(lineh.Enable))
    EnableTriggerPortH = porth.Enable;
    EnableTriggerLineH = lineh.Enable;
end
if (~isequal(lineh.Trigger, -1)) && (~isempty(lineh.Trigger))
    EnableTriggerPortH = porth.Trigger;
    EnableTriggerLineH = lineh.Trigger;
end
 
if (~isequal(lineh.Ifaction, -1)) && (~isempty(lineh.Ifaction))
    EnableTriggerPortH = porth.Ifaction;
    EnableTriggerLineH = lineh.Ifaction;
end

if ~isequal(EnableTriggerPortH, -1)
    % 获取当前port口的位置
    [portx, porty, ~, ~] = lgetpos(EnableTriggerPortH);
    % 获取当前port口连线的源模块的句柄
    curtLineSrcBlkH = get_param(EnableTriggerLineH, 'SrcBlockHandle');
    
    % 只有当enable port的源模块是 inport 类型的模块时，才对其位置进行优化
    if any(strcmp({'Inport','From'}, get_param(curtLineSrcBlkH, 'BlockType')))
        % 获取源模块的宽度和高度值
        [~, ~, width, height] = lgetpos(curtLineSrcBlkH);
        % 重新设置源模块的位置，保持其宽度和高度值不变
        newx = portx - width * 3;
        newy = porty - height * 2;
        lsetpos(curtLineSrcBlkH, newx, newy, width, height);
    end
end
 
end