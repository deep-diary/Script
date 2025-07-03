function [createdInport, createdOutport] = createModGroundTerm(path, varargin)
%%
% 目的: 为未连线的子模型端口自动添加输入输出端口，并将其自动连线。
% 输入：
%       Null
% 返回：已经成功创建的端口列表
% 范例：[createdInport, createdOutport] = createModGroundTerm(gcb), 默认为both
% 范例：[createdInport, createdOutport] = createModGroundTerm(path，'mode','inport'),
% 范例：[createdInport, createdOutport] = createModGroundTerm(path，'mode','outport'),
% 范例：[createdInport, createdOutport] = createModGroundTerm(path，'mode','both'),
% 说明：1. 鼠标点击在子模型上，2. 在命令窗口运行此函数
% 作者： Blue.ge
% 日期： 20231018
%%
    % 获取选中的模型
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'mode','both');      % 设置变量名和默认参数
    addParameter(p,'isDelSuffix',false);      % 设置变量名和默认参数
    addParameter(p,'suffixStr','in');      % 设置变量名和默认参数
    
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值


    isEnableIn = false;
    isEnableOut = false;
    mode = p.Results.mode;

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
    modelHandle = get_param(path, 'Handle');
    inports = get_param(modelHandle, 'InputPorts');
    outports = get_param(modelHandle, 'OutputPorts');
    
    inNums=size(inports, 1);  %  取得第一维度
    outNums=size(outports, 1);  %  取得第一维度

    PortConnectivity = get_param(modelHandle, 'PortConnectivity');
    parent = get_param(modelHandle, 'Parent');

    [name,PortsIn,PortsOut] = findModPorts(path);


%%
    createdInport={};
    if isEnableIn
        % 创建输入端口并连接
        for i = 1:inNums
            posIn = inports(i,:);
            % 判断这个端口是否有连接相关的模块，如果有，则返回
            % 这里需要添加代码
            % 判断这个端口是否有连接相关的模块，如果有，则跳过此循环
            if PortConnectivity(i).SrcBlock ~=-1
                continue
            end
    
            inportName=get_param(PortsIn{i}, 'Name');
    
            % 如果有后缀，去掉后缀
            isDelSuffix = p.Results.isDelSuffix;
            suffix=p.Results.suffixStr;
            if isDelSuffix && endsWith(inportName,suffix)
                inportName=extractBefore(inportName,length(inportName)-length(suffix)+1);
            end
    
             
            try
                % 尝试创建模块 built-in/Goto，built-in/Inport, built-in/From
                posX = posIn(1)-150;
                posY = posIn(2);
                pos = [posX-10, posY-10, posX+10, posY+10];
                bkCreated = add_block('built-in/Ground', [gcs '/Ground'],'MakeNameUnique','on', ...
              'Position', pos);
            catch
                % 如果创建模块引发异常，说明模块已存在，您可以在这里处理它
                disp('模块已存在');
                continue
            end
    
            hCreatedPort = get_param(bkCreated, 'PortHandles');
            pos = get_param(hCreatedPort.Outport,'Position');
            add_line(parent, [pos(1), pos(2); posIn(1), posIn(2)]);
            createdInport{end+1}=inportName;
        end
    end
%%
    % 创建输出端口并连接
    createdOutport={};
    i=inNums;  %  取得第一维度

    if isEnableOut
        for j = 1:outNums
            posOut = outports(j,:);
            % 判断这个端口是否有连接相关的模块，如果有，则跳过此循环
            if PortConnectivity(i+j).DstBlock ~=-1
                continue
            end
    
            outportName=get_param(PortsOut{j}, 'Name');
            
            try
                posX = posOut(1)+150;
                posY = posOut(2);
                pos = [posX-10, posY-10, posX+10, posY+10];
                bkCreated = add_block('built-in/Terminator', [gcs '/Terminator'],'MakeNameUnique','on', ...
                          'Position', pos);
                
            catch
                % 如果创建模块引发异常，说明模块已存在，您可以在这里处理它
                disp('模块已存在');
                continue
            end
            hCreatedPort = get_param(bkCreated, 'PortHandles');
            pos = get_param(hCreatedPort.Inport,'Position');
            add_line(parent, [posOut(1), posOut(2); pos(1), pos(2)]);
            createdOutport{end+1}=outportName;
        end
    end 
end



  