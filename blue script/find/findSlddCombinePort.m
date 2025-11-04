function [outPath, inputTable, outputTable] = findSlddCombinePort(fileName, varargin)
%% 从Excel文件的不同sheet页中读取SWC的输入输出端口信息，并合并到Combined sheet页
% 输入参数:
%   fileName - Excel文件路径
%   varargin - 可选参数对:
%     'IncludeSheets' - 需要包含的sheet页名称（cell数组），默认为{'TmAfCtrl','TmColtModeMgr'}
%     'PortTypeColumn' - 端口类型列名，默认为'PortType'
%     'InputValue' - 输入端口标识值，默认为'Input'
%     'OutputValue' - 输出端口标识值，默认为'Output'
%     'CombinedSheetName' - 合并后的sheet页名称，默认为'Combined'
% 输出参数:
%   outPath - 合并后的Excel文件路径
%   inputTable - 过滤出的输入端口表格
%   outputTable - 过滤出的输出端口表格

% 解析输入参数
p = inputParser;
addRequired(p, 'fileName', @ischar);
addParameter(p, 'IncludeSheets', {'TmAfCtrl','TmColtModeMgr'}, @(x) iscell(x) || ischar(x));
addParameter(p, 'PortTypeColumn', 'PortType', @ischar);
addParameter(p, 'InputValue', 'Input', @ischar);
addParameter(p, 'OutputValue', 'Output', @ischar);
addParameter(p, 'CombinedSheetName', 'Combined', @ischar);
parse(p, fileName, varargin{:});

% 获取解析后的参数
includeSheets = p.Results.IncludeSheets;
% 如果includeSheets是字符串，转换为cell数组
if ischar(includeSheets)
    includeSheets = {includeSheets};
end
portTypeColumn = p.Results.PortTypeColumn;
inputValue = p.Results.InputValue;
outputValue = p.Results.OutputValue;
combinedSheetName = p.Results.CombinedSheetName;

% 检查文件是否存在
if ~exist(fileName, 'file')
    error('文件不存在: %s', fileName);
end

try
    % 直接使用指定的包含页面
    fprintf('将处理指定的 %d 个sheet页: %s\n', length(includeSheets), strjoin(includeSheets, ', '));
    validSheets = includeSheets;
    
    % 初始化合并表格和列顺序
    allDataTable = [];
    referenceColumnOrder = [];
    
    % 遍历所有有效的sheet页
    for i = 1:length(validSheets)
        sheetName = validSheets{i};
        
        try
            % 检测导入选项，将所有列设置为字符类型
            opts = detectImportOptions(fileName, 'ReadVariableNames', true, 'Sheet', sheetName);
            for j = 1:length(opts.VariableTypes)
                opts.VariableTypes{j} = 'char';
            end
            
            % 读取当前sheet页的数据
            currentTable = readtable(fileName, opts, 'ReadVariableNames', true, 'Sheet', sheetName);
            
            % 检查是否包含PortType列
            if ~ismember(portTypeColumn, currentTable.Properties.VariableNames)
                warning('Sheet "%s" 中未找到列 "%s"，跳过此sheet', sheetName, portTypeColumn);
                continue;
            end
            
            % 如果是第一个有效的sheet，记录列顺序作为参考
            if isempty(referenceColumnOrder)
                referenceColumnOrder = currentTable.Properties.VariableNames;
            end
            
            % 添加来源sheet信息列
            currentTable.SourceSheet = repmat({sheetName}, height(currentTable), 1);
            
            % 合并到总表
            if isempty(allDataTable)
                allDataTable = currentTable;
            else
                % 确保列名一致，并按照参考列顺序排列
                commonCols = intersect(referenceColumnOrder, currentTable.Properties.VariableNames);
                allDataTable = allDataTable(:, commonCols);
                currentTable = currentTable(:, commonCols);
                allDataTable = [allDataTable; currentTable];
            end
            
            fprintf('已处理sheet: %s, 数据行数: %d\n', sheetName, height(currentTable));
            
        catch ME
            warning('处理sheet "%s" 时出错: %s', sheetName, ME.message);
            continue;
        end
    end
    
    if isempty(allDataTable)
        error('没有成功读取任何数据');
    end
    
    % 根据PortType列过滤输入和输出端口
    portTypeIdx = strcmp(allDataTable.Properties.VariableNames, portTypeColumn);
    if ~any(portTypeIdx)
        error('未找到指定的端口类型列: %s', portTypeColumn);
    end
    
    % 过滤输入端口
    inputMask = strcmp(allDataTable.(portTypeColumn), inputValue);
    inputTable = allDataTable(inputMask, :);
    
    % 过滤输出端口
    outputMask = strcmp(allDataTable.(portTypeColumn), outputValue);
    outputTable = allDataTable(outputMask, :);
    
    % 确保inputTable和outputTable的列顺序与原始表格一致
    if ~isempty(inputTable)
        inputTable = inputTable(:, referenceColumnOrder);
    end
    if ~isempty(outputTable)
        outputTable = outputTable(:, referenceColumnOrder);
    end
    
    % 删除现有的Combined sheet页（如果存在）
    if ismember(combinedSheetName, sheetNames)
        try
            % 使用更可靠的方法删除sheet
            Excel = actxserver('Excel.Application');
            Excel.Visible = false;
            Workbook = Excel.Workbooks.Open(fileName);
            try
                Workbook.Worksheets.Item(combinedSheetName).Delete;
            catch
                % 如果删除失败，继续执行
            end
            Workbook.Save;
            Workbook.Close;
            Excel.Quit;
            delete(Excel);
        catch
            % 如果COM方法失败，尝试使用xlswrite清空
            try
                xlswrite(fileName, {}, combinedSheetName);
            catch
                % 如果都失败，继续执行
            end
        end
    end
    
    % 将合并后的数据写入Combined sheet页
    try
        writetable(allDataTable, fileName, 'Sheet', combinedSheetName, 'WriteMode', 'overwritesheet');
    catch ME
        % 如果writetable失败，尝试使用xlswrite
        warning('MATLAB:findSlddCombinePort:writetableFailed', 'writetable失败，尝试使用xlswrite: %s', ME.message);
        try
            % 将table转换为cell数组
            dataCell = [allDataTable.Properties.VariableNames; table2cell(allDataTable)];
            xlswrite(fileName, dataCell, combinedSheetName);
        catch ME2
            error('无法写入Combined sheet页: %s', ME2.message);
        end
    end
    
    % 输出结果
    outPath = fileName;
    
    fprintf('\n合并完成!\n');
    fprintf('总数据行数: %d\n', height(allDataTable));
    fprintf('输入端口行数: %d\n', height(inputTable));
    fprintf('输出端口行数: %d\n', height(outputTable));
    fprintf('合并数据已保存到sheet: %s\n', combinedSheetName);
    
catch ME
    error('处理过程中发生错误: %s', ME.message);
end