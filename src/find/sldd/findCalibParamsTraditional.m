function result = findCalibParamsTraditional(path, varargin)
%FINDCALIBPARAMSTRADITIONAL 传统方式分类查找模型中的标定量
%
% 语法:
%   result = findCalibParamsTraditional(path)
%   result = findCalibParamsTraditional(path, 'Name', Value, ...)
%
% 功能描述:
%   使用 `find_system + get_param` 的传统扫描策略，从常见块类型与 Mask 参数中提取
%   标定相关变量名，并按来源分类返回结构体结果，便于后续统计、展示与追踪来源。
%
% 输入参数:
%   path - 模型路径或句柄 (char/string/double)
%
% 可选参数（Name-Value）:
%   'SearchDepth' - 搜索深度 (numeric 或 'all')，默认: 1
%   'SkipMask'    - 是否跳过 Mask 子系统内部，默认: true
%   'SkipLib'     - 是否跳过库链接，默认: true
%
% 输出参数:
%   result - 结构体，字段:
%            path        - 解析后的模型路径
%            options     - 输入参数快照
%            categories  - 分类结果结构体（各字段为 cellstr）:
%                          maskParams, constantParams, lookupTableParams,
%                          lookupBreakpointParams, lookup1DParams, gainParams,
%                          relayParams, switchParams, saturationParams,
%                          productParams, sumParams, mathParams
%            allParams   - 汇总去重后的标定量列表 (cellstr)
%            table       - 参数视图表（table），列: ParamName, SourceCategory
%            stats       - 各分类数量与总数统计
%
% 异常与边界行为:
%   - path 无法解析时 error。
%   - 单个块读参失败时跳过，不中断整体扫描。
%
% 示例:
%   R = findCalibParamsTraditional(gcs);
%   R = findCalibParamsTraditional(gcs, 'SearchDepth', 'all', 'SkipMask', true);
%
% 参见: FIND_SYSTEM, GET_PARAM, FINDPARAMMASK
%
% 作者: blue.ge(葛维冬@Smart)
% 版本: 2.1
% 日期: 2026-04-10
% 变更记录:
%   2026-04-10 v2.1 新增 result.table 视图，便于 GUI 显示与导出。
%   2026-04-10 v2.0 结构体分类返回，保留传统扫描逻辑并补齐规范文档。
%   2025-03-12 v1.4 传统实现。

p = inputParser;
addParameter(p, 'SearchDepth', 1, @(x) isnumeric(x) || (ischar(x) && strcmp(x, 'all')) || (isstring(x) && strcmpi(x, "all")));
addParameter(p, 'SkipMask', true, @islogical);
addParameter(p, 'SkipLib', true, @islogical);
parse(p, varargin{:});

searchDepth = p.Results.SearchDepth;
skipMask = p.Results.SkipMask;
skipLib = p.Results.SkipLib;

try
    if ~(ischar(path) || isstring(path))
        path = getfullname(path);
    end
    path = char(path);
catch
    error('%s: 无效的模型路径或句柄。', mfilename);
end

findParams = {'FollowLinks', ~skipLib};
if skipMask
    findParams = [findParams, {'LookUnderMasks', 'none'}];
else
    findParams = [findParams, {'LookUnderMasks', 'all'}];
end
if (ischar(searchDepth) || isstring(searchDepth)) && strcmpi(char(searchDepth), 'all')
    findParams = [findParams, {'SearchDepth', inf}];
else
    findParams = [findParams, {'SearchDepth', searchDepth}];
end

categories = struct( ...
    'maskParams', {{}}, ...
    'constantParams', {{}}, ...
    'lookupTableParams', {{}}, ...
    'lookupBreakpointParams', {{}}, ...
    'lookup1DParams', {{}}, ...
    'gainParams', {{}}, ...
    'relayParams', {{}}, ...
    'switchParams', {{}}, ...
    'saturationParams', {{}}, ...
    'productParams', {{}}, ...
    'sumParams', {{}}, ...
    'mathParams', {{}});

maskBlocks = find_system(path, findParams{:}, 'FindAll', 'on', 'Mask', 'on');
for i = 1:length(maskBlocks)
    try
        blockPath = getfullname(maskBlocks(i));
        blockParams = findParamMask(blockPath);
        categories.maskParams = i_mergeTokens(categories.maskParams, blockParams);
    catch
    end
end

constants = find_system(path, findParams{:}, 'BlockType', 'Constant');
for i = 1:length(constants)
    categories.constantParams = i_mergeTokens(categories.constantParams, get_param(constants{i}, 'Value'));
end

lookupTables = find_system(path, findParams{:}, 'BlockType', 'Lookup_n-D');
for i = 1:length(lookupTables)
    categories.lookupTableParams = i_mergeTokens(categories.lookupTableParams, get_param(lookupTables{i}, 'Table'));
    try
        bpCount = str2double(get_param(lookupTables{i}, 'NumberOfTableDimensions'));
        for j = 1:bpCount
            bpName = ['BreakpointsForDimension', num2str(j)];
            bpValue = get_param(lookupTables{i}, bpName);
            categories.lookupBreakpointParams = i_mergeTokens(categories.lookupBreakpointParams, bpValue);
        end
    catch
    end
end

lookup1D = find_system(path, findParams{:}, 'BlockType', 'Lookup');
for i = 1:length(lookup1D)
    categories.lookup1DParams = i_mergeTokens(categories.lookup1DParams, get_param(lookup1D{i}, 'Table'));
    categories.lookup1DParams = i_mergeTokens(categories.lookup1DParams, get_param(lookup1D{i}, 'InputValues'));
end

gainBlocks = find_system(path, findParams{:}, 'BlockType', 'Gain');
for i = 1:length(gainBlocks)
    categories.gainParams = i_mergeTokens(categories.gainParams, get_param(gainBlocks{i}, 'Gain'));
end

relayBlocks = find_system(path, findParams{:}, 'BlockType', 'Relay');
for i = 1:length(relayBlocks)
    categories.relayParams = i_mergeTokens(categories.relayParams, get_param(relayBlocks{i}, 'OnSwitchValue'));
    categories.relayParams = i_mergeTokens(categories.relayParams, get_param(relayBlocks{i}, 'OffSwitchValue'));
    % categories.relayParams = i_mergeTokens(categories.relayParams, get_param(relayBlocks{i}, 'OnOutputValue'));
    % categories.relayParams = i_mergeTokens(categories.relayParams, get_param(relayBlocks{i}, 'OffOutputValue'));
end

switchBlocks = find_system(path, findParams{:}, 'BlockType', 'Switch');
for i = 1:length(switchBlocks)
    categories.switchParams = i_mergeTokens(categories.switchParams, get_param(switchBlocks{i}, 'Threshold'));
end

satBlocks = find_system(path, findParams{:}, 'BlockType', 'Saturate');
for i = 1:length(satBlocks)
    categories.saturationParams = i_mergeTokens(categories.saturationParams, get_param(satBlocks{i}, 'UpperLimit'));
    categories.saturationParams = i_mergeTokens(categories.saturationParams, get_param(satBlocks{i}, 'LowerLimit'));
end

productBlocks = find_system(path, findParams{:}, 'BlockType', 'Product');
for i = 1:length(productBlocks)
    try
        categories.productParams = i_mergeTokens(categories.productParams, get_param(productBlocks{i}, 'InputValues'));
    catch
    end
end

sumBlocks = find_system(path, findParams{:}, 'BlockType', 'Sum');
for i = 1:length(sumBlocks)
    try
        categories.sumParams = i_mergeTokens(categories.sumParams, get_param(sumBlocks{i}, 'InputValues'));
    catch
    end
end

mathBlocks = find_system(path, findParams{:}, 'BlockType', 'Math');
for i = 1:length(mathBlocks)
    try
        categories.mathParams = i_mergeTokens(categories.mathParams, get_param(mathBlocks{i}, 'Parameter'));
    catch
    end
end

allParams = {};
catNames = fieldnames(categories);
for i = 1:numel(catNames)
    categories.(catNames{i}) = unique(categories.(catNames{i}), 'stable');
    allParams = unique([allParams, categories.(catNames{i})], 'stable');
end

stats = struct();
for i = 1:numel(catNames)
    stats.(catNames{i}) = numel(categories.(catNames{i}));
end
stats.totalParams = numel(allParams);

result = struct();
result.path = path;
result.options = struct('SearchDepth', searchDepth, 'SkipMask', skipMask, 'SkipLib', skipLib);
result.categories = categories;
result.allParams = allParams;
result.table = i_buildCategoryTable(categories);
result.stats = stats;

end

function out = i_mergeTokens(existing, value)
out = existing;
tokens = i_extractCalibTokens(value);
if isempty(tokens)
    return;
end
out = [out, tokens]; %#ok<AGROW>
out = unique(out, 'stable');
end

function tokens = i_extractCalibTokens(value)
tokens = {};
if iscell(value)
    for i = 1:numel(value)
        tokens = unique([tokens, i_extractCalibTokens(value{i})], 'stable'); %#ok<AGROW>
    end
    return;
end
if isstring(value)
    if numel(value) == 1
        value = char(value);
    else
        value = strjoin(cellstr(value), ' ');
    end
end
if ~(ischar(value) && ~isempty(value))
    return;
end

if isempty(regexp(value, '^[A-Za-z]', 'once')) || ...
        any(strcmp(value, {'pi', 'inf', 'nan', 'eps', 'realmax', 'realmin'}))
    return;
end

raw = regexp(value, '[A-Za-z][A-Za-z0-9_]*', 'match');
if isempty(raw)
    return;
end

for i = 1:numel(raw)
    token = raw{i};
    if ~any(strcmp(token, {'sin', 'cos', 'tan', 'exp', 'log', 'sqrt', 'abs', ...
            'min', 'max', 'round', 'floor', 'ceil', 'mod', 'rem', ...
            'and', 'or', 'not', 'xor', 'if', 'else', 'elseif', 'end', ...
            'for', 'while', 'switch', 'case', 'otherwise', 'break', 'continue'}))
        tokens{end+1} = token; %#ok<AGROW>
    end
end
tokens = unique(tokens, 'stable');
end

function T = i_buildCategoryTable(categories)
catNames = fieldnames(categories);
paramNames = strings(0, 1);
sourceCats = strings(0, 1);
for i = 1:numel(catNames)
    c = catNames{i};
    vals = categories.(c);
    for j = 1:numel(vals)
        paramNames(end+1, 1) = string(vals{j}); %#ok<AGROW>
        sourceCats(end+1, 1) = string(c); %#ok<AGROW>
    end
end
if isempty(paramNames)
    T = table(strings(0,1), strings(0,1), 'VariableNames', {'ParamName','SourceCategory'});
    return;
end
T = table(paramNames, sourceCats, 'VariableNames', {'ParamName','SourceCategory'});
T = unique(T, 'rows', 'stable');
end