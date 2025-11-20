function changeAutosarRunnable(model, varargin)
%CHANGEAUTOSARRUNNABLE 为当前模型配置AUTOSAR Runnable字典和Mapping属性
%   CHANGEAUTOSARRUNNABLE(MODEL) 使用默认参数配置指定模型的AUTOSAR Runnable
%   CHANGEAUTOSARRUNNABLE(MODEL, Name, Value, ...) 使用指定参数配置AUTOSAR Runnable
%
%   必需参数:
%      model         - 模型名称 (字符串)
%
%   可选参数 (名称-值对):
%      'Suffix'      - 模型后缀 (字符串, 默认: 'Arch')
%                     用于生成Runnable名称，格式: model_Suffix_Runnable
%      'RunnablePeriod' - Runnable运行周期 (数值, 默认: 0.02)
%                         周期性Runnable的调度周期（秒）
%      'Runnable'    - 自定义Runnable名称 (字符串或字符串元胞数组, 默认: '')
%                     如果提供，将使用指定的名称：
%                     - 字符串: 仅设置周期性Runnable名称
%                     - 元胞数组{initName, cyclicName}: 分别设置初始化和周期性Runnable名称
%      'AutoBuild'   - 是否自动生成代码 (逻辑值, 默认: true)
%
%   输出参数:
%      无
%
%   功能描述:
%      1. 打开并初始化模型
%      2. 初始化AUTOSAR API
%      3. 删除所有现有Runnable和事件
%      4. 创建初始化Runnable和事件
%      5. 创建周期性Runnable和事件
%      6. 验证事件配置
%      7. 配置XML选项和模型参数
%      8. 设置Simulink函数到AUTOSAR Runnable的映射
%         - Rate-Based模型: Initialize -> InitRunnable, Periodic -> CyclicRunnable
%         - Export-Function模型: Initialize -> InitRunnable, Exported Function -> CyclicRunnable
%      9. 可选：生成AUTOSAR代码
%
%   示例:
%      % 基本用法
%      changeAutosarRunnable('PrkgClimaActvMgr')
%      
%      % 指定周期和后缀
%      changeAutosarRunnable('PrkgClimaActvMgr', 'Suffix', 'Arch', 'RunnablePeriod', 0.2)
%      
%      % 仅指定周期
%      changeAutosarRunnable('PrkgClimaActvMgr', 'RunnablePeriod', 0.1)
%      
%      % 自定义周期性Runnable名称
%      changeAutosarRunnable('PrkgClimaActvMgr', 'Runnable', 'CustomRunnableName')
%      
%      % 自定义初始化和周期性Runnable名称
%      changeAutosarRunnable('PrkgClimaActvMgr', 'Runnable', {'InitRunnable', 'MainRunnable'})
%      
%      % 不自动生成代码
%      changeAutosarRunnable('PrkgClimaActvMgr', 'AutoBuild', false)
%
%   注意事项:
%      1. 模型必须已配置为AUTOSAR模型
%      2. 函数会删除所有现有的Runnable和事件，请谨慎使用
%      3. 如果模型是Export-Function类型，会自动检测并正确映射
%      4. 采样周期必须为正数
%
%   参见: AUTOSAR.API.CREATE, AUTOSAR.API.GETAUTOSARPROPERTIES,
%         AUTOSAR.API.GETSIMULINKMAPPING, MAPFUNCTION, SLBUILD
%
%   作者: Blue.ge
%   版本: 2.0
%   日期: 20251120

    %% 参数解析和验证
    % 创建输入解析器
    p = inputParser;
    p.FunctionName = mfilename;
    
    % 添加必需参数
    addRequired(p, 'model', @(x) validateattributes(x, {'char', 'string'}, {'nonempty', 'scalartext'}));
    
    % 添加可选参数
    addParameter(p, 'Suffix', '', @(x) validateattributes(x, {'char', 'string'}, {'nonempty', 'scalartext'}));
    addParameter(p, 'RunnablePeriod', 0.02, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive', 'finite'}));
    addParameter(p, 'Runnable', '', @(x) isempty(x) || ischar(x) || isstring(x) || iscellstr(x));
    addParameter(p, 'AutoBuild', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    
    % 解析输入
    parse(p, model, varargin{:});
    
    % 提取参数
    model = char(p.Results.model);
    suffix = char(p.Results.Suffix);
    runnablePeriod = p.Results.RunnablePeriod;
    runnable = p.Results.Runnable;
    autoBuild = p.Results.AutoBuild;
    
    % 处理Runnable参数
    if isempty(runnable)
        % 使用默认命名规则
        initRunnableName = [model, '_Init'];
        cyclicRunnableName = [model, '_Runnable'];
    elseif ischar(runnable) || isstring(runnable)
        % 仅指定周期性Runnable名称
        initRunnableName = [model, '_Init'];
        cyclicRunnableName = char(runnable);
    elseif iscell(runnable) && length(runnable) >= 2
        % 指定初始化和周期性Runnable名称
        initRunnableName = char(runnable{1});
        cyclicRunnableName = char(runnable{2});
    else
        error('MATLAB:changeAutosarRunnable:InvalidRunnable', ...
              'Runnable参数必须是字符串或包含2个元素的元胞数组');
    end

    %% 步骤1: 模型初始化和验证
    try
        % 打开模型
        if ~bdIsLoaded(model)
            open_system(model);
            fprintf('已打开模型: %s\n', model);
        else
            fprintf('模型已加载: %s\n', model);
        end
        
        % 验证模型是否为AUTOSAR模型
        try
            autosar.api.getAUTOSARProperties(model);
        catch
            warning('MATLAB:changeAutosarRunnable:NotAUTOSARModel', ...
                    '模型 "%s" 可能不是AUTOSAR模型，继续执行...', model);
        end
        
    catch ME
        error('MATLAB:changeAutosarRunnable:ModelInitFailed', ...
              '模型初始化失败: %s', ME.message);
    end

    %% 步骤2: AUTOSAR API初始化
    try
        autosar.api.create(model);
        arProps = autosar.api.getAUTOSARProperties(model);
        fprintf('AUTOSAR API初始化完成\n');
    catch ME
        error('MATLAB:changeAutosarRunnable:APIInitFailed', ...
              'AUTOSAR API初始化失败: %s', ME.message);
    end

    %% 步骤3: 检测模型类型
    try
        isExportFunction = strcmp(get_param(model, 'IsExportFunctionModel'), 'on');
        if isExportFunction
            fprintf('检测到模型类型: Export-Function模型\n');
        else
            fprintf('检测到模型类型: Rate-Based模型\n');
        end
    catch ME
        warning('MATLAB:changeAutosarRunnable:ModelTypeDetectionFailed', ...
                '无法检测模型类型，假设为Rate-Based模型: %s', ME.message);
        isExportFunction = false;
    end

    %% 步骤4: 重新创建AUTOSAR Runnable和事件
    try
        % 获取AUTOSAR组件和Behavior信息
        swc = get(arProps, 'XmlOptions', 'ComponentQualifiedName');
        ib = get(arProps, swc, 'Behavior');
        
        % 步骤4.1: 删除所有现有Runnable
        fprintf('步骤4.1: 删除所有现有Runnable...\n');
        existingRunnables = find(arProps, ib, 'Runnable', 'PathType', 'FullyQualified');
        for i = 1:length(existingRunnables)
            try
                delete(arProps, existingRunnables{i});
                fprintf('  已删除Runnable: %s\n', existingRunnables{i});
            catch ME
                warning('MATLAB:changeAutosarRunnable:DeleteRunnableFailed', ...
                        '删除Runnable失败: %s, 错误: %s', existingRunnables{i}, ME.message);
            end
        end
        if isempty(existingRunnables)
            fprintf('  未找到现有Runnable\n');
        end
        
        % 步骤4.2: 删除所有现有事件
        fprintf('步骤4.2: 删除所有现有事件...\n');
        existingEvents = find(arProps, ib, 'Event', 'PathType', 'FullyQualified');
        for i = 1:length(existingEvents)
            try
                delete(arProps, existingEvents{i});
                fprintf('  已删除事件: %s\n', existingEvents{i});
            catch ME
                warning('MATLAB:changeAutosarRunnable:DeleteEventFailed', ...
                        '删除事件失败: %s, 错误: %s', existingEvents{i}, ME.message);
            end
        end
        if isempty(existingEvents)
            fprintf('  未找到现有事件\n');
        end
        
        % 步骤4.3: 创建初始化Runnable
        fprintf('步骤4.3: 创建初始化Runnable...\n');
        initRunnablePath = [ib, '/', initRunnableName];
        add(arProps, ib, 'Runnables', initRunnableName);
        set(arProps, initRunnablePath, 'Name', initRunnableName);
        set(arProps, initRunnablePath, 'symbol', initRunnableName);
        fprintf('  已创建初始化Runnable: %s\n', initRunnableName);
        
        % 步骤4.4: 创建周期性Runnable
        fprintf('步骤4.4: 创建周期性Runnable...\n');
        cyclicRunnablePath = [ib, '/', cyclicRunnableName];
        add(arProps, ib, 'Runnables', cyclicRunnableName);
        set(arProps, cyclicRunnablePath, 'Name', cyclicRunnableName);
        set(arProps, cyclicRunnablePath, 'symbol', cyclicRunnableName);
        fprintf('  已创建周期性Runnable: %s\n', cyclicRunnableName);
        
        % 步骤4.5: 创建初始化事件
        fprintf('步骤4.5: 创建初始化事件...\n');
        initEventName = ['Event_', initRunnableName];
        initEventPath = [ib, '/', initEventName];
        add(arProps, ib, 'Events', initEventName, 'Category', 'InitEvent');
        set(arProps, initEventPath, 'Name', initEventName);
        set(arProps, initEventPath, 'StartOnEvent', initRunnablePath);
        fprintf('  已创建初始化事件: %s\n', initEventName);
        
        % 步骤4.6: 创建周期性事件
        fprintf('步骤4.6: 创建周期性事件...\n');
        cyclicEventName = ['Event_', cyclicRunnableName];
        cyclicEventPath = [ib, '/', cyclicEventName];
        add(arProps, ib, 'Events', cyclicEventName, 'Category', 'TimingEvent');
        set(arProps, cyclicEventPath, 'Name', cyclicEventName);
        set(arProps, cyclicEventPath, 'StartOnEvent', cyclicRunnablePath);
        set(arProps, cyclicEventPath, 'Period', runnablePeriod);
        fprintf('  已创建周期性事件: %s，周期: %f秒\n', cyclicEventName, runnablePeriod);
        
        fprintf('AUTOSAR Runnable和事件创建完成\n');
        
    catch ME
        error('MATLAB:changeAutosarRunnable:CreateRunnableFailed', ...
              'AUTOSAR Runnable和事件创建失败: %s', ME.message);
    end

    %% 步骤5: 验证AUTOSAR事件配置
    try
        allEvents = find(arProps, ib, 'Event', 'PathType', 'FullyQualified');
        
        fprintf('步骤5: 验证AUTOSAR事件配置...\n');
        for eventIdx = 1:length(allEvents)
            currentEvent = allEvents{eventIdx};
            
            % 获取事件属性
            eventStartOn = get(arProps, currentEvent, 'StartOnEvent');
            try
                eventPeriod = get(arProps, currentEvent, 'Period');
                fprintf('  事件 %s 触发于 %s，周期: %f秒\n', ...
                        currentEvent, eventStartOn, eventPeriod);
            catch
                fprintf('  事件 %s 触发于 %s (非周期性事件)\n', ...
                        currentEvent, eventStartOn);
            end
        end
        fprintf('已验证 %d 个事件配置\n', length(allEvents));
        
    catch ME
        warning('MATLAB:changeAutosarRunnable:VerifyEventFailed', ...
                'AUTOSAR事件配置验证失败: %s', ME.message);
    end

    %% 步骤6: 修改XML选项
    try
        fprintf('步骤6: 修改XML选项和模型配置...\n');
        
        % 设置XML选项：Source为Inline，打包为单文件
%         set(arProps, 'XmlOptions', 'XmlOptionsSource', 'Inlined');
%         set(arProps, 'XmlOptions', 'ArxmlFilePackaging', 'SingleFile');
%         fprintf('  已设置XML选项：Source=Inlined, Packaging=SingleFile\n');
        
        % 保存模型
        % save_system(model);
        % fprintf('XML选项和模型配置修改完成，模型已保存\n');
        
    catch ME
        error('MATLAB:changeAutosarRunnable:ConfigFailed', ...
              'XML选项和模型配置修改失败: %s', ME.message);
    end


    %% 步骤7: 修改Mapping属性
    try
        fprintf('步骤7: 设置AUTOSAR Mapping属性...\n');
        
        % 获取Simulink mapping对象
        slMap = autosar.api.getSimulinkMapping(model);
        
        % 设置Initialize函数映射到初始化Runnable
        try
            mapFunction(slMap, 'Initialize', initRunnableName);
            fprintf('  已设置Initialize函数映射到Runnable: %s\n', initRunnableName);
        catch ME
            warning('MATLAB:changeAutosarRunnable:MapInitializeFailed', ...
                    'Initialize函数映射设置失败: %s', ME.message);
        end
        
        % 根据模型类型设置周期性函数映射
        if isExportFunction
            % Export-Function模型：查找函数调用输入端口并映射
            try
                % 查找所有函数调用输入端口
                functionCallInports = find_system(model, 'SearchDepth', 1, ...
                                                   'BlockType', 'Inport', ...
                                                   'OutputFunctionCall', 'on');
                
                if ~isempty(functionCallInports)
                    % 获取第一个函数调用端口的名称
                    functionName = get_param(functionCallInports{1}, 'Name');
                    try
                        mapFunction(slMap, functionName, cyclicRunnableName);
                        fprintf('  已设置Exported Function "%s" 映射到Runnable: %s\n', ...
                                functionName, cyclicRunnableName);
                    catch ME2
                        warning('MATLAB:changeAutosarRunnable:MapFunctionFailed', ...
                                '映射函数 "%s" 失败: %s', functionName, ME2.message);
                    end
                else
                    % 如果没有找到函数调用端口，尝试使用模型名称
                    try
                        functionName = [model, '_Runnable'];
                        mapFunction(slMap, functionName, cyclicRunnableName);
                        fprintf('  已设置Exported Function "%s" 映射到Runnable: %s\n', ...
                                functionName, cyclicRunnableName);
                    catch
                        warning('MATLAB:changeAutosarRunnable:NoExportedFunction', ...
                                '未找到Exported Function，请手动映射函数调用端口到Runnable');
                    end
                end
            catch ME
                warning('MATLAB:changeAutosarRunnable:MapExportedFunctionFailed', ...
                        'Exported Function映射设置失败: %s', ME.message);
            end
        else
            % Rate-Based模型：映射Periodic函数
            try
                mapFunction(slMap, 'Periodic', cyclicRunnableName);
                fprintf('  已设置Periodic函数映射到Runnable: %s\n', cyclicRunnableName);
            catch ME
                warning('MATLAB:changeAutosarRunnable:MapPeriodicFailed', ...
                        'Periodic函数映射设置失败: %s', ME.message);
            end
            
            % 尝试映射Periodic:D1（如果存在）
            try
                mapFunction(slMap, 'Periodic:D1', cyclicRunnableName);
                fprintf('  已设置Periodic:D1函数映射到Runnable: %s\n', cyclicRunnableName);
            catch
                % 如果不存在，这是正常的，不显示警告
            end
        end
        
        % 验证mapping设置
        try
            initRunnable = getFunction(slMap, 'Initialize');
            fprintf('  验证Mapping设置:\n');
            fprintf('    Initialize -> %s\n', initRunnable);
            
            if isExportFunction
                try
                    % 查找函数调用端口并验证映射
                    functionCallInports = find_system(model, 'SearchDepth', 1, ...
                                                       'BlockType', 'Inport', ...
                                                       'OutputFunctionCall', 'on');
                    if ~isempty(functionCallInports)
                        functionName = get_param(functionCallInports{1}, 'Name');
                        cyclicRunnable = getFunction(slMap, functionName);
                        fprintf('    %s -> %s\n', functionName, cyclicRunnable);
                    end
                catch
                    % 忽略验证错误
                end
            else
                try
                    periodicRunnable = getFunction(slMap, 'Periodic');
                    fprintf('    Periodic -> %s\n', periodicRunnable);
                catch
                    % 忽略验证错误
                end
            end
        catch ME
            warning('MATLAB:changeAutosarRunnable:VerifyMappingFailed', ...
                    'Mapping验证失败: %s', ME.message);
        end
        
        fprintf('AUTOSAR Mapping属性设置完成\n');
        
    catch ME
        error('MATLAB:changeAutosarRunnable:MappingFailed', ...
              'AUTOSAR Mapping属性设置失败: %s', ME.message);
    end

    %% 步骤8: 生成AUTOSAR代码（可选）
    if autoBuild
        try
            fprintf('步骤8: 开始生成AUTOSAR代码...\n');
            slbuild(model);
            fprintf('模型 %s 代码生成完成\n', model);
        catch ME
            warning('MATLAB:changeAutosarRunnable:BuildFailed', ...
                    '代码生成失败: %s', ME.message);
        end
    else
        fprintf('步骤8: 跳过代码生成（AutoBuild=false）\n');
    end
    
    fprintf('AUTOSAR Runnable配置完成: %s\n', model);
end
