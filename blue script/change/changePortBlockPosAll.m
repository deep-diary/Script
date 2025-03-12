function changePortBlockPosAll(newPosin, newPosout)
%%
    % 目的: 重新整理当前模型所有的输入输出端口及其对应连线block的位置
    % 输入：
    %       newPosin： 新输入端口位置[-730 3600] 
    %       newPosout: 新输出端口位置[0 3600]
    % 返回： Null
    % 范例： 打开模型，执行changePortBlockPosAll([-730 3600], [0 3600])
    % 引用： Null    
    % 作者： Blue.ge
    % 日期： 20231020
    %%
    clc
    [ModelName,PortsIn,PortsOut] = findModPorts(bdroot);
    stp=30;
    %% 处理输入
    posX = newPosin(1);
    for i=1:length(PortsIn)
        posY = newPosin(2) + stp * i;
        changePortBlockPos(PortsIn{i}, [posX posY])
    end

    %% 处理输出
    posX = newPosout(1);
    for i=1:length(PortsOut)
        posY = newPosin(2) + stp * i;
        changePortBlockPos(PortsOut{i}, [posX posY])
    end
    
end