function result = queryPortFromPortsInfo(portName, varargin)
%% 【函数】根据 PortsInfo Excel 查询信号的输出组件与输入组件
%
% 背景：PortsInfo 表包含 3 列：
%   - ComponentName
%   - PortDirection （'Input' / 'Output'）
%   - PortName
%
% 用法：
%   R = queryPortFromPortsInfo('SunData_SunData', ...
%       'excelFile', 'CCM_Internal_swc_PortsInfo_20260409_114208.xlsx')
%
% 可选参数：
%   'excelFile'  - PortsInfo Excel 文件路径（默认：当前目录下最新的 *_PortsInfo_*.xlsx）
%   'matchMode'  - 'exact'(默认) | 'contains'
%   'ignoreCase' - true/false（默认 true）
%
% 输出 result 结构体：
%   result.outputProviders : table（PortDirection='Output' 的组件）
%   result.inputConsumers  : table（PortDirection='Input' 的组件）
%   result.allMatches      : table（所有匹配行）
%

validateattributes(portName, {'char','string'}, {'scalartext'}, mfilename, 'portName');
portName = char(portName);

p = inputParser;
addParameter(p, 'excelFile', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'matchMode', 'exact', @(x) ismember(lower(string(x)), ["exact","contains"]));
addParameter(p, 'ignoreCase', true, @islogical);
parse(p, varargin{:});

excelFile  = char(p.Results.excelFile);
matchMode  = lower(char(p.Results.matchMode));
ignoreCase = p.Results.ignoreCase;

if isempty(excelFile)
    excelFile = i_findLatestPortsInfoExcel(pwd);
end

if ~isfile(excelFile)
    error('%s: Excel 文件不存在: %s', mfilename, excelFile);
end

opts = detectImportOptions(excelFile, 'NumHeaderLines', 0);
T = readtable(excelFile, opts);

needCols = {'ComponentName','PortDirection','PortName'};
for i = 1:numel(needCols)
    if ~ismember(needCols{i}, T.Properties.VariableNames)
        error('%s: Excel 缺少列 "%s"。实际列为: %s', ...
            mfilename, needCols{i}, strjoin(T.Properties.VariableNames, ', '));
    end
end

% 统一为 string，方便匹配与筛选
T.ComponentName  = string(T.ComponentName);
T.PortDirection  = string(T.PortDirection);
T.PortName       = string(T.PortName);

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

% 去重（同一组件重复出现时）
providers = unique(providers(:, {'ComponentName','PortDirection','PortName'}), 'rows');
consumers = unique(consumers(:, {'ComponentName','PortDirection','PortName'}), 'rows');

result = struct();
result.outputProviders = providers;
result.inputConsumers  = consumers;
result.allMatches      = M;
result.excelFile       = excelFile;
result.queryPortName   = portName;

% 友好输出
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

function f = i_findLatestPortsInfoExcel(folderPath)
% 在指定目录下找最新的 *_PortsInfo_*.xlsx
pat = fullfile(folderPath, '*_PortsInfo_*.xlsx');
files = dir(pat);
if isempty(files)
    error('%s: 未在目录中找到匹配文件: %s', mfilename, pat);
end

[~, idx] = max([files.datenum]);
f = fullfile(files(idx).folder, files(idx).name);
end

