function Data = findSlddSigLocData(ModelName, hSig, varargin)
%FINDSLDDSIGLOCDATA 构建Signal表格数据，用于保存到Excel
%
%   DATA = FINDSLDDSIGLOCDATA(MODELNAME, HSIG) 根据模型名称和信号线句柄构建
%   信号表格数据。
%
%   DATA = FINDSLDDSIGLOCDATA(MODELNAME, HSIG, 'project', PROJECT) 指定项目类型，
%   返回对应项目的信号表格数据。
%
%   输入参数:
%       MODELNAME - 模型名称 (字符向量或字符串标量)
%       HSIG      - 信号线句柄数组
%       PROJECT   - 项目类型，可选值: 'XCU', 'PCMU', 'VCU', 'CUSTOM'
%                   (默认值: 'XCU')
%
%   输出参数:
%       DATA      - 满足sldd格式的信号数据矩阵
%
%   示例:
%       Data = findSlddSigLocData('ModelName', hSig)
%       Data = findSlddSigLocData('ModelName', hSig, 'project', 'XCU')
%
%   作者: Blue.ge
%   日期: 2024-02-02

% 验证输入参数
validateattributes(ModelName, {'char', 'string'}, {'scalartext'}, mfilename, 'ModelName');
% validateattributes(hSig, {'handle'}, {'vector'}, mfilename, 'hSig');

% 创建输入解析器
p = inputParser;
addParameter(p, 'project', 'XCU', @(x) ismember(x, {'XCU', 'PCMU', 'VCU', 'CUSTOM'}));
parse(p, varargin{:});

% 获取项目类型
project = p.Results.project;

% 检查信号句柄是否为空
if isempty(hSig)
    Data = {};
    return;
end

% 初始化数据矩阵
len = length(hSig);
Data = cell(len, 17);  % 17列数据

% 处理每个信号
for i = 1:len
    h = hSig(i);
    ins = get(h);
    
    % 获取信号类型和存储类信息
    [dataType, ScSig, ~] = findNameStroage(ins.Name, 'project', project);
    
    % 填充数据矩阵
    Data{i,1} = ModelName;  % ModelName
    Data{i,2} = 'Local';    % PortType
    Data{i,3} = ins.Name;   % Name
    Data{i,4} = dataType;   % DataType
    Data{i,5} = ScSig;      % CustomStorageClass
    Data{i,6} = [ModelName '.c'];  % DefinitionFile
    Data{i,7} = '';         % RTE_Interface
    Data{i,8} = '-1';       % Dimensions
    Data{i,9} = '';         % Details
    Data{i,10} = '';        % ValueTable
    Data{i,11} = 'inherit'; % Unit
    Data{i,12} = '';        % IniValue
    Data{i,13} = '[]';      % Min
    Data{i,14} = '[]';      % Max
    Data{i,15} = '';        % DataTypeSelect
    Data{i,16} = '';        % CustomStorageClassSelect
    Data{i,17} = '';        % DefinitionFile
end

end
