function result = changeAutosarPortToBus(model, varargin)
%CHANGEAUTOSARPORTTOBUS 将AUTOSAR端口转换为Bus Element
%
%   RESULT = CHANGEAUTOSARPORTTOBUS(MODEL) 将指定Simulink模型中的AUTOSAR
%   映射端口（Inport/Outport）转换为Bus Element（In Bus Element/Out Bus Element），
%   并保持原有的AUTOSAR映射关系。
%
%   输入参数:
%       MODEL - 字符向量或字符串标量，指定Simulink模型名称。如果未提供或为空，
%              则使用当前根模型（bdroot）。
%
%   可选参数（名值对）:
%       'Verbose' - 逻辑标量，是否显示详细处理信息。默认为 true。
%
%   输出参数:
%       RESULT - 结构体，包含转换结果统计信息，包含以下字段:
%           TotalInports      - 处理的输入端口总数
%           ConvertedInports  - 成功转换的输入端口数量
%           FailedInports     - 转换失败的输入端口数量
%           TotalOutports     - 处理的输出端口总数
%           ConvertedOutports - 成功转换的输出端口数量
%           FailedOutports    - 转换失败的输出端口数量
%           InportDetails     - 输入端口转换详情（结构体数组）
%           OutportDetails    - 输出端口转换详情（结构体数组）
%
%   示例:
%       % 转换当前模型的AUTOSAR端口为Bus Element
%       result = changeAutosarPortToBus();
%
%       % 转换指定模型的端口
%       result = changeAutosarPortToBus('myModel');
%
%       % 转换端口但不显示详细信息
%       result = changeAutosarPortToBus('myModel', 'Verbose', false);
%
%       % 查看转换结果
%       fprintf('成功转换 %d 个输入端口和 %d 个输出端口\n', ...
%           result.ConvertedInports, result.ConvertedOutports);
%
%   注意:
%       - 模型必须已配置AUTOSAR映射
%       - 如果模型未加载，函数会自动加载模型
%       - 转换后的Bus Element会保持原有的AUTOSAR映射关系（Port、Element、DataAccessMode）
%       - 原端口会被删除，新创建的Bus Element会使用MakeNameUnique确保名称唯一
%
%   另请参阅:
%       FINDAUTOSARMAPPINGPORTS, AUTOSAR.API.GETSIMULINKMAPPING
%
%   作者: Blue.ge
%   日期: 20251113
%   版本: 1.0

    %% 输入参数验证和解析
    p = inputParser;
    addOptional(p, 'model', [], @(x) ischar(x) || isstring(x) || isempty(x));
    addParameter(p, 'Verbose', true, @islogical);
    
    % 处理无参数调用的情况
    if nargin == 0
        parse(p);
    else
        parse(p, model, varargin{:});
    end
    
    model = p.Results.model;
    verbose = p.Results.Verbose;
    
    % 如果未提供模型名称，使用当前根模型
    if isempty(model)
        model = bdroot;
        if isempty(model)
            error('未找到打开的Simulink模型');
        end
    end
    
    % 确保模型名称是字符向量
    if isstring(model)
        model = char(model);
    end
    
    % 检查模型是否存在
    if ~bdIsLoaded(model)
        try
            load_system(model);
        catch ME
            error('无法加载模型 %s: %s', model, ME.message);
        end
    end
    
    %% 获取AUTOSAR映射端口信息
    try
        [inports, outports] = findAutosarMappingPorts(model);
        slMap = autosar.api.getSimulinkMapping(model);
    catch ME
        error('无法获取AUTOSAR映射信息: %s', ME.message);
    end
    
    %% 初始化结果统计
    result = struct(...
        'TotalInports', 0, ...
        'ConvertedInports', 0, ...
        'FailedInports', 0, ...
        'TotalOutports', 0, ...
        'ConvertedOutports', 0, ...
        'FailedOutports', 0, ...
        'InportDetails', [], ...
        'OutportDetails', []);
    
    % 初始化详情结构体模板（确保字段一致）
    detailTemplate = struct(...
        'OriginalName', '', ...
        'NewName', '', ...
        'Status', 'Failed', ...
        'Message', '', ...
        'ARPort', '', ...
        'ARElement', '', ...
        'DataAccessMode', '');
    
    inportDetails = [];
    outportDetails = [];
    
    % 用于跟踪已创建的Bus Element（按Port和Element组合）
    createdBusElements = containers.Map('KeyType', 'char', 'ValueType', 'any');

    %% 处理输入端口
    result.TotalInports = length(inports);
    if verbose && result.TotalInports > 0
        fprintf('开始处理 %d 个输入端口...\n', result.TotalInports);
    end
    
    for i = 1:result.TotalInports
        inport = inports(i);
        portName = inport.Source;

        % 判断是否是Inport端口而非bus element, 如果是后者，则跳过
        if strcmp(get_param(inport.PortHandle, 'IsBusElementPort'), 'on')
            if verbose
                fprintf('  [跳过] 输入端口%d: %s 是Bus Element，跳过\n', i, portName);
            end
            continue;
        end
        
        % 判断是否是IsUpdated端口，如果是，则跳过（原封不动保留）
        if strcmp(inport.DataAccessMode, 'IsUpdated')
            if verbose
                fprintf('  [跳过] 输入端口%d: %s 是IsUpdated端口，跳过（原封不动保留）\n', i, portName);
            end
            continue;
        end
        
        % 初始化详情结构（使用模板确保字段一致）
        detail = detailTemplate;
        detail.OriginalName = portName;
        detail.ARPort = inport.Port;
        detail.ARElement = inport.Element;
        detail.DataAccessMode = inport.DataAccessMode;
        
        try
            % 在删除前保存所有需要的信息
            pos = get_param(inport.PortHandle, 'Position');
            portNumber = get_param(inport.PortHandle, 'Port');
            dataType = get_param(inport.PortHandle, 'OutDataTypeStr');
            % 通过PortHandles获取连线信息（Inport块的输出端口连接到其他块）
            portHandles = get_param(inport.PortHandle, 'PortHandles');
            lineHandle = -1;
            DstPortHandle = [];
            if ~isempty(portHandles.Outport) && portHandles.Outport ~= -1
                lineHandle = get_param(portHandles.Outport, 'Line');
                % 获取连线源端口句柄（用于后续重新连接）
                if lineHandle ~= -1
                    DstPortHandle = get_param(lineHandle, 'DstPortHandle');
                end
            end
            
            % 对于非IsUpdated端口，检查是否已经存在相同Port和Element的Bus Element
            busElementKey = sprintf('%s.%s', inport.Port, inport.Element);
            if isKey(createdBusElements, busElementKey)
                % 复用已存在的Bus Element
                existingInfo = createdBusElements(busElementKey);
                actualPortName = existingInfo.Name;
                busElementPath = existingInfo.Path;
                detail.NewName = actualPortName;
                detail.Message = sprintf('复用已存在的Bus Element: %s', actualPortName);
 
                % 删除连线
                if lineHandle ~= -1
                    delete_line(lineHandle);
                end
                % 删除原来的端口
                delete_block(inport.PortHandle);
                
                if verbose
                    fprintf('  [复用] 输入端口%d: %s -> %s (%s.%s)\n', i, ...
                        portName, actualPortName, inport.Port, inport.Element);
                end
            else
                % 删除连线
                if lineHandle ~= -1
                    delete_line(lineHandle);
                end
                % 删除原来的端口
                delete_block(inport.PortHandle);
                
                % 检查是否已存在相同PortName的Bus Element（避免名称冲突）
                existingBlocks = find_system(model, 'SearchDepth', 1, ...
                    'BlockType', 'Inport', ...
                    'PortName', inport.Port);
                
                if ~isempty(existingBlocks)
                    % 如果已存在相同PortName的Bus Element，尝试复用
                    existingBlock = existingBlocks{1};
                    busElementPath = add_block(existingBlock, [model '/In Bus Element'],'MakeNameUnique','on');
                    set_param(busElementPath, ...
                        'Element', inport.Element, ...
                        'Position', pos);

                    actualPortName = get_param(busElementPath, 'Name');
                    detail.NewName = actualPortName;
                    detail.Message = sprintf('复用已存在的Bus Element（相同PortName）: %s', actualPortName);
                    
                    if verbose
                        fprintf('  [复用] 输入端口%d: %s -> %s (%s.%s, 已存在相同PortName)\n', i, ...
                            portName, actualPortName, inport.Port, inport.Element);
                    end

                else
                    % 创建In Bus Element
                    busElementPath = add_block('simulink/Ports & Subsystems/In Bus Element', ...
                        [model, '/', 'In Bus Element'], ...
                        'Position', pos, ...
                        'PortName', inport.Port, ...
                        'Element', inport.Element, ...
                        'Port', portNumber, ...
                        'OutDataTypeStr', dataType, ...
                        'MakeNameUnique', 'on');
                    
                    % 获取实际创建的块名称（因为MakeNameUnique可能会改变名称）
                    actualPortName = get_param(busElementPath, 'Name');
                    detail.NewName = actualPortName;
                    
                    if verbose
                        fprintf('  [成功] 输入端口%d: %s -> %s (%s.%s)\n', i, ...
                            portName, actualPortName, inport.Port, inport.Element);
                    end
                end
                
                % 保存创建的Bus Element信息
                createdBusElements(busElementKey) = struct('Name', actualPortName, 'Path', busElementPath);
            end
            
            % 添加连线（如果原来有连线）
            if ~isempty(DstPortHandle) && DstPortHandle ~= -1
                try
                    % 获取Bus Element的输出端口句柄
                    busElementPortHandles = get_param(busElementPath, 'PortHandles');
                    if ~isempty(busElementPortHandles.Outport)
                        add_line(model, busElementPortHandles.Outport, DstPortHandle, 'autorouting', 'on');
                    end
                catch ME
                    warning('无法添加连线到Bus Element %s: %s', actualPortName, ME.message);
                end
            end
            
            % 执行映射：保持原来的AUTOSAR映射关系
            % mapInport(SimulinkPortName, ARPort, ARDataElement, ARDataAccessMode)
            slMap.mapInport(actualPortName, inport.Port, inport.Element, inport.DataAccessMode);
            
            result.ConvertedInports = result.ConvertedInports + 1;
            detail.Status = 'Success';
            if isempty(detail.Message)
                detail.Message = sprintf('%d:成功转换并映射: %s -> %s.%s', i, ...
                    actualPortName, inport.Port, inport.Element);
            end
            
        catch ME
            result.FailedInports = result.FailedInports + 1;
            detail.Message = sprintf('转换失败: %s', ME.message);
            warning('处理输入端口 %s 时出错: %s', portName, ME.message);
        end
        
        % 保存详情
        if isempty(inportDetails)
            inportDetails = detail;
        else
            inportDetails(end+1) = detail; %#ok<AGROW>
        end
    end

    %% 处理输出端口
    result.TotalOutports = length(outports);
    if verbose && result.TotalOutports > 0
        fprintf('开始处理 %d 个输出端口...\n', result.TotalOutports);
    end
    
    % 清空并重新初始化用于输出端口的Map
    createdBusElements = containers.Map('KeyType', 'char', 'ValueType', 'any');
    
    for i = 1:result.TotalOutports
        outport = outports(i);
        portName = outport.Source;

        % 判断是否是Outport端口而非bus element, 如果是后者，则跳过
        if strcmp(get_param(outport.PortHandle, 'IsBusElementPort'), 'on')
            if verbose
                fprintf('  [跳过] 输出端口%d: %s 是Bus Element，跳过\n', i, portName);
            end
            continue;
        end
        
        % 判断是否是IsUpdated端口，如果是，则跳过（原封不动保留）
        if strcmp(outport.DataAccessMode, 'IsUpdated')
            if verbose
                fprintf('  [跳过] 输出端口%d: %s 是IsUpdated端口，跳过（原封不动保留）\n', i, portName);
            end
            continue;
        end
        
        % 初始化详情结构（使用模板确保字段一致）
        detail = detailTemplate;
        detail.OriginalName = portName;
        detail.ARPort = outport.Port;
        detail.ARElement = outport.Element;
        detail.DataAccessMode = outport.DataAccessMode;
        
        try
            % 在删除前保存所有需要的信息
            pos = get_param(outport.PortHandle, 'Position');
            portNumber = get_param(outport.PortHandle, 'Port');
            dataType = get_param(outport.PortHandle, 'OutDataTypeStr');
            % 通过PortHandles获取连线信息（Outport块的输入端口连接到其他块）
            portHandles = get_param(outport.PortHandle, 'PortHandles');
            lineHandle = -1;
            SrcPortHandle = [];
            if ~isempty(portHandles.Inport) && portHandles.Inport ~= -1
                lineHandle = get_param(portHandles.Inport, 'Line');
                % 获取连线目标端口句柄（用于后续重新连接）
                if lineHandle ~= -1
                    SrcPortHandle = get_param(lineHandle, 'SrcPortHandle');
                end
            end
            
            % 对于非IsUpdated端口，检查是否已经存在相同Port和Element的Bus Element
            busElementKey = sprintf('%s.%s', outport.Port, outport.Element);
            if isKey(createdBusElements, busElementKey)
                % 复用已存在的Bus Element
                existingInfo = createdBusElements(busElementKey);
                actualPortName = existingInfo.Name;
                busElementPath = existingInfo.Path;
                detail.NewName = actualPortName;
                detail.Message = sprintf('复用已存在的Bus Element: %s', actualPortName);
                
                % 删除连线
                if lineHandle ~= -1
                    delete_line(lineHandle);
                end
                % 删除原来的端口
                delete_block(outport.PortHandle);
                
                if verbose
                    fprintf('  [复用] 输出端口%d: %s -> %s (%s.%s)\n', i, ...
                        portName, actualPortName, outport.Port, outport.Element);
                end
            else
                % 删除连线
                if lineHandle ~= -1
                    delete_line(lineHandle);
                end
                % 删除原来的端口
                delete_block(outport.PortHandle);
                
                % 检查是否已存在相同PortName的Bus Element（避免名称冲突）
                existingBlocks = find_system(model, 'SearchDepth', 1, ...
                    'BlockType', 'Outport', ...
                    'PortName', outport.Port);
                
                if ~isempty(existingBlocks)
                    % 如果已存在相同PortName的Bus Element，尝试复用
                    existingBlock = existingBlocks{1};
                    busElementPath = add_block(existingBlock, [model '/Out Bus Element'],'MakeNameUnique','on');
                    set_param(busElementPath, ...
                        'Element', outport.Element, ...
                        'Position', pos);
                    actualPortName = get_param(busElementPath, 'Name');
                    detail.NewName = actualPortName;
                    detail.Message = sprintf('复用已存在的Bus Element（相同PortName）: %s', actualPortName);
                    
                    if verbose
                        fprintf('  [复用] 输出端口%d: %s -> %s (%s.%s, 已存在相同PortName)\n', i, ...
                            portName, actualPortName, outport.Port, outport.Element);
                    end


                else
                    % 创建Out Bus Element
                    busElementPath = add_block('simulink/Ports & Subsystems/Out Bus Element', ...
                        [model, '/', 'Out Bus Element'], ...
                        'Position', pos, ...
                        'PortName', outport.Port, ...
                        'Element', outport.Element, ...
                        'Port', portNumber, ...
                        'OutDataTypeStr', dataType, ...
                        'MakeNameUnique', 'on');
                    
                    % 获取实际创建的块名称（因为MakeNameUnique可能会改变名称）
                    actualPortName = get_param(busElementPath, 'Name');
                    detail.NewName = actualPortName;
                    
                    if verbose
                        fprintf('  [成功] 输出端口%d: %s -> %s (%s.%s)\n', i, ...
                            portName, actualPortName, outport.Port, outport.Element);
                    end
                end
                
                % 保存创建的Bus Element信息
                createdBusElements(busElementKey) = struct('Name', actualPortName, 'Path', busElementPath);
            end
            
            % 添加连线（如果原来有连线）
            if ~isempty(SrcPortHandle) && SrcPortHandle ~= -1
                try
                    % 获取Bus Element的输入端口句柄
                    busElementPortHandles = get_param(busElementPath, 'PortHandles');
                    if ~isempty(busElementPortHandles.Inport)
                        add_line(model, SrcPortHandle, busElementPortHandles.Inport, 'autorouting', 'on');
                    end

                catch ME
                    warning('无法添加连线到Bus Element %s: %s', actualPortName, ME.message);
                end
            end
            
            % 执行映射：保持原来的AUTOSAR映射关系
            % mapOutport(SimulinkPortName, ARPort, ARDataElement, ARDataAccessMode)
            slMap.mapOutport(actualPortName, outport.Port, outport.Element, outport.DataAccessMode);
            
            result.ConvertedOutports = result.ConvertedOutports + 1;
            detail.Status = 'Success';
            if isempty(detail.Message)
                detail.Message = sprintf('%d:成功转换并映射: %s -> %s.%s', i, ...
                    actualPortName, outport.Port, outport.Element);
            end
            
        catch ME
            result.FailedOutports = result.FailedOutports + 1;
            detail.Message = sprintf('转换失败: %s', ME.message);
            warning('处理输出端口 %s 时出错: %s', portName, ME.message);
        end
        
        % 保存详情
        if isempty(outportDetails)
            outportDetails = detail;
        else
            outportDetails(end+1) = detail; %#ok<AGROW>
        end
    end
    
    %% 保存结果并显示摘要
    result.InportDetails = inportDetails;
    result.OutportDetails = outportDetails;
    save_system(model);
    if verbose
        fprintf('\n%s 转换完成摘要:\n', model);
        fprintf('  输入端口: %d/%d 成功, %d 失败\n', ...
            result.ConvertedInports, result.TotalInports, result.FailedInports);
        fprintf('  输出端口: %d/%d 成功, %d 失败\n', ...
            result.ConvertedOutports, result.TotalOutports, result.FailedOutports);
    end

end
