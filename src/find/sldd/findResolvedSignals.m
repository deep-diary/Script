function result = findResolvedSignals(pathMd, varargin)
%FINDRESOLVEDSIGNALS 查找“必须解析到信号对象”的信号并返回结构化结果
%
% 语法:
%   result = findResolvedSignals(pathMd)
%   result = findResolvedSignals(pathMd, 'Name', Value, ...)
%
% 功能描述:
%   在指定模型/子系统范围内遍历 Line，筛选 MustResolveToSignalObject=on 的信号。
%   为避免分叉线导致同名信号返回多个句柄，本函数按“信号名去重”，每个解析信号只保留
%   一个代表句柄（首个命中，stable）。可选并入 Data Store Write 的 DataStoreName，
%   便于后续统一按可观测全局变量分析。
%
% 输入参数:
%   pathMd - 模型路径、块路径或句柄 (char/string/double)
%
% 可选参数（Name-Value）:
%   'IncludeDataStoreWrite' - 是否包含 Data Store Write 的 DataStoreName (logical)
%                             默认: false
%   'IncludeDescendants'    - 是否包含当前层以下所有层级 (logical)
%                             默认: true
%   'DisplaySignals'        - 是否在命令行打印 allSignalNames (logical)
%                             默认: true
%
% 输出参数:
%   result - 结构体，字段:
%            pathMd                - 实际输入路径（char）
%            lineHandlesRaw        - 命中的原始线句柄（可能含同名分叉）
%            signalHandles         - 去重后“每个信号一个代表句柄”
%            resolvedSignalNames   - 与 signalHandles 对齐的信号名（string 列向量）
%            dataStoreWriteNames   - Data Store Write 名称（string 列向量）
%            allSignalNames        - resolvedSignalNames 与 dataStoreWriteNames 合并去重
%            includeDescendants    - 本次是否包含子层
%            includeDataStoreWrite - 本次是否包含 Data Store Write
%
% 异常与边界行为:
%   - pathMd 非法时 error。
%   - 线无 Name 时不纳入“去重后信号映射”，但仍保留在 lineHandlesRaw。
%
% 示例:
%   % 示例1：默认扫描
%   R = findResolvedSignals(gcs);
%
%   % 示例2：仅当前层，且包含 Data Store Write
%   R = findResolvedSignals(gcs, ...
%       'IncludeDescendants', false, ...
%       'IncludeDataStoreWrite', true, ...
%       'DisplaySignals', false);
%
% 参见: FIND_SYSTEM, GET_PARAM
%
% 作者: blue.ge(葛维冬@Smart)
% 版本: 2.0
% 日期: 2026-04-10
% 变更记录:
%   2026-04-10 v2.0 返回结构体；同名解析信号仅保留一个代表句柄；同步输出 allSignalNames。
%   2026-04-10 v1.2 新增 IncludeDescendants 参数，支持“仅当前层/包含子层”范围控制。
%   2026-04-10 v1.1 增加去重、信号名返回与 Data Store Write 可选并入能力。
%   2023-10-31 v1.0 初版。

p = inputParser;
addRequired(p, 'pathMd', @(x) validateattributes(x, {'char','string','double'}, {'nonempty'}));
addParameter(p, 'IncludeDataStoreWrite', false, @islogical);
addParameter(p, 'IncludeDescendants', true, @islogical);
addParameter(p, 'DisplaySignals', true, @islogical);
parse(p, pathMd, varargin{:});

pathMd = char(string(p.Results.pathMd));
includeDataStoreWrite = p.Results.IncludeDataStoreWrite;
includeDescendants = p.Results.IncludeDescendants;
displaySignals = p.Results.DisplaySignals;

if includeDescendants
    lines = find_system(pathMd, 'FindAll', 'on', 'Type', 'Line');
else
    lines = i_findCurrentLevelLines(pathMd);
end

lineHandlesRaw = zeros(1, 0);
namedHandlesRaw = zeros(1, 0);
namedSignalsRaw = strings(0, 1);
dataStoreWriteNames = strings(0, 1);

for i = 1:length(lines)
    h = lines(i);
    try
        if ~get(h).MustResolveToSignalObject
            continue;
        end
    catch
        continue;
    end

    lineHandlesRaw(end+1) = h; %#ok<AGROW>
    try
        n = string(get(h).Name);
        if strlength(strtrim(n)) > 0
            namedHandlesRaw(end+1) = h; %#ok<AGROW>
            namedSignalsRaw(end+1, 1) = n; %#ok<AGROW>
        end
    catch
    end
end

% 对“解析信号名”去重，并保留首个句柄作为代表句柄（解决分叉线多句柄问题）
[resolvedSignalNames, firstIdx] = unique(namedSignalsRaw, 'stable');
signalHandles = namedHandlesRaw(firstIdx);
lineHandlesRaw = unique(lineHandlesRaw, 'stable');

if includeDataStoreWrite
    if includeDescendants
        dswBlocks = find_system(pathMd, ...
            'LookUnderMasks', 'all', ...
            'FollowLinks', 'on', ...
            'BlockType', 'DataStoreWrite');
    else
        dswBlocks = find_system(pathMd, ...
            'SearchDepth', 1, ...
            'LookUnderMasks', 'all', ...
            'FollowLinks', 'on', ...
            'BlockType', 'DataStoreWrite');
        dswBlocks = setdiff(dswBlocks, {char(string(pathMd))}, 'stable');
    end
    for i = 1:numel(dswBlocks)
        try
            dsName = string(get_param(dswBlocks{i}, 'DataStoreName'));
            if strlength(strtrim(dsName)) > 0
                dataStoreWriteNames(end+1, 1) = dsName; %#ok<AGROW>
            end
        catch
        end
    end
    dataStoreWriteNames = unique(dataStoreWriteNames, 'stable');
end

allSignalNames = unique([resolvedSignalNames; dataStoreWriteNames], 'stable');

if displaySignals
    for i = 1:numel(allSignalNames)
        disp(allSignalNames(i));
    end
end

result = struct();
result.pathMd = pathMd;
result.lineHandlesRaw = lineHandlesRaw;
result.signalHandles = signalHandles;
result.resolvedSignalNames = resolvedSignalNames;
result.dataStoreWriteNames = dataStoreWriteNames;
result.allSignalNames = allSignalNames;
result.includeDescendants = includeDescendants;
result.includeDataStoreWrite = includeDataStoreWrite;

end

function lines = i_findCurrentLevelLines(pathMd)
% 仅取当前层级的线：通过当前层 block 的 LineHandles 汇总
lines = zeros(1, 0);
try
    blocks = find_system(pathMd, 'SearchDepth', 1, 'Type', 'Block');
    blocks = setdiff(blocks, {char(string(pathMd))}, 'stable');
catch
    lines = find_system(pathMd, 'FindAll', 'on', 'Type', 'Line');
    return;
end

for i = 1:numel(blocks)
    try
        lh = get_param(blocks{i}, 'LineHandles');
    catch
        continue;
    end
    lines = [lines, i_collectLineHandles(lh)]; %#ok<AGROW>
end
lines = lines(lines ~= -1);
lines = unique(lines, 'stable');
end

function arr = i_collectLineHandles(lh)
arr = zeros(1, 0);
fn = fieldnames(lh);
for k = 1:numel(fn)
    v = lh.(fn{k});
    if isnumeric(v) && ~isempty(v)
        arr = [arr, v(:)']; %#ok<AGROW>
    end
end
end
