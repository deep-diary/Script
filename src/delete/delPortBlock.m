function delPortBlock(path, varargin)
%DELPORTBLOCK 删除指定路径下的输入输出端口块
%   DELPORTBLOCK(PATH) 删除指定路径下的所有输入输出端口块
%   DELPORTBLOCK(PATH, 'Parameter', Value, ...) 使用指定参数删除端口块
%
%   输入参数:
%      path        - 模型或子系统路径 (字符向量或字符串标量)
%
%   可选参数（名值对）:
%      'isEnableIn'  - 是否删除输入端口，可选值: true, false (默认值: true)
%      'isEnableOut' - 是否删除输出端口，可选值: true, false (默认值: true)
%      'verbose'     - 是否显示详细信息，可选值: true, false (默认值: true)
%
%   功能描述:
%      删除指定路径下的输入输出端口块及其连接线。支持选择性删除输入或输出端口。
%      会同时删除端口块、连接线和相关的模块。
%
%   示例:
%      delPortBlock(gcs);  % 删除当前系统的所有端口
%      delPortBlock('MyModel/SubSystem', 'isEnableIn', false);  % 只删除输出端口
%      delPortBlock('MyModel/SubSystem', 'verbose', false);  % 静默删除
%
%   作者: Blue.ge
%   日期: 2025-01-27
%   版本: 2.0

    %% 输入参数验证
    narginchk(1, inf);
    validateattributes(path, {'char', 'string'}, {'scalartext'}, mfilename, 'path', 1);
    
    % 确保输入为字符向量
    path = char(path);

    %% 参数解析
    p = inputParser;
    p.FunctionName = mfilename;
    
    addRequired(p, 'path', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'isEnableIn', true, @islogical);
    addParameter(p, 'isEnableOut', true, @islogical);
    addParameter(p, 'verbose', true, @islogical);
    
    parse(p, path, varargin{:});

    isEnableIn = p.Results.isEnableIn;
    isEnableOut = p.Results.isEnableOut;
    verbose = p.Results.verbose;
    %% 验证路径是否存在
    try
        get_param(path, 'Name');
    catch ME
        error('delPortBlock:invalidPath', '无效的路径 "%s": %s', path, ME.message);
    end

    %% 找到当前层的输入输出端口路径
    try
        [~, PortsIn, PortsOut] = findModPorts(path);
        
        if verbose
            fprintf('在路径 "%s" 中找到 %d 个输入端口, %d 个输出端口\n', path, length(PortsIn), length(PortsOut));
        end
        
    catch ME
        error('delPortBlock:portSearchError', '查找端口失败: %s', ME.message);
    end

    %% 根据参数确定要删除的端口路径
    portPath = {};
    portTypes = {}; % 记录端口类型，用于显示信息
    
    if isEnableIn && isEnableOut
        portPath = [PortsIn, PortsOut];
        portTypes = [repmat({'Inport'}, 1, length(PortsIn)), repmat({'Outport'}, 1, length(PortsOut))];
    elseif isEnableIn
        portPath = PortsIn;
        portTypes = repmat({'Inport'}, 1, length(PortsIn));
    elseif isEnableOut
        portPath = PortsOut;
        portTypes = repmat({'Outport'}, 1, length(PortsOut));
    else
        if verbose
            warning('delPortBlock:noPortsToDelete', '没有选择要删除的端口类型');
        end
        return;
    end

    if isempty(portPath)
        if verbose
            fprintf('没有找到要删除的端口\n');
        end
        return;
    end

    %% 删除端口块及其连接
    deletedCount = 0;
    errorCount = 0;
    
    if verbose
        fprintf('开始删除 %d 个端口...\n', length(portPath));
    end
    
    for i = 1:length(portPath)
        try
            % 获取端口、连线和模块句柄
            [hPort, hLine, hBlock] = findPortLineBlock(portPath{i});
            
            % 删除连接线（如果存在）
            if hLine ~= -1
                Name = get_param(hLine, 'Name');
                delete_line(hLine);
                if verbose
                    fprintf('  删除连接线: %s\n', Name);
                end
            end
            
            % 删除端口块
            if hPort ~= -1
                Name = get_param(hPort, 'Name');
                delete_block(hPort);
                if verbose
                    fprintf('  删除端口块: %s (%s)\n', Name, portTypes{i});
                end
            end
            
            % 删除连接的模块（如果存在且不是端口块本身）
            if hBlock ~= -1 && hBlock ~= hPort
                Name = get_param(hBlock, 'Name');
                delete_block(hBlock);
                if verbose
                    fprintf('  删除连接模块: %s\n', Name);
                end
            end
            
            deletedCount = deletedCount + 1;
            
        catch ME
            errorCount = errorCount + 1;
            if verbose
                warning('delPortBlock:deleteError', '删除端口 %s 时出错: %s', portPath{i}, ME.message);
            end
        end
    end

    %% 显示删除结果
    if verbose
        fprintf('\n删除操作完成:\n');
        fprintf('  成功删除: %d 个端口\n', deletedCount);
        if errorCount > 0
            fprintf('  删除失败: %d 个端口\n', errorCount);
        end
    end

end