function deleteArchPort(ArchModel, varargin)
%DELETEARCHPORT 删除AUTOSAR架构模型输入输出端口
%   DELETEARCHPORT(ARCHMODEL) 删除指定AUTOSAR架构模型中的所有输入输出端口
%
%   必需参数:
%      ArchModel    - 架构模型名称 (字符串) 或已加载的架构模型对象
%                     如果为字符串，将使用 autosar.arch.loadModel 加载模型
%                     如果为对象，将直接使用该对象
%
%   可选参数 (名称-值对):
%      无
%
%   输出参数:
%      无
%
%   功能描述:
%      1. 加载或使用指定的AUTOSAR架构模型
%      2. 查找架构模型中的所有输入端口（Receiver类型）
%      3. 查找架构模型中的所有输出端口（Sender类型）
%      4. 删除所有找到的输入输出端口
%
%   示例:
%      % 基本用法 - 使用字符串
%      deleteArchPort('CcmArch')
%      
%      % 使用已加载的架构模型对象
%      archModel = autosar.arch.loadModel('CcmArch');
%      deleteArchPort(archModel)
%
%   注意事项:
%      1. 如果输入为字符串，使用前需要确保架构模型文件存在
%      2. 如果输入为对象，确保该对象是有效的架构模型对象
%      3. 函数会删除架构模型中的所有输入输出端口，请谨慎使用
%      4. 删除操作会自动保存架构模型
%
%   参见: AUTOSAR.ARCH.LOADMODEL, DELETE
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 20251121

    %% 参数解析和验证
    % 创建输入解析器
    p = inputParser;
    p.FunctionName = mfilename;
    
    % 解析输入参数
    parse(p, varargin{:});

    %% 加载或使用架构模型
    % 判断输入是字符串还是已加载的模型对象
    if ischar(ArchModel) || isstring(ArchModel)
        % 输入是字符串，需要加载模型
        archModelName = char(ArchModel);
        try
            archModel = autosar.arch.loadModel(archModelName);
            fprintf('已加载架构模型: %s\n', archModelName);
        catch ME
            error('MATLAB:deleteArchPort:ModelLoadFailed', ...
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

    %% 查找并删除所有输入输出端口
    inportCount = 0;
    outportCount = 0;
    
    try
        % 直接获取所有端口
        allPorts = archModel.Ports;
        
        if ~isempty(allPorts)
            fprintf('找到 %d 个端口，开始筛选和删除...\n', length(allPorts));
            
            % 一次性获取所有端口的属性（向量化操作）
            try
                allKinds = {allPorts.Kind};  % 获取所有端口的Kind属性
                allHandles = [allPorts.SimulinkHandle];  % 获取所有端口的SimulinkHandle
                allNames = {allPorts.Name};  % 获取所有端口的Name属性
                
                % 使用逻辑索引筛选出需要删除的端口
                % 只处理输入端口（Receiver）和输出端口（Sender），且SimulinkHandle有效
                isValidHandle = allHandles ~= -1 & ~isnan(allHandles);
                isReceiverOrSender = strcmp(allKinds, 'Receiver') | strcmp(allKinds, 'Sender');
                portsToDeleteIdx = isValidHandle & isReceiverOrSender;
                
                % 获取需要删除的端口信息
                handlesToDelete = allHandles(portsToDeleteIdx);
                portNames = allNames(portsToDeleteIdx);
                portKinds = allKinds(portsToDeleteIdx);
                
                % 统计端口类型
                inportCount = sum(strcmp(portKinds, 'Receiver'));
                outportCount = sum(strcmp(portKinds, 'Sender'));
                
            catch ME
                warning('MATLAB:deleteArchPort:GetPortPropertiesFailed', ...
                        '获取端口属性失败，尝试使用循环方式: %s', ME.message);
                % 如果向量化操作失败，回退到循环方式
                handlesToDelete = [];
                portNames = {};
                portKinds = {};
                
                for i = 1:length(allPorts)
                    port = allPorts(i);
                    try
                        portKind = port.Kind;
                        portName = port.Name;
                        portHandle = port.SimulinkHandle;
                        
                        if (strcmp(portKind, 'Receiver') || strcmp(portKind, 'Sender')) && ...
                           ~isempty(portHandle) && portHandle ~= -1
                            handlesToDelete = [handlesToDelete, portHandle]; %#ok<AGROW>
                            portNames{end+1} = portName; %#ok<AGROW>
                            portKinds{end+1} = portKind; %#ok<AGROW>
                        end
                    catch
                        % 跳过无法处理的端口
                    end
                end
                
                inportCount = sum(strcmp(portKinds, 'Receiver'));
                outportCount = sum(strcmp(portKinds, 'Sender'));
            end
            
            % 一次性删除所有端口句柄
            if ~isempty(handlesToDelete)
                fprintf('准备删除 %d 个端口（%d 个输入端口，%d 个输出端口）...\n', ...
                        length(handlesToDelete), inportCount, outportCount);
                
                % 一次性删除所有端口句柄
                try
                    delete(handlesToDelete);
                    fprintf('已成功删除所有端口句柄\n');
                catch ME
                    warning('MATLAB:deleteArchPort:DeleteHandlesFailed', ...
                            '批量删除端口句柄失败: %s', ME.message);
                    % 如果批量删除失败，尝试逐个删除
                    fprintf('尝试逐个删除端口...\n');
                    for i = 1:length(handlesToDelete)
                        try
                            delete(handlesToDelete(i));
                        catch ME2
                            warning('MATLAB:deleteArchPort:DeleteSinglePortFailed', ...
                                    '删除端口 "%s" 失败: %s', portNames{i}, ME2.message);
                        end
                    end
                end
                
                fprintf('已删除 %d 个输入端口，%d 个输出端口\n', inportCount, outportCount);
            else
                fprintf('未找到需要删除的输入输出端口\n');
            end
        else
            fprintf('未找到任何端口\n');
        end
    catch ME
        warning('MATLAB:deleteArchPort:FindPortsFailed', ...
                '查找端口失败: %s', ME.message);
    end
    
    %% 保存架构模型
    try
        save(archModel);
        fprintf('架构模型 "%s" 已保存\n', modelNameForDisplay);
    catch ME
        warning('MATLAB:deleteArchPort:SaveModelFailed', ...
                '保存架构模型失败: %s', ME.message);
    end
    
    fprintf('架构模型 "%s" 端口删除完成（共删除 %d 个输入端口，%d 个输出端口）\n', ...
            modelNameForDisplay, inportCount, outportCount);
end
