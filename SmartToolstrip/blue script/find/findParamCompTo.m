function [PathCompTo, ParamCompTo] = findParamCompTo(path)
%%
% 目的: 找到当前打开模型中未定义的常量 Compare to
% 输入：
%       path: could be gcs or bdroot
% 返回：模型4个点的坐标
% 范例： [PathCompTo, ParamCompTo] = findParamCompTo(gcs)
% 作者： Blue.ge
% 日期： 20240202
%%
    clc
    PathCompTo = {};
    ParamCompTo={};
    % 'LookUnderMasks', 'all',增加这个配置，会搜索到Compare To Constant1 模块
    compToPath = find_system(path,'FollowLinks','on','BlockType','SubSystem');  
    for i=1:length(compToPath)
        p = compToPath{i};
        try
             % 正常的subsystem没有这个属性，只有compare to 才有
            value = get_param(p, 'const');
            if str2num(value)
%                 disp([value, '这是一个常量。']);
            elseif isvarname(value)
%                 disp([value, ' 是一个合法的变量名。']);
                ParamCompTo{end+1}=value;
                PathCompTo{end+1}=compToPath{i};
            else
%                 disp([value ' 不是一个合法的变量名。']);
            end
        catch
            continue
        end
    end
    ParamCompTo=unique(ParamCompTo);
end