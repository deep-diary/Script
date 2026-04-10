function result = findPortConnectionSignals(varargin)
%FINDPORTCONNECTIONSIGNALS 统计输出信号是否被其它组件使用
%
% 语法:
%   result = findPortConnectionSignals()
%   result = findPortConnectionSignals('Name', Value, ...)
%
% 功能描述:
%   读取 PortsInfo Excel，输出三类输出侧信号名称（去重、按字母排序）：
%   1) 所有输出信号；
%   2) 被其它组件作为输入使用的输出信号（存在输入组件与输出组件不同）；
%   3) 未被其它组件使用的输出信号。
%
% 可选参数（Name-Value）:
%   'excelFile'    - PortsInfo Excel 路径 (char/string)
%                    默认: <repo>/data/ccm/CCM_Internal_swc_PortsInfo.xlsx；
%                    若不存在则取 <repo>/artifacts 下最新 *_PortsInfo_*.xlsx；
%                    再不行则取当前目录下最新 *_PortsInfo_*.xlsx
%   'sheet'        - sheet 名称或序号，默认: 1
%   'componentCol' - 组件列名，默认: 'ComponentName'
%   'directionCol' - 方向列名，默认: 'PortDirection'
%   'portCol'      - 信号列名，默认: 'PortName'
%   'ignoreCase'   - 匹配是否忽略大小写，默认: true
%
% 输出参数:
%   result - 结构体，含 allOutputSignals / usedOutputSignals / unusedOutputSignals / excelFile
%
% 异常与边界行为:
%   - 找不到 Excel 或缺少列时 error。
%
% 示例:
%   R = findPortConnectionSignals();
%   R = findPortConnectionSignals('excelFile', 'CCM_Internal_swc_PortsInfo.xlsx', 'sheet', 1);
%
% 参见: FINDPORTFROMPORTSINFO, GETREPOROOT
%
% 作者: blue.ge(葛维冬@Smart)
% 版本: 1.1
% 日期: 2026-04-10
% 变更记录:
%   2026-04-10 v1.1 目录重构后默认路径与“其它组件使用”判定逻辑。
%   2026-04-09 v1.0 初版。

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
    excelFile = i_getDefaultPortsInfoExcel();
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

outRows = T(strcmpi(T.PortDirection, "Output"), :);
inRows  = T(strcmpi(T.PortDirection, "Input"), :);

allOutputs = unique(outRows.PortName);
allOutputs = i_sortStringsIgnoreCase(allOutputs);

usedSignals = strings(0, 1);
for i = 1:numel(allOutputs)
    sig = allOutputs(i);
    if ignoreCase
        outMask = lower(outRows.PortName) == lower(sig);
        inMask  = lower(inRows.PortName) == lower(sig);
    else
        outMask = outRows.PortName == sig;
        inMask  = inRows.PortName == sig;
    end

    sigOutComps = unique(string(outRows.ComponentName(outMask)));
    sigInComps  = unique(string(inRows.ComponentName(inMask)));

    isUsedByOtherComp = false;
    for io = 1:numel(sigOutComps)
        thisOut = sigOutComps(io);
        if any(sigInComps ~= thisOut)
            isUsedByOtherComp = true;
            break;
        end
    end

    if isUsedByOtherComp
        usedSignals(end+1, 1) = sig; %#ok<AGROW>
    end
end

usedOutputs = unique(usedSignals);
usedOutputs = i_sortStringsIgnoreCase(usedOutputs);
unusedOutputs = setdiff(allOutputs, usedOutputs, 'stable');
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

function f = i_getDefaultPortsInfoExcel()
repoRoot = getRepoRoot();
fixedFile = fullfile(repoRoot, 'data', 'ccm', 'CCM_Internal_swc_PortsInfo.xlsx');
if isfile(fixedFile)
    f = fixedFile;
    return;
end

pat = fullfile(repoRoot, 'artifacts', '*_PortsInfo_*.xlsx');
files = dir(pat);
if ~isempty(files)
    [~, idx] = max([files.datenum]);
    f = fullfile(files(idx).folder, files(idx).name);
    return;
end

pat = fullfile(pwd, '*_PortsInfo_*.xlsx');
files = dir(pat);
if ~isempty(files)
    [~, idx] = max([files.datenum]);
    f = fullfile(files(idx).folder, files(idx).name);
    return;
end

error('%s: 未找到默认 PortsInfo 文件，请传入 ''excelFile''。', mfilename);
end
