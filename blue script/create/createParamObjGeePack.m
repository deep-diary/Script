function paramObj = createParamObjGeePack(name, varargin)
%%
% 目的: 基于Gee pack， 创建名称为name 的标定量对象，并加载到工作空间中 
% 输入：
%       name: 标定量对象名称 (必需参数)
% 可选参数：
%       'DataType' - 数据类型 (默认值: 'single')
%       'CustomStorageClass' - 自定义存储类 (默认值: 'CAL_TYPES')
%       'Dimensions' - 维度 (默认值: 1)
%       'Description' - 描述信息 (默认值: '')
%       'Unit' - 单位 (默认值: '')
%       'Value' - 标定量值 (默认值: '')
%       'Min' - 最小值 (默认值: '')
%       'Max' - 最大值 (默认值: '')
%       'StorageClass' - 存储类 (默认值: 'Custom')
%       'verbose' - 是否显示详细信息 (默认值: true)
% 返回：
%       paramObj: 标定量对象
% 范例：
%       createParamObjGeePack('TestParam')
%       createParamObjGeePack('TestParam', 'DataType', 'boolean', 'Description', '测试标定量')
%       createParamObjGeePack('TestParam', 'Min', 0, 'Max', 100, 'Unit', 'V', 'Value', '50')
%       createParamObjGeePack('CalibrationParam', 'Description', '标定量参数', 'Value', '3.3')
% 说明：基于GeelyPack.Parameter创建标定量对象，支持完整的标定量属性配置
% 作者： Blue.ge
% 日期： 20250916
%%
    %% 输入参数验证
    narginchk(1, inf);
    validateattributes(name, {'char', 'string'}, {'scalartext'}, mfilename, 'name', 1);
    
    %% 参数处理
    p = inputParser;
    p.FunctionName = mfilename;
    
    % 添加必需参数
    addRequired(p, 'name', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    
    % 添加可选参数
    addParameter(p, 'DataType', 'single', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'CustomStorageClass', 'CAL_TYPES', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'Dimensions', 1, @(x) validateattributes(x, {'numeric'}, {'scalartext'}));
    addParameter(p, 'Description', '0', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'Unit', '', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'Value', '0', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'Min', '', @(x) validateattributes(x, {'char', 'string', 'numeric'}, {}));
    addParameter(p, 'Max', '', @(x) validateattributes(x, {'char', 'string', 'numeric'}, {}));
    addParameter(p, 'StorageClass', 'Custom', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'verbose', true, @islogical);
    
    % 解析输入参数
    parse(p, name, varargin{:});
    
    % 获取参数值
    paramName = char(p.Results.name);
    dataType = char(p.Results.DataType);
    customStorageClass = char(p.Results.CustomStorageClass);
    dimensions = p.Results.Dimensions;
    description = char(p.Results.Description);
    unit = char(p.Results.Unit);
    paramValue = char(p.Results.Value);
    minValue = p.Results.Min;
    maxValue = p.Results.Max;
    storageClass = char(p.Results.StorageClass);
    verbose = p.Results.verbose;
    
    %% 使用标定量名称
    finalParamName = paramName;
    
    %% 创建标定量对象
    try
        if verbose
            fprintf('正在创建标定量对象: %s\n', finalParamName);
        end
        
        % 创建GeelyPack.Parameter对象
        evalin('base', [finalParamName ' = GeelyPack.Parameter;']);
        
        % 设置基本属性
        evalin('base', [finalParamName '.DataType = "' dataType '";']);
        evalin('base', [finalParamName '.CoderInfo.StorageClass = "' storageClass '";']);
        evalin('base', [finalParamName '.CoderInfo.CustomStorageClass = "' customStorageClass '";']);
        evalin('base', [finalParamName '.Dimensions = ' num2str(dimensions) ';']);
        
        % 设置描述信息
        if ~isempty(description)
            % 处理换行符
            cleanDescription = strrep(description, char(10), ' ');
            evalin('base', [finalParamName '.Description = "' cleanDescription '";']);
        end
        
        % 设置单位
        if ~isempty(unit)
            evalin('base', [finalParamName '.Unit = "' unit '";']);
        end
        
        % 设置标定量值
        if ~isempty(paramValue)
            evalin('base', [finalParamName '.Value = ' paramValue ';']);
        end
        
        % 设置最小值
        if ~isempty(minValue)
            if isnumeric(minValue)
                evalin('base', [finalParamName '.Min = ' num2str(minValue) ';']);
            else
                evalin('base', [finalParamName '.Min = ' char(minValue) ';']);
            end
        end
        
        % 设置最大值
        if ~isempty(maxValue)
            if isnumeric(maxValue)
                evalin('base', [finalParamName '.Max = ' num2str(maxValue) ';']);
            else
                evalin('base', [finalParamName '.Max = ' char(maxValue) ';']);
            end
        end
        
        % 获取创建的对象
        paramObj = evalin('base', finalParamName);
        
        if verbose
            fprintf('标定量对象 "%s" 创建成功\n', finalParamName);
            fprintf('  - 数据类型: %s\n', dataType);
            fprintf('  - 存储类: %s\n', storageClass);
            fprintf('  - 自定义存储类: %s\n', customStorageClass);
            fprintf('  - 维度: %s\n', num2str(dimensions));
            if ~isempty(description)
                fprintf('  - 描述: %s\n', description);
            end
            if ~isempty(unit)
                fprintf('  - 单位: %s\n', unit);
            end
        end
        
    catch ME
        error('createParamObjGeePack:creationError', '创建标定量对象失败: %s', ME.message);
    end
end