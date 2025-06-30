function CheckStateFlowNum
%% 检查StateFlow数量,统计stateflow中状态数量，若状态小于2，提示是否必要
charts = find_system(bdroot, 'BlockType', 'SubSystem', 'SFBlockType', 'Chart');

if ~isempty(charts)
    for i = 1: length(charts)
        chartObj = get_param(charts{i},'Object');
        states = chartObj.find('-isa','Stateflow.State');
        if numel(states) < 2
            warning(['If Stateflow is necessary? : ',charts{i}]);
        end
    end
end