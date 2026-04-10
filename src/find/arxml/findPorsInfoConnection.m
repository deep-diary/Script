function result = findPorsInfoConnection(varargin)
%FINDPORSINFOCONNECTION 基于 PortsInfo 表统计输入/输出信号连接与组件清单
%
% 语法:
%   result = findPorsInfoConnection()
%   result = findPorsInfoConnection('Name', Value, ...)
%
% 功能描述:
%   读取 PortsInfo Excel，输出输入/输出信号及连接统计（去重、按字母排序）：
%   1) 所有输出信号；
%   2) 被其它组件作为输入使用的输出信号（存在输入组件与输出组件不同）；
%   3) 仅输出信号（有 Output、无任何 Input，对应 outputOnlySignals）。
%   另外输出“仅输入信号”（存在 Input 但不存在对应 Output 的信号）。
%   同时返回 PortsInfo 表内去重后的组件名称清单（按字母排序），便于快速浏览模型架构。
%
% 可选参数（Name-Value）:
%   'excelFile'    - PortsInfo Excel 路径 (char/string)
%                    默认: <repo>/data/ccm/CCM_Internal_swc_PortsInfo.xlsx；
%                    其次 <repo>/artifacts/CCM_Internal_swc_PortsInfo.xlsx；
%                    再取 artifacts/pwd 下按修改时间最新的 *PortsInfo*.xlsx
%   'sheet'        - sheet 名称或序号，默认: 1
%   'componentCol' - 组件列名，默认: 'ComponentName'
%   'directionCol' - 方向列名，默认: 'PortDirection'
%   'portCol'      - 信号列名，默认: 'PortName'
%   'ignoreCase'   - 匹配是否忽略大小写，默认: true
%
% 输出参数:
%   result - 结构体，字段:
%            allComponents     - Excel 中去重后的组件名称（string 数组）
%            allISignals       - 输入与输出信号合并去重后的全集（string 数组）
%            allInputSignals   - 所有输入信号（string 数组）
%            allOutputSignals  - 所有输出信号（string 数组）
%            usedInputSignals  - 有对应 Output 的输入信号（string 数组）
%            usedOutputSignals - 被其它组件使用的输出信号（string 数组）
%            outputOnlySignals - 仅在 Output 侧出现、无对应 Input 的信号（string 数组）
%            inputOnlySignals  - 仅在 Input 侧出现、无对应 Output 的信号（string 数组）
%            excelFile         - 实际使用的 Excel 路径
%
% 异常与边界行为:
%   - 找不到 Excel 或缺少列时 error。
%
% 示例:
%   R = findPorsInfoConnection();
%   R = findPorsInfoConnection('excelFile', 'CCM_Internal_swc_PortsInfo.xlsx', 'sheet', 1);
%
% 参见: FINDPORTFROMPORTSINFO, FINDCOMPONENTPORTSFROMPORTSINFO, ...
%       FINDDEFAULTPORTSINFOEXCELPATH, GETREPOROOT
%
% 作者: blue.ge(葛维冬@Smart)
% 版本: 1.3
% 日期: 2026-04-10
% 变更记录:
%   2026-04-10 v1.3 新增 allISignals（输入+输出合并去重后的全集）。
%   2026-04-10 v1.2 输出字段扩展为 allInputSignals/usedInputSignals/outputOnlySignals。
%   2026-04-10 v1.1 新增 inputOnlySignals（有 Input、无 Output）。
%   2026-04-10 v1.0 由 findPortConnectionSignals 更名，并新增 allComponents 输出。

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
    excelFile = findDefaultPortsInfoExcelPath('callerId', mfilename);
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

allComponents = unique(T.ComponentName);
allComponents = i_sortStringsIgnoreCase(allComponents);

outRows = T(strcmpi(T.PortDirection, "Output"), :);
inRows  = T(strcmpi(T.PortDirection, "Input"), :);

allOutputs = unique(outRows.PortName);
allOutputs = i_sortStringsIgnoreCase(allOutputs);
allInputs = unique(inRows.PortName);
allInputs = i_sortStringsIgnoreCase(allInputs);
allISignals = unique([allInputs; allOutputs]);
allISignals = i_sortStringsIgnoreCase(allISignals);

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
if ignoreCase
    usedInputs = allInputs(ismember(lower(allInputs), lower(allOutputs)));
    outputOnlySignals = allOutputs(~ismember(lower(allOutputs), lower(allInputs)));
    inputOnlySignals = allInputs(~ismember(lower(allInputs), lower(allOutputs)));
else
    usedInputs = intersect(allInputs, allOutputs, 'stable');
    outputOnlySignals = setdiff(allOutputs, allInputs, 'stable');
    inputOnlySignals = setdiff(allInputs, allOutputs, 'stable');
end
usedInputs = i_sortStringsIgnoreCase(usedInputs);
outputOnlySignals = i_sortStringsIgnoreCase(outputOnlySignals);
inputOnlySignals = i_sortStringsIgnoreCase(inputOnlySignals);

result = struct();
result.allComponents = allComponents;
result.allISignals = allISignals;
result.allInputSignals = allInputs;
result.allOutputSignals = allOutputs;
result.usedInputSignals = usedInputs;
result.usedOutputSignals = usedOutputs;
result.outputOnlySignals = outputOnlySignals;
result.inputOnlySignals = inputOnlySignals;
result.excelFile = excelFile;

fprintf('Excel: %s\n', excelFile);
fprintf('All components      : %d\n', numel(allComponents));
fprintf('All I signals       : %d\n', numel(allISignals));
fprintf('All input signals   : %d\n', numel(allInputs));
fprintf('All output signals  : %d\n', numel(allOutputs));
fprintf('Used input signals  : %d\n', numel(usedInputs));
fprintf('Used output signals : %d\n', numel(usedOutputs));
fprintf('Output only signals : %d\n', numel(outputOnlySignals));
fprintf('Input only signals  : %d\n', numel(inputOnlySignals));

end

function arr = i_sortStringsIgnoreCase(arr)
arr = string(arr);
if isempty(arr)
    return;
end
[~, idx] = sort(lower(arr));
arr = arr(idx);
end

