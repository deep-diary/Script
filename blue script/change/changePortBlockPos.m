function changePortBlockPos(portPath, newPos)
%%
    % 目的: 改变输入输出端口及其对应连线block的位置
    % 输入：
    %       portPath： 端口路径
    %       newPos:    新位置的起始坐标 [100 100 ]    
    % 返回： hPort：端口句柄，hLine： 对应线的句柄，hBlock：连接的模块句柄
    % 范例： 选中端口，执行changePortBlockPos(gcb, [-2825 200])
    % 场景： 此函数单独移动一对端口模块，可以根据端口路径，实现批量移动所需信号    
    % 作者： Blue.ge
    % 日期： 20231020
    %%
    clc
    [hPort, hLine, hBlock] = findPortLineBlock(portPath);

    bk = get(hPort);
    posType = bk.BlockType;

    %% 移动端口
    posPort = bk.Position;
    wid = posPort(3)-posPort(1);
    height = posPort(4)-posPort(2);
    posPortNew = [newPos, newPos(1)+wid, newPos(2) + height];
%     if strcmp(posType, 'Inport')
%         posPortNew = [newPos, newPos(1)+wid, newPos(2) + height];
%     end
%     if strcmp(posType, 'Outport')
%         posPortNew = [newPos, newPos(1)+wid, newPos(2) + height];
%     end
    set_param(hPort,'Position', posPortNew)

    
    %% 移动对应的Block
    posBlock = get(hBlock).Position;
    wid = posBlock(3)-posBlock(1);
    height = posBlock(4)-posBlock(2);
    posBlockNew = [newPos, newPos(1)+wid, newPos(2) + height];
    
    if strcmp(posType, 'Inport')
        posBlockNew = posBlockNew + [200 0 200 0];
    end
    if strcmp(posType, 'Outport')
        posBlockNew = posBlockNew + [-200 0 -200 0];
    end
    set_param(hBlock,'Position', posBlockNew)
end