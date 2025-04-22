function createSigOnLine(pathMd, varargin)
%CREATESIGONLINE 在模型输入输出端口的信号线上进行信号设置
%   createSigOnLine(pathMd) 对指定模型路径下的输入输出端口信号线进行设置，
%   包括信号名称、解析设置、数据记录和测试点等。
%
%   输入参数:
%       pathMd - 模型路径
%
%   可选参数:
%       'skipTrig' - 是否跳过触发信号，默认为false
%       'isEnableIn' - 是否处理输入端口，默认为true
%       'isEnableOut' - 是否处理输出端口，默认为true
%       'resoveValue' - 是否解析为Simulink信号对象，默认为false
%       'logValue' - 是否记录数据，默认为false
%       'testValue' - 是否设置为测试点，默认为false
%
%   示例:
%       createSigOnLine(gcs)
%       createSigOnLine(gcs, 'skipTrig', true, 'isEnableIn', true, 'isEnableOut', true, ...
%                      'resoveValue', false, 'logValue', false, 'testValue', false)
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2023-09-05
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        
        % 添加参数及其验证
        addParameter(p, 'skipTrig', false, @islogical);
        addParameter(p, 'isEnableIn', true, @islogical);
        addParameter(p, 'isEnableOut', true, @islogical);
        addParameter(p, 'resoveValue', true, @islogical);
        addParameter(p, 'logValue', false, @islogical);
        addParameter(p, 'testValue', false, @islogical);
        
        parse(p, varargin{:});
        
        % 获取参数值
        skipTrig = p.Results.skipTrig;
        isEnableIn = p.Results.isEnableIn;
        isEnableOut = p.Results.isEnableOut;
        resoveValue = p.Results.resoveValue;
        logValue = p.Results.logValue;
        testValue = p.Results.testValue;
        
        %% 验证模型路径
        [modelName, validPath] = findValidPath(pathMd);
        if isempty(validPath)
            error('无效的模型路径: %s', pathMd);
        end
        
        fprintf('开始处理模型 %s 的信号线设置\n', modelName);
        
        %% 处理输入端口信号线
        if isEnableIn
            try
                % 获取输入端口
                inportCell = find_system(validPath, 'SearchDepth', 1, 'BlockType', 'Inport');
                if isempty(inportCell)
                    fprintf('警告: 未找到输入端口\n');
                else
                    % 确定起始索引
                    startIdx = 1;
                    if skipTrig
                        startIdx = 2;
                        fprintf('跳过第一个触发信号\n');
                    end
                    
                    % 处理每个输入端口
                    for i = startIdx:length(inportCell)
                        try
                            % 获取端口信息
                            portName = get_param(inportCell{i}, 'Name');
                            portHandle = get_param(inportCell{i}, 'Handle');
                            
                            % 获取并设置信号线属性
                            lineHandles = get(portHandle, 'LineHandles');
                            if ~isempty(lineHandles.Outport)
                                set(lineHandles.Outport, ...
                                    'Name', portName, ...
                                    'MustResolveToSignalObject', resoveValue, ...
                                    'DataLogging', logValue, ...
                                    'TestPoint', testValue);
                                fprintf('已设置输入端口 %s 的信号线\n', portName);
                            end
                        catch ME
                            fprintf('警告: 处理输入端口 %s 时发生错误: %s\n', ...
                                get_param(inportCell{i}, 'Name'), ME.message);
                        end
                    end
                end
            catch ME
                error('处理输入端口时发生错误: %s', ME.message);
            end
        end
        
        %% 处理输出端口信号线
        if isEnableOut
            try
                % 获取输出端口
                outportCell = find_system(validPath, 'SearchDepth', 1, 'BlockType', 'Outport');
                if isempty(outportCell)
                    fprintf('警告: 未找到输出端口\n');
                else
                    % 处理每个输出端口
                    for i = 1:length(outportCell)
                        try
                            % 获取端口信息
                            portName = get_param(outportCell{i}, 'Name');
                            portHandle = get_param(outportCell{i}, 'Handle');
                            
                            % 获取并设置信号线属性
                            lineHandles = get(portHandle, 'LineHandles');
                            if ~isempty(lineHandles.Inport)
                                set(lineHandles.Inport, ...
                                    'Name', portName, ...
                                    'MustResolveToSignalObject', resoveValue, ...
                                    'DataLogging', logValue, ...
                                    'TestPoint', testValue);
                                fprintf('已设置输出端口 %s 的信号线\n', portName);
                            end
                        catch ME
                            fprintf('警告: 处理输出端口 %s 时发生错误: %s\n', ...
                                get_param(outportCell{i}, 'Name'), ME.message);
                        end
                    end
                end
            catch ME
                error('处理输出端口时发生错误: %s', ME.message);
            end
        end
        
        fprintf('信号线设置完成\n');
        
    catch ME
        error('信号线设置过程中发生错误: %s', ME.message);
    end
end