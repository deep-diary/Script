function result = findModInfo(path, varargin)
%FINDMODINFO 汇总模型/子系统的端口、标定量与解析信号信息
%
% 语法:
%   result = findModInfo(path)
%   result = findModInfo(path, 'Name', Value, ...)
%
% 功能描述:
%   对指定模型或子系统收集以下信息，并以结构体统一返回：
%   1) 模型名称与有效路径；
%   2) 输入/输出端口名称与数据类型；
%   3) 标定量信息（来自 `findCalibParams`）；
%   4) 解析信号/全局观测量信息（来自 `findResolvedSignals`）。
%   该函数适合作为 GUI、注释生成与导出逻辑的统一数据入口。
%
% 输入参数:
%   path - 模型路径、子系统路径或句柄 (char/string/double)
%
% 可选参数（Name-Value）:
%   'SearchDepth'            - 标定量搜索深度 (numeric 或 'all')，默认: 1
%   'IncludeResolvedSignals' - 是否收集解析信号信息 (logical)，默认: true
%   'IncludeDataStoreWrite'  - 收集解析信号时是否并入 Data Store Write 名称 (logical)，默认: true
%   'ResolvedDescendants'    - 解析信号是否包含子层级 (logical)，默认: false
%   'DisplayResolvedSignals' - 是否打印解析信号名称 (logical)，默认: false
%   'DCMfileName'            - 传给 `findCalibParams`：DCM 标定值查询，默认: ''
%   'ExcelfileName'          - 传给 `findCalibParams`：Excel 参数表查询，默认: ''
%   'ResolveFilesByWhich'   - 裸文件名是否用 MATLAB path 解析，默认: true
%   'SummaryIncludeCnt'      - summaryText 是否对各项添加序号，默认: false
%
% 输出参数:
%   result - 结构体，字段:
%            path              - 解析后的路径 (char)
%            modelName         - 当前块/系统名称 (char)
%            portsInNames      - 输入端口名称列表 (cell)
%            portsOutNames     - 输出端口名称列表 (cell)
%            portsInDataTypes  - 输入端口数据类型列表 (cell)
%            portsOutDataTypes - 输出端口数据类型列表 (cell)
%            portsInTable      - 输入端口视图表（Name, DataType）
%            portsOutTable     - 输出端口视图表（Name, DataType）
%            portsSpecial      - 特殊端口信息（沿用 findModPorts）
%            calibInfo         - 标定量结构体（`findCalibParams` 返回，可含 `calibValues` 名-值表）
%            resolvedSignals   - 解析信号结构体（findResolvedSignals 返回）
%            summary           - 计数摘要结构体
%            summaryText       - GUI 可直接显示的文本汇总（输入/输出/标定量/观测量）
%
% 异常与边界行为:
%   - path 无效时 error。
%   - IncludeResolvedSignals=false 时 resolvedSignals 返回空结构体。
%
% 示例:
%   R = findModInfo(gcs);
%   R = findModInfo(gcs, 'SearchDepth', 'all', 'ResolvedDescendants', true);
%   R = findModInfo(gcs, 'DCMfileName', 'a.dcm', 'ExcelfileName', 'b.xlsx');
%
% 参见: FINDMODPORTS, FINDCALIBPARAMS, FINDRESOLVEDSIGNALS
%
% 作者: blue.ge(葛维冬@Smart)
% 版本: 1.4
% 日期: 2026-04-17
% 变更记录:
%   2026-04-17 v1.4 summaryText 增加观测量区块，标定量与观测量去重对齐；支持可选序号。
%   2026-04-17 v1.3 新增 summaryText 字段：端口/标定量文本汇总，可直接用于 GUI。
%   2026-04-17 v1.2 透传 DCM/Excel 至 `findCalibParams`，标定名与值在同一入口获取。
%   2026-04-16 v1.1 新增端口数据类型与端口表字段，便于注释与 GUI 直接使用。
%   2026-04-10 v1.0 初版：统一聚合模型基本信息。

p = inputParser;
addRequired(p, 'path', @(x) ischar(x) || isstring(x) || isnumeric(x));
addParameter(p, 'SearchDepth', 1, @(x) isnumeric(x) || (ischar(x) && strcmp(x, 'all')) || (isstring(x) && strcmpi(x, "all")));
addParameter(p, 'IncludeResolvedSignals', true, @islogical);
addParameter(p, 'IncludeDataStoreWrite', true, @islogical);
addParameter(p, 'ResolvedDescendants', false, @islogical);
addParameter(p, 'DisplayResolvedSignals', false, @islogical);
addParameter(p, 'DCMfileName', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'ExcelfileName', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'ResolveFilesByWhich', true, @islogical);
addParameter(p, 'SummaryIncludeCnt', false, @islogical);
parse(p, path, varargin{:});

path = p.Results.path;
searchDepth = p.Results.SearchDepth;
includeResolvedSignals = p.Results.IncludeResolvedSignals;
includeDataStoreWrite = p.Results.IncludeDataStoreWrite;
resolvedDescendants = p.Results.ResolvedDescendants;
displayResolvedSignals = p.Results.DisplayResolvedSignals;
dcmFileName = char(string(p.Results.DCMfileName));
excelFileName = char(string(p.Results.ExcelfileName));
resolveFilesByWhich = p.Results.ResolveFilesByWhich;
summaryIncludeCnt = p.Results.SummaryIncludeCnt;

try
    if ~(ischar(path) || isstring(path))
        path = getfullname(path);
    end
    path = char(path);
catch
    error('%s: 无效的模型路径或句柄。', mfilename);
end

modelName = get_param(path, 'Name');
[~, portsInNames, portsOutNames, portsSpecial] = findModPorts(path, 'getType', 'Name');
[~, portsInDataTypes, portsOutDataTypes] = findModPorts(path, 'getType', 'OutDataTypeStr');
calibInfo = findCalibParams(path, ...
    'SearchDepth', searchDepth, ...
    'DCMfileName', dcmFileName, ...
    'ExcelfileName', excelFileName, ...
    'ResolveFilesByWhich', resolveFilesByWhich);
portsInTable = i_buildPortTable(portsInNames, portsInDataTypes);
portsOutTable = i_buildPortTable(portsOutNames, portsOutDataTypes);

if includeResolvedSignals
    resolvedSignals = findResolvedSignals(path, ...
        'IncludeDescendants', resolvedDescendants, ...
        'IncludeDataStoreWrite', includeDataStoreWrite, ...
        'DisplaySignals', displayResolvedSignals);
else
    resolvedSignals = struct();
end

summary = struct();
summary.inputPorts = numel(portsInNames);
summary.outputPorts = numel(portsOutNames);
summary.calibParams = numel(calibInfo.allParams);
if includeResolvedSignals && isfield(resolvedSignals, 'allSignalNames')
    summary.resolvedSignals = numel(resolvedSignals.allSignalNames);
else
    summary.resolvedSignals = 0;
end
summaryText = i_buildSummaryText( ...
    portsInNames, portsOutNames, ...
    portsInDataTypes, portsOutDataTypes, ...
    calibInfo, resolvedSignals, summaryIncludeCnt);

result = struct();
result.path = path;
result.modelName = modelName;
result.portsInNames = portsInNames;
result.portsOutNames = portsOutNames;
result.portsInDataTypes = portsInDataTypes;
result.portsOutDataTypes = portsOutDataTypes;
result.portsInTable = portsInTable;
result.portsOutTable = portsOutTable;
result.portsSpecial = portsSpecial;
result.calibInfo = calibInfo;
result.resolvedSignals = resolvedSignals;
result.summary = summary;
result.summaryText = summaryText;

end

function T = i_buildPortTable(names, dtypes)
names = names(:);
dtypes = dtypes(:);
n = min(numel(names), numel(dtypes));
if n == 0
    T = table(cell(0,1), cell(0,1), 'VariableNames', {'Name','DataType'});
    return;
end
T = table(names(1:n), dtypes(1:n), 'VariableNames', {'Name','DataType'});
end

function txt = i_buildSummaryText(portsInNames, portsOutNames, portsInDataTypes, portsOutDataTypes, calibInfo, resolvedSignals, includeCnt)
txt = '';
txt = [txt sprintf('【输入端口】(%d)', numel(portsInNames)) newline];
if isempty(portsInNames)
    txt = [txt '无输入端口' newline];
else
    for i = 1:numel(portsInNames)
        pLine = i_formatPortLine(portsInNames, portsInDataTypes, i);
        txt = [txt i_addIndexPrefix(pLine, i, includeCnt) newline]; %#ok<AGROW>
    end
end

txt = [txt newline sprintf('【输出端口】(%d)', numel(portsOutNames)) newline];
if isempty(portsOutNames)
    txt = [txt '无输出端口' newline];
else
    for i = 1:numel(portsOutNames)
        pLine = i_formatPortLine(portsOutNames, portsOutDataTypes, i);
        txt = [txt i_addIndexPrefix(pLine, i, includeCnt) newline]; %#ok<AGROW>
    end
end

observedNames = {};
if isfield(resolvedSignals, 'allSignalNames') && ~isempty(resolvedSignals.allSignalNames)
    observedNames = cellstr(string(resolvedSignals.allSignalNames(:)));
end
calibNames = setdiff(calibInfo.allParams, observedNames, 'stable');
txt = [txt newline sprintf('【标定量】(%d)', numel(calibNames)) newline];
txt = [txt i_buildCalibSourceLine(calibInfo)];
if ~isempty(calibNames)
    for i = 1:numel(calibNames)
        pName = calibNames{i};
        pVal = i_lookupCalibCellValue(calibInfo, pName);
        txt = [txt i_addIndexPrefix(i_formatParamLine(pName, pVal), i, includeCnt) newline]; %#ok<AGROW>
    end
else
    txt = [txt '无标定量' newline];
end

txt = [txt newline sprintf('【观测量】(%d)', numel(observedNames)) newline];
if ~isempty(observedNames)
    for i = 1:numel(observedNames)
        txt = [txt i_addIndexPrefix(i_toDisplayLine(observedNames{i}), i, includeCnt) newline]; %#ok<AGROW>
    end
else
    txt = [txt '无观测量' newline];
end
end

function line = i_formatPortLine(names, dtypes, idx)
nameStr = i_toDisplayLine(names{idx});
dtypeStr = '';
if idx <= numel(dtypes)
    dtypeStr = strtrim(i_toDisplayLine(dtypes{idx}));
end

if isempty(dtypeStr) || startsWith(lower(dtypeStr), 'inherit')
    line = nameStr;
else
    line = sprintf('%s(%s)', nameStr, dtypeStr);
end
end

function line = i_buildCalibSourceLine(calibInfo)
line = '';
if ~isfield(calibInfo, 'calibValues')
    return;
end
cv = calibInfo.calibValues;
if ~isfield(cv, 'requested') || ~cv.requested
    return;
end

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
    line = [line sprintf('注：数据来源 · DCM: %s%s', dcmDisp, i_dataSourceStatusTag(cv.hasDcmData)) newline];
end
if wantXls
    xlsDisp = i_infoTextBasename(cv.excelPath);
    if isempty(xlsDisp)
        xlsDisp = char(string(calibInfo.options.ExcelfileName));
    end
    line = [line sprintf('注：数据来源 · Excel: %s%s', xlsDisp, i_dataSourceStatusTag(cv.hasExcelData)) newline];
end

if ~(cv.hasDcmData || cv.hasExcelData)
    if wantDcm && wantXls
        line = [line '注: DCM 与本地参数表均未成功加载，无法补充标定量数值。' newline];
    elseif wantXls
        line = [line '注: 本地参数表未找到或读取失败，无法补充标定量数值。' newline];
    elseif wantDcm
        line = [line '注: DCM 文件未找到或读取失败，无法补充标定量数值。' newline];
    end
end
end

function v = i_lookupCalibCellValue(calibInfo, paramName)
v = [];
if ~isfield(calibInfo, 'calibValues')
    return;
end
cv = calibInfo.calibValues;
if ~isfield(cv, 'table') || isempty(cv.table) || height(cv.table) == 0
    return;
end
idx = strcmp(string(cv.table.ParamName), string(paramName));
if any(idx)
    v = cv.table.Value{find(idx, 1)};
end
end

function lineText = i_formatParamLine(paramName, paramValue)
if isempty(paramValue)
    lineText = i_toDisplayLine(paramName);
elseif (ischar(paramValue) || isstring(paramValue)) && strlength(strtrim(string(paramValue))) == 0
    lineText = i_toDisplayLine(paramName);
elseif isnumeric(paramValue) && isscalar(paramValue)
    lineText = [i_toDisplayLine(paramName) '=' num2str(paramValue)];
else
    lineText = [i_toDisplayLine(paramName) '=' char(strtrim(string(paramValue)))];
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

function s = i_toDisplayLine(v)
if ischar(v)
    s = v;
elseif isstring(v)
    s = char(v);
elseif isnumeric(v) && isscalar(v)
    s = num2str(v);
else
    s = char(strtrim(string(v)));
end
end

function line = i_addIndexPrefix(line, idx, includeCnt)
if includeCnt
    line = sprintf('%d. %s', idx, line);
end
end

