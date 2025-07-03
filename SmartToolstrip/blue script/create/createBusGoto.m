function result = createBusGoto()
%CREATEBUSGOTO 为总线信号创建对应的Goto模块
%   result = createBusGoto() 为当前选中的总线信号创建对应的Goto模块。
%   该函数会自动为总线中的每个未连接的输出信号创建Goto模块，并建立连接。
%
%   输入参数:
%       无
%
%   输出参数:
%       result - 操作结果，成功返回true，失败返回false
%
%   示例:
%       createBusGoto()
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
        
        % 为每个未连接的输出信号创建Goto模块
        for i = 1:length(signalArray)
            % 跳过已连接的端口
            if portConnectivity(i+1).DstBlock ~= -1
                continue;
            end
            
            % 获取信号名称和位置
            signalName = signalArray{i};
            busPosition = portConnectivity(i+1).Position;
            
            % 提取标签名称
            tagParts = split(signalName, '.');
            tag = tagParts{end};
            
            % 创建Goto模块
            gotoBlock = add_block('built-in/Goto', ...
                [parentPath '/Goto'], ...
                'GotoTag', tag, ...
                'MakeNameUnique', 'on', ...
                'Position', [busPosition(1)+200, busPosition(2)-5, ...
                            busPosition(1)+250, busPosition(2)+5]);
            
            % 获取Goto模块端口句柄
            gotoPorts = get_param(gotoBlock, 'PortHandles');
            gotoPosition = get_param(gotoPorts.Inport, 'Position');
            
            % 连接总线到Goto模块
            add_line(parentPath, ...
                    [busPosition(1), busPosition(2); ...
                     gotoPosition(1), gotoPosition(2)]);
        end
        
        
        result = true;
        fprintf('成功为总线 %s 创建Goto模块\n', busName);
        
    catch ME
        % 错误处理
        error('创建Goto模块时发生错误: %s', ME.message);
        result = false;
    end
end

  