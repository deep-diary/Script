function [PathFlow,ParamFlow] = findParamFlow2RpmAll(path)
%%
% 目的: 为所有的lookup table表，根据 Table data 的变量名，创建对应坐标轴的变量名
% 输入：
%       Null
% 返回：所有的变量名
% 范例： ParamFlow = findParamFlow2RpmAll(path)
% 作者： Blue.ge
% 日期： 20240202
%%

    clc
    PathFlow = {};
    ParamFlow = {};
    flow2Rpm = find_system(path,'FollowLinks','on','BlockType','SubSystem');
    for i=1:length(flow2Rpm)
        flowPath = flow2Rpm{i};
        try
            get_param(flowPath,'BlwHeatLevel_sw');
%             alddParamFlow = findParamFlow2Rpm(flowPath);
            ParamFlow = [ParamFlow, findParamFlow2Rpm(flowPath)];
            PathFlow{end+1} = flowPath;
        catch
            continue
        end
    end

    ParamFlow=unique(ParamFlow);
end