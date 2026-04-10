function [NmAfter] = findNameSigChg(nmAct, nmRef,varargin)
%%
    % 目的: 根据原始信号名和更换后的信号名，找到最终信号名：1. 包含前缀的。 2 不包含前缀是
    % 输入：
    %       nmAct： 原始信号名称，nmRef：更换后的信号名
    % 返回： nmAfter: 需要替换的信号
    % 范例： [NmAfter] = findNameSigChg('rDemo_X_i16BexvPoseLow','rTmRefriVlvCtrl_X_s32BexvPoseLow')
    % 说明： 比如当前信号名称是'rDemo_X_i16BexvPoseLow', 参考信号名rTmRefriVlvCtrl_X_s32BexvPoseLow
    % 则如下函数输出：rDemo_X_s32BexvPoseLow
    % 作者： Blue.ge
    % 日期： 20240603
%%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'keepPrefix',true);      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    keepPrefix = p.Results.keepPrefix;
    %% 确定信号前缀
    % 使用原来名称的前缀跟新名称后缀
    befList = split(nmAct,'_');
    afList = split(nmRef,'_');
    if keepPrefix
        afList{1} = befList{1};
    end
    NmAfter = join(afList,'_');
    NmAfter = NmAfter{1};
end