function [fSlddList, DataList] = findSlddSigPort(pathMd, varargin)
%FINDSLDDSIGPORT 获取模型的输入输出信号数据并保存到Excel文件中
%
%   [FSLDDLIST, DATALIST] = FINDSLDDSIGPORT(PATHMD) 获取指定模型的输入输出信号数据并保存。
%
%   [FSLDDLIST, DATALIST] = FINDSLDDSIGPORT(PATHMD, 'projectList', PROJECTLIST) 
%   指定项目列表，获取对应项目的输入输出信号数据并保存。
%
%   输入参数:
%       PATHMD      - 模型路径 (字符向量或字符串标量)
%       PROJECTLIST - 项目列表，可选值: {'PCMU','VCU','XCU','CUSTOM'} 的子集
%                    (默认值: {'CUSTOM'})
%
%   可选参数:
%       'overwrite' - 是否覆盖现有文件，可选值: true, false
%                    (默认值: false)
%
%   输出参数:
%       FSLDDLIST   - 保存的文件路径列表 (元胞数组)
%       DATALIST    - 信号数据列表 (元胞数组)
%
%   示例:
%       [fSlddList, DataList] = findSlddSigPort(bdroot)
%       [fSlddList, DataList] = findSlddSigPort('TmComprCtrlDev')
%       [fSlddList, DataList] = findSlddSigPort('TmComprCtrlDev', 'projectList', {'XCU'})
%
%   作者: Blue.ge
%   日期: 2025-10-16

% 验证输入参数
validateattributes(pathMd, {'char', 'string'}, {'scalartext'}, mfilename, 'pathMd');

% 创建输入解析器
p = inputParser;
addParameter(p, 'overwrite', false, @islogical);
addParameter(p, 'projectList', {'CUSTOM'}, ...
    @(x) all(ismember(x, {'PCMU','VCU','XCU','CUSTOM'})));
parse(p, varargin{:});

% 获取解析后的参数
overwrite = p.Results.overwrite;
projectList = p.Results.projectList;

% 获取模型端口信息
[ModelName, PortsIn, PortsOut] = findModPorts(pathMd);

% 初始化输出列表
projNum = length(projectList);
fSlddList = cell(1, projNum);
DataList = cell(1, projNum);

% 获取端口信号数据
sigPortList = cell(1, projNum);
for i = 1:projNum
    project = projectList{i};
    sigPortList{i} = findSlddSigPortData(ModelName, [PortsIn; PortsOut], ...
        'project', project);
end


% 合并并保存数据
for i = 1:projNum
    project = projectList{i};
    DataList{i} = sigPortList{i};
    fSlddList{i} = saveSldd(ModelName, DataList{i}, ...
        'project', project, ...
        'dataType', 'Signals', ...
        'overwrite', overwrite);
end

end