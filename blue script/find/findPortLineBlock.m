function [hPort, hLine, hBlock] = findPortLineBlock(portPath)
%%
    % 目的: 找到跟port相连的句柄，包括端口本身，连接线，对应模块的句柄
    % 输入：
    %       portPath： 端口路径
    % 返回： hPort：端口句柄，hLine： 对应线的句柄，hBlock：连接的模块句柄
    % 范例： [hPort, hLine, hBlock] = findPortLineBlock(gcb)
    % 引用： 可能的引用场景比如批量改变这些模块的位置，或者批量删除这些模块等
    % 作者： Blue.ge
    % 日期： 20231020
    %%
    clc
    bkType=get_param(portPath, 'BlockType');
    
    hPort=get_param(portPath, 'Handle');
    
    hPortCon=get_param(hPort, 'PortHandles');
    
    if strcmp(bkType, 'Inport')
    
        hLine=get_param(hPortCon.Outport, 'Line');
        if hLine == -1
            hBlock = -1;
            return
        end
    
        hBlock = get_param(hLine, 'DstBlockHandle');
    
    elseif strcmp(bkType, 'Outport')
    
        hLine=get_param(hPortCon.Inport, 'Line');
        if hLine == -   1
            hBlock = -1;
            return
        end
    
        hBlock = get_param(hLine, 'SrcBlockHandle');
    
    end
end