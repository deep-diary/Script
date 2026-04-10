function result = findPortFromPortsInfo(portName, varargin)
%FINDPORTFROMPORTSINFO 根据 PortsInfo 表查询信号的输出与输入组件
%
% 语法:
%   result = findPortFromPortsInfo(portName)
%   result = findPortFromPortsInfo(portName, 'Name', Value, ...)
%
% 功能描述:
%   从 PortsInfo Excel 按端口名查询：输出该信号的组件（Output）与使用该信号的
%   输入组件（Input），并返回去重后的表。
%
% 输入参数:
%   portName - 待查信号名 (char/string, 标量)
%
% 可选参数（Name-Value）:
%   'excelFile'    - Excel 路径；默认与 FINDPORTCONNECTIONSIGNALS 相同策略
%   'sheet'        - sheet，默认 1
%   'componentCol' / 'directionCol' / 'portCol' - 列名映射
%   'matchMode'    - 'exact'|'contains'，默认 'exact'
%   'ignoreCase'   - 默认 true
%
% 输出参数:
%   result - 含 outputProviders, inputConsumers, allMatches, excelFile, queryPortName
%
% 参见: FINDCOMPONENTPORTSFROMPORTSINFO, FINDPORSINFOCONNECTION,
%        FINDDEFAULTPORTSINFOEXCELPATH, GETREPOROOT
%
% 作者: blue.ge(葛维冬@Smart)
% 版本: 1.4
% 日期: 2026-04-10
% 变更记录:
%   2026-04-10 v1.4 默认 Excel 解析委托 findDefaultPortsInfoExcelPath。
%   2026-04-10 v1.3 默认 Excel 解析委托 getDefaultPortsInfoExcelPath（已更名）。
%   2026-04-10 v1.2 参见补充 FINDCOMPONENTPORTSFROMPORTSINFO。
%   2026-04-10 v1.1 默认 Excel 查找与 findPorsInfoConnection 同步（artifacts 固定名与 *PortsInfo*.xlsx）。
%   2026-04-10 v1.0 由 query 前缀更名为 find，并统一默认 Excel 解析路径。

validateattributes(portName, {'char','string'}, {'scalartext'}, mfilename, 'portName');
portName = char(portName);

p = inputParser;
addParameter(p, 'excelFile', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'sheet', 1, @(x) ischar(x) || isstring(x) || isnumeric(x));
addParameter(p, 'componentCol', 'ComponentName', @(x) ischar(x) || isstring(x));
addParameter(p, 'directionCol', 'PortDirection', @(x) ischar(x) || isstring(x));
addParameter(p, 'portCol', 'PortName', @(x) ischar(x) || isstring(x));
addParameter(p, 'matchMode', 'exact', @(x) ismember(lower(string(x)), ["exact","contains"]));
addParameter(p, 'ignoreCase', true, @islogical);
parse(p, varargin{:});

excelFile = char(p.Results.excelFile);
sheetArg = p.Results.sheet;
componentCol = char(p.Results.componentCol);
directionCol = char(p.Results.directionCol);
portCol = char(p.Results.portCol);
matchMode = lower(char(p.Results.matchMode));
ignoreCase = p.Results.ignoreCase;

if isempty(excelFile)
    excelFile = findDefaultPortsInfoExcelPath('callerId', mfilename);
end
if ~isfile(excelFile)
    error('%s: Excel 文件不存在: %s', mfilename, excelFile);
end

opts = detectImportOptions(excelFile, 'NumHeaderLines', 0, 'Sheet', sheetArg);
T = readtable(excelFile, opts, 'Sheet', sheetArg);

needCols = {componentCol, directionCol, portCol};
for i = 1:numel(needCols)
    if ~ismember(needCols{i}, T.Properties.VariableNames)
        error('%s: Excel 缺少列 "%s"（sheet=%s）。', ...
            mfilename, needCols{i}, string(sheetArg));
    end
end

T.ComponentName = string(T.(componentCol));
T.PortDirection = string(T.(directionCol));
T.PortName = string(T.(portCol));

q = string(portName);
src = T.PortName;
if ignoreCase
    q = lower(q);
    src = lower(src);
end

switch matchMode
    case 'exact'
        mask = (src == q);
    case 'contains'
        mask = contains(src, q);
    otherwise
        error('%s: 不支持的 matchMode: %s', mfilename, matchMode);
end

M = T(mask, :);
providers = M(strcmpi(M.PortDirection, "Output"), :);
consumers = M(strcmpi(M.PortDirection, "Input"), :);
providers = unique(providers(:, {'ComponentName','PortDirection','PortName'}), 'rows');
consumers = unique(consumers(:, {'ComponentName','PortDirection','PortName'}), 'rows');

result = struct();
result.outputProviders = providers;
result.inputConsumers = consumers;
result.allMatches = M;
result.excelFile = excelFile;
result.queryPortName = portName;

fprintf('Excel: %s\n', excelFile);
fprintf('Query: %s (matchMode=%s, ignoreCase=%d)\n', portName, matchMode, ignoreCase);
fprintf('Output providers: %d\n', height(providers));
fprintf('Input consumers : %d\n', height(consumers));
if height(providers) > 0
    fprintf('--- 输出组件(Output) ---\n');
    disp(providers(:, {'ComponentName','PortName'}));
end
if height(consumers) > 0
    fprintf('--- 输入组件(Input) ---\n');
    disp(consumers(:, {'ComponentName','PortName'}));
end

end
