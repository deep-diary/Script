function g = findPortsInfoToGjson(varargin)
%FINDPORTSINFOTOGJSON 基于 PortsInfo Excel 生成组件连线 gjson 文件
%
% 语法:
%   g = findPortsInfoToGjson()
%   g = findPortsInfoToGjson('Name', Value, ...)
%
% 功能描述:
%   本函数读取包含组件端口信息的 Excel，按“输出组件 -> 输入组件”的信号关系
%   生成 gjson 图数据，便于图谱可视化或后续 GUI 使用。输出结构包含 categories、
%   nodes、edges 三部分，其中 categories 当前固定为 component(组件)。
%
% 输入参数（Name-Value）:
%   'excelFile'    - PortsInfo Excel 路径 (char/string)
%                    默认: <repo>/data/ccm/CCM_Internal_swc_PortsInfo.xlsx；
%                    其次 <repo>/artifacts/CCM_Internal_swc_PortsInfo.xlsx；
%                    再取 artifacts/pwd 下按修改时间最新的 *PortsInfo*.xlsx
%   'outputFile'   - 输出 gjson 文件路径 (char/string)
%                    默认: 与 Excel 同目录同名 .gjson
%   'sheet'        - 读取的 sheet 名称或序号 (char/string/numeric)
%                    默认: 1 (第一个 sheet)
%   'componentCol' - 组件列名 (char/string)
%                    默认: 'ComponentName'
%   'directionCol' - 端口方向列名 (char/string)
%                    默认: 'PortDirection'
%   'portCol'      - 信号名称列名 (char/string)
%                    默认: 'PortName'
%   'ignoreCase'   - 信号匹配时是否忽略大小写 (logical)
%                    默认: true
%   'PrettyPrint'  - 写入 .gjson 时是否尽量使用缩进换行 (logical)
%                    默认: true（R2021a+ 支持 jsonencode PrettyPrint；否则自动回退为紧凑 JSON）
%
% 输出参数:
%   g              - 结果结构体，字段包括:
%                    g.categories         - 图类别（component）
%                    g.data.nodes         - 节点数组
%                    g.data.edges         - 连线数组
%                    g.paths.excelFile    - Excel 绝对路径（若可解析）
%                    g.paths.outputFile   - 输出 .gjson 绝对路径（若可解析）
%                    g.options            - 本次调用选项快照（sheet、列名、ignoreCase、prettyPrint 等）
%                    g.stats              - nodeCount / edgeCount / matchedSignals
%                    g.summaryText        - 可直接用于 UI 日志展示的摘要文本
%
%   写入磁盘的 .gjson 仅包含 categories 与 data，便于可视化工具消费；路径与统计仅在返回结构体中。
%
% 异常与边界行为:
%   - Excel 文件不存在时抛出 error。
%   - 指定 sheet 或列名不存在时抛出 error。
%   - 若不存在可连接信号，edges 返回空结构数组。
%   - 同组件自环连线会被自动跳过。
%
% 示例:
%   % 示例1：使用默认配置（自动选择最新 PortsInfo Excel）
%   g = findPortsInfoToGjson();
%
%   % 示例2：指定 Excel、sheet 与列名映射
%   g = findPortsInfoToGjson( ...
%       'excelFile', 'CCM_Internal_swc_PortsInfo_20260409_114208.xlsx', ...
%       'sheet', 'Ports', ...
%       'componentCol', 'ComponentName', ...
%       'directionCol', 'PortDirection', ...
%       'portCol', 'PortName');
%
% 参见: READTABLE, DETECTIMPORTOPTIONS, JSONENCODE, FINDDEFAULTPORTSINFOEXCELPATH
%
% 作者: blue.ge(葛维冬@Smart)
% 版本: 1.6
% 日期: 2026-04-17
% 变更记录:
%   2026-04-17 v1.6  新增 summaryText，便于 GUI 日志直接显示生成结果摘要。
%   2026-04-17 v1.5  写入 JSON 支持 PrettyPrint（若版本支持）；返回 paths/options/stats；文件内容仍为纯图数据。
%   2026-04-10 v1.4  默认 Excel 解析委托 findDefaultPortsInfoExcelPath。
%   2026-04-10 v1.3  默认 Excel 解析委托 getDefaultPortsInfoExcelPath（已更名）。
%   2026-04-10 v1.2  默认 Excel：支持 artifacts 下 CCM_Internal_swc_PortsInfo.xlsx 与 *PortsInfo*.xlsx（与 exportPorts 命名一致）。
%   2026-04-09 v1.1  按项目规则补齐官方风格注释结构。
%   2026-04-09 v1.0  初版实现 Excel 到 gjson 的转换。

p = inputParser;
addParameter(p, 'excelFile', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'outputFile', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'sheet', 1, @(x) ischar(x) || isstring(x) || isnumeric(x));
addParameter(p, 'componentCol', 'ComponentName', @(x) ischar(x) || isstring(x));
addParameter(p, 'directionCol', 'PortDirection', @(x) ischar(x) || isstring(x));
addParameter(p, 'portCol', 'PortName', @(x) ischar(x) || isstring(x));
addParameter(p, 'ignoreCase', true, @islogical);
addParameter(p, 'PrettyPrint', true, @islogical);
parse(p, varargin{:});

excelFile = char(p.Results.excelFile);
outputFile = char(p.Results.outputFile);
sheetArg = p.Results.sheet;
componentCol = char(p.Results.componentCol);
directionCol = char(p.Results.directionCol);
portCol = char(p.Results.portCol);
ignoreCase = p.Results.ignoreCase;
wantPretty = p.Results.PrettyPrint;

if isempty(excelFile)
    excelFile = findDefaultPortsInfoExcelPath('callerId', mfilename);
end
if ~isfile(excelFile)
    error('%s: Excel 文件不存在: %s', mfilename, excelFile);
end

if isempty(outputFile)
    [fdir, fbase, ~] = fileparts(excelFile);
    outputFile = fullfile(fdir, [fbase '.gjson']);
end

opts = detectImportOptions(excelFile, 'NumHeaderLines', 0, 'Sheet', sheetArg);
T = readtable(excelFile, opts, 'Sheet', sheetArg);

requiredCols = {componentCol, directionCol, portCol};
for i = 1:numel(requiredCols)
    if ~ismember(requiredCols{i}, T.Properties.VariableNames)
        error('%s: Excel 缺少列 "%s"（sheet=%s）。', ...
            mfilename, requiredCols{i}, string(sheetArg));
    end
end

T.ComponentName = string(T.(componentCol));
T.PortDirection = string(T.(directionCol));
T.PortName = string(T.(portCol));

% 节点：所有组件（按字母排序）
components = unique(T.ComponentName);
[~, idxComp] = sort(lower(components));
components = components(idxComp);

nodes = repmat(struct('id', '', 'label', '', 'categories', {{}}), numel(components), 1);
comp2id = containers.Map('KeyType', 'char', 'ValueType', 'char');
for i = 1:numel(components)
    idStr = char(string(i));
    name = char(components(i));
    nodes(i).id = idStr;
    nodes(i).label = name;
    nodes(i).categories = {'component'};
    comp2id(name) = idStr;
end

% 端口映射
outRows = T(strcmpi(T.PortDirection, "Output"), :);
inRows  = T(strcmpi(T.PortDirection, "Input"), :);

if ignoreCase
    outKey = lower(outRows.PortName);
    inKey  = lower(inRows.PortName);
else
    outKey = outRows.PortName;
    inKey  = inRows.PortName;
end

sigKeys = intersect(unique(outKey), unique(inKey));
edgeTriples = strings(0, 3); % [fromId,toId,signal]

for i = 1:numel(sigKeys)
    key = sigKeys(i);
    if ignoreCase
        outMask = lower(outRows.PortName) == key;
        inMask  = lower(inRows.PortName) == key;
    else
        outMask = outRows.PortName == key;
        inMask  = inRows.PortName == key;
    end

    outComps = unique(outRows.ComponentName(outMask));
    inComps  = unique(inRows.ComponentName(inMask));

    % label 保留端口原名（优先输出侧第一个）
    sigLabel = char(outRows.PortName(find(outMask, 1, 'first')));

    for io = 1:numel(outComps)
        fromComp = char(outComps(io));
        if ~isKey(comp2id, fromComp), continue; end
        fromId = string(comp2id(fromComp));

        for ii = 1:numel(inComps)
            toComp = char(inComps(ii));
            if ~isKey(comp2id, toComp), continue; end
            if strcmp(fromComp, toComp)
                continue; % 跳过同组件自环
            end
            toId = string(comp2id(toComp));
            edgeTriples(end+1, :) = [fromId, toId, string(sigLabel)]; %#ok<AGROW>
        end
    end
end

if isempty(edgeTriples)
    edges = struct('from', {}, 'to', {}, 'label', {});
else
    [~, ia] = unique(edgeTriples, 'rows', 'stable');
    edgeTriples = edgeTriples(sort(ia), :);
    edges = repmat(struct('from', '', 'to', '', 'label', ''), size(edgeTriples, 1), 1);
    for i = 1:size(edgeTriples, 1)
        edges(i).from = char(edgeTriples(i, 1));
        edges(i).to = char(edgeTriples(i, 2));
        edges(i).label = char(edgeTriples(i, 3));
    end
end

g = struct();
g.categories = struct('component', '组件');
g.data = struct('nodes', {nodes}, 'edges', {edges});
g.paths = struct('excelFile', i_canonicalPath(excelFile), 'outputFile', i_canonicalPath(outputFile));
g.options = struct( ...
    'sheet', sheetArg, ...
    'componentCol', componentCol, ...
    'directionCol', directionCol, ...
    'portCol', portCol, ...
    'ignoreCase', ignoreCase, ...
    'prettyPrintRequested', wantPretty, ...
    'prettyPrintApplied', false);
g.stats = struct('nodeCount', numel(nodes), 'edgeCount', numel(edges), 'matchedSignals', numel(sigKeys));

payload = struct('categories', g.categories, 'data', g.data);
jsonText = i_jsonEncodePayload(payload, wantPretty);
g.options.prettyPrintApplied = i_jsonPrettyPrintWasApplied(jsonText, wantPretty);
if wantPretty && ~g.options.prettyPrintApplied
    warning('%s: 未能生成格式化 JSON（当前版本可能不支持 jsonencode PrettyPrint），已输出紧凑 JSON。', mfilename);
end

fid = fopen(outputFile, 'w');
if fid < 0
    error('%s: 无法写入文件: %s', mfilename, outputFile);
end
cleanupObj = onCleanup(@() fclose(fid));
fwrite(fid, jsonText, 'char');
clear cleanupObj;

g.paths.outputFile = i_canonicalPath(outputFile);
g.summaryText = i_buildSummaryText(g);

fprintf('gjson 已生成: %s\n', g.paths.outputFile);
fprintf('nodes=%d, edges=%d\n', g.stats.nodeCount, g.stats.edgeCount);

end

function jsonText = i_jsonEncodePayload(payload, wantPretty)
jsonText = '';
if wantPretty
    try
        jsonText = jsonencode(payload, 'PrettyPrint', true);
    catch
        jsonText = '';
    end
end
if isempty(jsonText)
    jsonText = jsonencode(payload);
end
end

function tf = i_jsonPrettyPrintWasApplied(jsonText, wantPretty)
tf = false;
if ~wantPretty || isempty(jsonText)
    return;
end
tf = contains(jsonText, newline) || contains(jsonText, sprintf('\r\n'));
end

function p = i_canonicalPath(p)
p = char(strtrim(string(p)));
if isempty(p)
    return;
end
[ok, info] = fileattrib(p);
if ok
    p = char(info.Name);
end
end

function txt = i_buildSummaryText(g)
sheetStr = char(string(g.options.sheet));
txt = '';
txt = [txt '[findPortsInfoToGjson] 生成完成' newline];
txt = [txt sprintf('输入Excel: %s', g.paths.excelFile) newline];
txt = [txt sprintf('输出GJSON: %s', g.paths.outputFile) newline];
txt = [txt sprintf('Sheet: %s | 组件列: %s | 方向列: %s | 端口列: %s', ...
    sheetStr, g.options.componentCol, g.options.directionCol, g.options.portCol) newline];
txt = [txt sprintf('节点数: %d | 连线数: %d | 匹配信号数: %d', ...
    g.stats.nodeCount, g.stats.edgeCount, g.stats.matchedSignals) newline];
txt = [txt sprintf('IgnoreCase: %s | PrettyPrint: 请求=%s, 生效=%s', ...
    mat2str(g.options.ignoreCase), ...
    mat2str(g.options.prettyPrintRequested), ...
    mat2str(g.options.prettyPrintApplied))];
end
