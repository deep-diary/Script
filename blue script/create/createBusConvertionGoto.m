function result = createBusConvertionGoto()
%%
% 目的: 为Bus Selector 中的信号，依次创建goto，并将其自动连线
% 输入：
%       模型路径
% 返回：None
% 范例：creatBusSigAll(gcs)
% 说明：
% 0. 鼠标点击在Selector上，获取Selector句柄
% 1. 获取bus selector上所有的信号
% 2. 遍历所有的信号，在bus selector右边一定距离上，生成Gogo模块，其中GotoTag设置为信号名称，标签可以设置为信号_Goto
% 3. 将创建好的Goto模块，跟Bus相连
% 作者： Blue.ge
% 日期： 20231201
%%
    clc
    % 获取输出信号列表
    [ModelName,PortsIn,PortsOut] = findModPorts(gcs);
    sigLimit=cell(1,length(PortsOut));
    for i=1:length(PortsOut)
        sigLimit{i} = get_param(PortsOut{i},'Name');
    end

    % 获取选中的模型
    selectedBlocks = get(gcbh);
    busHandle = selectedBlocks.Handle;
    
    name = get_param(busHandle, 'Name');
    parent = get_param(busHandle, 'Parent');
    busPortH = get_param(busHandle, 'PortHandles');
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
        bus_pos=PortConnectivity(i+1).Position;


        % deal with SignalConversion
        % built-in/Goto，built-in/Inport, built-in/From, built-in/SignalConversion
        SignalConversionBlock = add_block('built-in/SignalConversion', [parent '/' name,'_sc'], ...
                  'Position', [bus_pos(1)+200, bus_pos(2)-5, bus_pos(1)+250, bus_pos(2)+5]);

        SignalConversionPortH = get_param(SignalConversionBlock, 'PortHandles');
        % add_line
        add_line(parent,busPortH.Outport(i),SignalConversionPortH.Inport(1), "autorouting",'smart')



        % deal with goto
        % signal is belongs to interface signal
        if ismember(name,sigLimit)
            gotoBlock = add_block('built-in/Goto', [parent '/' name,'_Goto'], ...
                      'Position', [bus_pos(1)+400, bus_pos(2)-5, bus_pos(1)+450, bus_pos(2)+5]);
            set_param(gotoBlock, 'GotoTag', name);
            gotoPortH = get_param(gotoBlock, 'PortHandles');
    
            % add_line
            add_line(parent,SignalConversionPortH.Outport(1),gotoPortH.Inport(1), "autorouting",'smart')
        else
            terminatorBlock = add_block('built-in/Terminator', [parent '/' name,'_Term'], ...
                      'Position', [bus_pos(1)+400, bus_pos(2)-10, bus_pos(1)+420, bus_pos(2)+10]);
            terminatorPortH = get_param(terminatorBlock, 'PortHandles');
    
            % add_line
            add_line(parent,SignalConversionPortH.Outport(1),terminatorPortH.Inport(1), "autorouting",'smart')
        end

    end

    result = true;
end

  