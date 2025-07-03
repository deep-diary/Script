function [constList, relayList,CompToList] = findNameParamRelated(Name,varargin)
%%
    % 目的: 根据标定量，找到跟其相关的标定量路径
    % 输入：
    %       Name： 输出信号名称
    % 返回： [constList, relayList,CompToList]: 跟目标信号相关的标定量路径
    % 范例： [constList, relayList,CompToList] = findNameParamRelated('cTmRefriVlvCtrl_X_i16ExvPoseLow')
    % 说明： 比如当前信号名称是'cTmRefriVlvCtrl_X_i16ExvPoseLow', 则如下函数输出跟此标定量相关的路径
    % 作者： Blue.ge
    % 日期： 20240603
%%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'all',true);      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    allLev = p.Results.all;

    %%
    constList = {};
    relayList = {};
    CompToList = {};
    % 常量标定量
    [PathConst, ParamConst] = findParamConstant(bdroot); 
    for i=1:length(PathConst)
        name = get_param(PathConst{i},'Value');
        if strcmp(name,Name)
            constList{end+1} = PathConst{i};
        end
    end
    % Relay标定量
    [PathRelay, ParamRelay] = findParamRelayAll(bdroot); 
    for i=1:length(PathRelay)
        nameOn = get_param(PathRelay{i},'OnSwitchValue');
        nameOff = get_param(PathRelay{i},'OffSwitchValue');
        if strcmp(nameOn,Name) || strcmp(nameOff,Name)
            relayList{end+1} = PathRelay{i};
        end
    end
    % Compare To标定量
    [PathCompTo, ParamCompTo] = findParamCompTo(bdroot);
    for i=1:length(PathCompTo)
        name = get_param(PathCompTo{i},'const');
        if strcmp(name,Name)
            CompToList{end+1} = PathCompTo{i};
        end
    end

    % table标定量
%     [PathLookup1D, PathLookup2D,Param1DLoopUp, Param2DLoopUp] = findParamLookupAll(path);

    % ParamFlow2Rpm 标定量
%     [PathFlow,ParamFlow] = findParamFlow2RpmAll(path);

end