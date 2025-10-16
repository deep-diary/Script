function [outputFile, sigTable] = createSlddSigGee(ModelName, varargin)
%CREATESLDDSIGGEE 获取模型根目录下输入输出端口，按模板格式，保存到Excel表格
%   [OUTPUTFILE, SIGTABLE] = CREATESLDDSIGGEE(MODELNAME) 获取模型根目录下输入输出端口，
%   按模板格式，保存到Excel表格。
%   [OUTPUTFILE, SIGTABLE] = CREATESLDDSIGGEE(MODELNAME, 'Parameter', Value, ...) 使用指定参数处理端口
%
%   功能描述:
%      获取指定模型的输入输出端口信息，按照预定义模板格式生成信号数据表格，
%      并保存到Excel文件中。支持AUTOSAR信号名解析，可以处理重复命名的信号。
%      将数据保存到对应项目的Excel文件中。
%
%   输入参数:
%       MODELNAME   - 模型名称 (字符向量或字符串标量)
%
%   可选参数:
%       'overwrite' - 是否覆盖现有文件，可选值: true, false (默认值: true)
%       'verbose'   - 是否显示详细信息，可选值: true, false (默认值: true)
%       'outputDir' - 输出目录路径 (默认值: 模型所在目录)
%       'ignoreInput' - 是否忽略输入端口，可选值: true, false (默认值: true)
%       'ignoreOutput' - 是否忽略输出端口，可选值: true, false (默认值: false)
%       'sheet'     - Excel工作表名称 (默认值: 'Interface')
%       'autosarMode' - AUTOSAR信号名解析模式，可选值: 'deleteTail', 'halfTail', 'justHalf', 'modelHalf' (默认值: '')
%                       当指定此参数时，将自动启用信号名截断功能
%                       - 'deleteTail': 删除后缀（_read 或 _write）
%                       - 'halfTail': 保留一半名称并添加相应后缀
%                       - 'justHalf': 只保留一半名称
%                       - 'modelHalf': 模型名_一半名称
%       'isUseSubModel' - 是否在第一个子模型中查找端口，可选值: true, false (默认值: false)
%                        当为true时，会先找到根模型下的第一个子模型，然后在该子模型中查找端口
%
%   返回值:
%       SIGTABLE    - 生成的信号数据表格
%       OUTPUTFILE  - 输出文件路径
%
%   示例:
%       [outputFile, sigTable] = createSlddSigGee('PrkgClimaEgyMgr');
%       [outputFile, sigTable] = createSlddSigGee('PrkgClimaEgyMgr', 'verbose', false);
%       [outputFile, sigTable] = createSlddSigGee('PrkgClimaEgyMgr', 'ignoreInput', false);
%       [outputFile, sigTable] = createSlddSigGee('PrkgClimaEgyMgr', 'sheet', 'Signal');
%       [outputFile, sigTable] = createSlddSigGee('PrkgClimaEgyMgr', 'autosarMode', 'halfTail');
%       [outputFile, sigTable] = createSlddSigGee('PrkgClimaEgyMgr', 'autosarMode', 'modelHalf', 'ignoreInput', false);
%       [outputFile, sigTable] = createSlddSigGee('PrkgClimaEgyMgr', 'isUseSubModel', true);
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
    addParameter(p, 'ignoreInput', false, @islogical);
    addParameter(p, 'ignoreOutput', false, @islogical);
    addParameter(p, 'sheet', 'Interface', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    % addParameter(p, 'truncateSignal', false, @islogical);
    addParameter(p,'autosarMode','', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'isUseSubModel', false, @islogical);

    parse(p, ModelName, varargin{:});

    % 获取解析后的参数
    modelName = char(p.Results.ModelName);
    overwrite = p.Results.overwrite;
    verbose = p.Results.verbose;
    outputDir = char(p.Results.outputDir);
    ignoreInput = p.Results.ignoreInput;
    ignoreOutput = p.Results.ignoreOutput;
    sheet = char(p.Results.sheet);
    % truncateSignal = p.Results.truncateSignal;
    autosarMode = char(p.Results.autosarMode);
    isUseSubModel = p.Results.isUseSubModel;

    % 确定是否截断信号名
    if ~isempty(autosarMode)
        truncateSignal = true;
        fprintf('AUTOSAR模式: %s (将截断信号名)\n', autosarMode);
    else
        truncateSignal = false;
        fprintf('AUTOSAR模式: 关闭 (不截断信号名)\n');
    end


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

    %% 确定要查找端口的模型路径
    targetModel = modelName;
    if isUseSubModel
        try
            % 查找第一个子模型
            subModels = find_system(modelName, 'SearchDepth', 1, 'BlockType', 'SubSystem');
            if length(subModels) >= 1  
                targetModel = subModels{1};  % 取第一个子模型
                if verbose
                    fprintf('使用子模型: %s\n', targetModel);
                end
            else
                if verbose
                    warning('createSlddSigGee:NoSubModel', '模型 "%s" 中没有找到子模型，将使用根模型', modelName);
                end
            end
        catch ME
            if verbose
                warning('createSlddSigGee:SubModelError', '查找子模型失败: %s，将使用根模型', ME.message);
            end
        end
    end

    %% 获取指定模型下的输入输出端口
    try
        [~, inPorts, outPorts] = findModPorts(targetModel, 'getType', 'Handle');
        
        if verbose
            if isUseSubModel && ~strcmp(targetModel, modelName)
                fprintf('在子模型 "%s" 中发现 %d 个输入端口, %d 个输出端口\n', targetModel, length(inPorts), length(outPorts));
            else
                fprintf('发现 %d 个输入端口, %d 个输出端口\n', length(inPorts), length(outPorts));
            end
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
    portTypes = {}; % 记录端口类型：'Inport' 或 'Outport'
    
    % 处理输入端口
    if ~ignoreInput && ~isempty(inPorts)
        allPorts = [allPorts, inPorts];
        portTypes = [portTypes, repmat({'Inport'}, 1, length(inPorts))];
    end
    
    % 处理输出端口
    if ~ignoreOutput && ~isempty(outPorts)
        allPorts = [allPorts, outPorts];
        portTypes = [portTypes, repmat({'Outport'}, 1, length(outPorts))];
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
                portName = findNameAutosar(portName,'nameMd',ModelName,'type',portType,'mode',autosarMode);
            end
            
            % 按照["SWC", "ElementType", "Name", "Min", "Max", "DataType", "Units", "Values", "Description"]顺序赋值
            sigTable.SWC(i) = modelName;                    % SWC
            sigTable.ElementType(i) = portType; % 'Signal';             % ElementType, 输入输出都是Signal, excel 自带脚本只识别这个
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
        clearOldData(outputFile, sheet);
        
        % 需要从A2开始写入，因为第一行是log 等相关信息
        writetable(sigTable, outputFile, 'Sheet', sheet, 'Range', 'A2');
        
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
