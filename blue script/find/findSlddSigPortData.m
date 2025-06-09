function Data = findSlddSigPortData(ModelName, portsPath, varargin)
%FINDSLDDSIGPORTDATA 构建端口信号表格数据，用于保存到Excel
%
%   DATA = FINDSLDDSIGPORTDATA(MODELNAME, PORTSPATH) 根据模型名称和端口路径构建
%   端口信号表格数据。
%
%   DATA = FINDSLDDSIGPORTDATA(MODELNAME, PORTSPATH, 'project', PROJECT) 指定项目类型，
%   返回对应项目的端口信号表格数据。
%
%   输入参数:
%       MODELNAME - 模型名称 (字符向量或字符串标量)
%       PORTSPATH - 模型中所有端口的路径 (元胞数组)
%       PROJECT   - 项目类型，可选值: 'XCU', 'PCMU', 'VCU', 'CUSTOM'
%                   (默认值: 'XCU')
%
%   输出参数:
%       DATA      - 满足sldd格式的端口信号数据矩阵
%
%   示例:
%       Data = findSlddSigPortData('ModelName', portsPath)
%       Data = findSlddSigPortData('ModelName', portsPath, 'project', 'XCU')
%
%   作者: Blue.ge
%   日期: 2023-10-27

% 验证输入参数
validateattributes(ModelName, {'char', 'string'}, {'scalartext'}, mfilename, 'ModelName');
validateattributes(portsPath, {'cell'}, {'vector'}, mfilename, 'portsPath');

% 创建输入解析器
p = inputParser;
addParameter(p, 'project', 'XCU', @(x) ismember(x, {'XCU', 'PCMU', 'VCU', 'CUSTOM'}));
parse(p, varargin{:});

% 获取项目类型
project = p.Results.project;

% 检查端口路径是否为空
if isempty(portsPath)
    warning('findSlddSigPortData:EmptyPortsPath', ...
        '端口路径为空，请提供有效的端口路径');
    Data = {};
    return;
end

% 初始化数据矩阵
len = length(portsPath);
Data = cell(len, 17);  % 17列数据

% 处理每个端口
iniValue = '';
for i = 1:len
    % 获取端口句柄和属性
    h = get_param(portsPath{i}, 'Handle');
    ins = get(h);
    
    % 根据端口类型设置属性
    if strcmp(ins.BlockType, 'Inport')
        portType = 'Input';
    elseif strcmp(ins.BlockType, 'Outport')
        portType = 'Output';
    else
        warning('findSlddSigPortData:UnknownPortType', ...
            '未知的端口类型: %s', ins.BlockType);
        continue;
    end
    
    % 获取信号类型和存储类信息
    [~, ScSig, ~] = findNameStroage(ins.Name, 'project', project, 'portType', 'Input');
    
    
    % 填充数据矩阵
    Data{i,1} = ModelName;           % ModelName
    Data{i,2} = portType;           % PortType
    Data{i,3} = ins.Name;           % Name
    Data{i,4} = ins.OutDataTypeStr; % DataType
    Data{i,5} = ScSig;              % CustomStorageClass
    Data{i,6} = [ModelName '.c'];   % DefinitionFile
    Data{i,7} = '';                 % RTE_Interface
    Data{i,8} = ins.PortDimensions; % Dimensions
    Data{i,9} = '';                 % Details
    Data{i,10} = '';                % ValueTable
    Data{i,11} = ins.Unit;          % Unit
    Data{i,12} = iniValue;          % IniValue
    Data{i,13} = ins.OutMin;        % Min
    Data{i,14} = ins.OutMax;        % Max
    Data{i,15} = '';                % DataTypeSelect
    Data{i,16} = '';                % CustomStorageClassSelect
    Data{i,17} = '';                % DefinitionFile
end

end
