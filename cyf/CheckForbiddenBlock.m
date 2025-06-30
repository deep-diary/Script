% clear
% Check 模型中是否使用了Delay模块
function CheckForbiddenBlock
InportCell = find_system(bdroot,'BlockType','Delay');  %获取顶层Inport模块路径
if ~isempty(InportCell)
    for i=1:length(InportCell)
        warning([' "Delay" is Forbidden Block : ',InportCell{i}]);

    end
    warning('Please use "Unit Delay"');
end

% Check 模型中是否使用了Memory模块
InportCell = find_system(bdroot,'BlockType','Memory');  %获取顶层Inport模块路径
if ~isempty(InportCell)
    for i=1:length(InportCell)
        warning([' "Memory" is Forbidden Block : ',InportCell{i}]);

    end
    warning('Please use "Unit Delay"');
end

% Check 模型中是否使用了Integrator模块
InportCell = find_system(bdroot,'BlockType','Integrator');  %获取顶层Inport模块路径
if ~isempty(InportCell)
    for i=1:length(InportCell)
        warning([' "Integrator" is Forbidden Block : ',InportCell{i}]);

    end
end

% Check 模型中是否使用了true,false模块
InportCell = find_system(bdroot,'BlockType','Constant');  %获取顶层Inport模块路径
for i=1:length(InportCell)
    BlockHandle = get_param(InportCell{i},'Handle');
    BlockValue = get_param(BlockHandle,'Value');
    if BlockValue == "true" ||( BlockValue == "false")

        warning([' "Constant" value should not be "true" or "false" : ',InportCell{i}]);
        warning('Please use "1" or "0"');
    end

end