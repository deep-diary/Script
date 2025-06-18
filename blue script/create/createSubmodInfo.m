function [portsInNames, portsOutNames, calibParams, infoText] = createSubmodInfo(varargin)
%CREATESUBMODINFO 创建包含子模型信息的注释模块并返回收集的信息
%   [PORTSINNAMES, PORTSOUTNAMES, CALIBPARAMS] = CREATESUBMODINFO() 在当前子模型中创建信息注释模块
%   [PORTSINNAMES, PORTSOUTNAMES, CALIBPARAMS] = CREATESUBMODINFO('Parameter', Value, ...) 使用指定参数创建
%
%   输入参数（名值对）:
%      'path'        - 目标系统路径 (字符串), 默认值: gcs (当前系统)
%      'position'    - 注释模块位置 [x y width height] (数组), 默认自动计算
%      'fontSize'    - 字体大小 (正整数), 默认值: 12
%      'fgColor'     - 前景颜色 (字符串), 默认值: 'blue'
%      'bgColor'     - 背景颜色 [R G B] (数组), 默认值: [0.9 0.9 0.9]
%      'includeCnt'  - 是否包含序号 (逻辑值), 默认值: false
%      'userData'    - 用户数据 (任意类型), 默认值: 'modInfo'
%      'DCMfileName' - DCM文件名 (字符串), 默认值: 'HY11_PCMU_Tm_OTA3_V6050327_All.DCM'
%
%   输出参数:
%      portsInNames  - 输入端口名称列表 (元胞数组)
%      portsOutNames - 输出端口名称列表 (元胞数组)
%      calibParams   - 标定量列表 (元胞数组)
%      infoText      - 信息文本 (字符串)
%   功能描述:
%      1. 收集子模型的输入端口信息
%      2. 收集子模型的输出端口信息
%      3. 收集子模型内部使用的标定量
%      4. 在子模型中创建包含这些信息的注释模块
%      5. 返回收集到的信息，可用于其他处理
%
%   示例:
%      [inPortNames, outPortNames, params] = createSubmodInfo()
%      [inPortNames, outPortNames, params] = createSubmodInfo('DCMfileName','HY11_PCMU_Tm_OTA3_V6050327_All.DCM')
%      [inPortNames, outPortNames, params] = createSubmodInfo('SearchDepth', 'all')
%      [~, ~, params] = createSubmodInfo('path', 'myModel/subsystem1', 'includeCnt', true)
%
%   注意事项:
%      1. 使用前需要打开目标Simulink模型
%      2. 如果已存在同名注释模块，会先删除再创建
%      3. 即使不需要创建注释模块，也可以使用此函数收集模型信息
%
%   参见: FINDMODPORTS, ADD_BLOCK, GET_PARAM, SET_PARAM, SIMULINK.FINDVARS, FINDANNOTATION
%
%   作者: Blue.ge
%   版本: 1.6
%   日期: 20250312

    %% 初始化返回值
    portsInNames = {};
    portsOutNames = {};
    calibParams = {};

    %% 输入参数处理
    p = inputParser;
    addParameter(p, 'path', gcs, @ischar);
    addParameter(p, 'position', [], @(x)isempty(x) || (isnumeric(x) && length(x)==4));
    addParameter(p, 'fontSize', 12, @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
    addParameter(p, 'fgColor', 'blue', @ischar);
    addParameter(p, 'bgColor', [0.9 0.9 0.9], @(x)validateattributes(x,{'numeric'},{'size',[1,3],'>=',0,'<=',1}));
    addParameter(p, 'includeCnt', false, @islogical);
    addParameter(p, 'createNote', true, @islogical); % 是否创建注释模块
    addParameter(p, 'annotationName', 'SubmodInfo', @ischar); % 注释模块名称
    addParameter(p, 'userData', 'modInfo', @(x)true); % 用户数据，默认为'modInfo'
    addParameter(p, 'DCMfileName', 'HY11_PCMU_Tm_OTA3_V6070519_All.DCM', @ischar); % DCM文件名
    addParameter(p, 'ExcelfileName', 'TmSovCtrl_DD_XCU.xlsx', @ischar); % excel sldd文件名
    addParameter(p, 'SearchDepth', 1, @(x)isnumeric(x) || (ischar(x) && strcmp(x, 'all')));
    
    parse(p, varargin{:});
    
    path = p.Results.path;
    searchDepth = p.Results.SearchDepth;
    position = p.Results.position;
    fontSize = p.Results.fontSize;
    fgColor = p.Results.fgColor;
    bgColor = p.Results.bgColor;
    includeCnt = p.Results.includeCnt;
    createNote = p.Results.createNote;
    annotationName = p.Results.annotationName;
    userData = p.Results.userData;
    DCMfileName = p.Results.DCMfileName;
    ExcelfileName = p.Results.ExcelfileName;

    %% 获取子模型信息
    try
        % 获取模型名称
        modelName = get_param(path, 'Name');
        
        % 获取端口信息 - 直接获取端口名称
        [~, portsIn, portsOut, portsSpecial] = findModPorts(path, 'getType', 'Name');
        
        % 保存端口名称
        portsInNames = portsIn;
        portsOutNames = portsOut;
        
        % 查找模型中的标定量
        calibParams = findCalibParams(path,'SearchDepth', searchDepth);
        
        % 如果需要创建注释模块
        if createNote
            % 检查是否已存在同名注释，如果存在则删除
            removeExistingAnnotation(path, annotationName, userData);
            
            % 生成信息文本
            infoText = generateInfoText(modelName, portsInNames, portsOutNames, calibParams, includeCnt,DCMfileName,ExcelfileName);
            
            % 创建或更新注释模块
            createAnnotationBlock(path, infoText, position, fontSize, fgColor, bgColor, annotationName, userData);
            
            disp(infoText)
            disp(['已创建子模型信息注释: ' modelName]);
        end
    catch ME
        warning('处理子模型信息失败: %s', ME.message);
    end
end

function removeExistingAnnotation(path, annotationName, userData)
    % 使用findAnnotation函数查找并删除现有的注释模块
    try
        % 查找匹配名称和用户数据的注释模块
        existingAnnotations = findAnnotation('path', path, 'UserData', userData);
        
        % 如果找到匹配的注释模块，则删除它们
        for i = 1:length(existingAnnotations)
            delete(existingAnnotations(i));
        end
        
        % 为了确保完全删除，也查找仅匹配名称的注释模块
        nameOnlyAnnotations = findAnnotation('path', path, 'Name', annotationName);
        for i = 1:length(nameOnlyAnnotations)
            delete(nameOnlyAnnotations(i));
        end
    catch ME
        warning('删除现有注释模块失败: %s', ME.message);
    end
end

function infoText = generateInfoText(modelName, portsInNames, portsOutNames, calibParams, includeCnt,DCMfileName,ExcelfileName)
    % 生成信息文本
    infoText = ['<模型信息: ' modelName '>' newline newline];
    
    % 添加输入端口信息
    infoText = [infoText newline '【输入端口】' newline];
    if ~isempty(portsInNames)
        for i = 1:length(portsInNames)
            if includeCnt
                infoText = [infoText num2str(i) '. ' portsInNames{i} newline];
            else
                infoText = [infoText portsInNames{i} newline];
            end
        end
    else
        infoText = [infoText '无输入端口' newline];
    end
    
    % 添加输出端口信息
    infoText = [infoText newline '【输出端口】' newline];
    if ~isempty(portsOutNames)
        for i = 1:length(portsOutNames)
            if includeCnt
                infoText = [infoText num2str(i) '. ' portsOutNames{i} newline];
            else
                infoText = [infoText portsOutNames{i} newline];
            end
        end
    else
        infoText = [infoText '无输出端口' newline];
    end

    param_idx = contains(calibParams,{'cTm','tTm','mTm'});
    params = calibParams(param_idx);
    sigs = calibParams(~param_idx);
    
    % 添加标定量信息
    infoText = [infoText newline '【标定量】' newline];
    paramsArr = findDCMParam(DCMfileName);
    %                     {1} - 常量 (FESTWERT)
    %                     {2} - 轴定义 (STUETZSTELLENVERTEILUNG)
    %                     {3} - 值块 (FESTWERTEBLOCK)
    paramsArr = paramsArr([1 3]);
    datatable = readSldd(ExcelfileName,'sheet','Parameters');

    if ~isempty(params)
        for i = 1:length(params)
            ParamName = params{i};

            % 从DCM文件中找到Param对应的值
%             ParamValue = findDCMValueByName(DCMfileName,ParamName);
%             if isempty(ParamValue)
%                 % 从本地excel 中查找
%                 ParamValue = findSlddExcelValueByName(ExcelfileName,ParamName);
%             end

            % 使用cache, 增加查询速度
            ParamValue = findDCMValueByNameCache(paramsArr,ParamName);
            if isempty(ParamValue)
                % 从本地excel 中查找
                ParamValue = findSlddExcelValueByNameCache(datatable,ParamName);
            end

            if includeCnt
                infoText = [infoText num2str(i) '. ' ParamName '=' num2str(ParamValue) newline];
            else
                infoText = [infoText ParamName '=' num2str(ParamValue) newline];
            end            
        end
    else
        infoText = [infoText '无标定量' newline];
    end

    % 添加观测量信息
    infoText = [infoText newline '【观测量】' newline];
    if ~isempty(sigs)
        for i = 1:length(sigs)
            sig = sigs{i};
            if includeCnt
                infoText = [infoText num2str(i) '. ' sig  newline];
            else
                infoText = [infoText sig  newline];
            end           
        end
    else
        infoText = [infoText '无观测量' newline];
    end
    
    % 添加创建时间
    infoText = [infoText newline '创建时间: ' datestr(now, 'yyyy-mm-dd HH:MM:SS')];
end

function createAnnotationBlock(path, infoText, position, fontSize, fgColor, bgColor, annotationName, userData)
    % 如果未指定位置，则自动计算位置
    if isempty(position)
        % 获取系统边界
        allBlocks = find_system(path, 'SearchDepth', 1);
        allBlocks = allBlocks(2:end); % 移除系统本身
        
        if isempty(allBlocks)
            % 如果没有块，使用默认位置
            position = [50, 50, 350, 250];
        else
            % 找到所有块的最右边界
            maxRight = 0;
            minTop = inf;
            
            for i = 1:length(allBlocks)
                try
                    pos = get_param(allBlocks{i}, 'Position');
                    maxRight = max(maxRight, pos(3));
                    minTop = min(minTop, pos(2));
                catch
                    % 跳过无法获取位置的块
                    continue;
                end
            end
            
            % 在最右边放置注释，与顶部对齐
            position = [maxRight + 50, minTop, maxRight + 350, minTop + 300];
        end
    end
    
    % 创建注释块
    try
        annotationPath = [path '/' annotationName];
        add_block('built-in/Note', annotationPath, ...
            'Position', position, ...
            'FontSize', fontSize, ...
            'BackgroundColor', mat2str(bgColor), ...
            'ForegroundColor', fgColor, ...
            'UserData', userData, ...
            'Text', infoText);
    catch ME
        warning('创建注释模块失败: %s', ME.message);
    end
end 