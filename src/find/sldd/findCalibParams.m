function result = findCalibParams(path, varargin)
%FINDCALIBPARAMS 分类查找模型标定量（优先 findVars，回退传统扫描）
%
% 语法:
%   result = findCalibParams(path)
%   result = findCalibParams(path, 'Name', Value, ...)
%
% 功能描述:
%   统一封装两类来源：
%   1) `Simulink.findVars`（当 MATLAB 版本支持且 SearchDepth='all'）；
%   2) `findCalibParamsTraditional`（传统块参数扫描）。
%   返回结构体，包含各来源明细与合并去重后的 allParams，便于上游直接消费。
%
% 输入参数:
%   path - 模型路径或句柄 (char/string/double)
%
% 可选参数（Name-Value）:
%   'SearchDepth'           - 搜索深度 (numeric 或 'all')，默认: 1
%   'SkipMask'              - 是否跳过 Mask 子系统内部，默认: true
%   'SkipLib'               - 是否跳过库链接，默认: true
%   'DCMfileName'           - DCM 文件路径或文件名，默认: ''（不进行 DCM 数值查询）
%   'ExcelfileName'         - 参数表 Excel（readSldd），默认: ''（不进行 Excel 数值查询）
%   'ResolveFilesByWhich'   - 对裸文件名是否用 which/MATLAB path 解析，默认: true
%
% 输出参数:
%   result - 结构体，字段:
%            path                - 解析后的模型路径
%            options             - 输入参数快照
%            paramsFromFindVars  - findVars 命中的变量名（cellstr）
%            traditional         - findCalibParamsTraditional 的完整结构体结果
%            allParams           - 汇总去重后的标定量列表（cellstr）
%            table               - 参数视图表（table），列: ParamName, SourceCategory, SourceMethod,
%                                  Value（cell，标定数值，未查到则为 []）, ValueSource（'dcm'/'excel'/'none'）
%            method              - 使用策略说明（'traditionalOnly' / 'mixed' / 'fallbackTraditional'）
%            calibValues         - 标定名-数值查询结果（见下）；与 allParams 行对齐的明细表
%
%   calibValues 子结构体:
%            requested     - 是否请求了外部数值查询 (logical)
%            dcmPath       - 解析后的 DCM 路径（未指定则为 ''）
%            excelPath     - 解析后的 Excel 路径（未指定则为 ''）
%            hasDcmData    - DCM 是否成功加载
%            hasExcelData  - Excel 是否成功加载
%            table         - table(ParamName, Value, Source)，Source 为 'dcm'/'excel'/'none'
%                            行顺序与 allParams 一致；未请求时为空表（0×3，列名同上）
%
% 异常与边界行为:
%   - path 无法解析时 error。
%   - findVars 失败时 warning 并自动回退传统方法。
%
% 示例:
%   R = findCalibParams(gcs);
%   R = findCalibParams(gcs, 'SearchDepth', 'all');
%   R = findCalibParams(gcs, 'DCMfileName', 'my.dcm', 'ExcelfileName', 'params.xlsx');
%
% 参见: FINDCALIBPARAMSTRADITIONAL, SIMULINK.FINDVARS, FINDDCMPARAM, READSLDD
%
% 作者: blue.ge(葛维冬@Smart)
% 版本: 2.3
% 日期: 2026-04-17
% 变更记录:
%   2026-04-17 v2.3 result.table 按 ParamName 合并 calibValues，增加 Value、ValueSource 列。
%   2026-04-17 v2.2 可选 DCM/Excel：与 allParams 对齐的 calibValues 表（名-值-来源），便于与查询逻辑合一。
%   2026-04-10 v2.1 新增 result.table 参数视图（含来源分类与方法）。
%   2026-04-10 v2.0 改为结构体返回，增加 findVars 与传统扫描来源信息。
%   2025-03-12 v1.2 传统 cell 返回实现。

p = inputParser;
addRequired(p, 'path', @(x) ischar(x) || isstring(x) || isnumeric(x));
addParameter(p, 'SearchDepth', 1, @(x) isnumeric(x) || (ischar(x) && strcmp(x, 'all')) || (isstring(x) && strcmpi(x, "all")));
addParameter(p, 'SkipMask', true, @islogical);
addParameter(p, 'SkipLib', true, @islogical);
addParameter(p, 'DCMfileName', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'ExcelfileName', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'ResolveFilesByWhich', true, @islogical);
parse(p, path, varargin{:});

path = p.Results.path;
searchDepth = p.Results.SearchDepth;
skipMask = p.Results.SkipMask;
skipLib = p.Results.SkipLib;
dcmFileName = char(string(p.Results.DCMfileName));
excelFileName = char(string(p.Results.ExcelfileName));
resolveFilesByWhich = p.Results.ResolveFilesByWhich;

try
    if ~(ischar(path) || isstring(path))
        path = getfullname(path);
    end
    path = char(path);
catch
    error('%s: 无效的模型路径或句柄。', mfilename);
end

paramsFromFindVars = {};

try
    % 使用 Simulink.findVars 查找标定量， 暂时屏蔽放弃使用
    % if ~verLessThan('matlab', '9.1') && ((ischar(searchDepth) || isstring(searchDepth)) && strcmpi(char(searchDepth), 'all'))
    %     vars = Simulink.findVars(path, 'SourceType', 'base workspace');
    %     for i = 1:length(vars)
    %         try
    %             varName = vars(i).Name;
    %             if ~any(strcmp(varName, {'pi', 'inf', 'nan', 'eps', 'realmax', 'realmin', 'const'})) && ...
    %                     isvarname(varName) && ~isempty(regexp(varName, '^[A-Za-z]', 'once'))
    %                 paramsFromFindVars{end+1} = varName; %#ok<AGROW>
    %             end
    %         catch
    %         end
    %     end
    %     paramsFromFindVars = unique(paramsFromFindVars, 'stable');
    % end

    traditional = findCalibParamsTraditional(path, ...
        'SearchDepth', searchDepth, ...
        'SkipMask', skipMask, ...
        'SkipLib', skipLib);

    if isempty(paramsFromFindVars)
        method = 'traditionalOnly';
    else
        method = 'mixed';
    end
catch ME
    warning('%s: 查找标定量失败(%s)，回退传统方法。', mfilename, ME.message);
    traditional = findCalibParamsTraditional(path, ...
        'SearchDepth', searchDepth, ...
        'SkipMask', skipMask, ...
        'SkipLib', skipLib);
    method = 'fallbackTraditional';
end

allParams = unique([paramsFromFindVars, traditional.allParams], 'stable');

result = struct();
result.path = path;
result.options = struct( ...
    'SearchDepth', searchDepth, ...
    'SkipMask', skipMask, ...
    'SkipLib', skipLib, ...
    'DCMfileName', dcmFileName, ...
    'ExcelfileName', excelFileName, ...
    'ResolveFilesByWhich', resolveFilesByWhich);
result.paramsFromFindVars = paramsFromFindVars;
result.traditional = traditional;
result.allParams = allParams;
result.table = i_buildParamTable(paramsFromFindVars, traditional);
result.method = method;
result.calibValues = i_buildCalibValues(allParams, dcmFileName, excelFileName, resolveFilesByWhich);
result.table = i_attachCalibValuesToParamTable(result.table, result.calibValues.table);

end

function T = i_buildParamTable(paramsFromFindVars, traditional)
% 合并 findVars 与 traditional 的参数来源视图
if isempty(paramsFromFindVars)
    tFind = table(strings(0,1), strings(0,1), strings(0,1), ...
        'VariableNames', {'ParamName','SourceCategory','SourceMethod'});
else
    p = string(paramsFromFindVars(:));
    tFind = table(p, ...
        repmat("baseWorkspaceFindVars", numel(p), 1), ...
        repmat("findVars", numel(p), 1), ...
        'VariableNames', {'ParamName','SourceCategory','SourceMethod'});
end

tTraditional = traditional.table;
if isempty(tTraditional)
    tTraditional = table(strings(0,1), strings(0,1), strings(0,1), ...
        'VariableNames', {'ParamName','SourceCategory','SourceMethod'});
else
    tTraditional.SourceMethod = repmat("traditional", height(tTraditional), 1);
    tTraditional = movevars(tTraditional, 'SourceMethod', 'After', 'SourceCategory');
end

T = [tFind; tTraditional];
if ~isempty(T)
    T = unique(T, 'rows', 'stable');
end
end

function Tout = i_attachCalibValuesToParamTable(T, cvTable)
% 将 calibValues.table 的 Value、Source 按 ParamName 并入参数来源表（增加 Value、ValueSource）
if isempty(T) || ~istable(T)
    Tout = T;
    return;
end
n = height(T);
vals = cell(n, 1);
vsrc = repmat("none", n, 1);
if ~isempty(cvTable) && istable(cvTable) && height(cvTable) > 0 && ...
        ismember('ParamName', cvTable.Properties.VariableNames) && ...
        ismember('Value', cvTable.Properties.VariableNames) && ...
        ismember('Source', cvTable.Properties.VariableNames)
    cNames = string(cvTable.ParamName);
    for i = 1:n
        pn = string(T.ParamName(i));
        idx = find(cNames == pn, 1, 'first');
        if ~isempty(idx)
            vals{i} = cvTable.Value{idx};
            vsrc(i) = string(cvTable.Source(idx));
        end
    end
end
Tout = T;
Tout.Value = vals;
Tout.ValueSource = vsrc;
Tout = movevars(Tout, 'Value', 'After', 'SourceMethod');
Tout = movevars(Tout, 'ValueSource', 'After', 'Value');
end

function cv = i_buildCalibValues(allParams, dcmFileName, excelFileName, resolveByWhich)
emptyT = table( ...
    strings(0, 1), ...
    cell(0, 1), ...
    strings(0, 1), ...
    'VariableNames', {'ParamName', 'Value', 'Source'});
cv = struct( ...
    'requested', false, ...
    'dcmPath', '', ...
    'excelPath', '', ...
    'hasDcmData', false, ...
    'hasExcelData', false, ...
    'table', emptyT);

if isempty(strtrim(dcmFileName)) && isempty(strtrim(excelFileName))
    return;
end

cv.requested = true;
paramsArr = {};
datatable = table();

if ~isempty(strtrim(dcmFileName))
    dcmPath = i_resolveFileByWhich(dcmFileName, resolveByWhich);
    cv.dcmPath = dcmPath;
    if isfile(dcmPath)
        try
            raw = findDCMParam(dcmPath);
            if numel(raw) >= 3
                paramsArr = raw([1 3]);
            else
                paramsArr = raw;
            end
            cv.hasDcmData = true;
        catch
            paramsArr = {};
            cv.hasDcmData = false;
        end
    end
end

if ~isempty(strtrim(excelFileName))
    excelPath = i_resolveFileByWhich(excelFileName, resolveByWhich);
    cv.excelPath = excelPath;
    if isfile(excelPath)
        try
            datatable = readSldd(excelPath, 'sheet', 'Parameters');
            cv.hasExcelData = true;
        catch
            cv.hasExcelData = false;
        end
    end
end

n = numel(allParams);
if n == 0
    return;
end

names = string(allParams(:));
vals = cell(n, 1);
src = repmat("none", n, 1);
for i = 1:n
    pn = char(names(i));
    v = [];
    if cv.hasDcmData
        v = findDCMValueByNameCache(paramsArr, pn);
        if ~i_isEmptyCalibLookupValue(v)
            src(i) = "dcm";
        else
            v = [];
        end
    end
    if isempty(v) && cv.hasExcelData
        vEx = i_safeExcelIniValue(datatable, pn);
        if ~i_isEmptyCalibLookupValue(vEx)
            v = vEx;
            src(i) = "excel";
        end
    end
    vals{i} = v;
end
cv.table = table(names, vals, src, 'VariableNames', {'ParamName', 'Value', 'Source'});
end

function tf = i_isEmptyCalibLookupValue(v)
if isempty(v)
    tf = true;
elseif (ischar(v) || isstring(v)) && strlength(strtrim(string(v))) == 0
    tf = true;
else
    tf = false;
end
end

function v = i_safeExcelIniValue(datatable, paramName)
v = [];
try
    if isempty(datatable) || ~istable(datatable)
        return;
    end
    vn = datatable.Properties.VariableNames;
    if ~ismember('Name', vn) || ~ismember('IniValue', vn)
        return;
    end
    idx = datatable.Name == string(paramName);
    if ~any(idx)
        return;
    end
    row = datatable(idx, :);
    v = row.IniValue(1);
    if iscell(v)
        v = v{1};
    end
catch
    v = [];
end
end

function filePath = i_resolveFileByWhich(filePath, resolveByWhich)
filePath = char(string(filePath));
if isempty(strtrim(filePath)) || isfile(filePath)
    return;
end
if ~resolveByWhich
    return;
end
if isempty(regexp(filePath, '[/\\]', 'once'))
    w = which(filePath);
    if ~isempty(w)
        lines = splitlines(string(w));
        for k = 1:numel(lines)
            cand = strtrim(lines(k));
            if strlength(cand) == 0
                continue;
            end
            cand = char(cand);
            if isfile(cand)
                filePath = cand;
                return;
            end
        end
    end
end
end