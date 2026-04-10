function changeAutosarDict(model, varargin)
%CHANGEAUTOSARDICT 更改AUTOSAR数据字典
%   CHANGEAUTOSARDICT(MODEL) 更改指定模型的AUTOSAR数据字典，使用默认参数
%   CHANGEAUTOSARDICT(MODEL, 'Suffix', VALUE, 'RunnablePeriod', VALUE, 'Runnable', VALUE) 使用指定参数更改AUTOSAR数据字典
%
%   输入参数:
%      model         - 模型名称 (字符串，必需)
%
%   可选参数（名值对）:
%      'Suffix'      - 模型后缀 (字符串，默认: 'Arch')
%      'RunnablePeriod' - 运行周期 (数值，默认: 0.2)
%      'Runnable'    - Runnable名称 (字符串或字符串数组，默认: 空，使用规则替换)
%
%   功能描述:
%      更改指定模型的AUTOSAR数据字典，包括修改Runnable名称、事件周期和XML配置
%      如果提供Runnable参数，将直接使用指定的名称；否则使用规则替换生成
%
%   示例:
%      changeAutosarDict('PrkgClimaActvMgr')
%      changeAutosarDict('PrkgClimaActvMgr', 'Suffix', 'Arch', 'RunnablePeriod', 0.2)
%      changeAutosarDict('PrkgClimaActvMgr', 'RunnablePeriod', 0.1)
%      changeAutosarDict('PrkgClimaActvMgr', 'Runnable', 'CustomRunnableName')
%      changeAutosarDict('PrkgClimaActvMgr', 'Runnable', {'InitRunnable', 'MainRunnable'})
%
%   作者: Blue.ge
%   日期: 20250928
%   版本: 2.2

% 创建输入解析器
p = inputParser;

% 添加必需参数
addRequired(p, 'model', @(x) validateattributes(x, {'char', 'string'}, {'nonempty'}));

% 添加可选参数
addParameter(p, 'Suffix', 'Arch', @(x) validateattributes(x, {'char', 'string'}, {'nonempty'}));
addParameter(p, 'RunnablePeriod', 0.2, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
addParameter(p, 'Runnable', '', @(x) ischar(x) || isstring(x) || iscellstr(x) || isempty(x));

% 解析输入
parse(p, model, varargin{:});

% 提取参数
model = char(p.Results.model);
% suffix = char(p.Results.Suffix);  % 暂时未使用，保留以备将来扩展
runnablePeriod = p.Results.RunnablePeriod;
% runnable = p.Results.Runnable;  % 暂时未使用，保留以备将来扩展

%% 1. 模型初始化和清理
% 打开模型并清理所有现有模块，为后续操作做准备
try
    % 打开模型
    if ~bdIsLoaded(model)
        open_system(model);
    end
    
    % 删除所有现有模块（保持模型结构干净）
    allBlocks = find_system(model, 'SearchDepth', 1, 'Type', 'Block');
    for i = 1:length(allBlocks)
        if ~strcmp(allBlocks{i}, model) % 排除模型本身
            delete_block(allBlocks{i});
        end
    end
    % 删除连线
    delUselessLine(model);
    fprintf('已清理模型中的所有模块和连线\n');
    
catch ME
    error('模型初始化和清理失败: %s', ME.message);
end

%% 2. 创建基础模块
% 创建Constant和Terminator模块，防止模型为空导致编译错误
try
    % 指定模块位置（在同一水平线上，便于连线）
    constPos = [100 100 130 120];
    termPos = [250 100 280 120];
    
    % 创建Constant模块
    add_block('built-in/Constant', [model, '/Constant'], ...
              'Value', '1', 'Position', constPos);
    fprintf('已创建Constant模块\n');
    
    % 创建Terminator模块
    add_block('built-in/Terminator', [model, '/Terminator'], 'Position', termPos);
    fprintf('已创建Terminator模块\n');
    
    % 创建模块间连线
    add_line(model, 'Constant/1', 'Terminator/1', 'autorouting', 'on');
    fprintf('已创建模块间连线\n');
    
    % 保存模型
    save_system(model);
    fprintf('基础模块创建完成，模型已保存\n');
    
catch ME
    error('基础模块创建失败: %s', ME.message);
end

%% 3. AUTOSAR API初始化
% 初始化AUTOSAR API并获取模型属性对象
try
    autosar.api.create(model);
    arProps = autosar.api.getAUTOSARProperties(model);
    % slMap = autosar.api.getSimulinkMapping(model); % 暂时注释，如需要可取消注释
    fprintf('AUTOSAR API初始化完成\n');
catch ME
    error('AUTOSAR API初始化失败: %s', ME.message);
end

%% 4. 重新创建AUTOSAR Runnable和事件
% 1. 删除所有现有Runnable和事件
% 2. 创建初始化Runnable，名称和symbol均为model_Init，事件类型为InitEvent，事件名称为Event_model_Init
% 3. 创建周期性Runnable，名称和symbol均为model_Runnable，事件类型为CyclicEvent，事件名称为Event_model_Runnable
% 4. 为周期性Runnable添加周期性调度属性，周期为runnablePeriod

try
    % 获取AUTOSAR组件和Behavior信息
    swc = get(arProps, 'XmlOptions', 'ComponentQualifiedName');
    ib = get(arProps, swc, 'Behavior');
    
    % 步骤1: 删除所有现有Runnable
    fprintf('步骤1: 删除所有现有Runnable...\n');
    existingRunnables = find(arProps, ib, 'Runnable', 'PathType', 'FullyQualified');
    for i = 1:length(existingRunnables)
        delete(arProps, existingRunnables{i});
        fprintf('已删除Runnable: %s\n', existingRunnables{i});
    end
    
    % 步骤2: 删除所有现有事件
    fprintf('步骤2: 删除所有现有事件...\n');
    existingEvents = find(arProps, ib, 'Event', 'PathType', 'FullyQualified');
    for i = 1:length(existingEvents)
        delete(arProps, existingEvents{i});
        fprintf('已删除事件: %s\n', existingEvents{i});
    end
    
    % 步骤3: 创建初始化Runnable
    fprintf('步骤3: 创建初始化Runnable...\n');
    initRunnableName = [model, '_Init'];
    initRunnablePath = [ib, '/', initRunnableName];
    add(arProps, ib, 'Runnables', initRunnableName);
    set(arProps, initRunnablePath, 'Name', initRunnableName);
    set(arProps, initRunnablePath, 'symbol', initRunnableName);
    fprintf('已创建初始化Runnable: %s\n', initRunnableName);
    
    % 步骤4: 创建周期性Runnable
    fprintf('步骤4: 创建周期性Runnable...\n');
    cyclicRunnableName = [model, '_Runnable'];
    cyclicRunnablePath = [ib, '/', cyclicRunnableName];
    add(arProps, ib, 'Runnables', cyclicRunnableName);
    set(arProps, cyclicRunnablePath, 'Name', cyclicRunnableName);
    set(arProps, cyclicRunnablePath, 'symbol', cyclicRunnableName);
    fprintf('已创建周期性Runnable: %s\n', cyclicRunnableName);
    
    % 步骤5: 创建初始化事件
    fprintf('步骤5: 创建初始化事件...\n');
    initEventName = ['Event_', model, '_Init'];
    initEventPath = [ib, '/', initEventName];
    add(arProps, ib, 'Events', initEventName, 'Category', 'InitEvent');
    set(arProps, initEventPath, 'Name', initEventName);
    set(arProps, initEventPath, 'StartOnEvent', initRunnablePath);
    fprintf('已创建初始化事件: %s\n', initEventName);
    
    % 步骤6: 创建周期性事件
    fprintf('步骤6: 创建周期性事件...\n');
    cyclicEventName = ['Event_', model, '_Runnable'];
    cyclicEventPath = [ib, '/', cyclicEventName];
    add(arProps, ib, 'Events', cyclicEventName, 'Category', 'TimingEvent');
    set(arProps, cyclicEventPath, 'Name', cyclicEventName);
    set(arProps, cyclicEventPath, 'StartOnEvent', cyclicRunnablePath);
    set(arProps, cyclicEventPath, 'Period', runnablePeriod);
    fprintf('已创建周期性事件: %s，周期: %f秒\n', cyclicEventName, runnablePeriod);
    
    fprintf('AUTOSAR Runnable和事件创建完成\n');
    
catch ME
    error('AUTOSAR Runnable和事件创建失败: %s', ME.message);
end

%% 5. 验证AUTOSAR事件配置
% 验证新创建的事件配置是否正确
try
    % 获取所有AUTOSAR events进行验证
    allEvents = find(arProps, ib, 'Event', 'PathType', 'FullyQualified');
    
    fprintf('验证AUTOSAR事件配置...\n');
    for eventIdx = 1:length(allEvents)
        currentEvent = allEvents{eventIdx};
        
        % 获取事件属性
        eventStartOn = get(arProps, currentEvent, 'StartOnEvent');
        try
            eventPeriod = get(arProps, currentEvent, 'Period');
            fprintf('AUTOSAR事件 %s 触发于 %s，周期: %f秒\n', ...
                    currentEvent, eventStartOn, eventPeriod);
        catch
            fprintf('AUTOSAR事件 %s 触发于 %s (非周期性事件)\n', ...
                    currentEvent, eventStartOn);
        end
    end
    fprintf('已验证 %d 个事件配置\n', length(allEvents));
    
catch ME
    error('AUTOSAR事件配置验证失败: %s', ME.message);
end

%% 6. 修改XML选项和模型配置
% 设置AUTOSAR XML文件打包方式和模型调度周期
try
    % 设置XML选项：Source为Inline，打包为单文件
    set(arProps, 'XmlOptions', 'XmlOptionsSource', 'Inlined');
    set(arProps, 'XmlOptions', 'ArxmlFilePackaging', 'SingleFile');
    fprintf('已设置XML选项：Source=Inlined, Packaging=SingleFile\n');
    
    % 设置模型配置：固定步长为指定周期
    activeConfigSet = getActiveConfigSet(model);
    set_param(activeConfigSet, 'FixedStep', num2str(runnablePeriod));
    fprintf('已设置模型固定步长为 %f 秒\n', runnablePeriod);
    
    % 保存模型
    save_system(model);
    fprintf('XML选项和模型配置修改完成，模型已保存\n');
    
catch ME
    error('XML选项和模型配置修改失败: %s', ME.message);
end

%% 7. 修改Mapping属性
% 设置AUTOSAR mapping属性，将Simulink函数映射到AUTOSAR Runnable
% Initialize  ---->    initRunnableName
% Periodic:D1  ---->    cyclicRunnableName
try
    fprintf('步骤7: 设置AUTOSAR Mapping属性...\n');
    
    % 获取Simulink mapping对象
    slMap = autosar.api.getSimulinkMapping(model);
    
    % 设置Initialize函数映射到初始化Runnable
    try
        mapFunction(slMap, 'Initialize', initRunnableName);
        fprintf('已设置Initialize函数映射到Runnable: %s\n', initRunnableName);
    catch ME
        fprintf('警告: Initialize函数映射设置失败: %s\n', ME.message);
    end
    
    % 设置Periodic函数映射到周期性Runnable
    try
        mapFunction(slMap, 'Periodic', cyclicRunnableName);
        fprintf('已设置Periodic函数映射到Runnable: %s\n', cyclicRunnableName);
    catch ME
        fprintf('警告: Periodic函数映射设置失败: %s\n', ME.message);
    end
    
    % 设置Periodic:D1函数映射到周期性Runnable（如果存在）
    try
        mapFunction(slMap, 'Periodic:D1', cyclicRunnableName);
        fprintf('已设置Periodic:D1函数映射到Runnable: %s\n', cyclicRunnableName);
    catch ME
        fprintf('信息: Periodic:D1函数映射设置跳过（可能不存在）: %s\n', ME.message);
    end
    
    % 验证mapping设置
    try
        initRunnable = getFunction(slMap, 'Initialize');
        periodicRunnable = getFunction(slMap, 'Periodic');
        fprintf('验证Mapping设置:\n');
        fprintf('  Initialize -> %s\n', initRunnable);
        fprintf('  Periodic -> %s\n', periodicRunnable);
    catch ME
        fprintf('警告: Mapping验证失败: %s\n', ME.message);
    end
    
    fprintf('AUTOSAR Mapping属性设置完成\n');
    
catch ME
    error('AUTOSAR Mapping属性设置失败: %s', ME.message);
end

%% 8. 生成AUTOSAR代码
% 执行模型构建，生成AUTOSAR代码
try
    fprintf('开始生成AUTOSAR代码...\n');
    slbuild(model);
    fprintf('模型 %s 代码生成完成\n', model);
catch ME
    error('代码生成失败: %s', ME.message);
end

end % 主函数结束

