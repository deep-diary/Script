function saveSlddTable(ModelName, Data, varargin)
%SAVESLDDTABLE 将SLDD数据保存为Excel表格
%
%   SAVESLDDTABLE(MODELNAME, DATA) 将SLDD数据保存为Excel表格。
%
%   SAVESLDDTABLE(MODELNAME, DATA, 'project', PROJECT) 指定项目类型，
%   将数据保存到对应项目的Excel文件中。
%
%   输入参数:
%       MODELNAME   - 模型名称 (字符向量或字符串标量)
%       DATA        - SLDD数据 (表格)
%
%   可选参数:
%       'project'   - 项目类型，可选值: 'XCU', 'PCMU', 'VCU', 'CUSTOM'
%                    (默认值: 'PCMU')
%       'dataType'  - 数据类型，可选值: '1D', '2D'
%                    (默认值: '1D')
%       'overwrite' - 是否覆盖现有文件，可选值: true, false
%                    (默认值: true)
%       'solveTabInputName' - 是否解析表格输入名称，可选值: true, false
%                           (默认值: false)
%
%   示例:
%       saveSlddTable('MyModel', Data, 'project', 'XCU')
%       saveSlddTable('MyModel', Data, 'dataType', '2D', 'overwrite', false)
%
%   作者: Blue.ge
%   日期: 2023-10-26
%   版本: 1.2

% 验证输入参数
validateattributes(ModelName, {'char', 'string'}, {'scalartext'}, mfilename, 'ModelName');
% validateattributes(Data, {'table'}, {}, mfilename, 'Data');

% 创建输入解析器
p = inputParser;
addParameter(p, 'project', 'PCMU', ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(p, 'dataType', '1D', ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(p, 'overwrite', true, @islogical);
addParameter(p, 'solveTabInputName', false, @islogical);
parse(p, varargin{:});

% 获取解析后的参数
project = p.Results.project;
dataType = p.Results.dataType;
overwrite = p.Results.overwrite;
solveTabInputName = p.Results.solveTabInputName;

% 验证项目类型
validProjects = {'XCU', 'PCMU', 'VCU', 'CUSTOM'};
if ~ismember(project, validProjects)
    error('saveSlddTable:InvalidProject', ...
        '项目类型必须是以下之一: %s', strjoin(validProjects, ', '));
end

% 验证数据类型
validTypes = {'1D', '2D'};
if ~ismember(dataType, validTypes)
    error('saveSlddTable:InvalidDataType', ...
        '数据类型必须是以下之一: %s', strjoin(validTypes, ', '));
end

% 处理模型名称
if contains(ModelName, "/")
    slashes = strfind(ModelName, "/");
    ModelName = extractAfter(ModelName, slashes(end));
end

% 构建文件路径
[modFold,name,ext] = fileparts(which(ModelName));
if overwrite
    filename = [ModelName '_DD_' project '.xlsx'];
else
    filename = [ModelName '_DD_' project '_EXPORT.xlsx'];
    
end
fSldd = fullfile(modFold, filename);

% 处理工作表名称
sheet = dataType;
if strlength(sheet) >= 31
    sheet = sheet(1:30);
end

try
    % 根据数据类型处理数据
    if strcmp(dataType, '1D')
        stData = process1DData(Data, solveTabInputName);
    else % '2D'
        stData = process2DData(Data, solveTabInputName);
    end
    
    % 保存数据到Excel
    writecell(stData, fSldd, 'Sheet', sheet, 'WriteMode', 'overwritesheet');
    
catch ME
    error('saveSlddTable:Error', '保存SLDD数据时发生错误: %s', ME.message);
end

end

function stData = process1DData(Data, solveTabInputName)
% 处理1D数据
rows = size(Data, 1);
stData = cell(rows/2*3, 10);

for i = 1:2:rows
    idy = 4*(i-1)/2+1;
    data = Data(i,:);
    X = Data(i+1,:);
    
    name = data{3};
    nameX = X{3};
    value = data{12};
    valueX = X{12};
    
    % 转换数值
    if ischar(value)
        value = str2num(value);
    end
    if ischar(valueX)
        valueX = str2num(valueX);
    end
    widX = length(valueX);
    
    % 处理表格输入名称
    if solveTabInputName
        try
            variables = Simulink.findVars(bdroot, ...
                'SourceType', 'base workspace', ...
                'SearchMethod', 'cached', ...
                'Name', name);
            path = variables(1).Users{1};
            [X,~] = findTableInputType(path);
            nameX = X.name;
        catch
            % 如果查找失败，保持原始名称
        end
    end
    
    % 填充数据
    stData{idy,1} = data{9};  % description
    stData{idy,2} = widX;     % 宽度
    stData{idy+1,1} = nameX;
    stData(idy+1,2:widX+1) = num2cell(valueX);
    stData{idy+2,1} = name;
    stData(idy+2,2:widX+1) = num2cell(value);
end
end

function stData = process2DData(Data, solveTabInputName)
% 处理2D数据
rows = size(Data, 1);
idy = 1;
stData = {};

for i = 1:3:rows
    data = Data(i,:);
    X = Data(i+1,:);
    Y = Data(i+2,:);
    
    name = data{3};
    nameX = X{3};
    nameY = Y{3};
    value = data{12};
    valueX = X{12};
    valueY = Y{12};
    
    % 转换数值
    if ischar(value)
        value = str2num(value);
    end
    if ischar(valueX)
        valueX = str2num(valueX);
    end
    if ischar(valueY)
        valueY = str2num(valueY);
    end
    widX = length(valueX);
    widY = length(valueY);
    
    % 处理表格输入名称
    if solveTabInputName
        try
            variables = Simulink.findVars(bdroot, ...
                'SourceType', 'base workspace', ...
                'SearchMethod', 'cached', ...
                'Name', name);
            path = variables(1).Users{1};
            [X,Y] = findTableInputType(path);
            nameX = X.name;
            nameY = Y.name;
        catch
            % 如果查找失败，保持原始名称
        end
    end
    
    % 填充数据
    stData{idy,1} = data{9};  % description
    stData{idy+1,1} = nameX;
    stData{idy,3} = widX;     % 宽度
    stData{idy+1,1} = nameY;
    stData{idy+1,2} = name;
    stData(idy+1,3:3+widX-1) = num2cell(valueX);
    stData{idy+2,1} = widY;
    stData(idy+2:idy+2+widY-1,2) = num2cell(valueY);
    stData(idy+2:idy+2+widY-1,3:3+widX-1) = num2cell(value);
    
    idy = idy + widY + 3;
end
end