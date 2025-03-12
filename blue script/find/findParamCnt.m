function [PathCnt,ParamCnt] = findParamCnt(path)
%%
% 目的: 找到当前打开模型中Cnt标定量
% 输入：
%       path: could be gcs or bdroot
% 返回：模型4个点的坐标
% 范例： [PathCnt,ParamCnt] = findParamCnt(gcs)
% 作者： Blue.ge
% 日期： 20240202
%%
    clc
    PathCnt={};
    ParamCnt={};
    % 'LookUnderMasks', 'all',增加这个配置，会搜索到Compare To Constant1 模块
    CntPath = find_system(path,'FollowLinks','on','BlockType','SubSystem');  
    for i=1:length(CntPath)
        p = CntPath{i};
        try
             % 正常的subsystem没有这个属性，只有compare to 才有
            CounterLim = get_param(p, 'CounterLim');

            if str2num(CounterLim)
                disp([CounterLim, '这是一个常量。']);
            elseif isvarname(CounterLim)
                disp([CounterLim, ' 是一个合法的变量名。']);
                ParamCnt{end+1}=CounterLim;
                PathCnt{end+1} = p;
            else
                disp([CounterLim ' 不是一个合法的变量名。']);
            end
            
        catch
            continue
        end
    end
    ParamCnt=unique(ParamCnt);
end