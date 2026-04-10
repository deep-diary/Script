function [PathRelay, ParamRelay] = findParamRelayAll(path)
%%
% 目的: 找到已经打开的模型中所有Relay中的变量
% 输入：
%       Null
% 返回：所有的变量名
% 范例： [PathRelay, ParamRelay] = findParamRelayAll(gcs)
% 作者： Blue.ge
% 日期： 20231027
%%
    % 找到模型中所有的Relay
    % 遍历所有的Relay
        % 将反回的变量依次添加到ParamRelay变量中
    % 
    clc
    ParamRelay = {};
    % 只有增加这个配置：'FollowLinks','on',才能找到switch case 模块中的对象     
    PathRelay = find_system(path,'FollowLinks','on','BlockType','Relay'); % 'FindAll','on',
    for i=1:length(PathRelay)
        [params] = findParamRelay(PathRelay{i});
        ParamRelay = [ParamRelay, params];
    end
%     转换成列输出
%     ParamRelay = ParamRelay';
%     信号去重
    ParamRelay=unique(ParamRelay);
    PathRelay = PathRelay';
end