function [inports, outports] = findAutosarMappingPorts(modelName, varargin)
%FINDAUTOSARMAPPINGPORTS 查找AUTOSAR映射端口信息
%
%   [INPORTS, OUTPORTS] = FINDAUTOSARMAPPINGPORTS(MODELNAME) 查找指定Simulink模型
%   中所有输入和输出端口的AUTOSAR映射信息。
%
%   输入参数:
%       MODELNAME - 字符向量或字符串标量，指定Simulink模型名称
%
%   输出参数:
%       INPORTS   - 结构体数组，包含所有输入端口的AUTOSAR映射信息
%       OUTPORTS  - 结构体数组，包含所有输出端口的AUTOSAR映射信息
%
%   每个端口结构体包含以下字段:
%       Source         - 字符向量，AUTOSAR源信息（等同于端口名称）
%       DataAccessMode - 字符向量，数据访问模式
%       Port           - 字符向量，AUTOSAR端口信息
%       Element        - 字符向量，AUTOSAR元素信息
%       PortType       - 字符向量，端口类型（'Inport' 或 'Outport'）
%       PortHandle     - 双精度标量，Simulink端口句柄
%
%   示例:
%       % 查找模型中的所有AUTOSAR映射端口
%       [inports, outports] = findAutosarMappingPorts('myModel');
%
%       % 显示输入端口信息
%       for i = 1:length(inports)
%           fprintf('输入端口 %d: %s (%s)\n', i, inports(i).Source, inports(i).PortType);
%           fprintf('  Source: %s\n', inports(i).Source);
%           fprintf('  DataAccessMode: %s\n', inports(i).DataAccessMode);
%           fprintf('  Port: %s\n', inports(i).Port);
%           fprintf('  Element: %s\n', inports(i).Element);
%       end
%
%       % 查找特定端口的映射信息
%       targetPort = 'In1';
%       for i = 1:length(inports)
%           if strcmp(inports(i).Source, targetPort)
%               fprintf('找到端口 %s 的映射信息\n', targetPort);
%               break;
%           end
%       end
%
%   注意:
%       - 模型必须已配置AUTOSAR映射
%       - 如果模型未加载，函数会自动加载模型
%       - 未映射的端口将返回空字符串
%
%   另请参阅:
%       AUTOSAR.API.GETSIMULINKMAPPING, AUTOSAR.API.SETSIMULINKMAPPING
%
%   作者: 自动生成
%   日期: 2024

    % 输入参数验证
    if nargin < 1
        error('需要提供模型名称');
    end
    
    % 检查模型是否存在
    if ~bdIsLoaded(modelName)
        try
            load_system(modelName);
        catch ME
            error('无法加载模型 %s: %s', modelName, ME.message);
        end
    end

    % 获取模型句柄
    modelHandle = get_param(modelName, 'Handle');

    % 获取AUTOSAR映射
    try
        slMap = autosar.api.getSimulinkMapping(modelHandle);
    catch ME
        error('无法获取AUTOSAR映射: %s', ME.message);
    end

    % 初始化输出结构体
    inports = [];
    outports = [];
    
    % 获取所有端口
    allPorts = find_system(modelName, 'SearchDepth', 1, ...
                          'BlockType', 'Inport');
    allOutPorts = find_system(modelName, 'SearchDepth', 1, ...
                             'BlockType', 'Outport');
    
    % 处理输入端口
    for i = 1:length(allPorts)
        try
            portName = get_param(allPorts{i}, 'Name');
            portHandle = get_param(allPorts{i}, 'Handle');

            % 检查trigger 属性，如果为true，则跳过
            if strcmp(get_param(allPorts{i}, 'OutputFunctionCall'), 'on')
                continue;
            end
            
            % 检查端口名称是否有效
            if isempty(portName) || ~ischar(portName) && ~isstring(portName)
                portName = sprintf('Inport_%d', i);
            end
            
            % 获取AUTOSAR映射信息
            [source, dataAccessMode, port, element] = getPortMappingInfo(slMap, portName, 'Inport');
            
            % 创建结构体
            portInfo = struct('Source', source, ...
                             'DataAccessMode', dataAccessMode, ...
                             'Port', port, ...
                             'Element', element, ...
                             'PortType', 'Inport', ...
                             'PortHandle', portHandle);
            
            inports = [inports; portInfo];
        catch ME
            warning(ME.identifier, '无法获取输入端口 %d 的映射信息: %s', i, ME.message);
        end
    end
    
    % 处理输出端口
    for i = 1:length(allOutPorts)
        try
            portName = get_param(allOutPorts{i}, 'Name');
            portHandle = get_param(allOutPorts{i}, 'Handle');

            % 检查trigger 属性，如果为true，则跳过
            if strcmp(get_param(allOutPorts{i}, 'OutputFunctionCall'), 'on')
                continue;
            end
            
            % 检查端口名称是否有效
            if isempty(portName) || ~ischar(portName) && ~isstring(portName)
                portName = sprintf('Outport_%d', i);
            end
            
            % 获取AUTOSAR映射信息
            [source, dataAccessMode, port, element] = getPortMappingInfo(slMap, portName, 'Outport');
            
            % 创建结构体
            portInfo = struct('Source', source, ...
                             'DataAccessMode', dataAccessMode, ...
                             'Port', port, ...
                             'Element', element, ...
                             'PortType', 'Outport', ...
                             'PortHandle', portHandle);
            
            outports = [outports; portInfo];
        catch ME
            warning(ME.identifier, '无法获取输出端口 %d 的映射信息: %s', i, ME.message);
        end
    end
    
    % 如果没有找到端口，返回空结构体
    if isempty(inports)
        inports = struct('Source', {}, 'DataAccessMode', {}, 'Port', {}, ...
                        'Element', {}, 'PortType', {}, 'PortHandle', {});
    end
    
    if isempty(outports)
        outports = struct('Source', {}, 'DataAccessMode', {}, 'Port', {}, ...
                         'Element', {}, 'PortType', {}, 'PortHandle', {});
    end
end

function [source, dataAccessMode, port, element] = getPortMappingInfo(slMap, portName, portType)
%GETPORTMAPPINGINFO 获取端口AUTOSAR映射信息的辅助函数
%
%   [SOURCE, DATAACCESSMODE, PORT, ELEMENT] = GETPORTMAPPINGINFO(SLMAP, PORTNAME, PORTTYPE)
%   从AUTOSAR映射对象中获取指定端口的映射信息。
%
%   输入参数:
%       SLMAP    - AUTOSAR映射对象，通过autosar.api.getSimulinkMapping获取
%       PORTNAME - 字符向量，Simulink端口名称
%       PORTTYPE - 字符向量，端口类型，'Inport' 或 'Outport'
%
%   输出参数:
%       SOURCE         - 字符向量，AUTOSAR源信息
%       DATAACCESSMODE - 字符向量，数据访问模式
%       PORT           - 字符向量，AUTOSAR端口信息
%       ELEMENT        - 字符向量，AUTOSAR元素信息
%
%   注意:
%       - 如果端口未映射或获取失败，返回空字符串
%       - 此函数为内部辅助函数，通常不需要直接调用
%
%   另请参阅:
%       FINDAUTOSARMAPPINGPORTS

    % 初始化返回值
    source = '';
    dataAccessMode = '';
    port = '';
    element = '';
    
    try
        % 验证端口名称是否有效
        if isempty(portName) || (~ischar(portName) && ~isstring(portName))
            return;
        end
        
        % 确保端口名称为字符向量
        portName = char(portName);
        
        if strcmp(portType, 'Inport')
            % 获取输入端口映射
            try
                [arPort, arDataElement, arDataAccessMode] = slMap.getInport(portName);
                if ~isempty(arPort) && ischar(arPort)
                    port = arPort;
                    element = arDataElement;
                    dataAccessMode = arDataAccessMode;
                    % Source属性等同于PortName
                    source = portName;
                end
            catch
                % 如果getInport失败，端口可能未映射
                port = '';
                element = '';
                dataAccessMode = '';
            end
        else
            % 获取输出端口映射
            try
                [arPort, arDataElement, arDataAccessMode] = slMap.getOutport(portName);
                if ~isempty(arPort) && ischar(arPort)
                    port = arPort;
                    element = arDataElement;
                    dataAccessMode = arDataAccessMode;
                    % Source属性等同于PortName
                    source = portName;
                end
            catch
                % 如果getOutport失败，端口可能未映射
                port = '';
                element = '';
                dataAccessMode = '';
            end
        end
    catch %#ok<CTCH>
        % 如果获取映射信息失败，返回空字符串
        % 不显示警告，因为很多端口可能未映射
        return;
    end
end

