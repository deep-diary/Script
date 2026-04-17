function modCount = createSubsystemsFromExcel(varargin)
%CREATESUBSYSTEMSFROMEXCEL 根据Excel配置批量创建Simulink子系统块
% Syntax
%   modCount = createSubsystemsFromExcel()
%   modCount = createSubsystemsFromExcel(Name, Value)
%
% Description
%   createSubsystemsFromExcel 会读取 Excel 配置表中的 FunctionID、
%   RequirementID 和 ModelName 列，并在当前 Simulink 系统
%   (gcs) 下按网格布局批量创建子系统块。
%
%   生成名称规则如下：
%   1. 当 FunctionID 不为 'None' 时：
%      FunPrefix + FunctionID + "_" + ReqPrefix + RequirementID + "_" + ModelName
%   2. 当 FunctionID 为 'None' 时：
%      ReqPrefix + RequirementID + "_" + ModelName
%
%   该函数会直接向当前模型添加块，属于有副作用操作。执行前请确保：
%   1. 已打开并激活目标 Simulink 模型或子系统；
%   2. Excel 文件存在且目标工作表包含必需列；
%   3. 当前系统下不存在同名块，否则 `add_block` 会报错。
%
% Input Arguments
%   Name-Value 参数：
%   template      - Excel 文件路径，字符串标量或字符向量。
%                   默认值: 'Template.xlsx'
%   sheet         - 工作表名称，字符串标量或字符向量。
%                   默认值: 'ModelName'
%   FunPrefix     - FunctionID 前缀，字符串标量或字符向量。
%                   默认值: ''
%   ReqPrefix     - RequirementID 前缀，字符串标量或字符向量。
%                   默认值: ''
%   rows          - 布局行数，正整数标量。
%                   默认值: 1
%   blockWidth    - 子系统块宽度，正整数标量。
%                   默认值: 150
%   blockHeight   - 子系统块高度，正整数标量。
%                   默认值: 100
%   hSpacing      - 水平间距，非负数值标量。
%                   默认值: 300
%   vSpacing      - 垂直间距，非负数值标量。
%                   默认值: 50
%
% Name-Value
%   template
%      默认值: 'Template.xlsx'
%   sheet
%      默认值: 'ModelName'
%   FunPrefix
%      默认值: ''
%   ReqPrefix
%      默认值: ''
%   rows
%      默认值: 1
%   blockWidth
%      默认值: 150
%   blockHeight
%      默认值: 100
%   hSpacing
%      默认值: 300
%   vSpacing
%      默认值: 50
%
% Output Arguments
%   modCount      - 成功创建的子系统块数量。
%
% Errors/Warnings
%   1. 当不存在当前系统 (gcs) 时，函数会报错。
%   2. 当 Excel 文件、工作表或必需列缺失时，函数会报错。
%   3. 当块名重复或块创建失败时，函数会报错并中断执行。
%   4. 当 Excel 中没有可处理的数据行时，函数返回 `0`。
%
% Examples
%   % 使用默认模板批量创建子系统块
%   modCount = createSubsystemsFromExcel();
%
%   % 指定模板、工作表和布局参数
%   modCount = createSubsystemsFromExcel( ...
%       'template', 'Template.xlsx', ...
%       'sheet', 'ModelName', ...
%       'FunPrefix', 'Fun', ...
%       'ReqPrefix', 'Req', ...
%       'rows', 3);
%
% See also
%   readtable, add_block, set_param, gcs
%
% 作者: blue.ge(葛维冬@Smart)
% 版本: 1.1
% 日期: 2026-04-16
% 变更记录:
%   2026-04-16  1.1  重命名函数并完善帮助文档、参数校验与表头校验
%   2025-03-12  1.0  初始版本

    parser = inputParser;
    parser.FunctionName = mfilename;

    addParameter(parser, 'template', 'Template.xlsx', @(x) i_mustBeTextScalar(x, 'template'));
    addParameter(parser, 'sheet', 'ModelName', @(x) i_mustBeTextScalar(x, 'sheet'));
    addParameter(parser, 'FunPrefix', '', @(x) i_mustBeTextScalar(x, 'FunPrefix'));
    addParameter(parser, 'ReqPrefix', '', @(x) i_mustBeTextScalar(x, 'ReqPrefix'));
    addParameter(parser, 'rows', 1, @(x) i_mustBePositiveIntegerScalar(x, 'rows'));
    addParameter(parser, 'blockWidth', 150, @(x) i_mustBePositiveIntegerScalar(x, 'blockWidth'));
    addParameter(parser, 'blockHeight', 100, @(x) i_mustBePositiveIntegerScalar(x, 'blockHeight'));
    addParameter(parser, 'hSpacing', 300, @(x) i_mustBeNonnegativeScalar(x, 'hSpacing'));
    addParameter(parser, 'vSpacing', 50, @(x) i_mustBeNonnegativeScalar(x, 'vSpacing'));

    parse(parser, varargin{:});
    opts = parser.Results;

    template = char(string(opts.template));
    sheet = char(string(opts.sheet));
    funPrefix = char(string(opts.FunPrefix));
    reqPrefix = char(string(opts.ReqPrefix));

    currentSystem = i_getCurrentSystem();
    if isempty(currentSystem)
        error('%s:noCurrentSystem', mfilename, ...
            '函数 %s 需要在已打开的 Simulink 当前系统中执行。', mfilename);
    end

    if ~isfile(template)
        error('%s:templateNotFound', mfilename, ...
            '函数 %s 未找到模板文件: %s', mfilename, template);
    end

    dataTable = readtable(template, 'Sheet', sheet);
    i_validateRequiredColumns(dataTable);

    functionIds = i_toCellstrColumn(dataTable.FunctionID, 'FunctionID');
    requirementIds = i_toCellstrColumn(dataTable.RequirementID, 'RequirementID');
    modelNames = i_toCellstrColumn(dataTable.ModelName, 'ModelName');

    totalModels = numel(functionIds);
    if totalModels == 0
        modCount = 0;
        return;
    end

    cols = ceil(totalModels / opts.rows);
    modCount = 0;

    for idx = 1:totalModels
        currentRow = ceil(idx / cols);
        currentCol = mod(idx - 1, cols) + 1;

        xPos = (currentCol - 1) * (opts.blockWidth + opts.hSpacing);
        yPos = (currentRow - 1) * (opts.blockHeight + opts.vSpacing);

        subSystemName = i_buildSubsystemName( ...
            functionIds{idx}, requirementIds{idx}, modelNames{idx}, funPrefix, reqPrefix);

        newBlock = add_block('built-in/SubSystem', [currentSystem, '/', subSystemName]);
        set_param(newBlock, 'Position', ...
            [xPos, yPos, xPos + opts.blockWidth, yPos + opts.blockHeight]);

        modCount = modCount + 1;
    end
end

function i_mustBeTextScalar(value, argName)
    if ~(ischar(value) || (isstring(value) && isscalar(value)))
        error('createSubsystemsFromExcel:invalidText', ...
            '参数 %s 必须是字符向量或字符串标量。', argName);
    end
end

function currentSystem = i_getCurrentSystem()
    try
        currentSystem = gcs;
    catch
        currentSystem = '';
    end
end

function i_mustBePositiveIntegerScalar(value, argName)
    validateattributes(value, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'positive', 'integer'}, ...
        mfilename, argName);
end

function i_mustBeNonnegativeScalar(value, argName)
    validateattributes(value, {'numeric'}, ...
        {'scalar', 'real', 'finite', 'nonnegative'}, ...
        mfilename, argName);
end

function i_validateRequiredColumns(dataTable)
    requiredColumns = {'FunctionID', 'RequirementID', 'ModelName'};
    missingColumns = requiredColumns(~ismember(requiredColumns, dataTable.Properties.VariableNames));

    if ~isempty(missingColumns)
        error('createSubsystemsFromExcel:missingColumns', ...
            '缺少必需列: %s。', strjoin(missingColumns, ', '));
    end
end

function values = i_toCellstrColumn(columnData, columnName)
    if iscellstr(columnData) %#ok<ISCLSTR>
        values = columnData;
        return;
    end

    if isstring(columnData) || ischar(columnData) || iscategorical(columnData)
        values = cellstr(string(columnData));
        return;
    end

    error('createSubsystemsFromExcel:invalidColumnType', ...
        '列 %s 必须可转换为文本。', columnName);
end

function subSystemName = i_buildSubsystemName(functionId, requirementId, modelName, funPrefix, reqPrefix)
    functionId = char(string(functionId));
    requirementId = char(string(requirementId));
    modelName = char(string(modelName));

    if strcmp(functionId, 'None')
        subSystemName = [reqPrefix, requirementId, '_', modelName];
    else
        subSystemName = [funPrefix, functionId, '_', reqPrefix, requirementId, '_', modelName];
    end
end
