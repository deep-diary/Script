function [outputFile, sigTable] = createSlddSigGee(ModelName, varargin)
%createSlddSigGee 获取模型根目录下输入输出端口，按模板格式，保存到Excel表格
%
%   [outputFile, sigTable] = createSlddSigGee(MODELNAME) 获取模型根目录下输入输出端口，
%   按模板格式，保存到Excel表格。
%
%   将数据保存到对应项目的Excel文件中。
%
%   输入参数:
%       MODELNAME   - 模型名称 (字符向量或字符串标量)
%
%   可选参数:
%       'overwrite' - 是否覆盖现有文件，可选值: true, false (默认值: true)
%       'verbose'   - 是否显示详细信息，可选值: true, false (默认值: true)
%       'outputDir' - 输出目录路径 (默认值: 模型所在目录)
%       'ignoreInput' - 是否忽略输入端口，可选值: true, false (默认值: false)
%       'ignoreOutput' - 是否忽略输出端口，可选值: true, false (默认值: false)
%       'truncateSignal' - 是否截断信号名，可选值: true, false (默认值: false)
%
%   返回值:
%       SIGTABLE    - 生成的信号数据表格
%       OUTPUTFILE  - 输出文件路径
%
%   示例:
%       [outputFile, sigTable] = createSlddSigGee('PrkgClimaEgyMgr');
%       [outputFile, sigTable] = createSlddSigGee('PrkgClimaEgyMgr', 'verbose', false);
%       [outputFile, sigTable] = createSlddSigGee('PrkgClimaEgyMgr', 'ignoreInput', true);
%       [outputFile, sigTable] = createSlddSigGee('PrkgClimaEgyMgr', 'truncateSignal', true);
%
%   作者: Blue.ge
%   日期: 2025-09-08
%   版本: 2.0

    %% 创建输入解析器
    p = inputParser;
    addRequired(p, 'ModelName', @(x) ischar(x) || isstring(x));
    addParameter(p, 'overwrite', true, @islogical);
    addParameter(p, 'verbose', true, @islogical);
    addParameter(p, 'outputDir', '', @(x) ischar(x) || isstring(x));
    addParameter(p, 'ignoreInput', true, @islogical);
    addParameter(p, 'ignoreOutput', false, @islogical);
    addParameter(p, 'truncateSignal', false, @islogical);

    parse(p, ModelName, varargin{:});

    % 获取解析后的参数
    modelName = char(p.Results.ModelName);
    overwrite = p.Results.overwrite;
    verbose = p.Results.verbose;
    outputDir = char(p.Results.outputDir);
    ignoreInput = p.Results.ignoreInput;
    ignoreOutput = p.Results.ignoreOutput;
    truncateSignal = p.Results.truncateSignal;


    %% 验证模型是否存在
    if isempty(which(modelName))
        error('模型 "%s" 不存在或未在MATLAB路径中, 请先打开对应的模型', modelName);
    end

    %% 构建文件路径
    [modFold, ~, ~] = fileparts(which(modelName));
    
    % 确定输出目录
    if isempty(outputDir)
        outputDir = modFold;
    end
    
    % 确保输出目录存在
    if ~isfolder(outputDir)
        mkdir(outputDir);
    end
    
    % 构建文件名
    if overwrite
        filename = [modelName '_Element_Management_AddPort.xlsm'];
    else
        filename = [modelName '_Element_Management_AddPort_EXPORT.xlsm'];
    end
    outputFile = fullfile(outputDir, filename);
    
    %% 打印处理信息
    if verbose
        fprintf('\n');
        fprintf('========================================\n');
        fprintf('      正在处理模型: %s\n', modelName);
        fprintf('========================================\n');
    end

    %% 获取根目录下输入输出端口
    try
        [~, inPorts, outPorts] = findModPorts(modelName, 'getType', 'Handle');
        
        if verbose
            fprintf('发现 %d 个输入端口, %d 个输出端口\n', length(inPorts), length(outPorts));
        end
        
    catch ME
        if verbose
            warning('createSlddSigGee:PortInfoError', '获取端口信息失败: %s', ME.message);
        end
        sigTable = table();
        outputFile = '';
        return;
    end

    %% 根据参数过滤端口
    allPorts = {};
    portTypes = {}; % 记录端口类型：'Input' 或 'Output'
    
    % 处理输入端口
    if ~ignoreInput && ~isempty(inPorts)
        allPorts = [allPorts, inPorts];
        portTypes = [portTypes, repmat({'Input'}, 1, length(inPorts))];
    end
    
    % 处理输出端口
    if ~ignoreOutput && ~isempty(outPorts)
        allPorts = [allPorts, outPorts];
        portTypes = [portTypes, repmat({'Output'}, 1, length(outPorts))];
    end
    
    if isempty(allPorts)
        if verbose
            fprintf('警告: 模型 "%s" 没有找到任何端口（可能被过滤）\n', modelName);
        end
        sigTable = table();
        return;
    end
    
    % 预分配表格
    numPorts = length(allPorts);
    sigTable = table('Size', [numPorts, 9], ...
                    'VariableTypes', {'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string', 'string'}, ...
                    'VariableNames', {'SWC', 'ElementType', 'Name', 'Min', 'Max', 'DataType', 'Units', 'Values', 'Description'});
    
    if verbose
        fprintf('开始处理 %d 个端口...\n', numPorts);
        if ignoreInput
            fprintf('  - 忽略输入端口\n');
        end
        if ignoreOutput
            fprintf('  - 忽略输出端口\n');
        end
        if truncateSignal
            fprintf('  - 启用信号名截断功能\n');
        end
    end
    
    for i = 1:numPorts
        portHandle = allPorts{i}; % 端口句柄
        portType = portTypes{i};  % 端口类型
        
        try
            % 获取端口名称
            portName = get_param(portHandle, 'Name');
            
            % 信号名截断处理
            if truncateSignal
                portName = truncateSignalName(portName, portType);
            end
            
            % 按照["SWC", "ElementType", "Name", "Min", "Max", "DataType", "Units", "Values", "Description"]顺序赋值
            sigTable.SWC(i) = modelName;                    % SWC
            sigTable.ElementType(i) = 'Signal';             % ElementType, 输入输出都是Signal, excel 自带脚本只识别这个
            sigTable.Name(i) = portName;                    % Name (可能被截断)
            sigTable.Min(i) = get_param(portHandle, 'OutMin');          % Min
            sigTable.Max(i) = get_param(portHandle, 'OutMax');          % Max
            sigTable.DataType(i) = get_param(portHandle, 'OutDataTypeStr'); % DataType
            sigTable.Units(i) = get_param(portHandle, 'Unit');          % Units
            sigTable.Values(i) = '';                                    % Values
            sigTable.Description(i) = get_param(portHandle, 'Description'); % Description
            
            if verbose && mod(i, 10) == 0
                fprintf('已处理 %d/%d 个端口 (%s)\n', i, numPorts, portType);
            end
            
        catch ME
            if verbose
                warning('createSlddSigGee:PortProcessError', '处理端口 %d 时出错: %s', i, ME.message);
            end
        end
    end
        


    %% 保存Excel文件
    try
        % 清除旧数据（保留第一行）
        clearOldData(outputFile, 'Signal');
        
        % 需要从A2开始写入，因为第一行是log 等相关信息
        writetable(sigTable, outputFile, 'Sheet', 'Signal', 'Range', 'A2');
        
        if verbose
            fprintf('\n');
            fprintf('========================================\n');
            fprintf('      模型 %s 处理完成\n', modelName);
            fprintf('========================================\n');
            fprintf('输出文件: %s\n', outputFile);
            fprintf('共处理 %d 个端口\n', height(sigTable));
            fprintf('========================================\n');
        end
        
    catch ME
        if verbose
            warning('createSlddSigGee:SaveError', '保存Excel文件失败: %s', ME.message);
        end
        outputFile = '';
    end
end

%% 辅助函数：清除Excel文件中的旧数据（高效版本）
function clearOldData(filePath, sheetName)
    % 清除Excel文件中指定工作表的旧数据（保留第一行）
    % 使用更高效的方法：获取有效行数，然后用空字符串填充
    
    try
        % 检查文件是否存在
        if ~isfile(filePath)
            return; % 文件不存在，无需清除
        end
        
        % 方法1：使用readtable获取有效行数（推荐，最高效）
        try
            % 读取现有数据以获取行数
            opts = detectImportOptions(filePath, 'Sheet', sheetName);
            if isempty(opts.DataRange)
                return; % 没有数据，无需清除
            end
            
            % 读取数据获取实际行数
            existingData = readtable(filePath, opts, 'Sheet', sheetName);
            existingRows = height(existingData);
            
            if existingRows > 0
                % 创建空字符串填充数据
                emptyData = array2table(repmat({''}, existingRows, width(existingData)), ...
                    'VariableNames', existingData.Properties.VariableNames);
                
                % 写入空数据覆盖旧数据
                writetable(emptyData, filePath, 'Sheet', sheetName, 'Range', 'A2');
            end
            
        catch
            % 方法2：使用COM对象（备用方法）
            try
                excelApp = actxserver('Excel.Application');
                excelApp.Visible = false;
                excelApp.DisplayAlerts = false;
                
                workbook = excelApp.Workbooks.Open(filePath);
                
                try
                    worksheet = workbook.Worksheets.Item(sheetName);
                catch
                    workbook.Close();
                    excelApp.Quit();
                    return;
                end
                
                % 获取已使用的范围
                usedRange = worksheet.UsedRange;
                
                if ~isempty(usedRange) && usedRange.Rows.Count > 1
                    % 清除第2行及以后的所有数据
                    clearRange = worksheet.Range(sprintf('A2:%s%d', ...
                        char(64 + usedRange.Columns.Count), usedRange.Rows.Count));
                    clearRange.ClearContents();
                end
                
                workbook.Save();
                workbook.Close();
                excelApp.Quit();
                
            catch
                % 方法3：使用xlsread/xlswrite（最后备用）
                try
                    [~, ~, rawData] = xlsread(filePath, sheetName);
                    
                    if size(rawData, 1) > 1
                        % 创建只包含第一行的新数据
                        newData = rawData(1, :);
                        xlswrite(filePath, newData, sheetName);
                    end
                catch
                    warning('createSlddSigGee:ClearDataWarning', '无法清除旧数据，新数据将追加到现有数据后面');
                end
            end
        end
        
    catch
        % 静默处理错误，不影响主程序运行
    end
end

%% 辅助函数：截断信号名
function truncatedName = truncateSignalName(originalName,portType)
    % 截断AUTOSAR信号名，提取第一个下划线后面的部分
    % 例如: 'NetReqFromPrkgClimaEveMgr_NetReqFromPrkgClimaEveMgr' -> 'NetReqFromPrkgClimaEveMgr'
    % 如果结果以_read或_write结尾，则去掉该后缀

    % 查找第一个下划线的位置
    underscorePos = strfind(originalName, '_');
    
    if ~isempty(underscorePos) && underscorePos(1) > 1
        % 提取第一个下划线后面的部分
        truncatedName = originalName(underscorePos(1)+1:end);
    else
        % 如果没有找到下划线或下划线在开头，返回原名
        truncatedName = originalName;
    end

    % % 检查并去除_read或_write后缀
    % if endsWith(truncatedName, '_read')
    %     truncatedName = truncatedName(1:end-5);
    % elseif endsWith(truncatedName, '_write')
    %     truncatedName = truncatedName(1:end-6);
    % end

    % 检查并添加_read或_write后缀
    if ~endsWith(truncatedName, '_read') && strcmp(portType, 'Input')
        truncatedName = [truncatedName '_read'];
    elseif ~endsWith(truncatedName, '_write') && strcmp(portType, 'Output')
        truncatedName = [truncatedName '_write'];
    end

end