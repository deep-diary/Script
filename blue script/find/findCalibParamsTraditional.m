function calibParams = findCalibParamsTraditional(path, varargin)
%FINDCALIBPARAMSTRADITIONAL 使用传统方法查找模型中的标定量
%   CALIBPARAMS = FINDCALIBPARAMSTRADITIONAL(PATH) 在指定路径的当前层查找标定量
%   CALIBPARAMS = FINDCALIBPARAMSTRADITIONAL(PATH, 'Parameter', Value, ...) 使用指定参数查找标定量
%
%   输入参数:
%      path         - 模型路径或句柄 (字符串或数值)
%
%   可选参数（名值对）:
%      'SearchDepth'   - 搜索深度 (正整数或'all'), 默认值: 1
%                      1表示仅当前层，'all'表示所有层级
%      'SkipMask'      - 是否跳过Mask子系统内部 (逻辑值), 默认值: true, 暂时未使用
%      'SkipLib'       - 是否跳过库链接 (逻辑值), 默认值: true
%
%   输出参数:
%      calibParams  - 找到的标定量列表 (元胞数组)
%
%   功能描述:
%      使用传统方法查找Simulink模型中的标定量，支持多种模块类型：
%      - Constant (常量)
%      - Lookup Table (查找表)
%      - Gain (增益)
%      - Relay (继电器)
%      - Switch (开关)
%      - Saturation (饱和)
%      - Product (乘法)
%      - Sum (求和)
%      - Math (数学函数)
%      - Mask参数 (对于Mask子系统)
%
%   示例:
%      params = findCalibParamsTraditional(gcs)
%      params = findCalibParamsTraditional(gcs, 'SearchDepth', 'all')
%      params = findCalibParamsTraditional(gcs, 'SearchDepth', 'all','SkipMask',false)
%
%   参见: FIND_SYSTEM, GET_PARAM, SIMULINK.FINDVARS, FINDMASKPARAMS
%
%   作者: Blue.ge
%   版本: 1.4
%   日期: 20250312

    %% 输入参数处理
    % 创建输入解析器
    p = inputParser;
    addParameter(p, 'SearchDepth', 1, @(x)isnumeric(x) || (ischar(x) && strcmp(x, 'all')));
    addParameter(p, 'SkipMask', true, @islogical);
    addParameter(p, 'SkipLib', true, @islogical);
        
    % 解析输入参数
    parse(p, varargin{:});  
    
    % 获取参数值
    searchDepth = p.Results.SearchDepth;
    skipMask = p.Results.SkipMask;
    skipLib = p.Results.SkipLib;
    
    % 验证路径
    try
        if ~ischar(path)
            path = getfullname(path);
        end
    catch
        error('无效的模型路径或句柄');
    end
    
    %% 构建查找参数
    findParams = {'FollowLinks', ~skipLib};
    
    if skipMask
        findParams = [findParams, 'LookUnderMasks', 'none'];
    else
        findParams = [findParams, 'LookUnderMasks', 'all'];
    end
    
    if ischar(searchDepth) && strcmpi(searchDepth, 'all')
        % 搜索所有层级
        findParams = [findParams, 'SearchDepth', inf];
    else
        % 搜索指定深度
        findParams = [findParams, 'SearchDepth', searchDepth];
    end
    
    %% 查找标定量
    calibParams = {};
    
    % 处理子模块中的Mask

    maskBlocks = find_system(path, findParams{:}, 'FindAll', 'on', 'Mask', 'on');
    % 收集所有Mask参数
    for i = 1:length(maskBlocks)
        try
            blockPath = getfullname(maskBlocks(i));
            blockParams = findMaskParams(blockPath);
            calibParams = [calibParams, blockParams];
        catch
            % 跳过有问题的模块
            continue;
        end
    end
        

    
    % 常规标定量查找
    % 查找Constant块
    constants = find_system(path, findParams{:}, 'BlockType', 'Constant');
    for i = 1:length(constants)
        value = get_param(constants{i}, 'Value');
        calibParams = addCalibParam(calibParams, value);
    end
    
    % 查找Lookup Table块
    lookupTables = find_system(path, findParams{:}, 'BlockType', 'Lookup_n-D');
    for i = 1:length(lookupTables)
        tableData = get_param(lookupTables{i}, 'Table');
        calibParams = addCalibParam(calibParams, tableData);
        
        % 检查BreakPoints参数
        try
            bpCount = str2double(get_param(lookupTables{i}, 'NumberOfTableDimensions'));
            for j = 1:bpCount
                bpName = ['BreakpointsForDimension', num2str(j)];
                bpValue = get_param(lookupTables{i}, bpName);
                calibParams = addCalibParam(calibParams, bpValue);
            end
        catch
            % 如果无法获取断点，则跳过
        end
    end
    
    % 查找1D Lookup Table块
    lookup1D = find_system(path, findParams{:}, 'BlockType', 'Lookup');
    for i = 1:length(lookup1D)
        tableData = get_param(lookup1D{i}, 'Table');
        calibParams = addCalibParam(calibParams, tableData);
        
        % 检查输入和输出值
        inputValues = get_param(lookup1D{i}, 'InputValues');
        calibParams = addCalibParam(calibParams, inputValues);
    end
    
    % 查找Gain块
    gainBlocks = find_system(path, findParams{:}, 'BlockType', 'Gain');
    for i = 1:length(gainBlocks)
        gain = get_param(gainBlocks{i}, 'Gain');
        calibParams = addCalibParam(calibParams, gain);
    end
    
    % 查找Relay块
    relayBlocks = find_system(path, findParams{:}, 'BlockType', 'Relay');
    for i = 1:length(relayBlocks)
        onValue = get_param(relayBlocks{i}, 'OnSwitchValue');
        offValue = get_param(relayBlocks{i}, 'OffSwitchValue');
        onOutput = get_param(relayBlocks{i}, 'OnOutputValue');
        offOutput = get_param(relayBlocks{i}, 'OffOutputValue');
        
        params = {onValue, offValue, onOutput, offOutput};
        for j = 1:length(params)
            calibParams = addCalibParam(calibParams, params{j});
        end
    end
    
    % 查找Switch块
    switchBlocks = find_system(path, findParams{:}, 'BlockType', 'Switch');
    for i = 1:length(switchBlocks)
        threshold = get_param(switchBlocks{i}, 'Threshold');
        calibParams = addCalibParam(calibParams, threshold);
    end
    
    % 查找Saturation块
    satBlocks = find_system(path, findParams{:}, 'BlockType', 'Saturate');
    for i = 1:length(satBlocks)
        upperLimit = get_param(satBlocks{i}, 'UpperLimit');
        lowerLimit = get_param(satBlocks{i}, 'LowerLimit');
        
        params = {upperLimit, lowerLimit};
        for j = 1:length(params)
            calibParams = addCalibParam(calibParams, params{j});
        end
    end
    
    % 查找Product块
    productBlocks = find_system(path, findParams{:}, 'BlockType', 'Product');
    for i = 1:length(productBlocks)
        try
            % 检查是否有常数输入
            inputParams = get_param(productBlocks{i}, 'InputValues');
            if ~isempty(inputParams) && ischar(inputParams)
                calibParams = addCalibParam(calibParams, inputParams);
            end
        catch
            % 如果无法获取输入值，则跳过
        end
    end
    
    % 查找Sum块
    sumBlocks = find_system(path, findParams{:}, 'BlockType', 'Sum');
    for i = 1:length(sumBlocks)
        try
            % 检查是否有常数输入
            inputParams = get_param(sumBlocks{i}, 'InputValues');
            if ~isempty(inputParams) && ischar(inputParams)
                calibParams = addCalibParam(calibParams, inputParams);
            end
        catch
            % 如果无法获取输入值，则跳过
        end
    end
    
    % 查找Math块
    mathBlocks = find_system(path, findParams{:}, 'BlockType', 'Math');
    for i = 1:length(mathBlocks)
        try
            % 检查是否有常数参数
            parameter = get_param(mathBlocks{i}, 'Parameter');
            if ~isempty(parameter) && ischar(parameter)
                calibParams = addCalibParam(calibParams, parameter);
            end
        catch
            % 如果无法获取参数，则跳过
        end
    end
    
    % 去除重复的标定量
    calibParams = unique(calibParams);
end

function calibParams = addCalibParam(calibParams, value)
    % 辅助函数：检查并添加标定量
    if ischar(value) && ~isempty(regexp(value, '^[A-Za-z]', 'once')) && ...
       ~any(strcmp(value, {'pi', 'inf', 'nan', 'eps', 'realmax', 'realmin'}))
        
        % 处理可能包含多个变量的表达式
        % 例如 "a*b + c" 应该提取 a, b, c
        tokens = regexp(value, '[A-Za-z][A-Za-z0-9_]*', 'match');
        
        for i = 1:length(tokens)
            token = tokens{i};
            
            % 排除MATLAB内置函数和运算符
            if ~any(strcmp(token, {'sin', 'cos', 'tan', 'exp', 'log', 'sqrt', 'abs', ...
                    'min', 'max', 'round', 'floor', 'ceil', 'mod', 'rem', ...
                    'and', 'or', 'not', 'xor', 'if', 'else', 'elseif', 'end', ...
                    'for', 'while', 'switch', 'case', 'otherwise', 'break', 'continue'}))
                
                % 检查是否已存在于列表中
                if ~any(strcmp(calibParams, token))
                    calibParams{end+1} = token;
                end
            end
        end
    end
end