function changePortNmBySigNm(model, varargin)
%CHANGPORTNMBYSIGNM 根据与输入输出端口相连接的解析信号名(框1)，更改输入端口(框2)及子模型(框3)的端口名
%   CHANGPORTNMBYSIGNM(MODEL) 根据连接的解析信号名更改指定模型的端口名称
%   CHANGPORTNMBYSIGNM(MODEL, 'Parameter', Value, ...) 使用指定参数配置端口重命名
%
%   输入参数:
%      model - 模型名称或路径 (字符串), 支持 gcs (当前系统)
%
%   可选参数（名值对）:
%      'enableIn'      - 启用输入端口处理 (逻辑值), 默认值: true
%      'enableOut'     - 启用输出端口处理 (逻辑值), 默认值: true
%      'verbose'       - 显示详细信息 (逻辑值), 默认值: true
%
%   功能描述:
%      根据与输入输出端口相连接的解析信号名，更改输入端口及子模型的端口名。
%      实现步骤：
%      0. 遍历模型中的所有输入输出端口
%      1. 找到与输入输出端口相连接的解析信号名，端口句柄，子模型句柄
%      2. 更改输入端口(框2)及子模型(框3)的端口名
%
%   示例:
%      changePortNmBySigNm('MyModel')
%      changePortNmBySigNm(gcs)  % 处理当前系统
%      changePortNmBySigNm('MyModel', 'enableIn', true, 'enableOut', false)
%
%   作者: Blue.ge
%   日期: 20250127
%   版本: 1.0

    %% 输入参数验证
    narginchk(1, inf);
    
    % 处理输入：支持字符串、句柄或 gcs
    if ischar(model) || isstring(model)
        model = char(model);
        % 如果输入是字符串 'gcs'，使用当前系统
        if strcmp(model, 'gcs')
            model = gcs;
        end
    elseif isnumeric(model) || ishandle(model)
        % 如果是句柄，转换为路径
        try
            model = getfullname(model);
        catch
            error('changePortNmBySigNm:invalidInput', '无效的输入参数');
        end
    else
        error('changePortNmBySigNm:invalidInput', '输入参数必须是字符串、路径或句柄');
    end
    
    % 确保输入为字符向量
    model = char(model);
    
    % 验证路径是否存在
    try
        get_param(model, 'Name');
    catch ME
        error('changePortNmBySigNm:invalidPath', '无效的模型路径: "%s" (%s)', model, ME.message);
    end
    
    %% 输入参数处理
    p = inputParser;
    p.FunctionName = mfilename;
    
    addParameter(p, 'enableIn', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'enableOut', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'verbose', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    
    parse(p, varargin{:});
    
    enableIn = p.Results.enableIn;
    enableOut = p.Results.enableOut;
    verbose = p.Results.verbose;
    
    try
        %% 获取端口块
        % 使用 find_system 查找输入输出端口块
        inportPaths = find_system(model, 'SearchDepth', 1, 'BlockType', 'Inport');
        outportPaths = find_system(model, 'SearchDepth', 1, 'BlockType', 'Outport');
        
        % 转换为句柄数组
        inports = [];
        outports = [];
        for i = 1:length(inportPaths)
            inports(i) = get_param(inportPaths{i}, 'Handle');
        end
        for i = 1:length(outportPaths)
            outports(i) = get_param(outportPaths{i}, 'Handle');
        end
        
        if verbose
            fprintf('=== 开始处理模型 "%s" ===\n', model);
            fprintf('输入端口数量: %d\n', length(inports));
            fprintf('输出端口数量: %d\n', length(outports));
            fprintf('\n');
        end
        
        %% 处理输入端口
        if enableIn
            if verbose
                fprintf('=== 处理输入端口 ===\n');
            end
            
            processedCount = 0;
            for i = 1:length(inports)
                try
                    % 获取输入端口块路径
                    inportPath = getfullname(inports(i));
                    if isempty(inportPath)
                        continue;
                    end
                    
                    % 获取输入端口连接的信号线
                    portHandles = get_param(inports(i), 'PortHandles');
                    hLine = get_param(portHandles.Outport, 'Line');
                    if hLine == -1
                        if verbose
                            fprintf('  输入端口 %d: 未连接信号线，跳过\n', i);
                        end
                        continue;
                    end
                    
                    % 获取信号线名称（解析信号名，框1）
                    signalName = get_param(hLine, 'Name');
                    if isempty(signalName)
                        if verbose
                            fprintf('  输入端口 %d: 信号线无名称，跳过\n', i);
                        end
                        continue;
                    end
                    
                    % 获取当前输入端口名称（框2）
                    currentInportName = get_param(inportPath, 'Name');
                    
                    % 获取信号线目标块
                    dstBlockHandle = get_param(hLine, 'DstBlockHandle');
                    if dstBlockHandle == -1
                        if verbose
                            fprintf('  输入端口 %d: 信号线无目标块，跳过\n', i);
                        end
                        continue;
                    end
                    
                    % 直接使用信号线名称作为新端口名
                    newPortName = signalName;
                    
                    % 更改输入端口名称（框2）
                    if ~strcmp(currentInportName, newPortName)
                        set_param(inportPath, 'Name', newPortName);
                        if verbose
                            fprintf('  输入端口 %d: "%s" -> "%s"\n', i, currentInportName, newPortName);
                        end
                    end
                    
                    % 检查目标块是否为子模型（SubSystem）
                    dstBlockType = get_param(dstBlockHandle, 'BlockType');
                    if strcmp(dstBlockType, 'SubSystem')
                        % 获取目标端口号
                        dstPortHandle = get_param(hLine, 'DstPortHandle');
                        if dstPortHandle ~= -1
                            dstPortNumber = get_param(dstPortHandle, 'PortNumber');
                            
                            % 获取子模型路径
                            subSystemPath = getfullname(dstBlockHandle);
                            
                            % 在子模型中查找对应的输入端口（框3）
                            subInports = find_system(subSystemPath, 'SearchDepth', 1, 'BlockType', 'Inport', 'Port', num2str(dstPortNumber));
                            if ~isempty(subInports)
                                subInportName = get_param(subInports{1}, 'Name');
                                if ~strcmp(subInportName, newPortName)
                                    set_param(subInports{1}, 'Name', newPortName);
                                    if verbose
                                        fprintf('    子模型端口: "%s" -> "%s"\n', subInportName, newPortName);
                                    end
                                end
                            end
                        end
                    end
                    
                    processedCount = processedCount + 1;
                    
                catch ME
                    if verbose
                        warning('changePortNmBySigNm:inportError', '处理输入端口 %d 时发生错误: %s', i, ME.message);
                    end
                end
            end
            
            if verbose
                fprintf('输入端口处理完成: %d 个\n\n', processedCount);
            end
        end
        
        %% 处理输出端口
        if enableOut
            if verbose
                fprintf('=== 处理输出端口 ===\n');
            end
            
            processedCount = 0;
            for i = 1:length(outports)
                try
                    % 获取输出端口块路径
                    outportPath = getfullname(outports(i));
                    if isempty(outportPath)
                        continue;
                    end
                    
                    % 获取输出端口连接的信号线
                    portHandles = get_param(outports(i), 'PortHandles');
                    hLine = get_param(portHandles.Inport, 'Line');
                    if hLine == -1
                        if verbose
                            fprintf('  输出端口 %d: 未连接信号线，跳过\n', i);
                        end
                        continue;
                    end
                    
                    % 获取信号线名称（解析信号名，框1）
                    signalName = get_param(hLine, 'Name');
                    if isempty(signalName)
                        if verbose
                            fprintf('  输出端口 %d: 信号线无名称，跳过\n', i);
                        end
                        continue;
                    end
                    
                    % 获取当前输出端口名称（框2）
                    currentOutportName = get_param(outportPath, 'Name');
                    
                    % 获取信号线源块
                    srcBlockHandle = get_param(hLine, 'SrcBlockHandle');
                    if srcBlockHandle == -1
                        if verbose
                            fprintf('  输出端口 %d: 信号线无源块，跳过\n', i);
                        end
                        continue;
                    end
                    
                    % 直接使用信号线名称作为新端口名
                    newPortName = signalName;
                    
                    % 更改输出端口名称（框2）
                    if ~strcmp(currentOutportName, newPortName)
                        set_param(outportPath, 'Name', newPortName);
                        if verbose
                            fprintf('  输出端口 %d: "%s" -> "%s"\n', i, currentOutportName, newPortName);
                        end
                    end
                    
                    % 检查源块是否为子模型（SubSystem）
                    srcBlockType = get_param(srcBlockHandle, 'BlockType');
                    if strcmp(srcBlockType, 'SubSystem')
                        % 获取源端口号
                        srcPortHandle = get_param(hLine, 'SrcPortHandle');
                        if srcPortHandle ~= -1
                            srcPortNumber = get_param(srcPortHandle, 'PortNumber');
                            
                            % 获取子模型路径
                            subSystemPath = getfullname(srcBlockHandle);
                            
                            % 在子模型中查找对应的输出端口（框3）
                            subOutports = find_system(subSystemPath, 'SearchDepth', 1, 'BlockType', 'Outport', 'Port', num2str(srcPortNumber));
                            if ~isempty(subOutports)
                                subOutportName = get_param(subOutports{1}, 'Name');
                                if ~strcmp(subOutportName, newPortName)
                                    set_param(subOutports{1}, 'Name', newPortName);
                                    if verbose
                                        fprintf('    子模型端口: "%s" -> "%s"\n', subOutportName, newPortName);
                                    end
                                end
                            end
                        end
                    end
                    
                    processedCount = processedCount + 1;
                    
                catch ME
                    if verbose
                        warning('changePortNmBySigNm:outportError', '处理输出端口 %d 时发生错误: %s', i, ME.message);
                    end
                end
            end
            
            if verbose
                fprintf('输出端口处理完成: %d 个\n\n', processedCount);
            end
        end
        
        if verbose
            fprintf('=== 模型 "%s" 端口重命名完成 ===\n', model);
        end
        
    catch ME
        error('changePortNmBySigNm:processingError', '处理模型端口时发生错误: %s', ME.message);
    end
end
