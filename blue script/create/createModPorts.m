function [createdInport, createdOutport] = createModPorts(path, varargin)
%%
% 目的: 为未连线的子模型端口自动添加输入输出端口，并将其自动连线。
% 输入：
%       Null
% 返回：已经成功创建的端口列表
% 范例：[createdInport, createdOutport] = createModPorts(gcb), 默认为both
% 范例：[createdInport, createdOutport] = createModPorts(gcb,'mode','inport'),
% 范例：[createdInport, createdOutport] = createModPorts(gcb,'mode','outport'),
% 范例：[createdInport, createdOutport] = createModPorts(gcb,'mode','both'),
% 说明：1. 鼠标点击在子模型上，2. 在命令窗口运行此函数
% 作者： Blue.ge
% 日期： 20230928
%%
    % 获取选中的模型
    clc

    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'mode','both');      % 设置变量名和默认参数
    addParameter(p,'isDelSuffix',true);      % 设置变量名和默认参数
    addParameter(p,'suffixStr','');      % 设置变量名和默认参数
    addParameter(p,'findType','base');      % base or interface or None
    addParameter(p,'add','None');      % None, blockType
    addParameter(p,'enFirstTrig',false);      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    mode = p.Results.mode;
    isDelSuffix = p.Results.isDelSuffix;
    suffix=p.Results.suffixStr;
    findType = p.Results.findType;
    enFirstTrig = p.Results.enFirstTrig;
    add = p.Results.add;

    
    %%

    modelHandle = get_param(path, 'Handle');
    isEnableIn = false;
    isEnableOut = false;
   

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
    
    %% 获取子模块的外部输入端口和输出端口
    inports = get_param(modelHandle, 'InputPorts');
    outports = get_param(modelHandle, 'OutputPorts');
   

    PortConnectivity = get_param(modelHandle, 'PortConnectivity');
    parent = get_param(modelHandle, 'Parent');

    [name,PortsIn,PortsOut] = findModPorts(path);

    inNums=length(PortsIn);       %  取得输入端口个数
    outNums=length(PortsOut);     %  取得输出端口个数


%%
    createdInport={};
    if isEnableIn
        % 创建输入端口并连接
        for i = 1:inNums
            inportPosition = inports(i,:);
            % 判断这个端口是否有连接相关的模块，如果有，则返回
            % 这里需要添加代码
            % 判断这个端口是否有连接相关的模块，如果有，则跳过此循环
            if PortConnectivity(i).SrcBlock ~=-1
                continue
            end
    
            inportName=get_param(PortsIn{i}, 'Name');
    %         % 根据信号名，获取数据类型dataType
    %         [dataType, ~, ~, ~, ~] = findNameType(inportName);
    
            % 如果有后缀，去掉后缀
            if isDelSuffix && endsWith(inportName,suffix)
                inportName=extractBefore(inportName,length(inportName)-length(suffix)+1);
            end
    
            if ~strcmp(add, 'None')
                posBase = [inportPosition(1)-400, inportPosition(2), inportPosition(1)-400, inportPosition(2)];
            else
                posBase = [inportPosition(1)-200, inportPosition(2), inportPosition(1)-200, inportPosition(2)];
            end
            posIn =  posBase + [-15 -7 15 7];
            posAdd = posBase + [100 0 100 0]  + [-15 -7 15 7];
            try
                % 尝试创建模块 built-in/Goto，built-in/Inport, built-in/From
                inputBlock = add_block('built-in/Inport', [parent '/' inportName], ...
                           'Position', posIn);
                % 根据信号名，获取数据类型dataType
    
                if strcmp(findType, 'base')
                    [dataType, ~, ~, ~, ~] = findNameType(inportName);
                    set_param(inputBlock,'OutDataTypeStr',dataType);
                elseif strcmp(findType, 'interface')
                    dataType = findNameIFType(inportName);
                    set_param(inputBlock,'OutDataTypeStr',dataType);
                else
                    % done nothing
                end
                
                set_param(inputBlock,"BackgroundColor","green");
    
                % 创建额外模块
          
                if ~strcmp(add, 'None')
                    bkAdd = add_block(['built-in/' add], [parent '/sigCov' ], 'MakeNameUnique','on',...
                               'Position', posAdd);
                end
    
            catch
                % 如果创建模块引发异常，说明模块已存在，您可以在这里处理它
                disp('Inport模块已存在');
                continue
            end
            %% 连线
            if ~strcmp(add, 'None')
                creatLines([inputBlock,bkAdd, modelHandle])
            else
                creatLines([inputBlock, modelHandle])
            end

            %% 如果第一个端口为function call
            if i == 1 && enFirstTrig
                % 将 inputBlock 句柄（Inport模块）中的 'Output function call' 勾选上
                % 这通常意味着启用某种形式的函数调用输出。这个选项的确切名称和方法可能会根据
                % 您使用的 Simulink 版本和模块类型而有所不同。以下代码是一个一般性示例：
                set_param(inputBlock, 'OutputFunctionCall', 'on');  % 根据您的模块类型调整属性名称
                % 将 bkAdd 的 comment 设置为直通
                if ~strcmp(add, 'None')
                    set_param(bkAdd, 'Commented', 'through');  % 假定 '直通' 是通过注释块来实现的
                end
            end
        end
    end
%%
    % 创建输出端口并连接
    createdOutport={};
    i=inNums;  %  取得第一维度

    if isEnableOut
        for j = 1:outNums
            outportPosition = outports(j,:);
            % 判断这个端口是否有连接相关的模块，如果有，则跳过此循环
            if PortConnectivity(i+j).DstBlock ~=-1
                continue
            end
    
            outportName=get_param(PortsOut{j}, 'Name');
            % 如果有后缀，去掉后缀
            if isDelSuffix && endsWith(outportName,suffix)
                outportName=extractBefore(outportName,length(outportName)-length(suffix)+1);
            end


%             % 根据信号名，获取数据类型dataType
%             [dataType, ~, ~, ~, ~] = findNameType(outportName);
            if ~strcmp(add, 'None')
                posBase = [outportPosition(1)+400, outportPosition(2), outportPosition(1)+400, outportPosition(2)];
            else
                posBase = [outportPosition(1)+200, outportPosition(2), outportPosition(1)+200, outportPosition(2)];
            end
            
            posOut =  posBase + [-15 -7 15 7];
            posAdd = posBase + [-100 0 -100 0]  + [-15 -7 15 7];
            try
                outputBlock = add_block('built-in/Outport', [parent '/' outportName], ...
                          'Position', posOut);
                % 根据信号名，获取数据类型dataType
                if strcmp(findType, 'base')
                    [dataType, ~, ~, ~, ~] = findNameType(outportName);
                    set_param(outputBlock,'OutDataTypeStr',dataType);
                elseif strcmp(findType, 'interface')
                    dataType = findNameIFType(outportName);
                    set_param(outputBlock,'OutDataTypeStr',dataType);
                else
                    % done nothing
                end
                
                set_param(outputBlock,"BackgroundColor","orange");

                % 创建额外模块
                if ~strcmp(add, 'None')
                    bkAdd = add_block(['built-in/' add], [parent '/sigCov' ], 'MakeNameUnique','on',...
                               'Position', posAdd);
                end
            catch
                % 如果创建模块引发异常，说明模块已存在，您可以在这里处理它
                disp('Outport模块已存在');
                continue
            end
            % 连线
            if ~strcmp(add, 'None')
                creatLines([modelHandle,bkAdd, outputBlock])
            else
                creatLines([modelHandle, outputBlock])
            end

            createdOutport{end+1}=outportName;
        end
    end 
    %% 改变模型大小
    changeModSize(path)
end



  