function [sigTable, paraTable, interfaceTable, loadedCnt] = findSlddLoadGee(path, varargin)
%FINDSLDDLOADGEE 导入sldd表格中的Signal, Parameter, Interface
%   [SIGTABLE, PARATABLE, INTERFACETABLE, LOADEDCNT] = FINDSLDDLOADGEE(PATH) 使用默认参数导入数据
%   [SIGTABLE, PARATABLE, INTERFACETABLE, LOADEDCNT] = FINDSLDDLOADGEE(PATH, 'Parameter', Value, ...) 使用指定参数导入
%
%   输入参数:
%      path        - sldd文件路径 (字符向量或字符串标量)
%
%   可选参数（名值对）:
%      'ProcessInterface' - 是否处理Interface数据，可选值: true, false (默认值: true)
%      'ProcessSignal'    - 是否处理Signal数据，可选值: true, false (默认值: false)
%      'ProcessParameter' - 是否处理Parameter数据，可选值: true, false (默认值: false)
%      'Verbose'          - 是否显示详细信息，可选值: true, false (默认值: true)
%      'StorageClassIn'   - 输入信号存储类，可选值: 'Auto', 'ImportedExtern', 'ExportedGlobal', 'Custom'等 (默认值: 'Auto')
%      'StorageClassOut'  - 输出信号存储类，可选值: 'Auto', 'ExportedGlobal', 'Custom'等 (默认值: 'Auto')
%
%   输出参数:
%      sigTable        - Signal数据表格
%      paraTable       - Parameter数据表格  
%      interfaceTable  - Interface数据表格（输入输出端口）
%      loadedCnt       - 成功导入的数据条数
%
%   功能描述:
%      从Excel文件中导入Signal、Parameter和Interface数据，并创建相应的AUTOSAR对象。
%      支持自定义输入输出信号的存储类设置。
%
%   示例:
%      [sigTable, paraTable, interfaceTable, loadedCnt] = findSlddLoadGee('PrkgClimaEgyMgr_Element_Management_AddPort.xlsm');
%      [sigTable, paraTable, interfaceTable, loadedCnt] = findSlddLoadGee('file.xlsm', 'ProcessSignal', true);
%      [sigTable, paraTable, interfaceTable, loadedCnt] = findSlddLoadGee('file.xlsm', 'StorageClassIn', 'ExportedGlobal');
%
%   作者: Blue.ge
%   日期: 2025-01-27
%   版本: 2.0 
    %% 输入参数处理
    p = inputParser;
    p.FunctionName = mfilename;
    
    addRequired(p, 'path', @(x) ischar(x) || isstring(x));
    addParameter(p, 'ProcessInterface', true, @islogical);
    addParameter(p, 'ProcessSignal', false, @islogical);
    addParameter(p, 'ProcessParameter', false, @islogical);
    addParameter(p, 'Verbose', true, @islogical);
    addParameter(p, 'StorageClassIn', 'ImportedExtern', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'StorageClassOut', 'Global', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    
    parse(p, path, varargin{:});
    
    filePath = p.Results.path;
    verbose = p.Results.Verbose;
    processInterface = p.Results.ProcessInterface;
    processSignal = p.Results.ProcessSignal;
    processParameter = p.Results.ProcessParameter;
    storageClassIn = char(p.Results.StorageClassIn);
    storageClassOut = char(p.Results.StorageClassOut);

    %% 验证文件路径
    if isempty(filePath) || ~(isfile(which(filePath)) || isfile(filePath))
        error('请提供正确的文件路径！文件不存在: %s', filePath);
    end
    
    loadedCnt = 0;
    interfaceTable = table();

    %% 打印文件名信息
    if verbose
        [~, fileName, fileExt] = fileparts(filePath);
        fprintf('\n');
        fprintf('==============================================\n');
        fprintf('      正在处理文件: %s%s\n', fileName, fileExt);
        fprintf('==============================================\n');
    end

    %% 分隔线 - 开始处理Interface数据
    if processInterface
        if verbose
            fprintf('          开始处理Interface数据\n');
            fprintf('========================================\n');
        end

        %% 读取Interface数据
        [interfaceTable, interfaceLoadedCnt] = readSheetData(filePath, 'Interface', 'Signal', verbose, storageClassIn, storageClassOut);
        loadedCnt = loadedCnt + interfaceLoadedCnt;
    end

    %% 分隔线 - 开始处理Signal数据
    if processSignal
        if verbose
            fprintf('\n');
            fprintf('          开始处理Signal数据\n');
            fprintf('========================================\n');
        end

        %% 读取Signal数据
        [sigTable, signalLoadedCnt] = readSheetData(filePath, 'Signal', 'Signal', verbose, storageClassIn, storageClassOut);
        loadedCnt = loadedCnt + signalLoadedCnt;
    else
        sigTable = table();
    end


    %% 分隔线 - Signal和Parameter之间
    if processParameter
        if verbose
            fprintf('\n');
            fprintf('========================================\n');
            fprintf('          开始处理Parameter数据\n');
            fprintf('========================================\n');
        end

        %% 读取Parameter数据
        [paraTable, parameterLoadedCnt] = readSheetData(filePath, 'Parameter', 'Parameter', verbose);
        loadedCnt = loadedCnt + parameterLoadedCnt;
    else
        paraTable = table();
    end
    
    if verbose
        [~, fileName, fileExt] = fileparts(filePath);
        fprintf('\n');
        fprintf('==============================================\n');
        fprintf('      文件 %s%s 处理完成\n', fileName, fileExt);
        fprintf('==============================================\n');
        fprintf('共成功导入 %d 条记录\n', loadedCnt);
        fprintf('==============================================\n');
    end

end

%% 辅助函数：通用读取工作表数据
function [dataTable, loadedCount] = readSheetData(filePath, sheetName, objectType, verbose, storageClassIn, storageClassOut)
    % 通用读取工作表数据的函数
    % 输入参数:
    %   filePath - Excel文件路径
    %   sheetName - 工作表名称
    %   objectType - 对象类型 ('Signal' 或 'Parameter')
    %   verbose - 是否显示详细信息
    %   storageClassIn - 输入信号存储类
    %   storageClassOut - 输出信号存储类
    % 输出参数:
    %   dataTable - 读取的数据表格
    %   loadedCount - 成功创建的对象数量
    
    loadedCount = 0;
    
    try
        % 配置导入选项：从第3行开始读取数据（第1行忽略，第2行标题）
        opts = detectImportOptions(filePath, 'Sheet', sheetName);
        opts.DataRange = 'A3';  % 从A3单元格开始读取
        opts.VariableNames = ["SWC", "ElementType", "Name", "Min", "Max", "DataType", "Units", "Values", "Description"];
        opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string", "string", "string"];
        opts = setvaropts(opts, "EmptyFieldRule", "auto");
        opts = setvaropts(opts, "WhitespaceRule", "preserve");
        
        dataTable = readtable(filePath, opts, "UseExcel", false);
        
        % 移除空行
        dataTable = dataTable(~ismissing(dataTable.Name) & dataTable.Name ~= "", :);
        
        if verbose
            fprintf('----开始解析%s, 共计%d条----\n', sheetName, height(dataTable));
        end
        
        % 解析每个数据项并创建相应的AUTOSAR对象
        for i = 1:height(dataTable)
            itemData = dataTable(i,:);
            itemName = string(itemData.Name);
            
            if ismissing(itemName) || itemName == ""
                continue;
            end
            
            if verbose
                fprintf('----开始解析%s: %s----\n', sheetName, itemName);
            end
            
            try
                % 根据对象类型创建相应的AUTOSAR对象
                if strcmp(objectType, 'Signal')
                    % 从表格数据中提取信号参数
                    signalParams = extractSignalParams(itemData, storageClassIn, storageClassOut);
                    % createSigObjGeePack(itemName, signalParams{:});
                    createSigObjAutosar4(itemName, signalParams{:});
                elseif strcmp(objectType, 'Parameter')
                    % 从表格数据中提取参数对象参数
                    paramParams = extractParameterParams(itemData);
                    % createParamObjGeePack(itemName, paramParams{:});
                    createParamObjAutosar4(itemName, paramParams{:});
                else
                    error('不支持的对象类型: %s', objectType);
                end
                loadedCount = loadedCount + 1;
            catch ME
                if verbose
                    warning('创建%s对象失败: %s, 错误: %s', sheetName, itemName, ME.message);
                end
            end
        end
        
    catch ME
        if verbose
            warning('findSlddLoadGee:%sReadError', '读取%s数据失败: %s', sheetName, sheetName, ME.message);
        end
        dataTable = table();
    end
end

%% 辅助函数：从表格数据中提取信号参数
function signalParams = extractSignalParams(itemData, storageClassIn, storageClassOut)
    % 从表格数据中提取信号对象的参数
    % 输入: itemData - 表格行数据
    %       storageClassIn - 输入信号存储类
    %       storageClassOut - 输出信号存储类
    % 输出: signalParams - 参数名称-值对单元数组
    
    signalParams = {};
    
    % 提取数据类型
    if ~ismissing(itemData.DataType) && itemData.DataType ~= ""
        signalParams{end+1} = 'DataType';
        signalParams{end+1} = char(itemData.DataType);
    end
    
    % 提取描述信息
    if ~ismissing(itemData.Description) && itemData.Description ~= ""
        signalParams{end+1} = 'Description';
        signalParams{end+1} = char(itemData.Description);
    end
    
    % 提取单位
    if ~ismissing(itemData.Units) && itemData.Units ~= ""
        signalParams{end+1} = 'Unit';
        signalParams{end+1} = char(itemData.Units);
    end
    
    % 提取最小值
    if ~ismissing(itemData.Min) && itemData.Min ~= ""
        try
            minVal = str2double(char(itemData.Min));
            if ~isnan(minVal)
                signalParams{end+1} = 'Min';
                signalParams{end+1} = minVal;
            end
        catch
            % 如果转换失败，作为字符串传递
            signalParams{end+1} = 'Min';
            signalParams{end+1} = char(itemData.Min);
        end
    end
    
    % 提取最大值
    if ~ismissing(itemData.Max) && itemData.Max ~= ""
        try
            maxVal = str2double(char(itemData.Max));
            if ~isnan(maxVal)
                signalParams{end+1} = 'Max';
                signalParams{end+1} = maxVal;
            end
        catch
            % 如果转换失败，作为字符串传递
            signalParams{end+1} = 'Max';
            signalParams{end+1} = char(itemData.Max);
        end
    end
    
    % 根据ElementType设置信号类型和存储类
    if ~ismissing(itemData.ElementType) && itemData.ElementType ~= ""
        elementType = char(itemData.ElementType);
        if contains(lower(elementType), 'inport') || contains(lower(elementType), 'input')
            signalParams{end+1} = 'sigType';
            signalParams{end+1} = 'Inport';
            % 设置输入信号存储类
            signalParams{end+1} = 'StorageClassIn';
            signalParams{end+1} = storageClassIn;
        elseif contains(lower(elementType), 'outport') || contains(lower(elementType), 'output')
            signalParams{end+1} = 'sigType';
            signalParams{end+1} = 'Outport';
            % 设置输出信号存储类
            signalParams{end+1} = 'StorageClassOut';
            signalParams{end+1} = storageClassOut;
        end
    end
    
    % 设置verbose为false，避免重复输出
    signalParams{end+1} = 'verbose';
    signalParams{end+1} = false;
end

%% 辅助函数：从表格数据中提取参数对象参数
function paramParams = extractParameterParams(itemData)
    % 从表格数据中提取参数对象的参数
    % 输入: itemData - 表格行数据
    % 输出: paramParams - 参数名称-值对单元数组
    
    paramParams = {};
    
    % 提取数据类型
    if ~ismissing(itemData.DataType) && itemData.DataType ~= ""
        paramParams{end+1} = 'DataType';
        paramParams{end+1} = char(itemData.DataType);
    end
    
    % 提取描述信息
    if ~ismissing(itemData.Description) && itemData.Description ~= ""
        paramParams{end+1} = 'Description';
        paramParams{end+1} = char(itemData.Description);
    end
    
    % 提取单位
    if ~ismissing(itemData.Units) && itemData.Units ~= ""
        paramParams{end+1} = 'Unit';
        paramParams{end+1} = char(itemData.Units);
    end
    
    % 提取值
    if ~ismissing(itemData.Values) && itemData.Values ~= ""
        paramParams{end+1} = 'Value';
        paramParams{end+1} = char(itemData.Values);
    end
    
    % 提取最小值
    if ~ismissing(itemData.Min) && itemData.Min ~= ""
        try
            minVal = str2double(char(itemData.Min));
            if ~isnan(minVal)
                paramParams{end+1} = 'Min';
                paramParams{end+1} = minVal;
            end
        catch
            % 如果转换失败，作为字符串传递
            paramParams{end+1} = 'Min';
            paramParams{end+1} = char(itemData.Min);
        end
    end
    
    % 提取最大值
    if ~ismissing(itemData.Max) && itemData.Max ~= ""
        try
            maxVal = str2double(char(itemData.Max));
            if ~isnan(maxVal)
                paramParams{end+1} = 'Max';
                paramParams{end+1} = maxVal;
            end
        catch
            % 如果转换失败，作为字符串传递
            paramParams{end+1} = 'Max';
            paramParams{end+1} = char(itemData.Max);
        end
    end
    
    % 设置verbose为false，避免重复输出
    paramParams{end+1} = 'verbose';
    paramParams{end+1} = false;
end
