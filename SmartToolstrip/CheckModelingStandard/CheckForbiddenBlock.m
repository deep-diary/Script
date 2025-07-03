% clear
% Check 模型中是否使用了Delay模块
function CheckForbiddenBlock
InportCell = find_system(bdroot,'BlockType','Delay');  %获取顶层Inport模块路径
if ~isempty(InportCell)
    for i=1:length(InportCell)
        warning([' "Delay" 是禁止使用的模块 : ',InportCell{i}]);

    end
    warning('请用 "Unit Delay" 模块！');
end

% Check 模型中是否使用了Memory模块
InportCell = find_system(bdroot,'BlockType','Memory');  %获取顶层Inport模块路径
if ~isempty(InportCell)
    for i=1:length(InportCell)
        warning([' "Memory" 是禁止使用的模块 : ',InportCell{i}]);

    end
    warning('请用 "Unit Delay" 模块！');
end

% Check 模型中是否使用了Integrator模块
InportCell = find_system(bdroot,'BlockType','Integrator');  %获取顶层Inport模块路径
if ~isempty(InportCell)
    for i=1:length(InportCell)
        warning([' "Integrator" 是禁止使用的模块 : ',InportCell{i}]);

    end
end

% Check 模型中是否使用了true,false模块
InportCell = find_system(bdroot,'BlockType','Constant');  %获取顶层Inport模块路径
for i=1:length(InportCell)
    BlockHandle = get_param(InportCell{i},'Handle');
    BlockValue = get_param(BlockHandle,'Value');
    if BlockValue == "true" ||( BlockValue == "false")

        warning([' "Constant" 值不能为 "true" or "false" : ',InportCell{i}]);
        warning('请使用 "1" 或 "0"');
    end

end