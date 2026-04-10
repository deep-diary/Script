function [createdInput, createdOutput] = createModConstDisp(path, varargin)
%%
% 目的: create const and disp for path mode
% 输入：
%       path: mode path

% 返回：成功创建好的信号
% 范例： createModConstDisp(gcb)
% 作者： Blue.ge
% 日期： 20240131
%%
    % 设置默认端口间距
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'mode','both');      % 设置变量名和默认参数
    addParameter(p,'bkHalfLength',15); 
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    mode = p.Results.mode;
    bkHalfLength = p.Results.bkHalfLength;

    %% 获取公共参数

    if strcmp(mode, 'inport')
        isEnableIn=true;
        isEnableOut = false;
    end
    if strcmp(mode, 'outport')
        isEnableIn = false;
        isEnableOut=true;
    end
    if strcmp(mode, 'both')
        isEnableIn=true;
        isEnableOut=true;
    end

    modelHandle = get_param(path, 'Handle');
    inports = get_param(modelHandle, 'InputPorts');
    outports = get_param(modelHandle, 'OutputPorts');
    PortConnectivity = get_param(modelHandle, 'PortConnectivity');
    parent = get_param(modelHandle, 'Parent');

    [name,PortsIn,PortsOut] = findModPorts(path);

    bkSize = [-bkHalfLength -15 bkHalfLength 15];
    bkDisp = [-45 -15 45 15];

    %% 输入处理逻辑

    createdInput={};
    if isEnableIn
        sprintf('-----------------start to creat the inpurt Blocks of the model');
        % 创建输入端口并连接
        sz = size(PortsIn);
        for i = 1:sz(1)  % inports 是个cell(1950        3356),不能用length
            % 判断这个端口是否有连接相关的模块，如果有，则跳过此循环
            if PortConnectivity(i).SrcBlock ~=-1
                continue
            end
    
            inPos = inports(i,:);
            %  根据模型内部名称，得到端口名称
            if isempty(PortsIn)
                break
            end
            inportName = get_param(PortsIn{i}, 'Name');
            [dataType, ~, ~, ~, ~] = findNameType(inportName);
            
            % 确定模块位置
            posBase = [inPos(1)-200, inPos(2), inPos(1)-200, inPos(2)];
            posIn =  posBase + bkSize;


            % signal is belongs to interface signal，创建模块
            inputBlock = add_block('built-in/Constant', [parent '/Constant'], 'MakeNameUnique','on', ...
                      'Position', posIn);
            set_param(inputBlock, 'OutDataTypeStr', dataType);
            set_param(inputBlock, 'Value', '0');
    
            % 创建连线
            creatLines([inputBlock, modelHandle])

            % 记录创建好的端口名
            createdInput=[createdInput,inportName];
        end
        sprintf('-----------------end creating the inpurt Blocks of the model');
    end
    
    %% 输出处理逻辑
    createdOutput={};
    i = length(PortsIn);
    if isEnableOut
        sprintf('-----------------start to creat the output Blocks of the model');
        % 创建输出端口并连接
        sz = size(PortsOut);
        for j = 1:sz(1)
            % 如果有遇到trigger 或enable ，则输入端口数量+1
            if any(strcmp(PortConnectivity(i+j).Type, {'trigger','enable'}))
                i = i+1;
            end

            % 判断这个端口是否有连接相关的模块，如果有，则跳过此循环
            if PortConnectivity(i+j).DstBlock ~=-1
                continue
            end

            outPos = outports(j,:);
            % 根据模型内部名称，得到端口名称，如果对于无端口的子模型，跳出循环
            if isempty(PortsOut)
                break
            end
            outportName = get_param(PortsOut{j}, 'Name');

            % 确定模块位置
            posBase = [outPos(1)+200, outPos(2), outPos(1)+200, outPos(2)];
            posOut =  posBase + bkDisp;

            % 创建模块
            outputBlock = add_block('built-in/Display', [parent '/Display'], 'MakeNameUnique','on', ...
                      'Position', posOut);

            % 创建连线
            creatLines([modelHandle, outputBlock])
    
            % 记录创建好的端口名
            createdOutput=[createdOutput,outportName];
        end
        sprintf('-----------------end creating the output Blocks of the model');
    end
end

  