function sigObj = createSigObjAutosar4(name, varargin)
%CREATESIGOBJAUTOSAR4 基于AUTOSAR4.Signal创建信号对象
%
%   SIGOBJ = CREATESIGOBJAUTOSAR4(NAME) 创建名称为NAME的信号对象并加载到工作空间
%   SIGOBJ = CREATESIGOBJAUTOSAR4(NAME, Name, Value) 使用名称-值对参数指定信号属性
%
%   INPUTS:
%       NAME        - 信号对象名称，指定为字符向量或字符串标量
%
%   Name-Value Arguments:
%       'DataType'              - 数据类型，指定为字符向量或字符串标量（默认: 'single'）
%       'CustomStorageClass'    - 自定义存储类，指定为字符向量或字符串标量（默认: 'Global'）
%       'sigType'               - 信号类型，指定为字符向量或字符串标量（默认: ''）
%                                可选值: 'Inport', 'Outport'
%                                当指定此参数时，将自动设置CustomStorageClass
%       'StorageClassIn'        - 输入信号存储类，指定为字符向量或字符串标量（默认: 'Auto'）
%                                可选值: 'Auto', 'ImportedExtern', 'ExportedGlobal', 'Custom'等
%                                当为'Auto'时，按当前规则自动处理；否则直接使用指定值
%       'StorageClassOut'       - 输出信号存储类，指定为字符向量或字符串标量（默认: 'Auto'）
%                                可选值: 'Auto', 'ExportedGlobal', 'Custom'等
%                                当为'Auto'时，按当前规则自动处理；否则直接使用指定值
%       'Dimensions'            - 维度，指定为正数标量（默认: 1）
%       'Description'           - 描述信息，指定为字符向量或字符串标量（默认: ''）
%       'Unit'                  - 单位，指定为字符向量或字符串标量（默认: ''）
%       'InitialValue'          - 初始值，指定为字符向量或字符串标量（默认: ''）
%       'Min'                   - 最小值，指定为数值或字符向量（默认: ''）
%       'Max'                   - 最大值，指定为数值或字符向量（默认: ''）
%       'StorageClass'          - 存储类，指定为字符向量或字符串标量（默认: 'Custom'）
%       'prefix'                - 前缀，指定为字符向量或字符串标量（默认: 'in'）
%       'isEnPrefix'            - 是否启用前缀，指定为逻辑标量（默认: false）
%       'verbose'               - 是否显示详细信息，指定为逻辑标量（默认: true）
%
%   OUTPUTS:
%       SIGOBJ      - 创建的信号对象，返回为AUTOSAR4.Signal对象
%
%   EXAMPLES:
%       % 基本用法
%       sigObj = createSigObjAutosar4('TestSignal');
%       
%       % 指定数据类型和描述
%       sigObj = createSigObjAutosar4('TestSignal', 'DataType', 'boolean', 'Description', '测试信号');
%       
%       % 设置数值范围
%       sigObj = createSigObjAutosar4('TestSignal', 'Min', 0, 'Max', 100, 'Unit', 'V');
%       
%       % 创建输入信号（使用Auto模式）
%       sigObj = createSigObjAutosar4('InputSignal', 'sigType', 'Inport', 'Description', '输入信号');
%       
%       % 创建输出信号（使用Auto模式）
%       sigObj = createSigObjAutosar4('OutputSignal', 'sigType', 'Outport', 'Description', '输出信号');
%       
%       % 自定义输入信号存储类
%       sigObj = createSigObjAutosar4('InputSignal', 'sigType', 'Inport', 'StorageClassIn', 'ExportedGlobal');
%       
%       % 自定义输出信号存储类
%       sigObj = createSigObjAutosar4('OutputSignal', 'sigType', 'Outport', 'StorageClassOut', 'Custom');
%
%   NOTES:
%       - 基于AUTOSAR4.Signal创建信号对象，支持完整的信号属性配置
%       - 信号对象将自动加载到基础工作空间
%       - 支持AUTOSAR4特有的CoderInfo属性设置
%
%   See also: AUTOSAR4.Signal, EVALIN
%
%   Author: Blue.ge
%   Date: 2025-09-17
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
    addParameter(p, 'CustomStorageClass', 'Global', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'sigType', '', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'StorageClassIn', 'ImportedExtern', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'StorageClassOut', 'Global', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
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
    storageClassIn = char(p.Results.StorageClassIn);
    storageClassOut = char(p.Results.StorageClassOut);
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
    
    %% 创建信号对象
    try
        if verbose
            fprintf('正在创建信号对象: %s\n', finalSignalName);
        end

        % 创建AUTOSAR4.Signal对象
        evalin('base', [finalSignalName ' = AUTOSAR4.Signal;']);
        
        % 设置基本属性
        evalin('base', [finalSignalName '.DataType = "' dataType '";']);
        evalin('base', [finalSignalName '.Dimensions = ' num2str(dimensions) ';']);

        % 设置AUTOSAR4特有的CoderInfo属性
        evalin('base', [finalSignalName '.CoderInfo.Alias = '''';']);
        evalin('base', [finalSignalName '.CoderInfo.Alignment = -1;']);

        %% 根据sigType和StorageClass参数设置存储类
        if ~isempty(sigType)
            switch lower(sigType)
                case 'inport'
                    % 处理输入信号存储类
                    if strcmpi(storageClassIn, 'Auto')
                        % Auto模式：使用默认规则
                        finalStorageClass = 'Auto';
                        if verbose
                            fprintf('检测到Inport类型，Auto模式自动设置StorageClass为: Auto\n');
                        end
                    else
                        % 非Auto模式：直接使用指定值
                        finalStorageClass = storageClassIn;
                        if verbose
                            fprintf('检测到Inport类型，使用指定的StorageClass: %s\n', finalStorageClass);
                        end
                    end
                    % 更新StorageClass属性
                    evalin('base', [finalSignalName '.CoderInfo.StorageClass = "' finalStorageClass '";']);
                    
                case 'outport'
                    % 处理输出信号存储类
                    if strcmpi(storageClassOut, 'Auto')
                        % Auto模式：使用默认规则
                        finalStorageClass = 'Auto';
                        if verbose
                            fprintf('检测到Outport类型，Auto模式自动设置StorageClass为: %s, CustomStorageClass为: %s\n', finalStorageClass, finalCustomStorageClass);
                        end
                        % 更新StorageClass属性
                        evalin('base', [finalSignalName '.CoderInfo.StorageClass = "' finalStorageClass '";']);
                    else
                        % 非Auto模式：直接使用指定值
                        finalStorageClass = 'Custom';
                        finalCustomStorageClass = storageClassOut;
                        if verbose
                            fprintf('检测到Outport类型，使用指定的StorageClass: %s\n', finalStorageClass);
                        end

                        % 更新StorageClass属性
                        evalin('base', [finalSignalName '.CoderInfo.StorageClass = "' finalStorageClass '";']);
                        % 更新CustomStorageClass属性
                        evalin('base', [finalSignalName '.CoderInfo.CustomStorageClass = "' finalCustomStorageClass '";']);
                        % 设置输出存储类属性
                        evalin('base', [finalSignalName '.CoderInfo.CustomAttributes.MemorySection = ''VAR'';']);
                        evalin('base', [finalSignalName '.CoderInfo.CustomAttributes.ConcurrentAccess = false;']);
                    end

            end
        end
        
        
        % 设置描述信息
        if ~isempty(description)
            % 处理换行符
            cleanDescription = strrep(description, char(10), ' ');
            evalin('base', [finalSignalName '.Description = "' cleanDescription '";']);
        end
        
        % 设置单位
        if ~isempty(unit)
            evalin('base', [finalSignalName '.DocUnits = "' unit '";']);
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
        
        % 设置AUTOSAR4特有的默认属性
        evalin('base', [finalSignalName '.DimensionsMode = ''auto'';']);
        evalin('base', [finalSignalName '.Complexity = ''auto'';']);
        evalin('base', [finalSignalName '.SampleTime = -1;']);
        evalin('base', [finalSignalName '.SwCalibrationAccess = ''ReadOnly'';']);
        
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
        error('createSigObjAutosar4:creationError', '创建信号对象失败: %s', ME.message);
    end
end