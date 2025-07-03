function Data = findSlddParamData(ModelName, parameters, varargin)
%FINDSLDDPARAMDATA 构建参数表格数据，用于保存到Excel
%
%   DATA = FINDSLDDPARAMDATA(MODELNAME, PARAMETERS) 根据模型名称和参数列表构建
%   参数表格数据。
%
%   DATA = FINDSLDDPARAMDATA(MODELNAME, PARAMETERS, 'project', PROJECT) 指定项目类型，
%   返回对应项目的参数表格数据。
%
%   输入参数:
%       MODELNAME  - 模型名称 (字符向量或字符串标量)
%       PARAMETERS - 模型中所有参数的列表 (元胞数组)
%       PROJECT    - 项目类型，可选值: 'XCU', 'PCMU', 'VCU', 'CUSTOM'
%                    (默认值: 'XCU')
%
%   输出参数:
%       DATA       - 满足sldd格式的参数数据矩阵
%
%   示例:
%       Data = findSlddParamData('ModelName', parameters)
%       Data = findSlddParamData('ModelName', parameters, 'project', 'XCU')
%
%   作者: Blue.ge
%   日期: 2023-10-27

% 验证输入参数
validateattributes(ModelName, {'char', 'string'}, {'scalartext'}, mfilename, 'ModelName');
validateattributes(parameters, {'cell'}, {'vector'}, mfilename, 'parameters');

% 创建输入解析器
p = inputParser;
addParameter(p, 'project', 'XCU', @(x) ismember(x, {'XCU', 'PCMU', 'VCU', 'CUSTOM'}));
parse(p, varargin{:});

% 获取项目类型
project = p.Results.project;

% 初始化数据矩阵
len = length(parameters);
Data = cell(len, 17);  % 17列数据

% 处理每个参数
for i = 1:len
    name = parameters{i};
    
    % 初始化默认值
    details = '';
    unit = '';
    minVal = '';
    maxVal = '';
    rteInterface = '';
    dimensions = -1;
    iniValue = 0;
    
    try
        % 尝试从工作空间获取参数值
        paramValue = evalin('base', name);
        type = paramValue.DataType;
        dimensions = mat2str(paramValue.Dimensions);
        iniValue = mat2str(paramValue.Value);
        details = paramValue.Description;
        unit = paramValue.Unit;
        minVal = paramValue.Min;
        maxVal = paramValue.Max;
        
    catch
        % 处理查找表参数
        if endsWith(name, '_X')
            tbName = name(1:end-2);
            lookups = find_system(bdroot, 'FollowLinks', 'on', ...
                'BlockType', 'Lookup_n-D', 'Table', tbName);
            try
                [X, ~] = findTableInputType(lookups{1});
                type = X.dataType;
            catch
                warning('findSlddParamData:LookupTableError', ...
                    '无法获取查找表 %s 的输入类型', tbName);
            end
        elseif endsWith(name, '_Y')
            try
                [~, Y] = findTableInputType(lookups{1});
                type = Y.dataType;
            catch
                warning('findSlddParamData:LookupTableError', ...
                    '无法获取查找表 %s 的输出类型', tbName);
            end
        else
            % 使用 findNameStroage 获取类型信息
            [type, ~, ~] = findNameStroage(name, 'project', project);
        end
    end
    
    % 获取存储类信息
    [~, ~, ScParam] = findNameStroage(name, 'project', project);
    
    % 填充数据矩阵
    Data{i,1} = ModelName;           % ModelName
    Data{i,2} = 'Local';            % PortType
    Data{i,3} = name;               % Name
    Data{i,4} = type;               % DataType
    Data{i,5} = ScParam;            % StorageClass
    Data{i,6} = [ModelName '.c'];   % DefinitionFile
    Data{i,7} = rteInterface;       % RTE_Interface
    Data{i,8} = dimensions;         % Dimensions
    Data{i,9} = details;            % Details
    Data{i,10} = '';                % ValueTable
    Data{i,11} = unit;              % Unit
    Data{i,12} = iniValue;          % IniValue
    Data{i,13} = minVal;            % Min
    Data{i,14} = maxVal;            % Max
    Data{i,15} = '';                % DataTypeSelect
    Data{i,16} = '';                % CustomStorageClassSelect
    Data{i,17} = '';                % DefinitionFile
end

end