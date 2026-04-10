function [PathDebug, ParamDebug] = findParamDebug(path)
%%
% 目的: 找到当前打开模型中debug标定量
% 输入：
%       path: could be gcs or bdroot
% 返回：模型4个点的坐标
% 范例： [PathDebug, ParamDebug] = findParamDebug(gcs)
% 作者： Blue.ge
% 日期： 20240202
%%
    clc
    PathDebug={};
    ParamDebug={};
    % 'LookUnderMasks', 'all',增加这个配置，会搜索到Compare To Constant1 模块
    DebugPath = find_system(path,'FollowLinks','on','BlockType','SubSystem');  
    for i=1:length(DebugPath)
        p = DebugPath{i};
        try
             % 正常的subsystem没有这个属性，只有compare to 才有
            SWI = get_param(p, 'SWI');
            DBI = get_param(p, 'DBI');
            ParamDebug{end+1}=SWI;
            ParamDebug{end+1}=DBI;
            PathDebug{end+1} = p;
        catch
            continue
        end
    end
    ParamDebug=unique(ParamDebug);
end