function [PathLookup1D, PathLookup2D, ParamLookup1D, ParamLookup2D] = findParamLookupAll(path)
%%
% 目的: 为所有的lookup table表，根据 Table data 的变量名，创建对应坐标轴的变量名
% 输入：
%       Null
% 返回：所有的变量名
% 范例： [PathLookup1D, PathLookup2D, ParamLookup1D, ParamLookup2D] = findParamLookupAll(gcs)
% 作者： Blue.ge
% 日期： 20231027
%%
    % 找到模型中所有的Lookup_n-D
    % 遍历所有的table
        % 将反回的变量依次添加到ParamLookup1D， ParamLookup2D变量中
    % 
    clc
    PathLookup1D = {};
    PathLookup2D = {};
    ParamLookup1D = {};
    ParamLookup2D = {};
    lookups = find_system(path,'FollowLinks','on','BlockType','Lookup_n-D');
    for i=1:length(lookups)
        [Path1D, Path2D, para1D,para2D] = findParamLookup(lookups{i});
        PathLookup1D = [PathLookup1D, Path1D];
        PathLookup2D = [PathLookup2D, Path2D];
        ParamLookup1D = [ParamLookup1D, para1D];
        ParamLookup2D = [ParamLookup2D, para2D];

    end
%     转换成列输出
%     ParamLookup1D = ParamLookup1D';
%     ParamLookup2D = ParamLookup2D';
%     信号去重
    ParamLookup1D=unique(ParamLookup1D,'stable');
    ParamLookup2D=unique(ParamLookup2D,'stable');
end