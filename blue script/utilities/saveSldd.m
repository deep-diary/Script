function fSldd = saveSldd(ModelName, Data, varargin)
%SAVESLDD 将信号或参数数据保存到Excel文件中
%
%   FSLDD = SAVESLDD(MODELNAME, DATA) 将数据保存到Excel文件中。
%
%   FSLDD = SAVESLDD(MODELNAME, DATA, 'project', PROJECT) 指定项目类型，
%   将数据保存到对应项目的Excel文件中。
%
%   输入参数:
%       MODELNAME - 模型名称 (字符向量或字符串标量)
%       DATA      - 要保存的数据矩阵
%       PROJECT   - 项目类型，可选值: 'XCU', 'PCMU', 'VCU', 'CUSTOM'
%                   (默认值: 'XCU')
%
%   可选参数:
%       'dataType'    - 数据类型，可选值: 'Signals', 'Parameters'
%                      (默认值: 'Signals')
%       'overwrite'   - 是否覆盖现有文件，可选值: true, false
%                      (默认值: true)
%
%   输出参数:
%       FSLDD     - 保存的文件完整路径
%
%   示例:
%       fSldd = saveSldd('ModelName', Data)
%       fSldd = saveSldd('ModelName', Data, 'project', 'XCU', 'dataType', 'Signals')
%
%   作者: Blue.ge
%   日期: 2023-10-10

% 验证输入参数
validateattributes(ModelName, {'char', 'string'}, {'scalartext'}, mfilename, 'ModelName');
validateattributes(Data, {'cell'}, {'2d'}, mfilename, 'Data');

% 创建输入解析器
p = inputParser;
addParameter(p, 'project', 'XCU', @(x) ismember(x, {'XCU', 'PCMU', 'VCU', 'CUSTOM'}));
addParameter(p, 'dataType', 'Signals', @(x) ismember(x, {'Signals', 'Parameters'}));
addParameter(p, 'overwrite', true, @islogical);
parse(p, varargin{:});

% 获取解析后的参数
project = p.Results.project;
dataType = p.Results.dataType;
overwrite = p.Results.overwrite;

% 处理模型名称
if contains(ModelName, "/")
    slashes = strfind(ModelName, "/");
    ModelName = extractAfter(ModelName, slashes(end));
end

% 获取模型路径
modPath = which(ModelName);
modFold = fileparts(modPath);

% 构建文件名
if overwrite
    fileName = [ModelName '_DD_' project '.xlsx'];
else
    fileName = [ModelName '_DD_' project '_EXPORT.xlsx'];
end

% 构建完整文件路径
fSldd = fullfile(modFold, fileName);

% 处理工作表名称
sheet = dataType;
if strlength(sheet) >= 31
    sheet = sheet(1:30);
end

% 合并标题
dataTitle = {'ModelName', 'PortType', 'Name', 'DataType', 'CustomStorageClass', ...
    'DefinitionFile', 'RTE_Interface', 'Dimensions', 'Details', 'ValueTable', ...
    'Unit', 'IniValue', 'Min', 'Max', 'DataTypeSelect', ...
    'CustomStorageClassSelect', 'DefinitionFile'};
DataWithTitle = [dataTitle; Data];

% 保存数据到Excel
writecell(DataWithTitle, fSldd, 'Sheet', sheet, 'WriteMode', 'overwritesheet');

end