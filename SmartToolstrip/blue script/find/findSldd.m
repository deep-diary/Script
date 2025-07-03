function [fSlddList, DataList] = findSldd(pathMd, varargin)
%FINDSLDD 查找模型中的SLDD数据并保存到Excel文件中
%
%   [FSLDDLIST, DATALIST] = FINDSLDD(PATHMD) 查找指定模型中的SLDD数据，
%   包括信号和参数，并将结果保存到Excel文件中。
%
%   [FSLDDLIST, DATALIST] = FINDSLDD(PATHMD, 'projectList', PROJECTLIST) 
%   指定项目列表，获取对应项目的SLDD数据并保存。
%
%   输入参数:
%       PATHMD      - 模型路径 (字符向量或字符串标量)
%       PROJECTLIST - 项目列表，可选值: {'PCMU','VCU','XCU','CUSTOM'} 的子集
%                    (默认值: {'PCMU','VCU','XCU','CUSTOM'})
%
%   可选参数:
%       'overwrite' - 是否覆盖现有文件，可选值: true, false
%                    (默认值: false)
%
%   输出参数:
%       FSLDDLIST   - 保存的文件路径列表 (元胞数组)
%       DATALIST    - SLDD数据列表 (元胞数组)
%
%   示例:
%       [fSlddList, DataList] = findSldd(bdroot)
%       [fSlddList, DataList] = findSldd(gcs, 'projectList', {'XCU'})
%
%   作者: Blue.ge
%   日期: 2023-10-26
%   版本: 1.2

% 验证输入参数
validateattributes(pathMd, {'char', 'string'}, {'scalartext'}, mfilename, 'pathMd');

% 创建输入解析器
p = inputParser;
addParameter(p, 'overwrite', false, @islogical);
addParameter(p, 'projectList', {'PCMU','VCU','XCU','CUSTOM'}, ...
    @(x) all(ismember(x, {'PCMU','VCU','XCU','CUSTOM'})));
parse(p, varargin{:});

% 获取解析后的参数
overwrite = p.Results.overwrite;
projectList = p.Results.projectList;

try
    % 初始化输出列表
    fSlddList = {};
    DataList = {};
    
    % 查找SLDD信号
    [fSigList, sigDataList] = findSlddSig(pathMd, ...
        'overwrite', overwrite, ...
        'projectList', projectList);
    fSlddList = [fSlddList, fSigList];
    DataList = [DataList, sigDataList];
    
    % 查找SLDD参数
    [fParamList, paramDataList] = findSlddParam(pathMd, ...
        'overwrite', overwrite, ...
        'projectList', projectList);
    fSlddList = [fSlddList, fParamList];
    DataList = [DataList, paramDataList];
    
catch ME
    % 错误处理
    error('findSldd:Error', '查找SLDD数据时发生错误: %s', ME.message);
end

end
