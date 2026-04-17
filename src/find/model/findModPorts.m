function [ModelName, PortsIn, PortsOut, PortsSpecial] = findModPorts(pathMd, varargin)
%FINDMODPORTS 查找模型中的输入输出端口
%   [MODELNAME, PORTSIN, PORTSOUT, PORTSSPECIAL] = FINDMODPORTS(PATHMD) 使用默认参数查找端口
%   [MODELNAME, PORTSIN, PORTSOUT, PORTSSPECIAL] = FINDMODPORTS(PATHMD, 'Parameter', Value, ...) 使用指定参数查找
%
%   输入参数:
%      pathMd       - 模型路径或句柄 (字符串或数值)
%
%   可选参数（名值对）:
%      'getType'    - 返回端口的属性类型 (字符串), 默认值: 'Path'
%                     可选值: 'path'(完整路径), 'Name'(端口名称), 'Handle'(句柄)等
%      'FiltUnconnected' - 是否只返回未连接的端口 (逻辑值), 默认值: false
%      'Verbose'    - 是否在命令行打印端口摘要 (逻辑值), 默认值: false
%
%   输出参数:
%      ModelName    - 模型名称 (字符串)
%      PortsIn      - 输入端口列表 (元胞数组)
%      PortsOut     - 输出端口列表 (元胞数组)
%                     格式同PortsIn
%      PortsSpecial - 特殊端口信息 (变量)
%
%   功能描述:
%      查找指定模型中的输入输出端口，可以选择返回端口的不同属性。
%      支持过滤未连接的端口和跳过触发端口；对于库链接子系统，优先回退到
%      ReferenceBlock 读取端口，确保传入库路径/链接块时仍可获取端口信息。   
%
%   示例:
%      [name, inPorts, outPorts] = findModPorts(gcb, 'getType', 'Path');
%      [name, inPorts, outPorts] = findModPorts(gcb, 'getType', 'Name');
%      [name, inPorts, outPorts] = findModPorts(gcb, 'getType', 'OutDataTypeStr');
%      [name, inPorts, outPorts] = findModPorts(gcs, 'FiltUnconnected', true);
%      findModPorts(gcb, 'getType', 'Name', 'Verbose', true);
%
%   参见: FIND_SYSTEM, GET_PARAM, BDROOT
%
%   作者: blue.ge(葛维冬@Smart)
%   版本: 1.3
%   日期: 2026-04-17
%   变更记录:
%      2026-04-17 v1.3 新增 Verbose（默认关闭）；优化命令行摘要格式。
%      2026-04-10 v1.2 增加库链接子系统端口回退（ReferenceBlock + PortHandles）。

    %% 输入参数处理
    p = inputParser;
    addRequired(p, 'pathMd', @(x)validateattributes(x,{'char','string','double'},{'nonempty'}));
    addParameter(p, 'getType', 'Path', @ischar);
    addParameter(p, 'skipTrig', false, @islogical);
    addParameter(p, 'FiltUnconnected', false, @islogical);
    addParameter(p, 'Verbose', false, @islogical);
    
    parse(p, pathMd, varargin{:});
    
    pathMd = p.Results.pathMd;
    getType = p.Results.getType;
    FiltUnconnected = p.Results.FiltUnconnected;
    skipTrig = p.Results.skipTrig;
    verbose = p.Results.Verbose;
    

    %% 找到所有端口
    [ModelName, validPath] = findValidPath(pathMd);
    PortsInAll = find_system(validPath, 'SearchDepth', 1, 'BlockType', 'Inport');
    PortsOutAll = find_system(validPath, 'SearchDepth', 1, 'BlockType', 'Outport');

    % 对库链接子系统做回退：从引用源块读取端口
    if isempty(PortsInAll) && isempty(PortsOutAll)
        [PortsInAll, PortsOutAll] = i_getPortsFromReferenceBlock(validPath);
    end

    % 兜底：若仍为空，则直接使用当前块端口句柄构造端口标识
    if isempty(PortsInAll) && isempty(PortsOutAll)
        [PortsInAll, PortsOutAll] = i_getPortsFromPortHandles(validPath);
    end

    %% 获取特殊端口
    PortsSpecial = -1;
    try
        if ~strcmp(validPath, bdroot(validPath))  % 如果不是root, 则尝试获取特殊端口
            portCn = get_param(validPath, 'PortConnectivity');
            ports = get_param(validPath, 'Ports');
            if sum(ports(3:end))  % 存在特殊端口
                PortsSpecialT = portCn(length(PortsInAll) + 1);  % 比输入端口数量 + 1
                PortsSpecial = PortsSpecialT.SrcBlock;
            end
        end
    catch
        % 如果获取特殊端口失败，保持默认值
        PortsSpecial = -1;
    end

    %% 过滤端口
    PortsIn = {};
    PortsOut = {};

    if FiltUnconnected
        % 只保留未连接的端口
        for i = 1:length(PortsInAll)
            if i_isUnconnectedPort(PortsInAll{i}, 'Inport')
                PortsIn{end+1} = PortsInAll{i}; %#ok<AGROW>
            end
        end
        for i = 1:length(PortsOutAll)
            if i_isUnconnectedPort(PortsOutAll{i}, 'Outport')
                PortsOut{end+1} = PortsOutAll{i}; %#ok<AGROW>
            end
        end
    else
        % 保留所有端口
        PortsIn = PortsInAll;
        PortsOut = PortsOutAll;
    end
    
    % 忽略function call触发端口
    if skipTrig && ~isempty(PortsIn)
        PortsInTemp = {};
        for i = 1:length(PortsIn)
            try
                if strcmp(get_param(PortsIn{i}, 'OutputFunctionCall'), 'off')
                    PortsInTemp{end+1} = PortsIn{i}; %#ok<AGROW>
                end
            catch
                % 端口句柄兜底路径不存在 OutputFunctionCall 属性，保留该端口
                PortsInTemp{end+1} = PortsIn{i}; %#ok<AGROW>
            end
        end
        PortsIn = PortsInTemp;
    end

    % 如果不是返回路径，则获取指定的属性
    if ~strcmp(getType, 'Path')
        PortsInTemp = {};
        PortsOutTemp = {};
        
        for i = 1:length(PortsIn)
            PortsInTemp{i} = i_getPortAttr(PortsIn{i}, getType, validPath, 'Inport');
        end
        
        for i = 1:length(PortsOut)
            PortsOutTemp{i} = i_getPortAttr(PortsOut{i}, getType, validPath, 'Outport');
        end
        
        PortsIn = PortsInTemp;
        PortsOut = PortsOutTemp;
    end

    if verbose
        i_printPortsSummary(ModelName, validPath, getType, PortsIn, PortsOut);
    end
    
end

function i_printPortsSummary(modelName, validPath, getType, portsIn, portsOut)
sep = repmat('-', 1, 52);
fprintf('\n%s\n', sep);
fprintf('findModPorts | 模型: %s\n', modelName);
fprintf('  路径: %s\n', validPath);
fprintf('  getType: %s | 输入 %d 个 | 输出 %d 个\n', getType, numel(portsIn), numel(portsOut));
fprintf('%s\n', sep);
fprintf('  [Inport]\n');
if isempty(portsIn)
    fprintf('    (无)\n');
else
    for i = 1:numel(portsIn)
        fprintf('    %3d  %s\n', i, i_portItemToDisplayStr(portsIn{i}));
    end
end
fprintf('  [Outport]\n');
if isempty(portsOut)
    fprintf('    (无)\n');
else
    for i = 1:numel(portsOut)
        fprintf('    %3d  %s\n', i, i_portItemToDisplayStr(portsOut{i}));
    end
end
fprintf('%s\n\n', sep);
end

function s = i_portItemToDisplayStr(item)
if isempty(item)
    s = '(empty)';
elseif isnumeric(item) && isscalar(item)
    s = num2str(item, '%.15g');
elseif ischar(item)
    s = item;
else
    s = char(strtrim(string(item)));
end
end

function [portsIn, portsOut] = i_getPortsFromReferenceBlock(validPath)
portsIn = {};
portsOut = {};
try
    refBlock = get_param(validPath, 'ReferenceBlock');
    if isempty(refBlock)
        return;
    end
    if exist('getSimulinkBlockHandle', 'file')
        hRef = getSimulinkBlockHandle(refBlock);
        if hRef <= 0
            return;
        end
    end
    portsIn = find_system(refBlock, 'SearchDepth', 1, 'BlockType', 'Inport');
    portsOut = find_system(refBlock, 'SearchDepth', 1, 'BlockType', 'Outport');
catch
end
end

function [portsIn, portsOut] = i_getPortsFromPortHandles(validPath)
portsIn = {};
portsOut = {};
try
    ph = get_param(validPath, 'PortHandles');
    if isfield(ph, 'Inport') && ~isempty(ph.Inport)
        portsIn = num2cell(ph.Inport(:)');
    end
    if isfield(ph, 'Outport') && ~isempty(ph.Outport)
        portsOut = num2cell(ph.Outport(:)');
    end
catch
end
end

function tf = i_isUnconnectedPort(portObj, directionType)
% 同时兼容 Inport/Outport 块路径与端口句柄
try
    lh = get_param(portObj, 'LineHandles');
    if strcmp(directionType, 'Inport')
        tf = (lh.Outport == -1);
    else
        tf = (lh.Inport == -1);
    end
    return;
catch
end
try
    lineH = get_param(portObj, 'Line');
    tf = (lineH == -1);
    return;
catch
end
tf = false;
end

function out = i_getPortAttr(portObj, getType, validPath, directionType)
% 兼容块路径与端口句柄的属性读取
try
    out = get_param(portObj, getType);
    return;
catch
end
if isnumeric(portObj)
    switch lower(getType)
        case 'path'
            try
                pn = get_param(portObj, 'PortNumber');
            catch
                pn = NaN;
            end
            out = sprintf('%s:%s(%d)', validPath, directionType, pn);
        case 'name'
            try
                out = get_param(portObj, 'Name');
            catch
                out = sprintf('%s%d', directionType, get_param(portObj, 'PortNumber'));
            end
        case 'handle'
            out = portObj;
        otherwise
            try
                out = get_param(portObj, getType);
            catch
                out = '';
            end
    end
else
    out = '';
end
end
