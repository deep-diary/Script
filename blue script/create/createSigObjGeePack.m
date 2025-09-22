function sigObj = createSigObjGeePack(name, varargin)
%%
% 目的: 基于Gee pack， 创建名称为name 的信号对象，并加载到工作空间中 
% 输入：
%       name: 信号对象名称 (必需参数)
% 可选参数：
%       'DataType' - 数据类型 (默认值: 'single')
%       'CustomStorageClass' - 自定义存储类 (默认值: 'DATA_EXP')
%       'sigType' - 信号类型，'Inport' 或 'Outport' (默认值: '')
%                   当指定此参数时，将自动设置CustomStorageClass:
%                   - 'Inport': CustomStorageClass = 'DATA_IMP'
%                   - 'Outport': CustomStorageClass = 'DATA_EXP'
%       'Dimensions' - 维度 (默认值: 1)
%       'Description' - 描述信息 (默认值: '')
%       'Unit' - 单位 (默认值: '')
%       'InitialValue' - 初始值 (默认值: '')
%       'Min' - 最小值 (默认值: '')
%       'Max' - 最大值 (默认值: '')
%       'StorageClass' - 存储类 (默认值: 'Custom')
%       'prefix' - 前缀 (默认值: 'in')
%       'isEnPrefix' - 是否启用前缀 (默认值: false)
%       'verbose' - 是否显示详细信息 (默认值: true)
% 返回：
%       sigObj: 信号对象
% 范例：
%       createSigObjGeePack('TestSignal')
%       createSigObjGeePack('TestSignal', 'DataType', 'boolean', 'Description', '测试信号')
%       createSigObjGeePack('TestSignal', 'Min', 0, 'Max', 100, 'Unit', 'V')
%       createSigObjGeePack('InputSignal', 'sigType', 'Inport', 'Description', '输入信号')
%       createSigObjGeePack('OutputSignal', 'sigType', 'Outport', 'Description', '输出信号')
% 说明：基于GeelyPack.Signal创建信号对象，支持完整的信号属性配置
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
    addParameter(p, 'CustomStorageClass', 'DATA_EXP', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'sigType', '', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'Dimensions', 1, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
    addParameter(p, 'Description', '', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'Unit', '', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'InitialValue', '', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'Min', '', @(x) validateattributes(x, {'char', 'string', 'numeric'}, {}));
    addParameter(p, 'Max', '', @(x) validateattributes(x, {'char', 'string', 'numeric'}, {}));
    addParameter(p, 'StorageClass', 'Custom', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'prefix', 'in', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'isEnPrefix', false, @islogical);
    addParameter(p, 'verbose', true, @islogical);
    
    % 解析输入参数
    parse(p, name, varargin{:});
    
    % 获取参数值
    signalName = char(p.Results.name);
    dataType = char(p.Results.DataType);
    customStorageClass = char(p.Results.CustomStorageClass);
    sigType = char(p.Results.sigType);
    dimensions = p.Results.Dimensions;
    description = char(p.Results.Description);
    unit = char(p.Results.Unit);
    initialValue = char(p.Results.InitialValue);
    minValue = p.Results.Min;
    maxValue = p.Results.Max;
    storageClass = char(p.Results.StorageClass);
    prefix = char(p.Results.prefix);
    isEnPrefix = p.Results.isEnPrefix;
    verbose = p.Results.verbose;
    
    %% 处理信号名称
    if isEnPrefix
        finalSignalName = [prefix '_' signalName];
    else
        finalSignalName = signalName;
    end
    
    %% 根据sigType自动设置CustomStorageClass
    if ~isempty(sigType)
        switch lower(sigType)
            case 'inport'
                customStorageClass = 'DATA_IMP';
                if verbose
                    fprintf('检测到Inport类型，自动设置CustomStorageClass为: DATA_IMP\n');
                end
            case 'outport'
                customStorageClass = 'DATA_EXP';
                if verbose
                    fprintf('检测到Outport类型，自动设置CustomStorageClass为: DATA_EXP\n');
                end
            otherwise
                warning('createSigObjGeePack:invalidSigType', '无效的sigType: %s。支持的类型: Inport, Outport', sigType);
        end
    end
    
    %% 创建信号对象
    try
        if verbose
            fprintf('正在创建信号对象: %s\n', finalSignalName);
        end
        
        % 创建GeelyPack.Signal对象
        evalin('base', [finalSignalName ' = GeelyPack.Signal;']);
        
        % 设置基本属性
        evalin('base', [finalSignalName '.DataType = "' dataType '";']);
        evalin('base', [finalSignalName '.CoderInfo.StorageClass = "' storageClass '";']);
        evalin('base', [finalSignalName '.CoderInfo.CustomStorageClass = "' customStorageClass '";']);
        evalin('base', [finalSignalName '.Dimensions = ' num2str(dimensions) ';']);
        
        % 设置描述信息
        if ~isempty(description)
            % 处理换行符
            cleanDescription = strrep(description, char(10), ' ');
            evalin('base', [finalSignalName '.Description = "' cleanDescription '";']);
        end
        
        % 设置单位
        if ~isempty(unit)
            evalin('base', [finalSignalName '.Unit = "' unit '";']);
        end
        
        % 设置初始值
        if ~isempty(initialValue)
            evalin('base', [finalSignalName '.InitialValue = "' initialValue '";']);
        end
        
        % 设置最小值
        if ~isempty(minValue)
            if isnumeric(minValue)
                evalin('base', [finalSignalName '.Min = ' num2str(minValue) ';']);
            else
                evalin('base', [finalSignalName '.Min = ' char(minValue) ';']);
            end
        end
        
        % 设置最大值
        if ~isempty(maxValue)
            if isnumeric(maxValue)
                evalin('base', [finalSignalName '.Max = ' num2str(maxValue) ';']);
            else
                evalin('base', [finalSignalName '.Max = ' char(maxValue) ';']);
            end
        end
        
        % 获取创建的对象
        sigObj = evalin('base', finalSignalName);
        
        if verbose
            fprintf('信号对象 "%s" 创建成功\n', finalSignalName);
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
        error('createSigObjGeePack:creationError', '创建信号对象失败: %s', ME.message);
    end
end