function [createdInput, createdOutput] = createModGoto(path, varargin)
%%
% 目的: 给定一个模型或者子模型，创建对应的goto或者from模块，并进行连线。
% 输入：
%       inList: 限制创建的输入信号
%       outList：限制创建的输出信号
%       isEnableIn：使能禁止输入，false则不创建输入信号
%       isEnableOut：使能禁止输入，false则不创建输出信号
% 返回：成功创建好的信号
% 范例： createModGoto(gcb, 'mode','both')
% 范例： createModGoto(gcb, 'mode','both','suffixStr','In')
% 作者： Blue.ge
% 日期： 20230928
%%
    % 设置默认端口间距
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'mode','both');      % 设置变量名和默认参数
%     addParameter(p,'isDelSuffix',false);      % 设置变量名和默认参数
    addParameter(p,'isCreateMatch',false);      % 设置变量名和默认参数
    addParameter(p,'suffixStr','NoTail');      % 设置变量名和默认参数
    addParameter(p,'inList',{}); 
    addParameter(p,'outList',{}); 
    addParameter(p,'bkHalfLength',25); 
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值


    isEnableIn = false;
    isCreateMatch = p.Results.isCreateMatch;
    isEnableOut = false;
    mode = p.Results.mode;
    inList = p.Results.inList;
    outList = p.Results.outList;
    bkHalfLength = p.Results.bkHalfLength;
    suffixStr=p.Results.suffixStr;

    %% 当前路径验证
    if ~strcmp(get_param(path, 'Parent'), gcs)
        open_system(get_param(path, 'Parent')) % 需要返回上一层执行
    end

    %% 获取公共参数

    if strcmp(mode, 'inport')
        isEnableIn=true;
    end
    if strcmp(mode, 'outport')
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

    [name,PortsIn,PortsOut] = findModPorts(path,'skipTrig',false);

    bkSize = [-bkHalfLength -7 bkHalfLength 7];

    %% 输入处理逻辑

    createdInput={};
    if isEnableIn
        sprintf('-----------------start to creat the inpurt Goto Blocks of the model');
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
             % 如果有后缀，去掉后缀
            
            if endsWith(inportName,suffixStr)
                inportName=extractBefore(inportName,length(inportName)-length(suffixStr)+1);
            end
            
            % 确定模块位置
            posBase = [inPos(1)-200, inPos(2), inPos(1)-200, inPos(2)];
            posFrom =  posBase + bkSize;

            % 如果inList不为空，则判断端口是否在其中
            if ~isempty(inList) && ~ismember(inportName, inList)
                fprintf('%s不在输入端口列表中\n', inportName);

                % built-in/Goto，built-in/Inport, built-in/From
                fromBlock = add_block('built-in/Ground', [parent '/' inportName], ...
                          'Position', posFrom);
        
                % 创建连线
                creatLines([fromBlock, modelHandle])
                continue
            end
    
        
            % signal is belongs to interface signal，创建模块
            inputBlock = add_block('built-in/From', [parent '/From'], 'MakeNameUnique','on', ...
                      'Position', posFrom);
            set_param(inputBlock, 'GotoTag', inportName);
    
            % 创建连线
            creatLines([inputBlock, modelHandle])

            % 记录创建好的端口名
            createdInput=[createdInput,inportName];
        end
        sprintf('-----------------end creating the inpurt Goto Blocks of the model');
    end
    
    %% 输出处理逻辑
    createdOutput={};
    i = length(PortsIn);
    if isEnableOut
        sprintf('-----------------start to creat the output From Blocks of the model');
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
            % 如果inList不为空，则判断端口是否在其中
            if ~isempty(outList) && ~ismember(outportName, outList)
                fprintf('%s不在输入端口列表中\n', outportName);
                continue
            end
    
            % 确定模块位置
            posBase = [outPos(1)+200, outPos(2), outPos(1)+200, outPos(2)];
            posGoto =  posBase + bkSize;
            posMatch = posGoto + [200 0 200 0] + [-75 0 75 0];

            % 创建模块
            outputBlock = add_block('built-in/Goto', [parent '/Goto'], 'MakeNameUnique','on', ...
                      'Position', posGoto);
            set_param(outputBlock, 'GotoTag', outportName);

            if isCreateMatch
                bkMatch = add_block('built-in/From', [parent '/From'], 'MakeNameUnique','on', ...
                          'Position', posMatch);
                set_param(bkMatch, 'GotoTag', outportName);
            end

            % 创建连线
            creatLines([modelHandle, outputBlock])
    
            % 记录创建好的端口名
            createdOutput=[createdOutput,outportName];
        end
        sprintf('-----------------end creating the output From Blocks of the model');
    end

%     changeModSize(path,'wid',400)
end

  