function [mappingResults, unmappedInports, unmappedOutports] = createAutosarMapByRef(modelName, refModelName, varargin)
%CREATEAUTOSARMAPBYREF 根据参考模型创建AUTOSAR映射
%
%   [MAPPINGRESULTS, UNMAPPEDINPORTS, UNMAPPEDOUTPORTS] = CREATEAUTOSARMAPBYREF(MODELNAME, REFMODELNAME)
%   根据参考模型的AUTOSAR映射信息，为新模型创建相应的映射配置。
%
%   输入参数:
%       MODELNAME    - 字符向量或字符串标量，目标模型名称
%       REFMODELNAME - 字符向量或字符串标量，参考模型名称
%
%   输出参数:
%       MAPPINGRESULTS  - 结构体，包含映射统计信息
%       UNMAPPEDINPORTS - 字符向量元胞数组，未映射的输入端口名称
%       UNMAPPEDOUTPORTS- 字符向量元胞数组，未映射的输出端口名称
%
%   映射结果结构体包含以下字段:
%       totalInports           - 双精度标量，总输入端口数量
%       totalProcessedInports  - 双精度标量，实际处理的输入端口数量
%       mappedInports          - 双精度标量，已映射的输入端口数量
%       unmappedInports        - 双精度标量，未映射的输入端口数量
%       skippedTriggerInports  - 双精度标量，跳过的触发输入端口数量
%       totalOutports          - 双精度标量，总输出端口数量
%       totalProcessedOutports - 双精度标量，实际处理的输出端口数量
%       mappedOutports         - 双精度标量，已映射的输出端口数量
%       unmappedOutports       - 双精度标量，未映射的输出端口数量
%       mappingSuccess         - 逻辑标量，映射是否成功完成
%
%   示例:
%       % 基本用法
%       [results, unmappedIn, unmappedOut] = createAutosarMapByRef('newModel', 'referenceModel');
%
%       % 显示映射结果
%       fprintf('映射完成！\n');
%       fprintf('输入端口: %d/%d 已映射\n', results.mappedInports, results.totalInports);
%       fprintf('输出端口: %d/%d 已映射\n', results.mappedOutports, results.totalOutports);
%
%       % 显示未映射的端口
%       if ~isempty(unmappedIn)
%           fprintf('未映射的输入端口: %s\n', strjoin(unmappedIn, ', '));
%       end
%       if ~isempty(unmappedOut)
%           fprintf('未映射的输出端口: %s\n', strjoin(unmappedOut, ', '));
%       end
%
%   注意:
%       - 两个模型都必须已配置AUTOSAR映射
%       - 端口名称匹配基于包含关系（contains函数）
%       - 如果模型未加载，函数会自动加载模型
%       - 映射操作会覆盖现有的映射配置
%
%   另请参阅:
%       FINDAUTOSARMAPPINGPORTS, AUTOSAR.API.GETSIMULINKMAPPING
%
%   作者: 自动生成
%   日期: 2024
    % 输入参数验证
    if nargin < 2
        error('需要提供目标模型名称和参考模型名称');
    end
    
    % 检查模型是否存在并加载
    if ~bdIsLoaded(modelName)
        try
            load_system(modelName);
        catch ME
            error('无法加载目标模型 %s: %s', modelName, ME.message);
        end
    end
    
    if ~bdIsLoaded(refModelName)
        try
            load_system(refModelName);
        catch ME
            error('无法加载参考模型 %s: %s', refModelName, ME.message);
        end
    end

    % 获取参考模型的AUTOSAR映射信息
    try
        [inports, outports] = findAutosarMappingPorts(refModelName);
    catch ME
        error('无法获取参考模型 %s 的AUTOSAR映射信息: %s', refModelName, ME.message);
    end

    % 获取目标模型的AUTOSAR映射对象
    try
        slMap = autosar.api.getSimulinkMapping(modelName);
    catch ME
        error('无法获取目标模型 %s 的AUTOSAR映射对象: %s', modelName, ME.message);
    end
    % 获取所有端口
    allInPorts = find_system(modelName, 'SearchDepth', 1, ...
                          'BlockType', 'Inport');
    allOutPorts = find_system(modelName, 'SearchDepth', 1, ...
                             'BlockType', 'Outport');
    
    % 初始化统计变量
    unmappedInports = {};
    unmappedOutports = {};
    mappedInports = 0;
    mappedOutports = 0;
    skippedTriggerInports = 0;
    totalProcessedInports = 0;
    totalProcessedOutports = 0;
    mappingSuccess = true;
    
    % 处理输入端口
    fprintf('开始处理输入端口映射...\n');
    for i = 1:length(allInPorts)
        try
            portName = get_param(allInPorts{i}, 'Name');
            if isempty(portName) || ~ischar(portName) && ~isstring(portName)
                continue;
            end
            
            totalProcessedInports = totalProcessedInports + 1;
            
            % 检查trigger属性，如果为true，则跳过
            if strcmp(get_param(allInPorts{i}, 'OutputFunctionCall'), 'on')
                skippedTriggerInports = skippedTriggerInports + 1;
                fprintf('跳过触发端口: %s\n', portName);
                continue;
            end

            % 注： 如果两个模型命名规则不同，则需要转换，
            % 比如参考模型名称格式为BookTrvlClimaActvReq_BookTrvlClimaActvReq，
            % 目标模型格式为BookTrvlClimaActvReq
            % 则需要将目标名字扩展成参考模型名字，比如demo-->demo_demo; demo_IsUpdate-->demo_demo_IsUpdate
            if endsWith(portName, '_IsUpdated')
                % 去掉_IsUpdated
                portNameRaw = extractBefore(portName, '_IsUpdated');
                portNameRef = [portNameRaw, '_', portNameRaw, '_IsUpdated'];
            else
                portNameRef = [portName, '_', portName];
            end
            
            % 查找匹配的参考端口
            idx = find(strcmp({inports.Source}, portNameRef));
            if isempty(idx)
                unmappedInports{end+1} = portName;
                fprintf('未找到匹配的参考输入端口: %s\n', portName);
                continue;
            end
            
            % 执行映射
            try
                slMap.mapInport(portName, inports(idx).Port, inports(idx).Element, inports(idx).DataAccessMode);
                mappedInports = mappedInports + 1;
                fprintf('成功映射输入端口: %s -> %s\n', portName, inports(idx).Port);
            catch ME
                warning(ME.identifier, '映射输入端口 %s 失败: %s', portName, ME.message);
                unmappedInports{end+1} = portName;
                mappingSuccess = false;
            end
        catch ME
            warning(ME.identifier, '处理输入端口 %d 时出错: %s', i, ME.message);
            mappingSuccess = false;
        end
    end
    
    % 处理输出端口
    fprintf('开始处理输出端口映射...\n');
    for i = 1:length(allOutPorts)
        try
            portName = get_param(allOutPorts{i}, 'Name');
            if isempty(portName) || ~ischar(portName) && ~isstring(portName)
                continue;
            end
            
            totalProcessedOutports = totalProcessedOutports + 1;
            
            % 查找匹配的参考端口
            idx = find(contains({outports.Source}, portName));
            if isempty(idx)
                unmappedOutports{end+1} = portName;
                fprintf('未找到匹配的参考输出端口: %s\n', portName);
                continue;
            end
            
            % 执行映射
            try
                slMap.mapOutport(portName, outports(idx).Port, outports(idx).Element, outports(idx).DataAccessMode);
                mappedOutports = mappedOutports + 1;
                fprintf('成功映射输出端口: %s -> %s\n', portName, outports(idx).Port);
            catch ME
                warning(ME.identifier, '映射输出端口 %s 失败: %s', portName, ME.message);
                unmappedOutports{end+1} = portName;
                mappingSuccess = false;
            end
        catch ME
            warning(ME.identifier, '处理输出端口 %d 时出错: %s', i, ME.message);
            mappingSuccess = false;
        end
    end
    
    % 创建映射结果结构体
    mappingResults = struct('totalInports', length(allInPorts), ...
                           'totalProcessedInports', totalProcessedInports, ...
                           'mappedInports', mappedInports, ...
                           'unmappedInports', length(unmappedInports), ...
                           'skippedTriggerInports', skippedTriggerInports, ...
                           'totalOutports', length(allOutPorts), ...
                           'totalProcessedOutports', totalProcessedOutports, ...
                           'mappedOutports', mappedOutports, ...
                           'unmappedOutports', length(unmappedOutports), ...
                           'mappingSuccess', mappingSuccess);
    
    % 输出映射结果摘要
    fprintf('\n=== 映射结果摘要 ===\n');
    fprintf('输入端口统计:\n');
    fprintf('  总端口数: %d\n', length(allInPorts));
    fprintf('  处理端口数: %d\n', totalProcessedInports);
    fprintf('  已映射: %d\n', mappedInports);
    fprintf('  未映射: %d\n', length(unmappedInports));
    fprintf('  跳过触发端口: %d\n', skippedTriggerInports);
    fprintf('  跳过无效端口: %d\n', length(allInPorts) - totalProcessedInports);
    
    fprintf('输出端口统计:\n');
    fprintf('  总端口数: %d\n', length(allOutPorts));
    fprintf('  处理端口数: %d\n', totalProcessedOutports);
    fprintf('  已映射: %d\n', mappedOutports);
    fprintf('  未映射: %d\n', length(unmappedOutports));
    fprintf('  跳过无效端口: %d\n', length(allOutPorts) - totalProcessedOutports);
    
    % 验证统计数据的正确性
    fprintf('\n数据验证:\n');
    inportCheck = totalProcessedInports == (mappedInports + length(unmappedInports) + skippedTriggerInports);
    outportCheck = totalProcessedOutports == (mappedOutports + length(unmappedOutports));
    fprintf('  输入端口统计正确: %s\n', mat2str(inportCheck));
    fprintf('  输出端口统计正确: %s\n', mat2str(outportCheck));
    
    if ~isempty(unmappedInports)
        fprintf('\n未映射的输入端口 (%d个):\n', length(unmappedInports));
        for i = 1:min(10, length(unmappedInports))  % 只显示前10个
            fprintf('  %s\n', unmappedInports{i});
        end
        if length(unmappedInports) > 10
            fprintf('  ... 还有 %d 个未显示\n', length(unmappedInports) - 10);
        end
    end
    
    if ~isempty(unmappedOutports)
        fprintf('\n未映射的输出端口 (%d个):\n', length(unmappedOutports));
        for i = 1:min(10, length(unmappedOutports))  % 只显示前10个
            fprintf('  %s\n', unmappedOutports{i});
        end
        if length(unmappedOutports) > 10
            fprintf('  ... 还有 %d 个未显示\n', length(unmappedOutports) - 10);
        end
    end
    
    if mappingSuccess
        fprintf('\n映射操作成功完成！\n');
    else
        fprintf('\n映射操作完成，但存在错误或警告。\n');
    end
end
