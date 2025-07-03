function [numInputPorts, numOutputPorts] = createPortsGoto(varargin)
%%
% 目的: 给定一个端口列表，创建对应的输入输出端口，及其相连接的goto或者from模块，并进行连线。
% 输入：
%       inList: 限制创建的输入信号
%       outList：限制创建的输出信号
%       inputStep：输入端口步长
%       outputStep：输出端口步长
% 返回：成功创建好的信号
% 范例： createPortsGoto(inList, []),
% 作者： Blue.ge
% 日期： 20230928
%%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'posIn',[-10000 0]);      % 设置变量名和默认参数 [0 0]
    addParameter(p,'posOut',[10000 0]);      % 设置变量名和默认参数 [9000 0]
    addParameter(p,'NAStr','NA');      % 设置变量名和默认参数
    addParameter(p,'step',30);      % 设置变量名和默认参数
    addParameter(p,'inList',{});      % 设置变量名和默认参数
    addParameter(p,'outList',{});      % 设置变量名和默认参数
    addParameter(p,'keepName',false);      % 设置变量名和默认参数
    addParameter(p,'mode','tail');      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    NAStr = p.Results.NAStr;
    inList = p.Results.inList;
    outList = p.Results.outList;
    inputStep = p.Results.step;
    outputStep = p.Results.step;
    posIn = p.Results.posIn;
    posOut = p.Results.posOut;
    mode = p.Results.mode;

    if posIn(1) == -10000 && posOut(1) == -10000  % 默认值
        pos = findGcsPos();
        posIn = [pos(1)-500,pos(2)];               % [50, 50]; % 输入端口起始位置
        posOut = [pos(3),pos(2)];     % 输出端口起始位置
    end


    %% 过滤 创建一个新的 cell 数组，不包括 'NAStr'
    if ~isempty(inList)
        disp('inList is true')
        inList = inList(~strcmp(inList, NAStr));
    else
        disp('inList is None')
    end

    if ~isempty(outList)
        disp('outList is true')
        outList = outList(~strcmp(outList, NAStr));
    else
        disp('outList is None')
    end
    
    

    %%
    numInputPorts = 0; % 记录已生成的输入端口数量
    numOutputPorts = 0; % 记录已生成的输出端口数量
    
    % 循环生成输入端口
    for i = 1:length(inList)
        numInputPorts = numInputPorts + 1;
        Name=inList{i};
        if strcmp(Name, NAStr)
            continue
        end

        %% 生成输入端口
        pos=[posIn(1), posIn(2) + (numInputPorts-1)*inputStep, posIn(1)+30, posIn(2) + 14 + (numInputPorts-1)*inputStep];
        bkIn = add_block('built-in/Inport', [gcs '/' Name], ...
                      'Position', pos);  

        % 根据信号名，获取数据类型dataType
        [dataType, ~, ~, ~, ~] = findNameType(Name);
        set_param(bkIn,'OutDataTypeStr',dataType);
        set_param(bkIn,"BackgroundColor","green");

        
        %% 创建goto
        gotoPos = pos+[300 0 300 0];
        bkGoto = add_block('built-in/Goto', [gcs '/Goto'],'MakeNameUnique','on', ...
                              'Position',gotoPos);
        set_param(bkGoto, 'GotoTag', Name);

        %% 连线
        creatLines([bkIn,bkGoto])
    end



    % 循环生成输出端口
    for i=1:length(outList)
        numOutputPorts = numOutputPorts + 1;
        Name=outList{i};
        if strcmp(Name, NAStr)
            continue
        end

        %% 输出端口名字变换
        [dataType, nameOutPort] = findNameMdOut(Name,'mode',mode);

        %% 生成输出端口
        pos=[posOut(1), posOut(2) + (numOutputPorts-1)*outputStep, posOut(1)+30, posOut(2) + 14 + (numOutputPorts-1)*outputStep];
        bkOut = add_block('built-in/Outport', [gcs '/' nameOutPort], 'MakeNameUnique','on',...
                  'Position', pos); % 'Port', num2str(numOutputPorts), 
        % 根据信号名，获取数据类型dataType
        
        set_param(bkOut,'OutDataTypeStr',dataType);
        set_param(bkOut,"BackgroundColor","orange");
       
        %% 创建from
        fromPos = pos+[-300 0 -300 0];
        bkFrom = add_block('built-in/From', [gcs '/From'],'MakeNameUnique','on', ...
                              'Position',fromPos);
        set_param(bkFrom, 'GotoTag', Name);

        %% 连线
        creatLines([bkFrom,bkOut])

    end
        
end

