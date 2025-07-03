function [paramters] = findParamSaturate(path)
%%
% 目的: 找到Saturate 模块中的变量名
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
    upperLimit = bk.UpperLimit;
    lowerLimit = bk.LowerLimit;
    if isvarname(upperLimit)
        paramters=[paramters, upperLimit];
    end

    if isvarname(lowerLimit)
         paramters=[paramters, lowerLimit];
    end
end