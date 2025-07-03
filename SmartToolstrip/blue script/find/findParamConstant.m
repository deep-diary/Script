function [PathConst, ParamConst] = findParamConstant(path)
%%
% 目的: 找到当前打开模型中未定义的常量Constant
% 输入：
%       path: could be gcs or bdroot
% 返回：模型4个点的坐标
% 范例： [PathConst, ParamConst] = findParamConstant(gcs)
% 作者： Blue.ge
% 日期： 20231027
%%
    clc
    PathConst={};
    ParamConst={};
    % 'LookUnderMasks', 'on',增加这个配置，会搜索到Compare To Constant1 模块
    valuePath = find_system(path,'FollowLinks','on','BlockType','Constant');  % 'LookUnderMasks','on'
    for i=1:length(valuePath)
        value = get_param(valuePath{i}, 'Value');
        if str2num(value)
%             disp([value, '这是一个常量。']);
        elseif isvarname(value)
%             disp([value, ' 是一个合法的变量名。']);
            ParamConst{end+1}=value;
            PathConst{end+1}=valuePath{i};
        else
%             disp([value ' 不是一个合法的变量名。']);
        end
    end
    ParamConst=unique(ParamConst);
end