function [paramters] = findParamRelay(path)
%%
% 目的: 找到Relay 模块中的变量名
% 输入：
%       Null
% 返回：所有的变量名
% 范例：[paramters] = findParamRelay(path)
% 作者： Blue.ge
% 日期： 20231027
%%
    clc
    paramters = {};
    h = get_param(path, 'Handle');
    bk = get(h);
    onPt = bk.OnSwitchValue;
    offPt = bk.OffSwitchValue;
    if isvarname(onPt)
        paramters=[paramters, onPt];
    end

    if isvarname(offPt)
         paramters=[paramters, offPt];
    end
end