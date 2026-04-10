function changeSigName(template, varargin)
%%
    % 目的: 改变端口的信号类型
    % 输入：
    %        template： 模板路径
    %        all： 是否在全局进行改变
    % 返回： 
    % 范例： changeSigName('Template_ChangeName.xlsx','keepPrefix',false)
    % 作者： Blue.ge
    % 日期： 20240603
    %%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'all',true);      % 设置变量名和默认参数
    addParameter(p,'sheet','All');      % Signals, Parameters
    addParameter(p,'keepPrefix',true);      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    allLev = p.Results.all;
    sheet = p.Results.sheet;
    keepPrefix = p.Results.keepPrefix;

    %% 读取模板信号，分别得到改名前后的

    %% 如果是观测量
    if strcmp(sheet, 'Signals')||strcmp(sheet, 'All')
        dataTable = readtable(template, 'Sheet', 'Signals');
        NmBefores = dataTable.NameBefore;
        NmAfters = dataTable.NameAfter;
        sz = size(dataTable);
        for i=1:sz(1)
            NmBefore = NmBefores{i};
            [typeBefore, ~, ~, ~, ~] = findNameType(NmBefore);
            
            NmAfter = NmAfters{i};
            [typeAfter, ~, ~, ~, ~] = findNameType(NmAfter);

            %% 
            [portList, sigList, gotoFromList] = findNameSigRelated(NmBefore);
            % 更新端口
            for j=1:length(portList)
                NmAct = get_param(portList{j}, 'Name');
                NameChangedTo = findNameSigChg(NmAct, NmAfter,'keepPrefix',keepPrefix);
                set_param(portList{j}, 'Name', NameChangedTo, ...
                    'OutDataTypeStr', typeAfter);
            end

            % 更新信号
            for j=1:length(sigList)
                NmAct = get_param(sigList(j), 'Name');
                NameChangedTo = findNameSigChg(NmAct, NmAfter,'keepPrefix',keepPrefix);
                set_param(sigList(j), 'Name', NameChangedTo); % 句柄
            end

            % 更新goto from
            for j=1:length(gotoFromList)
                NmAct = get_param(gotoFromList{j}, 'GotoTag');
                NameChangedTo = findNameSigChg(NmAct, NmAfter,'keepPrefix',keepPrefix);
                set_param(gotoFromList{j}, 'GotoTag', NameChangedTo);
            end

        end

    end

    %% 如果是标定量
    if strcmp(sheet, 'Parameters')||strcmp(sheet, 'All')
        dataTable = readtable(template, 'Sheet', 'Parameters');
        NmBefores = dataTable.NameBefore;
        NmAfters = dataTable.NameAfter;
        sz = size(dataTable);

        for i=1:sz(1)
            NmBefore = NmBefores{i};
            [typeBefore, ~, ~, ~, ~] = findNameType(NmBefore);
            
            NmAfter = NmAfters{i};
            [typeAfter, ~, ~, ~, ~] = findNameType(NmAfter);
            %% 找到匹配的标定量
            [constList, relayList,CompToList] = findNameParamRelated(NmBefore);

            %% 更新常量
            for j=1:length(constList)
                set_param(constList{j}, 'Value', NmAfter, ...
                    'OutDataTypeStr', typeAfter);
            end

            %% 更新Relay
            for j=1:length(relayList)
                nameOn = get_param(relayList{i},'OnSwitchValue');
                nameOff = get_param(relayList{i},'OffSwitchValue');
                if strcmp(nameOn, NmBefore)
                    set_param(relayList{i},'OnSwitchValue',NmAfter);
                end

                if strcmp(nameOff, NmBefore)
                    set_param(relayList{i},'OffSwitchValue',NmAfter);
                end
            end 

            %% 更新比较常量
            for j=1:length(CompToList)
                set_param(CompToList{j}, 'const', NmAfter);
            end

        end

    end