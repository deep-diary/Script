function [PathSatur, ParamSatur] = findParamSaturateAll(path)
%%
% 目的: 找到已经打开的模型中所有Saturate中的变量
% 输入：
%       Null
% 返回：所有的变量名
% 范例： [PathSatur, ParamSatur] = findParamSaturateAll(path)
% 作者： Blue.ge
% 日期： 20231027
%%
    % 找到模型中所有的Relay
    % 遍历所有的Relay
        % 将反回的变量依次添加到ParamSatur变量中
    % 
    clc
    ParamSatur = {};
    % 只有增加这个配置：'FollowLinks','on',才能找到switch case 模块中的对象     
    PathSatur = find_system(path,'FollowLinks','on','BlockType','Saturate'); % 'FindAll','on',
    for i=1:length(PathSatur)
        [params] = findParamSaturate(PathSatur{i});
        ParamSatur = [ParamSatur, params];
    end
%     转换成列输出
%     ParamSatur = ParamSatur';
%     信号去重
    ParamSatur=unique(ParamSatur);
    PathSatur= PathSatur';
end