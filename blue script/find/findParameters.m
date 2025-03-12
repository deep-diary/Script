function [PathAll, ParamAll] = findParameters(path)
% 目的: 找到path的模型中所有的标定量，主要包括常量，1维表，2维表
% 输入：
%       Null
% 返回：modelName: 模型名称，ParamAll = 所有的变量名
% 范例： [PathAll, ParamAll] = findParameters(bdroot)
% 作者： Blue.ge
% 日期： 20231027
%%
    clc
    ParamAll={};
    PathAll={};
    % 常量标定量
    [PathConst, ParamConst] = findParamConstant(path); 
    % Compare To标定量
    [PathCompTo, ParamCompTo] = findParamCompTo(path);

    % table标定量
    [PathLookup1D, PathLookup2D,Param1DLoopUp, Param2DLoopUp] = findParamLookupAll(path);

    % ParamFlow2Rpm 标定量
    [PathFlow,ParamFlow] = findParamFlow2RpmAll(path);

    % Relay标定量
    [PathRelay, ParamRelay] = findParamRelayAll(path); 
    % Saturate 标定量
    [PathSatur, ParamSatur] = findParamSaturateAll(path);
    % debug 标定量
    [PathDebug, ParamDebug] = findParamDebug(path);
    % 周期性脉冲 标定量
    [PathCnt,ParamCnt] = findParamCnt(path);
    %% 合并所有的标定量
    ParamAll = [ParamConst, ParamCompTo, ...
        Param1DLoopUp,Param2DLoopUp ParamFlow, ...
        ParamRelay, ParamSatur, ParamDebug,ParamCnt]; % ParamAll,
    ParamAll=ParamAll';
    ParamAll=unique(ParamAll,'stable');
    %% 合并所有的路径
%     PathAll = [PathConst,PathCompTo,PathLookup1D,PathLookup2D,PathFlow,PathRelay,PathSatur,PathDebug,PathCnt];
%     PathAll = PathAll';

end
