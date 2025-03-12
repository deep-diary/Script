function result = createGoto(modelName, inportList, outportList)
% modelName是已经打开的模型名称
% 如果不存在，弹出对话框提示下并直接退出函数
% 如果确认已经打开，则执行如下操作
% 1.查找未连接任何模块的输入端口，为其创建一个goto模块，其位置跟对应端口在同一个水平上， 并在其右边100的位置上，创建后将两者连接起来
% 
% 2.查找未连接任何模块的输出端口，为其创建一个goto模块，其位置跟对应端口在同一个水平上， 并在其左边100的位置上，创建后将两者连接起来


    % 检查模型是否已经打开
%     if ~bdIsLoaded(modelName)
%         % 如果模型未打开，弹出提示框并退出函数
%         errordlg(['模型 ' modelName ' 未打开'], '错误');
%         result = false; % 返回 false 表示操作失败
%         return;
%     end
    
    % 获取模型尺寸
%     modelPosition = get_param(modelName, 'Position');
    
    % 获取模型的根级输入端口
    inports = find_system(modelName, 'SearchDepth', 1, 'BlockType', 'Inport', 'Parent', modelName);
    
    % 获取模型的根级输出端口
    outports = find_system(modelName, 'SearchDepth', 1, 'BlockType', 'Outport', 'Parent', modelName);
    
    % 遍历根级输入端口，为其创建 Goto 模块并连接
    for i = 1:numel(inports)
        inportHandle = get_param(inports{i}, 'PortHandles');
        portName=get_param(inports{i}, 'Name');
        portName = getArxmlName(portName);

        % 如果inportList不为空，则做如下判断：
        % 判断输入端口是否在inportList，如果不在，则continue返回
        % 如果inportList不为空，则判断端口是否在其中
        if ~isempty(inportList) && ~ismember(portName, inportList)
            fprintf('%s不在输入端口列表中\n', portName);
            continue
        end
        
        ready=delPortsTerminator(inportHandle);
        % 如果该信号不是接terminator
        if ~ready
            continue
        end

        inportPosition = get_param(inports{i}, 'Position');
        gotoBlock = add_block('built-in/Goto', [modelName '/' portName '_Goto'], ...
                              'Position', [inportPosition(1)+300, inportPosition(2), inportPosition(1)+350, inportPosition(2)+10]);
        set_param(gotoBlock, 'GotoTag', portName);
        
        gotoHandle = get_param(gotoBlock, 'PortHandles');
        add_line(modelName, inportHandle.Outport, gotoHandle.Inport, 'autorouting', 'on');
    end
    
    % 遍历根级输出端口，为其创建 Goto 模块并连接
    for i = 1:numel(outports)
        outportHandle = get_param(outports{i}, 'PortHandles');
        portName=get_param(outports{i}, 'Name');
        portName = getArxmlName(portName);

        % 如果outportList不为空，则做如下判断：
        % 判断输出端口是否在outportList，如果不在，则continue返回
        if ~isempty(outportList) && ~ismember(portName, outportList)
            fprintf('%s不在输出端口列表中\n', portName);
            continue
        end
        ready=delPortsGround(outportHandle);
        % 如果该信号不是接ground
        if ~ready
            continue
        end

        outportPosition = get_param(outports{i}, 'Position');
        fromBlock = add_block('built-in/From', [outports{i} '_From'], ...
                              'Position', [outportPosition(1)-350, outportPosition(2), outportPosition(1)-300, outportPosition(2)+10]);
        set_param(fromBlock, 'GotoTag', portName);

        fromHandle = get_param(fromBlock, 'PortHandles');
        add_line(modelName, fromHandle.Outport, outportHandle.Inport, 'autorouting', 'on');
    end
    
    result = true; % 返回 true 表示操作成功
end



