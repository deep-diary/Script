function [fSlddList, DataList] = findSlddParam(path, varargin)
%FINDSLDDPARAM 获取模型的参数数据并保存到Excel文件中
%
%   [FSLDDLIST, DATALIST] = FINDSLDDPARAM(PATH) 获取指定模型的参数数据并保存。
%
%   [FSLDDLIST, DATALIST] = FINDSLDDPARAM(PATH, 'projectList', PROJECTLIST) 
%   指定项目列表，获取对应项目的参数数据并保存。
%
%   输入参数:
%       PATH        - 模型路径 (字符向量或字符串标量)
%       PROJECTLIST - 项目列表，可选值: {'PCMU','VCU','XCU'} 的子集
%                    (默认值: {'PCMU','VCU','XCU'})
%
%   可选参数:
%       'overwrite' - 是否覆盖现有文件，可选值: true, false
%                    (默认值: false)
%
%   输出参数:
%       FSLDDLIST   - 保存的文件路径列表 (元胞数组)
%       DATALIST    - 参数数据列表 (元胞数组)
%
%   示例:
%       [fSlddList, DataList] = findSlddParam('TmComprCtrl')
%       [fSlddList, DataList] = findSlddParam('TmComprCtrl', 'projectList', {'XCU'})
%
%   作者: Blue.ge
%   日期: 2023-10-09

% 验证输入参数
validateattributes(path, {'char', 'string'}, {'scalartext'}, mfilename, 'path');

% 创建输入解析器
p = inputParser;
addParameter(p, 'overwrite', false, @islogical);
addParameter(p, 'projectList', {'PCMU','VCU','XCU'}, ...
    @(x) all(ismember(x, {'PCMU','VCU','XCU'})));
parse(p, varargin{:});

% 获取解析后的参数
overwrite = p.Results.overwrite;
projectList = p.Results.projectList;

% 获取系统参数
[PathAll, parameters] = findParameters(path);

% 初始化输出列表
projNum = length(projectList);
fSlddList = cell(1, projNum);
DataList = cell(1, projNum);

% 处理每个项目的参数数据
for i = 1:projNum
    project = projectList{i};
    % 获取参数数据
    DataList{i} = findSlddParamData(path, parameters, 'project', project);
    
    % 保存参数数据到Excel
    fSlddList{i} = saveSldd(path, DataList{i}, ...
        'project', project, ...
        'dataType', 'Parameters', ...
        'overwrite', overwrite);
end

% 获取查找表参数
[PathLookup1D, PathLookup2D, Param1DLoopUp, Param2DLoopUp] = findParamLookupAll(bdroot);

% 处理1维查找表数据
for i = 1:projNum
    project = projectList{i};
    % 获取1维查找表数据
    Data1D = findParameterSlddData(bdroot, Param1DLoopUp);
    
    % 保存1维查找表数据
    saveSlddTable(path, Data1D, ...
        'project', project, ...
        'dataType', '1D', ...
        'overwrite', overwrite);
end

% 处理2维查找表数据
for i = 1:projNum
    project = projectList{i};
    % 获取2维查找表数据
    Data2D = findParameterSlddData(bdroot, Param2DLoopUp);
    
    % 保存2维查找表数据
    saveSlddTable(path, Data2D, ...
        'project', project, ...
        'dataType', '2D', ...
        'overwrite', overwrite);
end

end

