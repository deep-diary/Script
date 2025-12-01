function [successPort, failPort] = createArchInterface(ArchModel, interfaceDict, varargin)
%CREATEARCHINTERFACE 为AUTOSAR架构模型的输入输出端口，创建对应的interface接口
%
% 语法:
%   [successPort, failPort] = createArchInterface(ArchModel, interfaceDict)
%
% 输入参数:
%   ArchModel      - AUTOSAR架构模型对象
%   interfaceDict  - Interface字典对象
%
% 输出参数:
%   successPort    - 成功处理的端口名称列表
%   failPort       - 处理失败的端口名称列表
%
% 示例:
%   [success, fail] = createArchInterface(ArchModel, interfaceDict);

% 输入验证
narginchk(2, inf);
validateattributes(ArchModel, {'handle'}, {'scalar'}, mfilename, 'ArchModel');
validateattributes(interfaceDict, {'handle'}, {'scalar'}, mfilename, 'interfaceDict');

% 获取端口列表
ports = ArchModel.Ports;
numPorts = numel(ports);
successPort = cell(0, 1);
failPort = cell(0, 1);

% 遍历所有端口
for iPort = 1:numPorts
    % 显示处理进度
    port = ports(iPort);
    portName = port.Name;
    fprintf('---- (%d / %d) ----处理端口: %s ----\n', iPort, numPorts, portName);
    
    % 如果端口已有interface，跳过
    if ~isempty(port.Interface)
        fprintf('  端口 %s 已存在interface，跳过\n', portName);
%         successPort{end+1} = portName;
%         continue;
    end
    
    % 尝试获取或创建interface
    interface = [];
    try
        % 尝试从字典中获取已存在的interface
        interface = getInterface(interfaceDict, portName);
        fprintf('  已找到对应的interface: %s\n', portName);
        
    catch %#ok<NASGU>
        % 如果不存在，则创建新的interface
        fprintf('  未找到interface: %s，准备创建\n', portName);
        try
            % 获取端口的数据类型
            dataType = get_param(port.SimulinkHandle, 'OutDataTypeStr');
            
            % 创建新的DataInterface
            interface = addDataInterface(interfaceDict, portName);
            
            % 添加数据元素
            dataElm = addElement(interface, portName);
            dataElm.Type = dataType;
            
            fprintf('  成功创建interface: %s (类型: %s)\n', portName, dataType);
            
        catch createME
            % 记录创建失败的错误
            fprintf('  错误: 创建interface %s 失败 - %s\n', portName, createME.message);
            failPort{end+1} = portName;
            continue;
        end
    end
    
    % 为端口设置interface
%     if ~isempty(interface)
        try
            setInterface(port, interface);
            successPort{end+1} = portName;
        catch setME
            fprintf('  错误: 设置interface %s 失败 - %s\n', portName, setME.message);
            failPort{end+1} = portName;
        end
%     end
end

% 保存字典和模型
try
    save(interfaceDict);
    save(ArchModel);
    fprintf('\n成功保存字典和模型\n');
catch saveME
    warning(saveME.identifier, '保存失败: %s', saveME.message);
end

% 输出处理结果摘要
fprintf('\n处理完成: 成功 %d 个，失败 %d 个\n', numel(successPort), numel(failPort));
