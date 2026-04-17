function createModSig(pathMd, varargin)
%CREATEMODSIG 对模型输入输出端口的信号线进行命名和配置
%   CREATEMODSIG(PATHMD) 对指定模型的输入输出端口信号线进行命名和配置
%   CREATEMODSIG(PATHMD, 'Parameter', Value, ...) 使用指定参数配置信号线
%
%   输入参数:
%      pathMd      - 模型路径 (字符串)
%
%   可选参数（名值对）:
%      'skipTrig'      - 是否跳过触发器端口 (逻辑值), 默认值: true
%      'isEnableIn'    - 是否启用输入端口处理 (逻辑值), 默认值: true
%      'isEnableOut'   - 是否启用输出端口处理 (逻辑值), 默认值: true
%      'resoveValue'   - 是否解析为信号对象 (逻辑值), 默认值: false
%      'logValue'      - 是否启用数据记录 (逻辑值), 默认值: false
%      'testValue'     - 是否启用测试点 (逻辑值), 默认值: false
%      'dispName'      - 是否显示信号名称 (逻辑值), 默认值: true
%      'autosarMode'   - AUTOSAR信号名解析模式 (字符串), 默认值: ''
%                        可选值: 'deleteTail', 'halfTail', 'justHalf', 'modelHalf', 'prefixHalf'
%      'prefixName'    - 前缀名称，用于 'prefixHalf' 模式 (字符串), 默认值: 'CcmIF'
%
%   功能描述:
%      对模型的输入输出端口信号线进行命名和配置，支持AUTOSAR信号名解析。
%      可以设置信号对象解析、数据记录、测试点等属性。
%
%   示例:
%      createModSig(gcs)
%      createModSig(gcs, 'isEnableIn', true, 'isEnableOut', true)
%      createModSig(gcs, 'autosarMode', 'deleteTail', 'dispName', true)
%      createModSig(gcs, 'autosarMode', 'prefixHalf', 'prefixName', 'CustomPrefix')
%
%   作者: Blue.ge
%   日期: 2023-9-5
%   版本: 2.0
%%
    %% 输入参数验证
    narginchk(1, inf);
    validateattributes(pathMd, {'char', 'string'}, {'scalartext'}, mfilename, 'pathMd', 1);
    
    % 确保输入为字符向量
    pathMd = char(pathMd);
    
    %% 显示启动信息
    fprintf('=== 开始配置模型信号线 ===\n');
    fprintf('模型路径: %s\n', pathMd);
    
    % 验证模型是否存在
    if ~bdIsLoaded(bdroot(pathMd))
        error('createModSig:modelNotLoaded', '模型未加载: %s', pathMd);
    end
    
    %% 解析输入参数
    p = inputParser;
    p.FunctionName = mfilename;
    
    addParameter(p,'skipTrig',true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p,'isEnableIn',true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p,'isEnableOut',true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p,'resoveValue',false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p,'logValue',false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p,'testValue',false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p,'dispName',true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p,'autosarMode','', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p,'prefixName','CcmIF', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    
    parse(p,varargin{:});

    % 获取参数值
    skipTrig = p.Results.skipTrig;
    isEnableIn = p.Results.isEnableIn;
    isEnableOut = p.Results.isEnableOut;
    resoveValue = p.Results.resoveValue;
    logValue = p.Results.logValue;
    testValue = p.Results.testValue;
    dispName = p.Results.dispName;
    autosarMode = char(p.Results.autosarMode);
    prefixName = char(p.Results.prefixName);

    % 信号解析等属性需要显示信号名称
    if logValue || testValue || resoveValue
        dispName = true;
        fprintf('注意: 由于启用了信号对象解析、数据记录或测试点，自动启用信号名称显示\n');
    end

    % 确定是否截断信号名
    if ~isempty(autosarMode)
        truncateSignal = true;
        fprintf('AUTOSAR模式: %s (将截断信号名)\n', autosarMode);
    else
        truncateSignal = false;
        fprintf('AUTOSAR模式: 关闭 (不截断信号名)\n');
    end
    
    %% 显示配置参数
    fprintf('\n--- 配置参数 ---\n');
    fprintf('跳过触发器端口: %s\n', mat2str(skipTrig));
    fprintf('启用输入端口处理: %s\n', mat2str(isEnableIn));
    fprintf('启用输出端口处理: %s\n', mat2str(isEnableOut));
    fprintf('解析为信号对象: %s\n', mat2str(resoveValue));
    fprintf('启用数据记录: %s\n', mat2str(logValue));
    fprintf('启用测试点: %s\n', mat2str(testValue));
    fprintf('显示信号名称: %s\n', mat2str(dispName));
    fprintf('截断信号名: %s\n', mat2str(truncateSignal));
    fprintf('----------------\n\n');

    %% 找到模型端口
    fprintf('正在分析模型端口...\n');
    PortHandles = get_param(pathMd, 'PortHandles');
    modelName = get_param(pathMd,'Name');
    inports = PortHandles.Inport;
    outports = PortHandles.Outport;
    
    fprintf('模型名称: %s\n', modelName);
    fprintf('输入端口数量: %d\n', length(inports));
    fprintf('输出端口数量: %d\n', length(outports));
    
    %% 找到有效路径
    fprintf('正在查找有效路径...\n');
    [~, validPath] = findValidPath(pathMd);
    InportCell = find_system(validPath,'SearchDepth',1,'BlockType','Inport');  % 获取所有Inport模块路径
    OutportCell = find_system(validPath,'SearchDepth',1,'BlockType','Outport');  % 获取所有Outport模块路径
    
    fprintf('找到输入端口模块: %d 个\n', length(InportCell));
    fprintf('找到输出端口模块: %d 个\n', length(OutportCell));
    fprintf('有效路径: %s\n\n', validPath);
    
    %% 处理信号
    processedInports = 0;
    processedOutports = 0;
    
    if isEnableIn
        fprintf('=== 处理输入端口信号 ===\n');
        for i = 1:length(inports)  % 遍历输入端口
            InportName = get_param(InportCell{i},'Name');  % 获取模块名称
            BlockType = get_param(InportCell{i},'BlockType');  % 获取模块类型
            originalName = InportName;
            
            % 根据truncateSignal参数决定是否截断信号名
            if truncateSignal
                InportName = findNameAutosar(InportName,'nameMd',modelName,'type',BlockType,'mode',autosarMode,'prefixName',prefixName);
                fprintf('  端口 %d: %s -> %s\n', i, originalName, InportName);
            else
                fprintf('  端口 %d: %s (未截断)\n', i, InportName);
            end
            
            hLine = get_param(inports(i), 'Line');
            if dispName
                set(hLine,'Name',InportName)  % 设置信号线名称为模块名称
            else
                set(hLine,'Name','')  % 清空信号线名称
            end
            set(hLine,'MustResolveToSignalObject',resoveValue)   % 设置信号线关联Simulink Signal Object
            set(hLine,'DataLogging',logValue) 
            set(hLine,'TestPoint',testValue)
            
            processedInports = processedInports + 1;
        end
        fprintf('输入端口处理完成: %d 个\n\n', processedInports);
    else
        fprintf('跳过输入端口处理\n\n');
    end
        
    if isEnableOut
        fprintf('=== 处理输出端口信号 ===\n');
        for i = 1:length(outports)  
            OutportName = get_param(OutportCell{i},'Name');  % 获取模块名称
            BlockType = get_param(OutportCell{i},'BlockType');  % 获取模块类型
            originalName = OutportName;
            
            % 根据truncateSignal参数决定是否截断信号名
            if truncateSignal
                OutportName = findNameAutosar(OutportName,'nameMd',modelName,'type',BlockType,'mode',autosarMode,'prefixName',prefixName);
                fprintf('  端口 %d: %s -> %s\n', i, originalName, OutportName);
            else
                fprintf('  端口 %d: %s (未截断)\n', i, OutportName);
            end
            
            hLine = get_param(outports(i), 'Line');
            if dispName
                set(hLine,'Name',OutportName)  % 设置信号线名称为模块名称
            else
                set(hLine,'Name','')  % 清空信号线名称
            end
            set(hLine,'MustResolveToSignalObject',resoveValue)   % 设置信号线关联Simulink Signal Object
            set(hLine,'DataLogging',logValue) 
            set(hLine,'TestPoint',testValue)
            
            processedOutports = processedOutports + 1;
        end
        fprintf('输出端口处理完成: %d 个\n\n', processedOutports);
    else
        fprintf('跳过输出端口处理\n\n');
    end
    
    %% 显示处理结果摘要
    fprintf('=== 处理结果摘要 ===\n');
    fprintf('模型名称: %s\n', modelName);
    fprintf('处理的输入端口: %d 个\n', processedInports);
    fprintf('处理的输出端口: %d 个\n', processedOutports);
    fprintf('总处理端口数: %d 个\n', processedInports + processedOutports);
    
    if truncateSignal
        fprintf('AUTOSAR信号名解析模式: %s\n', autosarMode);
    else
        fprintf('AUTOSAR信号名解析: 未启用\n');
    end
    
    fprintf('信号名称显示: %s\n', mat2str(dispName));
    fprintf('信号对象解析: %s\n', mat2str(resoveValue));
    fprintf('数据记录: %s\n', mat2str(logValue));
    fprintf('测试点: %s\n', mat2str(testValue));
    fprintf('========================\n');
    fprintf('模型信号线配置完成！\n');
end
