function modelPath = createModExportFun(modelName, varargin)
%CREATEMODEXPORTFUN 创建或加载导出函数模型
%   CREATEMODEXPORTFUN(MODELNAME) 创建或加载导出函数模型
%   CREATEMODEXPORTFUN(MODELNAME, 'Periodic', VALUE, 'TargetFolder', VALUE, 'ModelType', VALUE) 使用指定参数创建或加载导出函数模型
%
%   必需参数:
%      modelName    - 模型名称 (字符串)
%                     如果模型文件不存在，将创建新模型；如果存在，将加载现有模型
%
%   可选参数 (名称-值对):
%      'Periodic'     - 采样周期 (数值, 默认: 0.02)
%                       用于设置模型的固定步长和函数调用端口的采样时间
%      'TargetFolder' - 目标文件夹 (字符串, 默认: '')
%                       如果指定，模型将保存到该文件夹下，例如 'ModelErt' 会保存到 ./ModelErt/
%                       如果文件夹不存在，将自动创建
%      'ModelType'    - 模型类型 (字符串, 默认: 'ert')
%                       可选值: 'autosar' 或 'ert'
%                       根据不同的类型配置不同的TLC文件
%
%   输出参数:
%      modelPath    - 模型文件的完整路径 (字符串)
%                     如果指定了TargetFolder，返回目标文件夹中的路径
%                     否则返回当前目录或MATLAB路径中的模型路径
%
%   功能描述:
%      1. 检查模型是否存在，不存在则创建新模型，存在则加载
%      2. 配置模型为Export-Function模式
%      3. 根据ModelType设置对应的TLC文件（autosar.tlc 或 ert.tlc）
%      4. 设置固定步长求解器和采样周期
%      5. 创建函数调用输入端口（ModelName_Runnable）
%      6. 创建可执行子系统（ModelName_Runnable_sys）
%      7. 在子系统中创建函数调用触发端口
%      8. 创建常量模块避免空模型
%      9. 连接输入端口到子系统的触发端口
%      10. 保存模型到指定文件夹（如果指定了TargetFolder）
%
%   示例:
%      % 基本用法
%      modelPath = createModExportFun('MyModel')
%      
%      % 指定采样周期
%      modelPath = createModExportFun('MyModel', 'Periodic', 0.01)
%      
%      % 指定目标文件夹
%      modelPath = createModExportFun('MyModel', 'TargetFolder', 'ModelErt')
%      
%      % 指定模型类型为AUTOSAR
%      modelPath = createModExportFun('MyModel', 'ModelType', 'autosar')
%      
%      % 组合使用
%      modelPath = createModExportFun('MyModel', 'Periodic', 0.01, 'TargetFolder', 'ModelErt', 'ModelType', 'ert')
%
%   注意事项:
%      1. 模型名称必须是有效的MATLAB标识符
%      2. 如果模型文件已存在，函数会加载现有模型
%      3. 如果模型文件不存在，函数会创建新模型
%      4. 函数调用端口需要设置为函数调用类型
%      5. 采样周期必须为正数
%      6. 如果指定了TargetFolder，函数会自动创建文件夹（如果不存在）
%      7. 函数默认会自动保存模型
%
%   参见: NEW_SYSTEM, LOAD_SYSTEM, ADD_BLOCK, SET_PARAM, GET_PARAM,
%         ADD_LINE, FIND_SYSTEM, SWITCHTARGET
%
%   作者: Blue.ge
%   版本: 4.0
%   日期: 20251120

    %% 参数解析和验证
    % 验证必需参数
    if nargin < 1
        error('MATLAB:createModExportFun:NotEnoughInputs', ...
              '至少需要一个输入参数：modelName');
    end
    
    % 验证modelName是否为有效字符串
    validateattributes(modelName, {'char', 'string'}, {'nonempty', 'scalartext'}, ...
                      mfilename, 'modelName', 1);
    modelName = char(modelName);
    
    % 创建输入解析器
    p = inputParser;
    p.FunctionName = mfilename;
    
    % 添加可选参数
    addParameter(p, 'Periodic', 0.02, ...
                 @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive', 'finite'}));
    addParameter(p, 'TargetFolder', '', ...
                 @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'ModelType', 'autosar', ...
                 @(x) (ischar(x) || (isstring(x) && isscalar(x))) && ...
                      (strcmpi(char(x), 'autosar') || strcmpi(char(x), 'ert')));
    
    % 解析输入参数
    parse(p, varargin{:});
    
    % 提取参数值
    periodic = p.Results.Periodic;
    targetFolder = char(p.Results.TargetFolder);
    modelType = lower(char(p.Results.ModelType));

    %% 步骤1: 创建或加载模型
    try
        % 检查模型文件是否存在
        modelFile = which([modelName, '.slx']);
        
        % 如果指定了目标文件夹，也检查目标文件夹中是否存在模型文件
        if isempty(modelFile) && ~isempty(targetFolder)
            targetModelFile = fullfile(targetFolder, [modelName, '.slx']);
            if exist(targetModelFile, 'file')
                modelFile = targetModelFile;
            end
        end
        
        if isempty(modelFile)
            % 模型文件不存在，创建新模型
            new_system(modelName);
            fprintf('已创建新模型: %s\n', modelName);
        else
            % 模型文件存在，加载模型
            if ~bdIsLoaded(modelName)
                load_system(modelFile);
                fprintf('已加载现有模型: %s\n', modelName);
            else
                fprintf('模型已加载: %s\n', modelName);
            end
        end
    catch ME
        error('MATLAB:createModExportFun:ModelOperationFailed', ...
              '模型操作失败: %s', ME.message);
    end

    %% 步骤2: 配置为 Export-Function 模型
    try
        set_param(modelName, 'IsExportFunctionModel', 'on');
        fprintf('已配置为导出函数模型\n');
    catch ME
        error('MATLAB:createModExportFun:SetExportFunctionFailed', ...
              '设置导出函数模式失败: %s', ME.message);
    end

    %% 步骤3: 设置模型配置：固定步长为指定周期
    try
        activeConfigSet = getActiveConfigSet(modelName);
        set_param(activeConfigSet, 'SolverType', 'Fixed-step');
        set_param(activeConfigSet, 'Solver', 'FixedStepDiscrete');
        set_param(activeConfigSet, 'FixedStep', num2str(periodic));
%         set_param(activeConfigSet, 'SampleTimeConstraint', 'STIndependent');
        fprintf('已配置求解器：固定步长 = %g 秒\n', periodic);
    catch ME
        warning('MATLAB:createModExportFun:ConfigSolverFailed', ...
                '配置求解器失败: %s', ME.message);
    end

    %% 步骤3.5: 根据ModelType设置TLC文件
    try
        activeConfigSet = getActiveConfigSet(modelName);
        % 根据模型类型设置对应的TLC文件
        switch modelType
            case 'autosar'
                tlcFile = 'autosar.tlc';
            case 'ert'
                tlcFile = 'ert.tlc';
            otherwise
                error('MATLAB:createModExportFun:InvalidModelType', ...
                      '不支持的模型类型: %s，仅支持 ''autosar'' 或 ''ert''', modelType);
        end
        
        % 切换目标TLC文件
        switchTarget(activeConfigSet, tlcFile, '');
        fprintf('已设置TLC文件: %s (模型类型: %s)\n', tlcFile, modelType);
    catch ME
        warning('MATLAB:createModExportFun:SetTLCFailed', ...
                '设置TLC文件失败: %s', ME.message);
    end

    %% 步骤4: 创建函数调用输入端口
    inportName = [modelName, '_Runnable'];
    inportPath = [modelName, '/', inportName];
    
    try
        % 检查输入端口是否已存在
        if ~any(strcmp(get_param(modelName, 'Blocks'), inportName))
            % 创建输入端口，位置在左上角
            inportPos = [50, 100, 80, 114];
            inportBlock = add_block('built-in/Inport', inportPath, ...
                                   'Position', inportPos);
            
            % 设置为函数调用端口
            set_param(inportBlock, 'OutputFunctionCall', 'on');
            
            % 设置采样时间
            set_param(inportBlock, 'SampleTime', num2str(periodic));
            
            fprintf('已创建函数调用输入端口: %s\n', inportName);
        else
            fprintf('输入端口已存在: %s\n', inportName);
            inportBlock = [modelName, '/', inportName];
        end
    catch ME
        error('MATLAB:createModExportFun:CreateInportFailed', ...
              '创建输入端口失败: %s', ME.message);
    end

    %% 步骤5: 创建可执行子系统
    subsystemName = [modelName, '_Runnable_sys'];
    subsystemPath = [modelName, '/', subsystemName];
    
    try
        % 检查子系统是否已存在
        if ~any(strcmp(get_param(modelName, 'Blocks'), subsystemName))
            % 创建子系统，位置在输入端口右侧
            subsystemPos = [150, 80, 250, 150];
            subsystemBlock = add_block('built-in/Subsystem', subsystemPath, ...
                                      'Position', subsystemPos);
            
            fprintf('已创建子系统: %s\n', subsystemName);
        else
            fprintf('子系统已存在: %s\n', subsystemName);
            subsystemBlock = subsystemPath;
        end
    catch ME
        error('MATLAB:createModExportFun:CreateSubsystemFailed', ...
              '创建子系统失败: %s', ME.message);
    end

    %% 步骤6: 进入子系统，配置触发端口和常量模块
    try
        % 打开子系统
        % open_system(subsystemPath);
        
        % 查找或创建触发端口
        triggerPorts = find_system(subsystemPath, 'SearchDepth', 1, ...
                                   'BlockType', 'TriggerPort');
        
        if isempty(triggerPorts)
            % 创建触发端口
            triggerPortPath = [subsystemPath, '/Trigger'];
            triggerPort = add_block('built-in/TriggerPort', triggerPortPath, ...
                                   'Position', [50, 100, 80, 130]);
            
            % 设置为函数调用端口
            set_param(triggerPort, 'TriggerType', 'function-call');
            set_param(triggerPort, 'StatesWhenEnabling', 'held');
            
            fprintf('已在子系统中创建函数调用触发端口\n');
        else
            % 如果已存在，确保设置为函数调用类型
            triggerPort = triggerPorts{1};
            set_param(triggerPort, 'TriggerType', 'function-call');
            fprintf('已配置现有触发端口为函数调用类型\n');
        end
        
        % 创建常量模块避免空模型
        % 创建Constant和Terminator模块，防止模型为空导致编译错误
        try
            % 指定模块位置（在同一水平线上，便于连线）
            constPos = [100 100 130 120];
            termPos = [250 100 280 120];
            
            % 创建Constant模块
            add_block('built-in/Constant', [subsystemPath, '/Constant'], ...
                    'Value', '1', 'Position', constPos);
            fprintf('已创建Constant模块\n');
            
            % 创建Terminator模块
            add_block('built-in/Terminator', [subsystemPath, '/Terminator'], 'Position', termPos);
            fprintf('已创建Terminator模块\n');
            
            % 创建模块间连线
            add_line(subsystemPath, 'Constant/1', 'Terminator/1', 'autorouting', 'on');
            fprintf('已创建模块间连线\n');

            fprintf('基础模块创建完成\n');
            
        catch ME
            error('基础模块创建失败: %s', ME.message);
        end
        
        % 关闭子系统（返回到顶层）
        close_system(subsystemPath);
        
    catch ME
        warning('MATLAB:createModExportFun:ConfigureSubsystemFailed', ...
                '配置子系统失败: %s', ME.message);
        % 确保返回到顶层模型
        try
            close_system(subsystemPath);
        catch
            % 忽略关闭错误
        end
    end

    %% 步骤7: 连接输入端口到子系统的触发端口
    try
        % 获取输入端口的输出端口句柄
        inportPortHandles = get_param(inportBlock, 'PortHandles');
        if isempty(inportPortHandles.Outport) || inportPortHandles.Outport == -1
            error('MATLAB:createModExportFun:InportHandleInvalid', ...
                  '无法获取输入端口的输出句柄');
        end
        outportHandle = inportPortHandles.Outport(1);
        
        % 获取子系统的端口句柄
        subsystemPortHandles = get_param(subsystemBlock, 'PortHandles');
        
        % 查找触发端口句柄
        triggerPortHandle = -1;
        if isfield(subsystemPortHandles, 'Trigger') && ...
           ~isempty(subsystemPortHandles.Trigger) && ...
           subsystemPortHandles.Trigger(1) ~= -1
            triggerPortHandle = subsystemPortHandles.Trigger(1);
        else
            % 如果找不到，尝试通过查找系统获取
            triggerPorts = find_system(subsystemBlock, 'SearchDepth', 1, ...
                                      'BlockType', 'TriggerPort');
            if ~isempty(triggerPorts)
                triggerPortHandles = get_param(triggerPorts{1}, 'PortHandles');
                if isfield(triggerPortHandles, 'Inport') && ...
                   ~isempty(triggerPortHandles.Inport) && ...
                   triggerPortHandles.Inport(1) ~= -1
                    triggerPortHandle = triggerPortHandles.Inport(1);
                end
            end
        end
        
        if triggerPortHandle == -1
            error('MATLAB:createModExportFun:TriggerPortNotFound', ...
                  '无法找到子系统的触发端口');
        end
        
        % 检查连线是否已存在
        lineHandle = get_param(outportHandle, 'Line');
        if lineHandle == -1
            % 创建连线：从输入端口的输出到子系统的触发端口
            add_line(modelName, outportHandle, triggerPortHandle);
            fprintf('已连接输入端口到子系统的触发端口\n');
        else
            fprintf('输入端口到子系统的连线已存在\n');
        end
        
    catch ME
        warning('MATLAB:createModExportFun:ConnectPortsFailed', ...
                '连接端口失败: %s', ME.message);
    end

    %% 步骤8: 保存模型到指定文件夹
    modelPath = '';
    try
        % 如果指定了目标文件夹，需要处理文件夹路径
        if ~isempty(targetFolder)
            % 确保目标文件夹存在
            if ~exist(targetFolder, 'dir')
                mkdir(targetFolder);
                fprintf('已创建目标文件夹: %s\n', targetFolder);
            end
            
            % 构建完整的保存路径
            savePath = fullfile(targetFolder, modelName);
            save_system(modelName, savePath);
            modelPath = [savePath, '.slx'];
            fprintf('已保存模型到: %s\n', savePath);
        else
            % 保存到当前目录
            save_system(modelName);
            % 获取模型文件的完整路径
            modelPath = which([modelName, '.slx']);
            if isempty(modelPath)
                modelPath = fullfile(pwd, [modelName, '.slx']);
            end
            fprintf('已保存模型: %s\n', modelName);
        end
    catch ME
        warning('MATLAB:createModExportFun:SaveModelFailed', ...
                '保存模型失败: %s', ME.message);
        % 即使保存失败，也尝试返回模型路径
        if isempty(modelPath)
            if ~isempty(targetFolder)
                modelPath = fullfile(targetFolder, [modelName, '.slx']);
            else
                modelPath = which([modelName, '.slx']);
                if isempty(modelPath)
                    modelPath = fullfile(pwd, [modelName, '.slx']);
                end
            end
        end
    end
    close_system(modelName)
    fprintf('导出函数模型 "%s" 创建完成\n', modelName);
end
