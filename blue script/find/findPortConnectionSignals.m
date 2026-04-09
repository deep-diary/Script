function result = findPortConnectionSignals(varargin)
%% 【函数】基于 PortsInfo 表检查组件连线并输出三类信号
%
% 输入（可选参数）:
%   'excelFile'  - PortsInfo Excel 路径
%                  默认: 当前目录下最新的 *_PortsInfo_*.xlsx
%   'sheet'      - 读取的 sheet 名称或序号（默认：1，即第一个 sheet）
%   'componentCol'  - 组件列名（默认：'ComponentName'）
%   'directionCol'  - 端口方向列名（默认：'PortDirection'）
%   'portCol'       - 信号名列名（默认：'PortName'）
%   'ignoreCase' - 信号名比较是否忽略大小写，默认 true
%
% 输出 result 结构体:
%   result.allOutputSignals   - 所有输出信号名称（去重、按字母排序）
%   result.usedOutputSignals  - 被其它组件作为输入使用的输出信号（去重、按字母排序）
%   result.unusedOutputSignals- 未被任何组件使用的输出信号（去重、按字母排序）
%   result.excelFile          - 实际使用的 Excel 路径
%
% 示例:
%   R = findPortConnectionSignals('excelFile', 'CCM_Internal_swc_PortsInfo_20260409_114208.xlsx');

p = inputParser;
addParameter(p, 'excelFile', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'sheet', 1, @(x) ischar(x) || isstring(x) || isnumeric(x));
addParameter(p, 'componentCol', 'ComponentName', @(x) ischar(x) || isstring(x));
addParameter(p, 'directionCol', 'PortDirection', @(x) ischar(x) || isstring(x));
addParameter(p, 'portCol', 'PortName', @(x) ischar(x) || isstring(x));
addParameter(p, 'ignoreCase', true, @islogical);
parse(p, varargin{:});

excelFile = char(p.Results.excelFile);
sheetArg = p.Results.sheet;
componentCol = char(p.Results.componentCol);
directionCol = char(p.Results.directionCol);
portCol = char(p.Results.portCol);
ignoreCase = p.Results.ignoreCase;

if isempty(excelFile)
    excelFile = i_findLatestPortsInfoExcel(pwd);
end
if ~isfile(excelFile)
    error('%s: Excel 文件不存在: %s', mfilename, excelFile);
end

opts = detectImportOptions(excelFile, 'NumHeaderLines', 0, 'Sheet', sheetArg);
T = readtable(excelFile, opts, 'Sheet', sheetArg);

requiredCols = {componentCol, directionCol, portCol};
for i = 1:numel(requiredCols)
    if ~ismember(requiredCols{i}, T.Properties.VariableNames)
        error('%s: Excel 缺少列 "%s"（sheet=%s）。实际列: %s', ...
            mfilename, requiredCols{i}, string(sheetArg), strjoin(T.Properties.VariableNames, ', '));
    end
end

T.ComponentName = string(T.(componentCol));
T.PortDirection = string(T.(directionCol));
T.PortName = string(T.(portCol));

% 基础集合
outRows = T(strcmpi(T.PortDirection, "Output"), :);
inRows  = T(strcmpi(T.PortDirection, "Input"), :);

allOutputs = unique(outRows.PortName);
allOutputs = i_sortStringsIgnoreCase(allOutputs);

if ignoreCase
    outKey = lower(string(outRows.PortName));
    inKey  = lower(string(inRows.PortName));
    usedKey = unique(intersect(outKey, inKey));

    allKey = lower(allOutputs);
    usedMask = ismember(allKey, usedKey);
    usedOutputs = allOutputs(usedMask);
else
    usedOutputs = unique(intersect(outRows.PortName, inRows.PortName));
    usedOutputs = i_sortStringsIgnoreCase(usedOutputs);
end

unusedOutputs = setdiff(allOutputs, usedOutputs);
unusedOutputs = i_sortStringsIgnoreCase(unusedOutputs);

result = struct();
result.allOutputSignals = allOutputs;
result.usedOutputSignals = usedOutputs;
result.unusedOutputSignals = unusedOutputs;
result.excelFile = excelFile;

fprintf('Excel: %s\n', excelFile);
fprintf('All output signals   : %d\n', numel(allOutputs));
fprintf('Used output signals  : %d\n', numel(usedOutputs));
fprintf('Unused output signals: %d\n', numel(unusedOutputs));

end

function arr = i_sortStringsIgnoreCase(arr)
arr = string(arr);
if isempty(arr)
    return;
end
[~, idx] = sort(lower(arr));
arr = arr(idx);
end

function f = i_findLatestPortsInfoExcel(folderPath)
pat = fullfile(folderPath, '*_PortsInfo_*.xlsx');
files = dir(pat);
if isempty(files)
    error('%s: 未在目录中找到匹配文件: %s', mfilename, pat);
end
[~, idx] = max([files.datenum]);
f = fullfile(files(idx).folder, files(idx).name);
end

