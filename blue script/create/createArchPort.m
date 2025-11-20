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
%      'RxComponentName' - 接收组件名称 (字符串, 默认: 'SdbRxSigProc')
%                         用于获取输入端口信息的组件
%      'TxComponentName' - 发送组件名称 (字符串, 默认: 'SdbTxSigProc')
%                         用于获取输出端口信息的组件
%      'SkipTrigger'    - 是否跳过触发端口 (逻辑值, 默认: true)
%
%   输出参数:
%      inport       - 创建的输入端口对象数组 (Arch.Port 数组)
%      outport      - 创建的输出端口对象数组 (Arch.Port 数组)
%
%   功能描述:
%      1. 加载或使用指定的AUTOSAR架构模型
%      2. 从接收组件中读取输入端口信息并创建架构模型输入端口
%      3. 从发送组件中读取输出端口信息并创建架构模型输出端口
%      4. 复制端口的数据类型和描述信息
%
%   示例:
%      % 基本用法 - 使用字符串
%      [inport, outport] = createArchPort('CcmArch')
%      
%      % 使用已加载的架构模型对象
%      archModel = autosar.arch.loadModel('CcmArch');
%      [inport, outport] = createArchPort(archModel)
%      
%      % 指定组件名称
%      [inport, outport] = createArchPort('CcmArch', ...
%                                         'RxComponentName', 'MyRxSWC', ...
%                                         'TxComponentName', 'MyTxSWC')
%
%   注意事项:
%      1. 如果输入为字符串，使用前需要确保架构模型文件存在
%      2. 如果输入为对象，确保该对象是有效的架构模型对象
%      3. 接收组件和发送组件必须存在于架构模型中
%      4. 输入端口只处理 BusElementPort 类型的端口
%      5. 端口的数据类型和描述信息会从 Simulink 模型中复制
%
%   参见: AUTOSAR.ARCH.LOADMODEL, AUTOSAR.ARCH.FIND, AUTOSAR.ARCH.ADDPORT,
%         FINDMODPORTS, GET_PARAM, SET_PARAM
%
%   作者: Blue.ge
%   版本: 2.0
%   日期: 20251120

    %% 参数解析和验证
    % 创建输入解析器
    p = inputParser;
    p.FunctionName = mfilename;
    
    % 添加可选参数
    addParameter(p, 'RxComponentName', 'SdbRxSigProc', ...
                 @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'TxComponentName', 'SdbTxSigProc', ...
                 @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'SkipTrigger', true, ...
                 @(x) validateattributes(x, {'logical'}, {'scalar'}));
    
    % 解析输入参数
    parse(p, varargin{:});
    
    % 提取参数值
    rxComponentName = char(p.Results.RxComponentName);
    txComponentName = char(p.Results.TxComponentName);
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

    %% 查找接收组件和发送组件
    try
        swcRx = find(archModel, 'Component', 'Name', rxComponentName);
        if isempty(swcRx)
            error('MATLAB:createArchPort:RxComponentNotFound', ...
                  '未找到接收组件 "%s"', rxComponentName);
        end
    catch ME
        if strcmp(ME.identifier, 'MATLAB:createArchPort:RxComponentNotFound')
            rethrow(ME);
        else
            error('MATLAB:createArchPort:FindRxComponentFailed', ...
                  '查找接收组件 "%s" 失败: %s', rxComponentName, ME.message);
        end
    end
    
    try
        swcTx = find(archModel, 'Component', 'Name', txComponentName);
        if isempty(swcTx)
            error('MATLAB:createArchPort:TxComponentNotFound', ...
                  '未找到发送组件 "%s"', txComponentName);
        end
    catch ME
        if strcmp(ME.identifier, 'MATLAB:createArchPort:TxComponentNotFound')
            rethrow(ME);
        else
            error('MATLAB:createArchPort:FindTxComponentFailed', ...
                  '查找发送组件 "%s" 失败: %s', txComponentName, ME.message);
        end
    end

    %% 处理接收组件的输入端口
    inport = [];
    try
        % 获取接收组件的输入端口信息
        [~, PortsIn, ~, ~] = findModPorts(swcRx.SimulinkHandle, ...
                                           'skipTrig', skipTrigger, ...
                                           'getType', 'Handle');
        
        if ~isempty(PortsIn)
            inportCount = 0;
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
                    warning('MATLAB:createArchPort:GetPortPropertyFailed', ...
                            '无法获取端口属性，跳过端口 %d', i);
                    continue;
                end
                
                % 获取端口属性
                try
                    PortName = get_param(portHandle, 'PortName');
                    OutDataTypeStr = get_param(portHandle, 'OutDataTypeStr');
                    Description = get_param(portHandle, 'Description');
                catch ME
                    warning('MATLAB:createArchPort:GetPortInfoFailed', ...
                            '获取端口信息失败，跳过端口 %d: %s', i, ME.message);
                    continue;
                end
                
                % 创建架构模型输入端口
                try
                    port = addPort(archModel, 'Receiver', PortName);
                    set_param(port.SimulinkHandle, 'OutDataTypeStr', OutDataTypeStr);
                    set_param(port.SimulinkHandle, 'Description', Description);
                    inportCount = inportCount + 1;
                    inport = [inport, port]; %#ok<AGROW>
                catch ME
                    warning('MATLAB:createArchPort:CreateInPortFailed', ...
                            '创建输入端口 "%s" 失败: %s', PortName, ME.message);
                end
            end
            fprintf('已创建 %d 个输入端口 (来自组件 "%s")\n', inportCount, rxComponentName);
        else
            fprintf('组件 "%s" 中没有找到输入端口\n', rxComponentName);
        end
    catch ME
        warning('MATLAB:createArchPort:ProcessInPortsFailed', ...
                '处理输入端口失败: %s', ME.message);
    end

    %% 处理发送组件的输出端口
    outport = [];
    try
        % 获取发送组件的输出端口信息
        [~, ~, PortsOut, ~] = findModPorts(swcTx.SimulinkHandle, ...
                                            'getType', 'Handle');
        
        if ~isempty(PortsOut)
            outportCount = 0;
            for i = 1:length(PortsOut)
                portHandle = PortsOut{i};
                
                % 获取端口属性
                try
                    PortName = get_param(portHandle, 'PortName');
                    OutDataTypeStr = get_param(portHandle, 'OutDataTypeStr');
                    Description = get_param(portHandle, 'Description');
                catch ME
                    warning('MATLAB:createArchPort:GetPortInfoFailed', ...
                            '获取端口信息失败，跳过端口 %d: %s', i, ME.message);
                    continue;
                end
                
                % 创建架构模型输出端口
                try
                    port = addPort(archModel, 'Sender', PortName);
                    set_param(port.SimulinkHandle, 'OutDataTypeStr', OutDataTypeStr);
                    set_param(port.SimulinkHandle, 'Description', Description);
                    outportCount = outportCount + 1;
                    outport = [outport, port]; %#ok<AGROW>
                catch ME
                    warning('MATLAB:createArchPort:CreateOutPortFailed', ...
                            '创建输出端口 "%s" 失败: %s', PortName, ME.message);
                end
            end
            fprintf('已创建 %d 个输出端口 (来自组件 "%s")\n', outportCount, txComponentName);
        else
            fprintf('组件 "%s" 中没有找到输出端口\n', txComponentName);
        end
    catch ME
        warning('MATLAB:createArchPort:ProcessOutPortsFailed', ...
                '处理输出端口失败: %s', ME.message);
    end
    
    fprintf('架构模型 "%s" 端口创建完成\n', modelNameForDisplay);
end
