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
%      支持过滤未连接的端口和跳过触发端口。
%
%   示例:
%      [name, inPorts, outPorts] = findModPorts(gcb, 'getType', 'Path');
%      [name, inPorts, outPorts] = findModPorts(gcb, 'getType', 'Name');
%      [name, inPorts, outPorts] = findModPorts(gcb, 'getType', 'OutDataTypeStr');
%      [name, inPorts, outPorts] = findModPorts(gcs, 'FiltUnconnected', true);
%
%   参见: FIND_SYSTEM, GET_PARAM, BDROOT
%
%   作者: Blue.ge
%   版本: 1.1
%   日期: 20250312

    %% 输入参数处理
    p = inputParser;
    addRequired(p, 'pathMd', @(x)validateattributes(x,{'char','string','double'},{'nonempty'}));
    addParameter(p, 'getType', 'Path', @ischar);
    addParameter(p, 'skipTrig', false, @islogical);
    addParameter(p, 'FiltUnconnected', false, @islogical);
    
    parse(p, pathMd, varargin{:});
    
    pathMd = p.Results.pathMd;
    getType = p.Results.getType;
    FiltUnconnected = p.Results.FiltUnconnected;
    

    %% 找到所有端口
    [ModelName, validPath] = findValidPath(pathMd);
    PortsInAll = find_system(validPath, 'SearchDepth', 1, 'BlockType', 'Inport');
    PortsOutAll = find_system(validPath, 'SearchDepth', 1, 'BlockType', 'Outport');

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
            LineHandles = get_param(PortsInAll{i}, 'LineHandles');
            if LineHandles.Outport == -1
                PortsIn{end+1} = PortsInAll{i};
            end
        end
        for i = 1:length(PortsOutAll)
            LineHandles = get_param(PortsOutAll{i}, 'LineHandles');
            if LineHandles.Inport == -1
                PortsOut{end+1} = PortsOutAll{i};
            end
        end
    else
        % 保留所有端口
        PortsIn = PortsInAll;
        PortsOut = PortsOutAll;
    end
    
    % 忽略function call触发端口
%     if ~isempty(PortsIn) && (skipTrig || ...
%        (length(PortsIn) >= 1 && strcmp(get_param(PortsIn{1}, 'OutputFunctionCall'), 'on')))
%         PortsIn = PortsIn(2:end);
%     end

    % 如果不是返回路径，则获取指定的属性
    if ~strcmp(getType, 'Path')
        PortsInTemp = {};
        PortsOutTemp = {};
        
        for i = 1:length(PortsIn)
            PortsInTemp{i} = get_param(PortsIn{i}, getType);
        end
        
        for i = 1:length(PortsOut)
            PortsOutTemp{i} = get_param(PortsOut{i}, getType);
        end
        
        PortsIn = PortsInTemp;
        PortsOut = PortsOutTemp;
    end

    % 显示提示信息
    fprintf('----------------------------------------:\n');
    fprintf('输入端口:\n');
    for i = 1:length(PortsIn)
        fprintf('    %s\n', PortsIn{i});
    end
    fprintf('-----------------------------:\n');
    fprintf('输出端口:\n');
    for i = 1:length(PortsOut)
        fprintf('    %s\n', PortsOut{i});
    end
    fprintf('----------------------------------------:\n');
    
    
end
