function [inport, outport] = createArchPort(ArchModel, varargin)
%CREATEARCHPORT 为AUTOSAR架构模型创建输入输出端口
%   [INPORT, OUTPORT] = CREATEARCHPORT(ARCHMODEL, Name, Value, ...)
%   为AUTOSAR架构模型创建输入输出端口，输入输出端口是架构模型中的端口，不是Simulink模型中的端口
%
%   必需参数:
%      ArchModel    - 架构模型名称 (字符串) 或已加载的架构模型对象
%                     如果为字符串，将使用 autosar.arch.loadModel 加载模型
%                     如果为对象，将直接使用该对象
%
%   可选参数 (名称-值对):
%      'SkipTrigger' - 是否跳过触发端口 (逻辑值, 默认: true)
%
%   输出参数:
%      inport       - 创建的输入端口对象数组 (Arch.Port 数组)
%      outport      - 创建的输出端口对象数组 (Arch.Port 数组)
%
%   功能描述:
%      1. 加载或使用指定的AUTOSAR架构模型
%      2. 从架构模型中获取所有顶层组件和组合内的组件
%      3. 遍历所有AUTOSAR组件，收集输入输出端口信息
%      4. 对端口进行去重（基于端口名称）
%      5. 为架构模型创建输入输出端口
%      6. 复制端口的数据类型和描述信息
%
%   示例:
%      % 基本用法 - 使用字符串
%      [inport, outport] = createArchPort('CcmArch')
%      
%      % 使用已加载的架构模型对象
%      archModel = autosar.arch.loadModel('CcmArch');
%      [inport, outport] = createArchPort(archModel)
%
%   注意事项:
%      1. 如果输入为字符串，使用前需要确保架构模型文件存在
%      2. 如果输入为对象，确保该对象是有效的架构模型对象
%      3. 函数会遍历所有AUTOSAR组件（包括组合内的组件）
%      4. 输入端口只处理 BusElementPort 类型的端口
%      5. 端口的数据类型和描述信息会从 Simulink 模型中复制
%      6. 相同名称的端口会被去重，只创建一个架构端口
%
%   参见: AUTOSAR.ARCH.LOADMODEL, AUTOSAR.ARCH.FIND, AUTOSAR.ARCH.ADDPORT,
%         FINDMODPORTS, GET_PARAM, SET_PARAM
%
%   作者: Blue.ge
%   版本: 3.0
%   日期: 20251120

    %% 参数解析和验证
    % 创建输入解析器
    p = inputParser;
    p.FunctionName = mfilename;
    
    % 添加可选参数
    addParameter(p, 'SkipTrigger', true, ...
                 @(x) validateattributes(x, {'logical'}, {'scalar'}));
    
    % 解析输入参数
    parse(p, varargin{:});
    
    % 提取参数值
    skipTrigger = p.Results.SkipTrigger;

    %% 加载或使用架构模型
    % 判断输入是字符串还是已加载的模型对象
    if ischar(ArchModel) || isstring(ArchModel)
        % 输入是字符串，需要加载模型
        archModelName = char(ArchModel);
        try
            archModel = autosar.arch.loadModel(archModelName);
            fprintf('已加载架构模型: %s\n', archModelName);
        catch ME
            error('MATLAB:createArchPort:ModelLoadFailed', ...
                  '无法加载架构模型 "%s": %s', archModelName, ME.message);
        end
        modelNameForDisplay = archModelName;
    else
        % 输入是对象，直接使用
        archModel = ArchModel;
        try
            % 尝试获取模型名称，如果无法获取则使用默认名称
            if isprop(archModel, 'Name')
                modelNameForDisplay = archModel.Name;
            else
                modelNameForDisplay = '架构模型';
            end
        catch
            modelNameForDisplay = '架构模型';
        end
        fprintf('使用已加载的架构模型对象\n');
    end

    %% 收集所有AUTOSAR组件
    allComponents = [];
    try
        % 获取顶层组件
        topLevelComponents = archModel.Components;
        if ~isempty(topLevelComponents)
            % 确保是行向量，避免维度不一致的问题
            topLevelComponents = topLevelComponents(:)';
            allComponents = [allComponents, topLevelComponents];
            fprintf('找到 %d 个顶层组件\n', length(topLevelComponents));
        end
        
        % 获取所有组合及其内的组件
        compositions = archModel.Compositions;
        if ~isempty(compositions)
            fprintf('找到 %d 个组合\n', length(compositions));
            for i = 1:length(compositions)
                composition = compositions(i);
                compComponents = composition.Components;
                if ~isempty(compComponents)
                    % 确保是行向量，避免维度不一致的问题
                    compComponents = compComponents(:)';
                    allComponents = [allComponents, compComponents]; %#ok<AGROW>
                    fprintf('  组合 "%s" 包含 %d 个组件\n', composition.Name, length(compComponents));
                end
            end
        end
        
        if isempty(allComponents)
            warning('MATLAB:createArchPort:NoComponents', ...
                    '架构模型中未找到任何组件');
        else
            fprintf('共找到 %d 个组件（包括顶层和组合内的组件）\n', length(allComponents));
        end
    catch ME
        error('MATLAB:createArchPort:GetComponentsFailed', ...
              '获取组件列表失败: %s', ME.message);
    end

    %% 收集所有组件的输入输出端口信息
    % 使用容器映射来存储端口信息（用于去重）
    inportInfoMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
    outportInfoMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
    
    if isempty(allComponents)
        fprintf('没有组件需要处理\n');
    else
        fprintf('开始遍历所有组件，收集端口信息...\n');
        for compIdx = 1:length(allComponents)
            component = allComponents(compIdx);
            componentName = component.Name;
            
            try
                % 检查组件是否有Simulink句柄
                if isempty(component.SimulinkHandle) || component.SimulinkHandle == -1
                    fprintf('  组件 "%s" 没有Simulink句柄，跳过\n', componentName);
                    continue;
                end
                
                % 获取组件的输入端口信息
                try
                    [~, PortsIn, ~, ~] = findModPorts(component.SimulinkHandle, ...
                                                       'skipTrig', skipTrigger, ...
                                                       'getType', 'Handle');
                    
                    if ~isempty(PortsIn)
                        for i = 1:length(PortsIn)
                            portHandle = PortsIn{i};
                            
                            % 检查是否为 BusElementPort
                            try
                                IsBusElementPort = get_param(portHandle, 'IsBusElementPort');
                                if strcmp(IsBusElementPort, 'off')
                                    % 不是 BusElementPort，跳过（如 Updated 端口）
                                    continue;
                                end
                            catch
                                % 如果无法获取属性，跳过该端口
                                continue;
                            end
                            
                            % 获取端口属性
                            try
                                PortName = get_param(portHandle, 'PortName');
                                OutDataTypeStr = get_param(portHandle, 'OutDataTypeStr');
                                Description = get_param(portHandle, 'Description');
                                
                                % 存储端口信息（如果端口名称不存在或需要更新）
                                if ~isKey(inportInfoMap, PortName)
                                    inportInfoMap(PortName) = struct('Name', PortName, ...
                                                                     'DataType', OutDataTypeStr, ...
                                                                     'Description', Description);
                                end
                            catch
                                % 跳过无法获取信息的端口
                                continue;
                            end
                        end
                    end
                catch ME
                    warning('MATLAB:createArchPort:GetInPortsFailed', ...
                            '获取组件 "%s" 的输入端口失败: %s', componentName, ME.message);
                end
                
                % 获取组件的输出端口信息
                try
                    [~, ~, PortsOut, ~] = findModPorts(component.SimulinkHandle, ...
                                                        'getType', 'Handle');
                    
                    if ~isempty(PortsOut)
                        for i = 1:length(PortsOut)
                            portHandle = PortsOut{i};
                            
                            % 获取端口属性
                            try
                                PortName = get_param(portHandle, 'PortName');
                                OutDataTypeStr = get_param(portHandle, 'OutDataTypeStr');
                                Description = get_param(portHandle, 'Description');
                                
                                % 存储端口信息（如果端口名称不存在或需要更新）
                                if ~isKey(outportInfoMap, PortName)
                                    outportInfoMap(PortName) = struct('Name', PortName, ...
                                                                      'DataType', OutDataTypeStr, ...
                                                                      'Description', Description);
                                end
                            catch
                                % 跳过无法获取信息的端口
                                continue;
                            end
                        end
                    end
                catch ME
                    warning('MATLAB:createArchPort:GetOutPortsFailed', ...
                            '获取组件 "%s" 的输出端口失败: %s', componentName, ME.message);
                end
                
            catch ME
                warning('MATLAB:createArchPort:ProcessComponentFailed', ...
                        '处理组件 "%s" 失败: %s', componentName, ME.message);
            end
        end
        
        fprintf('端口信息收集完成：输入端口 %d 个，输出端口 %d 个（已去重）\n', ...
                inportInfoMap.Count, outportInfoMap.Count);
    end

    %% 创建架构模型输入端口
    inport = [];
    try
        if inportInfoMap.Count > 0
            inportNames = keys(inportInfoMap);
            inportCount = 0;
            for i = 1:length(inportNames)
                portName = inportNames{i};
                portInfo = inportInfoMap(portName);
                
                try
                    % 检查端口是否已存在
                    existingPorts = find(archModel, 'Port', 'Name', portName);
                    if ~isempty(existingPorts)
                        % 端口已存在，跳过或更新
                        fprintf('  输入端口 "%s" 已存在，跳过创建\n', portName);
                        continue;
                    end
                    
                    % 创建架构模型输入端口
                    port = addPort(archModel, 'Receiver', portInfo.Name);
                    set_param(port.SimulinkHandle, 'OutDataTypeStr', portInfo.DataType);
                    set_param(port.SimulinkHandle, 'Description', portInfo.Description);
                    inportCount = inportCount + 1;
                    inport = [inport, port]; %#ok<AGROW>
                catch ME
                    warning('MATLAB:createArchPort:CreateInPortFailed', ...
                            '创建输入端口 "%s" 失败: %s', portName, ME.message);
                end
            end
            fprintf('已创建 %d 个输入端口\n', inportCount);
        else
            fprintf('没有输入端口需要创建\n');
        end
    catch ME
        warning('MATLAB:createArchPort:CreateInPortsFailed', ...
                '创建输入端口失败: %s', ME.message);
    end

    %% 创建架构模型输出端口
    outport = [];
    try
        if outportInfoMap.Count > 0
            outportNames = keys(outportInfoMap);
            outportCount = 0;
            for i = 1:length(outportNames)
                portName = outportNames{i};
                portInfo = outportInfoMap(portName);
                
                try
                    % 检查端口是否已存在
                    existingPorts = find(archModel, 'Port', 'Name', portName);
                    if ~isempty(existingPorts)
                        % 端口已存在，跳过或更新
                        fprintf('  输出端口 "%s" 已存在，跳过创建\n', portName);
                        continue;
                    end
                    
                    % 创建架构模型输出端口
                    port = addPort(archModel, 'Sender', portInfo.Name);
                    set_param(port.SimulinkHandle, 'OutDataTypeStr', portInfo.DataType);
                    set_param(port.SimulinkHandle, 'Description', portInfo.Description);
                    outportCount = outportCount + 1;
                    outport = [outport, port]; %#ok<AGROW>
                catch ME
                    warning('MATLAB:createArchPort:CreateOutPortFailed', ...
                            '创建输出端口 "%s" 失败: %s', portName, ME.message);
                end
            end
            fprintf('已创建 %d 个输出端口\n', outportCount);
        else
            fprintf('没有输出端口需要创建\n');
        end
    catch ME
        warning('MATLAB:createArchPort:CreateOutPortsFailed', ...
                '创建输出端口失败: %s', ME.message);
    end
    
    fprintf('架构模型 "%s" 端口创建完成\n', modelNameForDisplay);
    save(archModel)
end
