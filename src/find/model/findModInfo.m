function result = findModInfo(path, varargin)
%FINDMODINFO 汇总模型/子系统的端口、标定量与解析信号信息
%
% 语法:
%   result = findModInfo(path)
%   result = findModInfo(path, 'Name', Value, ...)
%
% 功能描述:
%   对指定模型或子系统收集以下信息，并以结构体统一返回：
%   1) 模型名称与有效路径；
%   2) 输入/输出端口名称与数据类型；
%   3) 标定量信息（来自 `findCalibParams`）；
%   4) 解析信号/全局观测量信息（来自 `findResolvedSignals`）。
%   该函数适合作为 GUI、注释生成与导出逻辑的统一数据入口。
%
% 输入参数:
%   path - 模型路径、子系统路径或句柄 (char/string/double)
%
% 可选参数（Name-Value）:
%   'SearchDepth'            - 标定量搜索深度 (numeric 或 'all')，默认: 1
%   'IncludeResolvedSignals' - 是否收集解析信号信息 (logical)，默认: true
%   'IncludeDataStoreWrite'  - 收集解析信号时是否并入 Data Store Write 名称 (logical)，默认: true
%   'ResolvedDescendants'    - 解析信号是否包含子层级 (logical)，默认: false
%   'DisplayResolvedSignals' - 是否打印解析信号名称 (logical)，默认: false
%   'DCMfileName'            - 传给 `findCalibParams`：DCM 标定值查询，默认: ''
%   'ExcelfileName'          - 传给 `findCalibParams`：Excel 参数表查询，默认: ''
%   'ResolveFilesByWhich'   - 裸文件名是否用 MATLAB path 解析，默认: true
%
% 输出参数:
%   result - 结构体，字段:
%            path              - 解析后的路径 (char)
%            modelName         - 当前块/系统名称 (char)
%            portsInNames      - 输入端口名称列表 (cell)
%            portsOutNames     - 输出端口名称列表 (cell)
%            portsInDataTypes  - 输入端口数据类型列表 (cell)
%            portsOutDataTypes - 输出端口数据类型列表 (cell)
%            portsInTable      - 输入端口视图表（Name, DataType）
%            portsOutTable     - 输出端口视图表（Name, DataType）
%            portsSpecial      - 特殊端口信息（沿用 findModPorts）
%            calibInfo         - 标定量结构体（`findCalibParams` 返回，可含 `calibValues` 名-值表）
%            resolvedSignals   - 解析信号结构体（findResolvedSignals 返回）
%            summary           - 计数摘要结构体
%
% 异常与边界行为:
%   - path 无效时 error。
%   - IncludeResolvedSignals=false 时 resolvedSignals 返回空结构体。
%
% 示例:
%   R = findModInfo(gcs);
%   R = findModInfo(gcs, 'SearchDepth', 'all', 'ResolvedDescendants', true);
%   R = findModInfo(gcs, 'DCMfileName', 'a.dcm', 'ExcelfileName', 'b.xlsx');
%
% 参见: FINDMODPORTS, FINDCALIBPARAMS, FINDRESOLVEDSIGNALS
%
% 作者: blue.ge(葛维冬@Smart)
% 版本: 1.2
% 日期: 2026-04-17
% 变更记录:
%   2026-04-17 v1.2 透传 DCM/Excel 至 `findCalibParams`，标定名与值在同一入口获取。
%   2026-04-16 v1.1 新增端口数据类型与端口表字段，便于注释与 GUI 直接使用。
%   2026-04-10 v1.0 初版：统一聚合模型基本信息。

p = inputParser;
addRequired(p, 'path', @(x) ischar(x) || isstring(x) || isnumeric(x));
addParameter(p, 'SearchDepth', 1, @(x) isnumeric(x) || (ischar(x) && strcmp(x, 'all')) || (isstring(x) && strcmpi(x, "all")));
addParameter(p, 'IncludeResolvedSignals', true, @islogical);
addParameter(p, 'IncludeDataStoreWrite', true, @islogical);
addParameter(p, 'ResolvedDescendants', false, @islogical);
addParameter(p, 'DisplayResolvedSignals', false, @islogical);
addParameter(p, 'DCMfileName', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'ExcelfileName', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'ResolveFilesByWhich', true, @islogical);
parse(p, path, varargin{:});

path = p.Results.path;
searchDepth = p.Results.SearchDepth;
includeResolvedSignals = p.Results.IncludeResolvedSignals;
includeDataStoreWrite = p.Results.IncludeDataStoreWrite;
resolvedDescendants = p.Results.ResolvedDescendants;
displayResolvedSignals = p.Results.DisplayResolvedSignals;
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

modelName = get_param(path, 'Name');
[~, portsInNames, portsOutNames, portsSpecial] = findModPorts(path, 'getType', 'Name');
[~, portsInDataTypes, portsOutDataTypes] = findModPorts(path, 'getType', 'OutDataTypeStr');
calibInfo = findCalibParams(path, ...
    'SearchDepth', searchDepth, ...
    'DCMfileName', dcmFileName, ...
    'ExcelfileName', excelFileName, ...
    'ResolveFilesByWhich', resolveFilesByWhich);
portsInTable = i_buildPortTable(portsInNames, portsInDataTypes);
portsOutTable = i_buildPortTable(portsOutNames, portsOutDataTypes);

if includeResolvedSignals
    resolvedSignals = findResolvedSignals(path, ...
        'IncludeDescendants', resolvedDescendants, ...
        'IncludeDataStoreWrite', includeDataStoreWrite, ...
        'DisplaySignals', displayResolvedSignals);
else
    resolvedSignals = struct();
end

summary = struct();
summary.inputPorts = numel(portsInNames);
summary.outputPorts = numel(portsOutNames);
summary.calibParams = numel(calibInfo.allParams);
if includeResolvedSignals && isfield(resolvedSignals, 'allSignalNames')
    summary.resolvedSignals = numel(resolvedSignals.allSignalNames);
else
    summary.resolvedSignals = 0;
end

result = struct();
result.path = path;
result.modelName = modelName;
result.portsInNames = portsInNames;
result.portsOutNames = portsOutNames;
result.portsInDataTypes = portsInDataTypes;
result.portsOutDataTypes = portsOutDataTypes;
result.portsInTable = portsInTable;
result.portsOutTable = portsOutTable;
result.portsSpecial = portsSpecial;
result.calibInfo = calibInfo;
result.resolvedSignals = resolvedSignals;
result.summary = summary;

end

function T = i_buildPortTable(names, dtypes)
names = names(:);
dtypes = dtypes(:);
n = min(numel(names), numel(dtypes));
if n == 0
    T = table(cell(0,1), cell(0,1), 'VariableNames', {'Name','DataType'});
    return;
end
T = table(names(1:n), dtypes(1:n), 'VariableNames', {'Name','DataType'});
end

