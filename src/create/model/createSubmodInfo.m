function result = createSubmodInfo(varargin)
%CREATESUBMODINFO 创建包含子模型信息的注释模块并返回结构化结果
%   RESULT = CREATESUBMODINFO() 在当前子模型中创建信息注释模块
%   RESULT = CREATESUBMODINFO('Parameter', Value, ...) 使用指定参数创建
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
%      'PurposeText' - 模块目的说明文本 (字符串), 默认值: ''
%      'MethodText'  - 方法及实现说明文本 (字符串), 默认值: ''
%      'SwrsText'    - SWRS 编号或说明文本 (字符串), 默认值: ''
%                     以上三项若为空，注释中仍输出对应【…】标题及占位行「（待补充）」，便于在 Note 中直接填写。
%
%   输出参数:
%      result - 结构体，字段:
%               path          - 目标系统路径
%               modInfo       - `findModInfo` 返回的模型信息结构体
%               portsInNames  - 输入端口名称列表 (cell)
%               portsOutNames - 输出端口名称列表 (cell)
%               portsInTable  - 输入端口表（Name, DataType）
%               portsOutTable - 输出端口表（Name, DataType）
%               calibInfo     - 标定量信息结构体（`findModInfo.calibInfo`，含 `calibValues` 名-值表）
%               observedSignals - 观测量/解析信号列表 (cell)
%               purposeText   - 目的说明文本 (char)
%               methodText    - 方法及实现说明文本 (char)
%               swrsText      - SWRS说明文本 (char)
%               infoText      - 信息文本 (char)
%               noteCreated   - 是否创建/更新了注释模块 (logical)
%               annotationName - 注释模块名称 (char)
%   功能描述:
%      1. 调用 `findModInfo` 收集子模型输入/输出端口与标定量信息
%      2. 基于收集结果生成信息文本
%      3. 在子模型中创建包含这些信息的注释模块
%      4. 返回收集到的信息，可用于其他处理
%
%   示例:
%      R = createSubmodInfo();
%      R = createSubmodInfo('DCMfileName','HY11_PCMU_Tm_OTA3_V6050327_All.DCM');
%      R = createSubmodInfo('SearchDepth', 'all');
%      R = createSubmodInfo('path', 'myModel/subsystem1', 'includeCnt', true);
%      R = createSubmodInfo('PurposeText', '空调自干燥激活请求逻辑处理', ...
%          'MethodText', '满足条件置位 BlwAftRunAct 并外发唤醒时间', ...
%          'SwrsText', '697092 V8 空调自干燥（3.5平台）');
%
%   注意事项:
%      1. 使用前需要打开目标Simulink模型
%      2. 如果已存在同名注释模块，会先删除再创建
%      3. 即使不需要创建注释模块，也可以使用此函数收集模型信息
%
%   参见: FINDMODINFO, FINDMODPORTS, ADD_BLOCK, GET_PARAM, SET_PARAM, FINDANNOTATION
%
%   作者: blue.ge(葛维冬@Smart)
%   版本: 2.5
%   日期: 2026-04-17
%   变更记录:
%      2026-04-17 v2.5 目的/方法/SWRS 区块无参数时也输出标题与占位行，便于在 Note 内补写。
%      2026-04-17 v2.4 新增 PurposeText/MethodText/SwrsText，可在注释中输出模块信息。
%      2026-04-17 v2.3 标定量区块显示 DCM/Excel 文件名与加载状态；仅当请求的数据源均未加载成功时再显示“注”。
%      2026-04-17 v2.2 信息文本末尾增加作者行。
%      2026-04-17 v2.1 DCM/Excel 标定值查询上移至 `findCalibParams`/`findModInfo`，注释文本仅消费 `calibInfo.calibValues`。
%      2026-04-10 v2.0 改为结构体返回，便于 GUI/脚本直接复用。
%      2025-03-12 v1.6 复用 findModInfo 收集端口和标定量信息。

    %% 初始化返回值
    result = struct( ...
        'path', '', ...
        'modInfo', struct(), ...
        'portsInNames', {{}}, ...
        'portsOutNames', {{}}, ...
        'portsInTable', table(), ...
        'portsOutTable', table(), ...
        'calibInfo', struct(), ...
        'observedSignals', {{}}, ...
        'purposeText', '', ...
        'methodText', '', ...
        'swrsText', '', ...
        'infoText', '', ...
        'noteCreated', false, ...
        'annotationName', '');

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
    addParameter(p, 'DCMfileName', '', @ischar); % DCM文件名
    addParameter(p, 'ExcelfileName', '', @ischar); % excel sldd文件名
    addParameter(p, 'SearchDepth', 1, @(x)isnumeric(x) || (ischar(x) && strcmp(x, 'all')));
    addParameter(p, 'PurposeText', '', @(x)ischar(x) || isstring(x));
    addParameter(p, 'MethodText', '', @(x)ischar(x) || isstring(x));
    addParameter(p, 'SwrsText', '', @(x)ischar(x) || isstring(x));
    
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
    purposeText = char(string(p.Results.PurposeText));
    methodText = char(string(p.Results.MethodText));
    swrsText = char(string(p.Results.SwrsText));

    result.path = path;
    result.annotationName = annotationName;
    result.purposeText = purposeText;
    result.methodText = methodText;
    result.swrsText = swrsText;

    %% 获取子模型信息
    try
        modInfo = findModInfo(path, ...
            'SearchDepth', searchDepth, ...
            'IncludeResolvedSignals', true, ...
            'DCMfileName', DCMfileName, ...
            'ExcelfileName', ExcelfileName, ...
            'ResolveFilesByWhich', true);

        modelName = modInfo.modelName;
        portsInNames = modInfo.portsInNames;
        portsOutNames = modInfo.portsOutNames;
        calibInfo = modInfo.calibInfo;
        observedSignals = {};
        if isfield(modInfo, 'resolvedSignals') && isfield(modInfo.resolvedSignals, 'allSignalNames')
            observedSignals = cellstr(modInfo.resolvedSignals.allSignalNames);
        end

        result.modInfo = modInfo;
        result.portsInNames = portsInNames;
        result.portsOutNames = portsOutNames;
        result.portsInTable = modInfo.portsInTable;
        result.portsOutTable = modInfo.portsOutTable;
        result.calibInfo = calibInfo;
        result.observedSignals = observedSignals;
        
        % 如果需要创建注释模块
        if createNote
            % 检查是否已存在同名注释，如果存在则删除
            removeExistingAnnotation(path, annotationName, userData);
            
            % 生成信息文本
            infoText = generateInfoText(modelName, modInfo.portsInTable, modInfo.portsOutTable, calibInfo, observedSignals, includeCnt, purposeText, methodText, swrsText);
            result.infoText = infoText;
            
            % 创建或更新注释模块
            createAnnotationBlock(path, infoText, position, fontSize, fgColor, bgColor, annotationName, userData);
            result.noteCreated = true;
            
            disp(infoText)
            disp(['已创建子模型信息注释: ' modelName]);
        else
            result.infoText = generateInfoText(modelName, modInfo.portsInTable, modInfo.portsOutTable, calibInfo, observedSignals, includeCnt, purposeText, methodText, swrsText);
        end
    catch ME
        warning(ME.identifier, '%s', ME.message);
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
        warning(ME.identifier, '%s', ME.message);
    end
end

function infoText = generateInfoText(modelName, portsInTable, portsOutTable, calibInfo, observedSignals, includeCnt, purposeText, methodText, swrsText)
    % 生成信息文本（标定数值来自 calibInfo.calibValues，由 findCalibParams 填充）
    if isempty(observedSignals)
        observedSignals = {};
    end
    params = setdiff(calibInfo.allParams, observedSignals, 'stable');
    sigs = observedSignals;
    portN = height(portsInTable) + height(portsOutTable);
    infoText = ['<模型信息: ' modelName '>' newline];
    infoText = [infoText sprintf('<接口 %d | 标定量 %d | 观测量 %d>', portN, numel(params), numel(sigs)) newline newline];

    % 添加模块信息区块（可选）
    infoText = i_appendInfoSection(infoText, '目的', purposeText);
    infoText = i_appendInfoSection(infoText, '方法及具体实现', methodText);
    infoText = i_appendInfoSection(infoText, 'SWRS号', swrsText);
    
    % 添加输入端口信息
    infoText = [infoText newline sprintf('【输入端口】(%d)', height(portsInTable)) newline];
    if ~isempty(portsInTable)
        for i = 1:height(portsInTable)
            portText = i_formatPortDisplay(portsInTable.Name{i}, portsInTable.DataType{i});
            if includeCnt
                infoText = [infoText num2str(i) '. ' portText newline];
            else
                infoText = [infoText portText newline];
            end
        end
    else
        infoText = [infoText '无输入端口' newline];
    end
    
    % 添加输出端口信息
    infoText = [infoText newline sprintf('【输出端口】(%d)', height(portsOutTable)) newline];
    if ~isempty(portsOutTable)
        for i = 1:height(portsOutTable)
            portText = i_formatPortDisplay(portsOutTable.Name{i}, portsOutTable.DataType{i});
            if includeCnt
                infoText = [infoText num2str(i) '. ' portText newline];
            else
                infoText = [infoText portText newline];
            end
        end
    else
        infoText = [infoText '无输出端口' newline];
    end

    % 添加标定量信息
    infoText = [infoText newline sprintf('【标定量】(%d)', numel(params)) newline];
    cv = struct();
    if isfield(calibInfo, 'calibValues')
        cv = calibInfo.calibValues;
    end
    if isfield(cv, 'requested') && cv.requested
        wantDcm = false;
        wantXls = false;
        if isfield(calibInfo, 'options')
            wantDcm = ~isempty(strtrim(char(string(calibInfo.options.DCMfileName))));
            wantXls = ~isempty(strtrim(char(string(calibInfo.options.ExcelfileName))));
        end
        if wantDcm
            dcmDisp = i_infoTextBasename(cv.dcmPath);
            if isempty(dcmDisp)
                dcmDisp = char(string(calibInfo.options.DCMfileName));
            end
            infoText = [infoText sprintf('数据来源 · DCM: %s%s', dcmDisp, i_dataSourceStatusTag(cv.hasDcmData)) newline];
        end
        if wantXls
            xlsDisp = i_infoTextBasename(cv.excelPath);
            if isempty(xlsDisp)
                xlsDisp = char(string(calibInfo.options.ExcelfileName));
            end
            infoText = [infoText sprintf('数据来源 · Excel: %s%s', xlsDisp, i_dataSourceStatusTag(cv.hasExcelData)) newline];
        end
        hasAnySource = cv.hasDcmData || cv.hasExcelData;
        if ~hasAnySource
            if wantDcm && wantXls
                infoText = [infoText '注: DCM 与本地参数表均未成功加载，无法补充标定量数值。' newline];
            elseif wantXls
                infoText = [infoText '注: 本地参数表未找到或读取失败，无法补充标定量数值。' newline];
            elseif wantDcm
                infoText = [infoText '注: DCM 文件未找到或读取失败，无法补充标定量数值。' newline];
            end
        end
    end

    if ~isempty(params)
        for i = 1:length(params)
            ParamName = params{i};
            ParamValue = i_lookupCalibCellValue(cv, ParamName);

            if includeCnt
                infoText = [infoText num2str(i) '. ' i_formatParamLine(ParamName, ParamValue) newline];
            else
                infoText = [infoText i_formatParamLine(ParamName, ParamValue) newline];
            end
        end
    else
        infoText = [infoText '无标定量' newline];
    end

    % 添加观测量信息
    infoText = [infoText newline sprintf('【观测量】(%d)', numel(sigs)) newline];
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
    
    % 添加创建时间与作者
    infoText = [infoText newline '创建时间: ' datestr(now, 'yyyy-mm-dd HH:MM:SS')];
    infoText = [infoText newline '作者: blue.ge(葛维冬@Smart)'];
end

function lineText = i_formatParamLine(paramName, paramValue)
if isempty(paramValue)
    lineText = paramName;
elseif (ischar(paramValue) || isstring(paramValue)) && strlength(strtrim(string(paramValue))) == 0
    lineText = paramName;
elseif isnumeric(paramValue) && isscalar(paramValue)
    lineText = [paramName '=' num2str(paramValue)];
else
    lineText = [paramName '=' char(strtrim(string(paramValue)))];
end
end

function v = i_lookupCalibCellValue(cv, paramName)
v = [];
if isempty(cv) || ~isfield(cv, 'table') || isempty(cv.table) || height(cv.table) == 0
    return;
end
idx = strcmp(string(cv.table.ParamName), string(paramName));
if any(idx)
    v = cv.table.Value{find(idx, 1)};
end
end

function s = i_dataSourceStatusTag(ok)
if ok
    s = '（已加载）';
else
    s = '（未成功加载）';
end
end

function bn = i_infoTextBasename(p)
p = char(strtrim(string(p)));
if isempty(p)
    bn = '';
    return;
end
[~, n, e] = fileparts(p);
if isempty(n) && isempty(e)
    bn = p;
else
    bn = [n e];
end
end

function infoText = i_appendInfoSection(infoText, sectionTitle, sectionText)
% 始终输出标题；未传入正文时用占位行，便于在 Simulink Note 中直接改写
placeholder = '（待补充）';
sectionText = char(strtrim(string(sectionText)));
infoText = [infoText sprintf('【%s】', sectionTitle) newline];
if isempty(sectionText)
    sectionText = placeholder;
end
infoText = [infoText sectionText newline newline];
end

function portText = i_formatPortDisplay(portName, dataType)
portText = portName;
if isempty(dataType)
    return;
end
dataType = strtrim(char(string(dataType)));
if isempty(dataType)
    return;
end
if startsWith(lower(dataType), 'inherit')
    return;
end
portText = sprintf('%s (%s)', portName, dataType);
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
        warning(ME.identifier, '%s', ME.message);
    end
end 