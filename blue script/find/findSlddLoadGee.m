function [sigTable, paraTable, loadedCnt] = findSlddLoadGee(path, varargin)
%%
% 目的: 导入sldd表格中的Signal, Parameter
% 输入：
%       path: sldd文件路径
%       varargin: 可选参数
% 返回： 
%       sigTable: Signal数据表格
%       paraTable: Parameter数据表格  
%       loadedCnt: 成功导入的数据条数
% 范例： [sigTable, paraTable, loadedCnt] = findSlddLoadGee('PrkgClimaEgyMgr_Element_Management_AddPort.xlsm');
% 作者： Blue.ge
% 日期： 20250908
%% 
    %% 输入参数处理
    p = inputParser;
    addRequired(p, 'path', @(x) ischar(x) || isstring(x));
    addParameter(p, 'SheetName', 'Signal', @(x) ischar(x) || isstring(x));
    addParameter(p, 'Verbose', true, @islogical);
    
    parse(p, path, varargin{:});
    
    filePath = p.Results.path;
    verbose = p.Results.Verbose;

    %% 验证文件路径
    if isempty(filePath) || ~(isfile(which(filePath)) || isfile(filePath))
        error('请提供正确的文件路径！文件不存在: %s', filePath);
    end
    
    loadedCnt = 0;

    %% 打印文件名信息
    if verbose
        [~, fileName, fileExt] = fileparts(filePath);
        fprintf('\n');
        fprintf('==============================================\n');
        fprintf('      正在处理文件: %s%s\n', fileName, fileExt);
        fprintf('==============================================\n');
    end

    %% 分隔线 - 开始处理Signal数据
    if verbose
        fprintf('          开始处理Signal数据\n');
        fprintf('========================================\n');
    end

    %% 读取Signal数据
    try
        % 配置导入选项：从第3行开始读取数据（第1行忽略，第2行标题）
        opts = detectImportOptions(filePath, 'Sheet', 'Signal');
        opts.DataRange = 'A3';  % 从A3单元格开始读取
        opts.VariableNames = ["SWC", "ElementType", "Name", "Min", "Max", "DataType", "Units", "Values", "Description"];
        opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string", "string", "string"];
        opts = setvaropts(opts, "EmptyFieldRule", "auto");
        opts = setvaropts(opts, "WhitespaceRule", "preserve");
        
        sigTable = readtable(filePath, opts, "UseExcel", false);
        
        % 移除空行
        sigTable = sigTable(~ismissing(sigTable.Name) & sigTable.Name ~= "", :);
        
        if verbose
            fprintf('----开始解析Signal, 共计%d条----\n', height(sigTable));
        end
        
        % 解析每个Signal并创建AUTOSAR4.Signal对象
        for i = 1:height(sigTable)
            sigData = sigTable(i,:);
            signalName = string(sigData.Name);
            
            if ismissing(signalName) || signalName == ""
                continue;
            end
            
            if verbose
                fprintf('----开始解析Signal: %s----\n', signalName);
            end
            
            try
                % 创建AUTOSAR4.Signal对象
                createSignalObject(signalName, sigData);
                loadedCnt = loadedCnt + 1;
            catch ME
                if verbose
                    warning('创建Signal对象失败: %s, 错误: %s', signalName, ME.message);
                end
            end
        end
        
    catch ME
        if verbose
            warning('findSlddLoadGee:SignalReadError', '读取Signal数据失败: %s', ME.message);
        end
        sigTable = table();
    end

    % 每行按如下格式进行解析, 将excel中的数据转换为代码，如果不存在的列，赋默认值
    % HvBattMntnActv = AUTOSAR4.Signal;
    % HvBattMntnActv.CoderInfo.StorageClass = 'Custom';
    % HvBattMntnActv.CoderInfo.Alias = '';
    % HvBattMntnActv.CoderInfo.Alignment = -1;
    % HvBattMntnActv.CoderInfo.CustomStorageClass = 'Global';
    % HvBattMntnActv.CoderInfo.CustomAttributes.MemorySection = 'VAR';
    % HvBattMntnActv.CoderInfo.CustomAttributes.ConcurrentAccess = false;
    % HvBattMntnActv.Description = 'aaaa';
    % HvBattMntnActv.DataType = 'Boolean';
    % HvBattMntnActv.Min = 1;
    % HvBattMntnActv.Max = 10;
    % HvBattMntnActv.DocUnits = '';
    % HvBattMntnActv.Dimensions = -1;
    % HvBattMntnActv.DimensionsMode = 'auto';
    % HvBattMntnActv.Complexity = 'auto';
    % HvBattMntnActv.SampleTime = -1;
    % HvBattMntnActv.InitialValue = '';
    % HvBattMntnActv.SwCalibrationAccess = 'ReadOnly';

    %% 分隔线 - Signal和Parameter之间
    if verbose
        fprintf('\n');
        fprintf('========================================\n');
        fprintf('          开始处理Parameter数据\n');
        fprintf('========================================\n');
    end

    %% 读取Parameter数据
    try
        % 配置导入选项：从第3行开始读取数据（第1行忽略，第2行标题）
        opts = detectImportOptions(filePath, 'Sheet', 'Parameter');
        opts.DataRange = 'A3';  % 从A3单元格开始读取
        opts.VariableNames = ["SWC", "ElementType", "Name", "Min", "Max", "DataType", "Units", "Values", "Description"];
        opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string", "string", "string"];
        opts = setvaropts(opts, "EmptyFieldRule", "auto");
        opts = setvaropts(opts, "WhitespaceRule", "preserve");
        
        paraTable = readtable(filePath, opts, "UseExcel", false);
        
        % 移除空行
        paraTable = paraTable(~ismissing(paraTable.Name) & paraTable.Name ~= "", :);
        
        if verbose
            fprintf('----开始解析Parameter, 共计%d条----\n', height(paraTable));
        end
        
        % 解析每个Parameter并创建AUTOSAR4.Parameter对象
        for i = 1:height(paraTable)
            paraData = paraTable(i,:);
            paramName = string(paraData.Name);
            
            if ismissing(paramName) || paramName == ""
                continue;
            end
            
            if verbose
                fprintf('----开始解析Parameter: %s----\n', paramName);
            end
            
            try
                % 创建AUTOSAR4.Parameter对象
                createParameterObject(paramName, paraData);
                loadedCnt = loadedCnt + 1;
            catch ME
                if verbose
                    warning('创建Parameter对象失败: %s, 错误: %s', paramName, ME.message);
                end
            end
        end
        
    catch ME
        if verbose
            warning('findSlddLoadGee:ParameterReadError', '读取Parameter数据失败: %s', ME.message);
        end
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

    
    % ACRunTiLmtforBlwrAftrn = AUTOSAR4.Parameter;
    % ACRunTiLmtforBlwrAftrn.DataType = 'VCCTi39';
    % ACRunTiLmtforBlwrAftrn.Value = [ 3;];
    % ACRunTiLmtforBlwrAftrn.CoderInfo.StorageClass = 'Custom';
    % ACRunTiLmtforBlwrAftrn.CoderInfo.Alias = '';
    % ACRunTiLmtforBlwrAftrn.CoderInfo.Alignment = -1;
    % ACRunTiLmtforBlwrAftrn.CoderInfo.CustomStorageClass = 'Global';
    % ACRunTiLmtforBlwrAftrn.CoderInfo.CustomAttributes.MemorySection = 'CONST_VOLATILE';
    % ACRunTiLmtforBlwrAftrn.CoderInfo.CustomAttributes.ConcurrentAccess = false;
    % ACRunTiLmtforBlwrAftrn.Description = 'AC runing time limit for blower afterrun [Minutes]';
    % ACRunTiLmtforBlwrAftrn.Min = 0;
    % ACRunTiLmtforBlwrAftrn.Max = 40;
    % ACRunTiLmtforBlwrAftrn.DocUnits = 'Mins';
    % ACRunTiLmtforBlwrAftrn.SwCalibrationAccess = 'ReadWrite';


end

%% 辅助函数：创建Signal对象
function createSignalObject(signalName, sigData)
    % 创建AUTOSAR4.Signal对象
    assignin('base', char(signalName), AUTOSAR4.Signal);
    
    % 设置基本属性
    if ~ismissing(sigData.DataType) && sigData.DataType ~= ""
        evalin('base', [char(signalName) '.DataType = ''' char(sigData.DataType) ''';']);
    end
    
    if ~ismissing(sigData.Description) && sigData.Description ~= ""
        evalin('base', [char(signalName) '.Description = ''' char(sigData.Description) ''';']);
    end
    
    if ~ismissing(sigData.Units) && sigData.Units ~= ""
        evalin('base', [char(signalName) '.DocUnits = ''' char(sigData.Units) ''';']);
    end
    
    % 设置数值范围
    if ~ismissing(sigData.Min) && sigData.Min ~= ""
        try
            minVal = str2double(char(sigData.Min));
            if ~isnan(minVal)
                evalin('base', [char(signalName) '.Min = ' num2str(minVal) ';']);
            end
        catch
            % 忽略转换错误
        end
    end
    
    if ~ismissing(sigData.Max) && sigData.Max ~= ""
        try
            maxVal = str2double(char(sigData.Max));
            if ~isnan(maxVal)
                evalin('base', [char(signalName) '.Max = ' num2str(maxVal) ';']);
            end
        catch
            % 忽略转换错误
        end
    end
    
    % 设置CoderInfo属性
    evalin('base', [char(signalName) '.CoderInfo.StorageClass = ''Custom'';']);
    evalin('base', [char(signalName) '.CoderInfo.Alias = '''';']);
    evalin('base', [char(signalName) '.CoderInfo.Alignment = -1;']);
    evalin('base', [char(signalName) '.CoderInfo.CustomStorageClass = ''Global'';']);
    evalin('base', [char(signalName) '.CoderInfo.CustomAttributes.MemorySection = ''VAR'';']);
    evalin('base', [char(signalName) '.CoderInfo.CustomAttributes.ConcurrentAccess = false;']);
    
    % 设置默认属性
    evalin('base', [char(signalName) '.Dimensions = -1;']);
    evalin('base', [char(signalName) '.DimensionsMode = ''auto'';']);
    evalin('base', [char(signalName) '.Complexity = ''auto'';']);
    evalin('base', [char(signalName) '.SampleTime = -1;']);
    evalin('base', [char(signalName) '.InitialValue = '''';']);
    evalin('base', [char(signalName) '.SwCalibrationAccess = ''ReadOnly'';']);
end

%% 辅助函数：创建Parameter对象
function createParameterObject(paramName, paraData)
    % 创建AUTOSAR4.Parameter对象
    assignin('base', char(paramName), AUTOSAR4.Parameter);
    
    % 设置基本属性
    if ~ismissing(paraData.DataType) && paraData.DataType ~= ""
        evalin('base', [char(paramName) '.DataType = ''' char(paraData.DataType) ''';']);
    end
    
    if ~ismissing(paraData.Description) && paraData.Description ~= ""
        evalin('base', [char(paramName) '.Description = ''' char(paraData.Description) ''';']);
    end
    
    if ~ismissing(paraData.Units) && paraData.Units ~= ""
        evalin('base', [char(paramName) '.DocUnits = ''' char(paraData.Units) ''';']);
    end
    
    % 设置数值范围
    if ~ismissing(paraData.Min) && paraData.Min ~= ""
        try
            minVal = str2double(char(paraData.Min));
            if ~isnan(minVal)
                evalin('base', [char(paramName) '.Min = ' num2str(minVal) ';']);
            end
        catch
            % 忽略转换错误
        end
    end
    
    if ~ismissing(paraData.Max) && paraData.Max ~= ""
        try
            maxVal = str2double(char(paraData.Max));
            if ~isnan(maxVal)
                evalin('base', [char(paramName) '.Max = ' num2str(maxVal) ';']);
            end
        catch
            % 忽略转换错误
        end
    end
    
    % 设置Values（初始值）
    if ~ismissing(paraData.Values) && paraData.Values ~= ""
        try
            % 尝试解析Values字段
            valuesStr = char(paraData.Values);
            if contains(valuesStr, '[') && contains(valuesStr, ']')
                % 如果包含数组格式，直接赋值
                evalin('base', [char(paramName) '.Value = ' valuesStr ';']);
            else
                % 否则尝试转换为数值
                val = str2double(valuesStr);
                if ~isnan(val)
                    evalin('base', [char(paramName) '.Value = ' num2str(val) ';']);
                end
            end
        catch
            % 忽略转换错误
        end
    end
    
    % 设置CoderInfo属性
    evalin('base', [char(paramName) '.CoderInfo.StorageClass = ''Custom'';']);
    evalin('base', [char(paramName) '.CoderInfo.Alias = '''';']);
    evalin('base', [char(paramName) '.CoderInfo.Alignment = -1;']);
    evalin('base', [char(paramName) '.CoderInfo.CustomStorageClass = ''Global'';']);
    evalin('base', [char(paramName) '.CoderInfo.CustomAttributes.MemorySection = ''CONST_VOLATILE'';']);
    evalin('base', [char(paramName) '.CoderInfo.CustomAttributes.ConcurrentAccess = false;']);
    
    % 设置默认属性
    evalin('base', [char(paramName) '.SwCalibrationAccess = ''ReadWrite'';']);
end
