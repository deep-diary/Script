%% 创建CCM autosar 软件架构


% Create AUTOSAR architecture model
%%--------------------------------参数定义
swcAppend = '';  % 防止跟原始模型冲突
modelName = 'CcmArch';
names = {'PrkgClimaActvMgr','PrkgClimaEgyMgr'};

% 读取autosar 任务mapping 表格，获取各个SWC的调度周期
[init, tasks, tasksAll] = readAutosarTasks('CCMtaskmappingV2.0.xlsx', 'Sheet1');

% 各周期任务列表
task1ms = tasks.task1ms;
task2ms = tasks.task2ms;
task5ms = tasks.task5ms;
task10ms = tasks.task10ms;
task20ms = tasks.task20ms;
task50ms = tasks.task50ms;
task100ms = tasks.task100ms;
task200ms = tasks.task200ms;
task500ms = tasks.task500ms;
task1000ms = tasks.task1000ms;
% 统计所有组件的总数
totalComponentsAll = length(tasksAll);
%%--------------------------------

% 如果不存在，则创建架构模型
if ~exist(which(modelName), 'file')
    archModel = autosar.arch.createModel(modelName);
else
    archModel = autosar.arch.loadModel(modelName);
end

%% 遍历tasks任务列表，动态创建组合和组件
% 获取tasks结构体的所有字段名
taskFields = fieldnames(tasks);
fprintf('开始遍历tasks结构体，共 %d 个时间周期\n', length(taskFields));

% 注意：不再需要存储组件对象引用，直接从架构模型中查找

for i = 1:length(taskFields)
    fieldName = taskFields{i};
    taskList = tasks.(fieldName);
    
    % 如果任务列表不为空，创建对应的组合和组件
    if ~isempty(taskList)
        % 提取时间周期（去掉'task'和'ms'）
        periodStr = strrep(fieldName, 'task', '');
        periodStr = strrep(periodStr, 'ms', '');
        period = str2double(periodStr);
        
        fprintf('\n处理 %dms 周期任务，共 %d 个任务:\n', period, length(taskList));
        
        % 创建组合名称
        compositionName = sprintf('Composition_%dms', period);
        
        try
            % 创建组合
            composition = addComposition(archModel, compositionName);
            fprintf('  创建组合: %s\n', compositionName);
            
            % 为任务列表中的每个任务创建组件名称
            componentNames = {};
            for j = 1:length(taskList)
                taskName = taskList{j};
                % 从任务名称中提取组件名称（去掉_Runnable后缀）
                if endsWith(taskName, '_Runnable')
                    componentName = strrep(taskName, '_Runnable', '');
                else
                    componentName = taskName;
                end
                componentName = [componentName, swcAppend];  % 添加后缀
                componentNames{end+1} = componentName;
                fprintf('    任务: %s -> 组件: %s\n', taskName, componentName);
            end
            
            % 在组合内创建组件
            if ~isempty(componentNames)
                components = addComponent(composition, componentNames, 'Kind', 'Application');
                fprintf('  在组合 %s 中创建了 %d 个组件\n', compositionName, length(componentNames));
                
                % 组件已创建，将在后续步骤中从架构模型中查找
                
                % 自动排列组合内的组件
                layout(composition);
            end
            
        catch ME
            fprintf('  创建组合 %s 失败: %s\n', compositionName, ME.message);
        end
    else
        fprintf('跳过 %s: 无任务\n', fieldName);
    end
end

% 自动排列整个架构模型
layout(archModel);

fprintf('\n组合和组件创建完成\n');


%% 生成 SWC 框架模型
% 创建SubModelArch文件夹（如果不存在）
subModelDir = fullfile(pwd, 'SubModelArch');
if ~exist(subModelDir, 'dir')
    mkdir(subModelDir);
end

%% 按组合层次遍历，生成模型和代码
% 遍历架构模型中的所有组合
compositions = archModel.Compositions;
totalCompositions = length(compositions);


fprintf('\n开始按组合层次处理 %d 个组合，共 %d 个组件...\n', totalCompositions, totalComponents);

% 全局组件计数器
globalComponentCounter = 0;

for i = 1:totalCompositions
    composition = compositions(i);
    compositionName = composition.Name;
    
    % 从组合名称中提取时间周期信息
    % 例如：Composition_10ms -> 10
    periodStr = strrep(compositionName, 'Composition_', '');
    periodStr = strrep(periodStr, 'ms', '');
    period = str2double(periodStr);
    
    % 计算RunnablePeriod（秒）
    runnablePeriod = period / 1000.0;  % 转换为秒
    
    % 显示组合处理进度
    fprintf('\n=== [%d/%d] 处理组合: %s (周期: %dms, RunnablePeriod: %.3fs) ===\n', ...
        i, totalCompositions, compositionName, period, runnablePeriod);
    
    % 获取组合内的所有组件
    components = composition.Components;
    totalComponents = length(components);
    fprintf('  组合内包含 %d 个组件\n', totalComponents);
    
    % 遍历组合内的组件
    for j = 1:totalComponents
        component = components(j);
        componentName = component.Name;
        modelPath = fullfile(subModelDir, [componentName '.slx']);
        
        % 增加全局组件计数器
        globalComponentCounter = globalComponentCounter + 1;
        
        % 显示组件处理进度（组合内进度 + 全局进度）
        percent = (globalComponentCounter / totalComponents) * 100;
        fprintf('\n  --- [%d/%d] 处理组件: %s (全局: %d/%d, %.1f%%) ---\n', ...
            j, totalComponents, componentName, globalComponentCounter, totalComponentsAll, percent);
        
        %% 生成AUTOSAR实现模型
        try
            if ~exist(modelPath, 'file')
                % 使用AUTOSAR API创建实现模型
                createModel(component, modelPath);
                fprintf('    ✓ 生成AUTOSAR模型: %s\n', componentName);
            else
                fprintf('    - AUTOSAR模型已存在: %s\n', componentName);
            end
        catch ME
            fprintf('    ✗ 生成AUTOSAR模型 %s 失败: %s\n', componentName, ME.message);
            continue;  % 模型创建失败，跳过代码生成
        end
        
        %% 生成AUTOSAR代码
        try
            % 从任务名称中提取Runnable名称
            % 例如：CCMLoad_DiagArch -> CCMLoad_DiagRunnable
            if endsWith(componentName, 'Arch')
                runnableName = strrep(componentName, 'Arch', 'Runnable');
            else
                runnableName = [componentName, 'Runnable'];
            end
            
            % 传递调度时间信息和Runnable名称给changeAutosarDict
            changeAutosarDict(componentName, 'RunnablePeriod', runnablePeriod);
            fprintf('    ✓ 生成AUTOSAR代码: %s (周期: %.3fs, Runnable: %s)\n', componentName, runnablePeriod, runnableName);
        catch ME
            fprintf('    ✗ 生成AUTOSAR代码 %s 失败: %s\n', componentName, ME.message);
        end
    end
    
    % 显示组合完成进度
    fprintf('=== 组合 %s 处理完成 [%d/%d] ===\n', compositionName, i, totalCompositions);
end

% 显示整体完成信息
fprintf('\n🎉 所有组合处理完成！共处理了 %d 个组合，%d 个组件\n', totalCompositions, totalComponents);

%% 导出arxml
% 找到代码生成目录下的arxml文件
[codeFiles, mapping] = findCodeFiles('CodeGen', ...
    'fileType', {'arxml'}, ...
    'targetPath', 'SubModelArxml', ...
    'combine', false);






%% -----------------------------------------------backup-----------------------------------------------
%% 遍历tasks任务列表，创建组件


%% 遍历组件，创建SWC

% 如果不存在，则创建
% % Add a composition
% composition = addComposition(archModel,'Sensors');
% 
% % Add 2 components inside Sensors
% names = {'PedalSnsr','ThrottleSnsr'};
% sensorSWCs = addComponent(composition,names,'Kind','SensorActuator');
% layout(composition); % auto-arrange layout

% Add components at architecture model top level
% Add 2 components inside Sensors
% 为names 添加swcAppend
% swcNames = strcat(names,swcAppend);
% CcmSWCs = addComponent(archModel,swcNames,'Kind','Application');
% layout(archModel);  % Auto-arrange layout
% % 创建模型，并放在SubModelArch文件夹下
% for i = 1:length(swcNames)
%     modelPath = fullfile(subModelDir, [swcNames{i} '.slx']);
%     createModel(CcmSWCs(i), modelPath);
%     disp(['Generated implementation model for: ' swcNames{i} ' at ' modelPath]);
% 链接模型
% % Link to Simulink implementation model and inherit its interface
% linkToModel(component,'autosar_tpc_controller');





