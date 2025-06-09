function [fSlddList, DataList] = findSlddSig(pathMd, varargin)
%FINDSLDDSIG 获取模型的信号数据并保存到Excel文件中
%
%   [FSLDDLIST, DATALIST] = FINDSLDDSIG(PATHMD) 获取指定模型的信号数据并保存。
%
%   [FSLDDLIST, DATALIST] = FINDSLDDSIG(PATHMD, 'projectList', PROJECTLIST) 
%   指定项目列表，获取对应项目的信号数据并保存。
%
%   输入参数:
%       PATHMD      - 模型路径 (字符向量或字符串标量)
%       PROJECTLIST - 项目列表，可选值: {'PCMU','VCU','XCU'} 的子集
%                    (默认值: {'PCMU','VCU','XCU'})
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
%       [fSlddList, DataList] = findSlddSig('TmComprCtrlDev')
%       [fSlddList, DataList] = findSlddSig('TmComprCtrlDev', 'projectList', {'XCU'})
%
%   作者: Blue.ge
%   日期: 2024-02-02

% 验证输入参数
validateattributes(pathMd, {'char', 'string'}, {'scalartext'}, mfilename, 'pathMd');

% 创建输入解析器
p = inputParser;
addParameter(p, 'overwrite', false, @islogical);
addParameter(p, 'projectList', {'PCMU','VCU','XCU'}, ...
    @(x) all(ismember(x, {'PCMU','VCU','XCU'})));
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

% 获取内部信号线数据
sigLocList = cell(1, projNum);
subSysPath = find_system(pathMd, 'SearchDepth', 1, 'BlockType', 'SubSystem');
signalHandles = [];

% 收集所有子系统的信号句柄
for i = 1:length(subSysPath)
    handles = findResolvedSignals(subSysPath{i});
    signalHandles = [signalHandles handles];
end

% 获取每个项目的内部信号数据
for i = 1:projNum
    project = projectList{i};
    sigLocList{i} = findSlddSigLocData(ModelName, signalHandles, ...
        'project', project);
end

% 合并并保存数据
for i = 1:projNum
    project = projectList{i};
    % 合并端口信号和内部信号数据
    DataList{i} = [sigPortList{i}; sigLocList{i}];
    
    % 保存数据到Excel
    fSlddList{i} = saveSldd(ModelName, DataList{i}, ...
        'project', project, ...
        'dataType', 'Signals', ...
        'overwrite', overwrite);
end

end