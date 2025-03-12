function [numInputPorts, numOutputPorts] = createGotoBasedPorts(varargin)
%%
% 目的: 为输入输出端口，创建对应的goto, from模块，并进行连线。
% 输入：
% 返回：成功创建好的信号
% 范例： createGotoBasedPorts()
% 作者： Blue.ge
% 日期： 20230429
%%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器

    addParameter(p,'FiltUnconnected',true);      % 设置变量名和默认参数
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    FiltUnconnected = p.Results.FiltUnconnected;

    %% 整理端口位置
    changePortPos('isEnableIn',true,'isEnableOut',true)

    %% 找到对应的端口
    [ModelName,PortsIn,PortsOut] = findModPorts(gcs, 'getType', 'Handle', 'FiltUnconnected',FiltUnconnected) 


    %% 循环生成输入端口
    numInputPorts = 0; % 记录已生成的输入端口数量
    numOutputPorts = 0; % 记录已生成的输出端口数量
    
    for i = 1:length(PortsIn)
        numInputPorts = numInputPorts + 1;
        bkIn = PortsIn{i};
        Name=get_param(bkIn, 'Name');
        pos = get_param(bkIn, 'Position');

        %% 创建goto
        gotoPos = pos+[300 0 300 0];
        bkGoto = add_block('built-in/Goto', [gcs '/Goto'],'MakeNameUnique','on', ...
                              'Position',gotoPos);
        set_param(bkGoto, 'GotoTag', Name);

        %% 连线
        creatLines([bkIn,bkGoto])
    end



    %% 循环生成输出端口
    for i=1:length(PortsOut)
        numOutputPorts = numOutputPorts + 1;
        %% 输出端口名字变换
        bkOut = PortsOut{i};
        Name=get_param(bkOut, 'Name');
        pos = get_param(bkOut, 'Position');
       
        %% 创建from
        fromPos = pos+[-300 0 -300 0];
        bkFrom = add_block('built-in/From', [gcs '/From'],'MakeNameUnique','on', ...
                              'Position',fromPos);
        set_param(bkFrom, 'GotoTag', Name);

        %% 连线
        creatLines([bkFrom,bkOut])

    end
        
end

