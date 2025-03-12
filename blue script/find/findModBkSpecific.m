function [bkIn, bkOut] = findModBkSpecific(path, varargin)
%%
% 目的: find the the sepcific block from the mode
% 输入：
%       condition：useless, unconnected
% 返回：bkIn: 输入模块列表，bkOut: 输出模块列表
% 范例：[bkIn, bkOut] = findModBkSpecific(gcb, 'condition', 'unconnected') useless, unconnected
% 说明：找到路径中模型的输入输出端口
% 作者： Blue.ge
% 日期：20231117

    %%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'condition','useless');      % 设置变量名和默认参数
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    condition = p.Results.condition;

    %%
    [bkInAll, bkOutAll] = findModBk(path);
    [ModelName,PortsIn,PortsOut] = findModPorts(path);
    bkIn = {};
    bkOut = {};

    %% deal with the input
    for i=1:length(bkInAll)
        h = bkInAll(i);

        if strcmp(condition, 'useless')  % useless means ground and terminator
            if h==-1    
                continue
            end
            name=get_param(PortsIn{i}, 'Name');
            bkType=get_param(h, 'BlockType');
            if strcmp(bkType, 'Ground')
                bkIn = [bkIn,name];
            end
        elseif strcmp(condition, 'unconnected')
            if h~=-1    
                continue
            end
            name=get_param(PortsIn{i}, 'Name');
            bkIn = [bkIn,name];
        else
            error('pls input the right condition, the valiable are: useless, unconnected')
        end
        
    end

    %% deal with the output
    for i=1:length(bkOutAll)
        h = bkOutAll(i);

        if strcmp(condition, 'useless')  % useless means ground and terminator
            if h==-1    
                continue
            end
            name=get_param(PortsOut{i}, 'Name');
            bkType=get_param(h, 'BlockType');
            if strcmp(bkType, 'Terminator')
                bkOut = [bkOut,name];
            end
        elseif strcmp(condition, 'unconnected')
            if h~=-1    
                continue
            end
            name=get_param(PortsOut{i}, 'Name');
            bkOut = [bkOut,name];
        else
            error('pls input the right condition, the valiable are: useless, unconnected')
        end
        
    end



end


