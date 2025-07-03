function changeModName(pathMd, varargin)
%CHANGEMODNAME 为模型增加层级关系数字
%   CHANGEMODNAME(PATHMD) 为指定路径的模型及其子系统添加层级编号
%   CHANGEMODNAME(PATHMD, PREFIX) 使用指定的前缀添加层级编号
%   CHANGEMODNAME(PATHMD, PREFIX, 'UseLastName', true) 只使用模型名称中最后一个下划线后的部分
%
%   输入参数:
%       pathMd - 模型路径，字符串
%       varargin - 可选参数:
%           prefix - 编号前缀，字符串，默认为空
%           'UseLastName' - 标志，如果设置则只使用模型名称中最后一个下划线后的部分
%
%   示例:
%       % 基本用法
%       changeModName('myModel')
%
%       % 使用前缀
%       changeModName('myModel', 'prefix', 'MOD_')
%
%       % 使用前缀并只保留最后部分名称
%       changeModName('myModel', 'prefix', 'MOD_', 'UseLastName', true)
%
%   作者: Blue.ge
%   日期: 20250609

    % 解析输入参数
    p = inputParser;
    addRequired(p, 'pathMd', @ischar);
    addParameter(p, 'prefix', '', @ischar);
    addParameter(p, 'UseLastName', false);
    parse(p, pathMd, varargin{:});

    prefix = p.Results.prefix;
    useLastName = p.Results.UseLastName;

    % 开始递归处理
    processSubsystem(pathMd, prefix, '', useLastName);
end

function processSubsystem(pathMd, prefix, parentNumber, useLastName)
    % 获取当前模型句柄
    hMd = get_param(pathMd, 'Handle');
    mdBlock = get(hMd);
    
    % 获取所有子系统
    allSubSystems = find_system(pathMd, 'SearchDepth', 1, 'BlockType', 'SubSystem');
    
    % 过滤掉带有mask的子系统
    subSystems = {};
    for i = 2:length(allSubSystems)
        if strcmp(get_param(allSubSystems{i}, 'Mask'), 'off')
            subSystems{end+1} = allSubSystems{i};
        end
    end
    
    % 处理每个子系统
    for i = 1:length(subSystems)
        % 构建新的编号
        currentNumber = [parentNumber, num2str(i)];
        
        % 获取原始名称
        originalName = get_param(subSystems{i}, 'Name');
        
        % 如果需要只使用最后部分名称
        if useLastName
            parts = strsplit(originalName, '_');
            originalName = parts{end};
        end
        
        % 构建新名称
        newName = [prefix, currentNumber, '_', originalName];
        
        % 设置新名称
        set_param(subSystems{i}, 'Name', newName);
        
        % 获取新的子系统路径
        newPath = [pathMd, '/', newName];
        
        % 递归处理子系统
        processSubsystem(newPath, prefix, currentNumber, useLastName);
    end
end