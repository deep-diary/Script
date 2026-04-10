function result = createBusPort()
%CREATEBUSPORT 为总线信号创建对应的输出端口
%   result = createBusPort() 为当前选中的总线信号创建对应的输出端口。
%   该函数会自动为总线中的每个未连接的输出信号创建Outport模块，并建立连接。
%
%   输入参数:
%       无
%
%   输出参数:
%       result - 操作结果，成功返回true，失败返回false
%
%   示例:
%       createBusPort()
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2023-10-09
%   版本: 1.1

    try
        % 获取当前选中的模块
        selectedBlocks = get(gcbh);
        if isempty(selectedBlocks)
            error('未选中任何模块');
        end
        
        busHandle = selectedBlocks.Handle;
        if isempty(busHandle)
            error('无法获取总线模块句柄');
        end
        
        % 获取总线模块信息
        busName = get_param(busHandle, 'Name');
        parentPath = get_param(busHandle, 'Parent');
        outputSignals = get_param(busHandle, 'OutputSignals');
        portConnectivity = get_param(busHandle, 'PortConnectivity');
        
        % 检查输出信号
        if isempty(outputSignals)
            error('总线模块没有输出信号');
        end
        
        % 分割信号名称
        signalArray = strsplit(outputSignals, ',');
        
        % 为每个未连接的输出信号创建Outport模块
        for i = 1:length(signalArray)
            % 跳过已连接的端口
            if portConnectivity(i+1).DstBlock ~= -1
                continue;
            end
            
            % 获取信号名称和位置
            signalName = signalArray{i};
            busPosition = portConnectivity(i+1).Position;
            
            % 提取端口名称
            nameParts = strsplit(signalName, '.');
            portName = nameParts{end};
            
            % 创建Outport模块
            portBlock = add_block('built-in/Outport', ...
                [parentPath '/' portName], ...
                'Position', [busPosition(1)+200, busPosition(2)-5, ...
                            busPosition(1)+230, busPosition(2)+5]);
            
            % 获取Outport模块端口句柄
            portHandles = get_param(portBlock, 'PortHandles');
            portPosition = get_param(portHandles.Inport, 'Position');
            
            % 连接总线到Outport模块
            add_line(parentPath, ...
                    [busPosition(1), busPosition(2); ...
                     portPosition(1), portPosition(2)]);
        end
        
        result = true;
        fprintf('成功为总线 %s 创建输出端口\n', busName);
        
    catch ME
        % 错误处理
        error('创建输出端口时发生错误: %s', ME.message);
        result = false;
    end
end

  