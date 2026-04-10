function result = findComponentPortsFromPortsInfo(componentName, varargin)
%FINDCOMPONENTPORTSFROMPORTSINFO 根据 PortsInfo 表查询组件的输入与输出信号
%
% 语法:
%   result = findComponentPortsFromPortsInfo(componentName)
%   result = findComponentPortsFromPortsInfo(componentName, 'Name', Value, ...)
%
% 功能描述:
%   从 PortsInfo Excel 按组件名筛选行，再按 PortDirection 分为该组件的
%   输出端口(Output)与输入端口(Input)，返回去重后的表。默认 Excel 解析策略与
%   FINDPORTFROMPORTSINFO 一致。
%
% 输入参数:
%   componentName - 待查组件名 (char/string, 标量)
%
% 可选参数（Name-Value）:
%   'excelFile'    - Excel 路径；默认与 FINDPORTFROMPORTSINFO 相同策略
%   'sheet'        - sheet，默认 1
%   'componentCol' / 'directionCol' / 'portCol' - 列名映射
%   'matchMode'    - 'exact'|'contains'，默认 'exact'
%                    'contains' 时可能匹配多个组件，结果中通过 ComponentName 区分
%   'ignoreCase'   - 组件名匹配是否忽略大小写，默认 true
%   'dataTypeCol'  - 附带的数据类型列名 (char/string)，默认 'OutDataTypeStr'
%                    Excel 中存在该列时并入 outputPorts/inputPorts 并参与去重；
%                    传空字符串 '' 表示不附带类型列
%
% 输出参数:
%   result - 结构体，字段:
%            outputPorts      - 该组件 Output 行（含 ComponentName, PortDirection,
%                              PortName；若表中有类型列则含 OutDataTypeStr 等）
%            inputPorts       - 该组件 Input 行（列集合与 outputPorts 一致）
%            allMatches       - 组件名匹配到的全部原始行
%            excelFile        - 使用的 Excel 路径
%            queryComponentName - 查询所用的组件名字符串
%
% 异常与边界行为:
%   - Excel 不存在或缺少必需列时 error。
%   - 无匹配行时不报错；outputPorts / inputPorts 为空表。
%
% 示例:
%   % 示例1：精确查询某组件的输入输出信号（默认 Excel）
%   R = findComponentPortsFromPortsInfo('SomeSwc');
%
%   % 示例2：指定 Excel，组件名包含匹配
%   R = findComponentPortsFromPortsInfo('CCM', ...
%       'excelFile', 'artifacts/CCM_Internal_swc_PortsInfo.xlsx', ...
%       'matchMode', 'contains', ...
%       'ignoreCase', true);
%
%   % 示例3：不附带类型列（Excel 有该列时默认会带上）
%   R = findComponentPortsFromPortsInfo('CCMLoad', 'dataTypeCol', '');
%
% 参见: FINDPORTFROMPORTSINFO, FINDPORTCONNECTIONSIGNALS,
%        GETDEFAULTPORTSINFOEXCELPATH, GETREPOROOT
%
% 作者: blue.ge(葛维冬@Smart)
% 版本: 1.2
% 日期: 2026-04-10
% 变更记录:
%   2026-04-10 v1.2 默认 Excel 解析委托 getDefaultPortsInfoExcelPath。
%   2026-04-10 v1.1 默认附带 OutDataTypeStr（存在则写入 outputPorts/inputPorts）。
%   2026-04-10 v1.0 初版：按组件名查询输入输出端口表。

validateattributes(componentName, {'char','string'}, {'scalartext'}, mfilename, 'componentName');
componentName = char(componentName);

p = inputParser;
addParameter(p, 'excelFile', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'sheet', 1, @(x) ischar(x) || isstring(x) || isnumeric(x));
addParameter(p, 'componentCol', 'ComponentName', @(x) ischar(x) || isstring(x));
addParameter(p, 'directionCol', 'PortDirection', @(x) ischar(x) || isstring(x));
addParameter(p, 'portCol', 'PortName', @(x) ischar(x) || isstring(x));
addParameter(p, 'matchMode', 'exact', @(x) ismember(lower(string(x)), ["exact","contains"]));
addParameter(p, 'ignoreCase', true, @islogical);
addParameter(p, 'dataTypeCol', 'OutDataTypeStr', @(x) ischar(x) || isstring(x));
parse(p, varargin{:});

excelFile = char(p.Results.excelFile);
sheetArg = p.Results.sheet;
componentCol = char(p.Results.componentCol);
directionCol = char(p.Results.directionCol);
portCol = char(p.Results.portCol);
matchMode = lower(char(p.Results.matchMode));
ignoreCase = p.Results.ignoreCase;
dataTypeCol = char(p.Results.dataTypeCol);

if isempty(excelFile)
    excelFile = getDefaultPortsInfoExcelPath('callerId', mfilename);
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

colsOut = {'ComponentName','PortDirection','PortName'};
if ~isempty(dataTypeCol)
    if ismember(dataTypeCol, T.Properties.VariableNames)
        T.(dataTypeCol) = string(T.(dataTypeCol));
        colsOut{end+1} = dataTypeCol;
    end
end

q = string(componentName);
cmp = T.ComponentName;
if ignoreCase
    q = lower(q);
    cmp = lower(cmp);
end

switch matchMode
    case 'exact'
        mask = (cmp == q);
    case 'contains'
        mask = contains(cmp, q);
    otherwise
        error('%s: 不支持的 matchMode: %s', mfilename, matchMode);
end

M = T(mask, :);
outRows = M(strcmpi(M.PortDirection, "Output"), :);
inRows = M(strcmpi(M.PortDirection, "Input"), :);
outRows = unique(outRows(:, colsOut), 'rows');
inRows = unique(inRows(:, colsOut), 'rows');

result = struct();
result.outputPorts = outRows;
result.inputPorts = inRows;
result.allMatches = M;
result.excelFile = excelFile;
result.queryComponentName = componentName;

fprintf('Excel: %s\n', excelFile);
fprintf('Query component: %s (matchMode=%s, ignoreCase=%d)\n', ...
    componentName, matchMode, ignoreCase);
fprintf('Output signals (rows): %d\n', height(outRows));
fprintf('Input signals  (rows): %d\n', height(inRows));
dispCols = i_buildDispPortColumns(colsOut);
if height(outRows) > 0
    fprintf('--- Output 端口 ---\n');
    disp(outRows(:, dispCols));
end
if height(inRows) > 0
    fprintf('--- Input 端口 ---\n');
    disp(inRows(:, dispCols));
end

end

function dispCols = i_buildDispPortColumns(colsOut)
% 控制台展示列：组件名、端口名，以及 colsOut 中除 PortDirection 外的其余列（如类型列）
dispCols = {'ComponentName','PortName'};
for k = 1:numel(colsOut)
    c = colsOut{k};
    if ~strcmp(c, 'ComponentName') && ~strcmp(c, 'PortName') && ~strcmp(c, 'PortDirection')
        dispCols{end+1} = c; %#ok<AGROW>
    end
end
end
