function createMergeFrom(path, sigList,sigOut, varargin)
%%
    % 目的: 对Merge 创建对应的From, 信号来自于sigList
    % 输入：
    %       信号列表
    % 返回： None
    % 范例： createMergeFrom(path, sigList)
    % 作者： Blue.ge
    % 日期： 20231207
%%
    
    clc
            %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'resovleSig',true);      % 设置变量名和默认参数


    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    
    resovleSig = p.Results.resovleSig;

    %%
    % 检查信号长度跟Merge 长度是否一致
    len = str2double(get_param(path, 'Inputs'));
    if len~=length(sigList)
        error('wrong signal length')
    end

    PortConnectivity = get_param(path, 'PortConnectivity');

    %% 创建输入From 模块
    for i=1:len
        posBase = PortConnectivity(i).Position;
        posBase = posBase + [-150 0];
        pos = [posBase posBase]+ [-100 -7 100 7 ];
        bk_from = add_block('built-in/From', [gcs '/From'], 'MakeNameUnique','on',...
          'Position', pos, 'GotoTag', sigList{i}); % 'Port', num2str(numOutputPorts), 
        bk_merg = get_param(path, 'Handle');

        hArray = [bk_from bk_merg];
        PortHd = get_param(hArray, 'PortHandles');

        add_line(gcs, PortHd{1}.Outport, PortHd{2}.Inport(i), 'autorouting', 'on');
    end
    %% 创建输出Goto
    posBase = PortConnectivity(len+1).Position;
    posBase = posBase + [250 0];
    pos = [posBase posBase]+ [-100 -7 100 7 ];
    bk_goto = add_block('built-in/Goto', [gcs '/Goto'], 'MakeNameUnique','on',...
      'Position', pos, 'GotoTag', sigOut); % 'Port', num2str(numOutputPorts), 
    bk_merg = get_param(path, 'Handle');

    hArray = [bk_merg bk_goto];
    PortHd = get_param(hArray, 'PortHandles');

    hline = add_line(gcs, PortHd{1}.Outport, PortHd{2}.Inport, 'autorouting', 'on');

    if resovleSig
        set(hline,'Name',sigOut)  %设置信号线名称为输入模块名称
        set(hline,'MustResolveToSignalObject',1)   %设置信号线关联Simulink Signal Object
    end
end


% changeModPortName(gcb, 'SM123', 'TmComprCtrl')