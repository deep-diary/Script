function result = createBusGoto()
%%
    % 目的: 点击bus后，为bus信号创建对应的goto模块
    % 输入：
    %       None
    % 返回： None
    % 范例： createBusGoto()
    % 作者： Blue.ge
    % 日期： 20231009
%%
    clc

    % 获取选中的模型
    selectedBlocks = get(gcbh);
    busHandle = selectedBlocks.Handle;
    
    name = get_param(busHandle, 'Name')
    parent = get_param(busHandle, 'Parent')
%     根据bus selector句柄，得到其中的所有信号
    OutputSignals = get_param(busHandle, 'OutputSignals');
    signalArray = strsplit(OutputSignals, ',');
    OutputSignalNames = get_param(busHandle, 'OutputSignalNames');
    
    PortConnectivity = get_param(busHandle, 'PortConnectivity');

    
    % 创建输入端口并连接
    for i = 1:length(signalArray)
        % 判断这个端口是否有连接相关的模块，如果有，则返回
        % 这里需要添加代码
        % 判断这个端口是否有连接相关的模块，如果有，则跳过此循环
        % i+1 表示跳过第一个端口，即输入端口
        if PortConnectivity(i+1).DstBlock ~=-1
            continue
        end
        name = signalArray{i};
        bus_pos=PortConnectivity(i+1).Position

        % built-in/Goto，built-in/Inport, built-in/From
        gotoBlock = add_block('built-in/Goto', [parent '/' name,'_Goto'], ...
                  'Position', [bus_pos(1)+200, bus_pos(2)-5, bus_pos(1)+250, bus_pos(2)+5]);
        set_param(gotoBlock, 'GotoTag', name);

%         inportHandle = get_param([parent '/' inportName,'_From'], 'PortHandles');
        inportHandle = get_param(gotoBlock, 'PortHandles');
        gotoPos = get_param(inportHandle.Inport,'Position')
        add_line(parent, [bus_pos(1), bus_pos(2); gotoPos(1), gotoPos(2)]);
        %         add_line(parent, [inportHandle.Outport '/1'], [busHandle '/' num2str(i)], 'autorouting', 'on');
        %         add_line(parent, inportHandle.Outport, busHandle, 'autorouting', 'on');
    end

    result = true;
end

  