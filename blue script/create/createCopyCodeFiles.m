function createCopyCodeFiles(codeFiles, mapping, targetPath, varargin)
%CREATECOPYCODEFILES 复制代码文件到目标目录
%   createCopyCodeFiles(codeFiles, mapping, targetPath) 复制代码文件到目标目录
%   createCopyCodeFiles(codeFiles, mapping, targetPath, 'Parameter', Value, ...) 使用指定参数复制文件
%
%   输入参数:
%       codeFiles  - 代码文件列表 (元胞数组，由findCodeFiles函数生成)
%       mapping    - 文件类型映射 (结构体，由findCodeFiles函数生成)
%       targetPath - 目标目录路径 (字符串)
%
%   可选参数（名值对）:
%       'combine'   - 是否合并文件到同一目录 (逻辑值), 默认: true
%       'showInfo'  - 是否显示详细信息 (逻辑值), 默认: true
%       'overwrite' - 是否覆盖已存在的文件 (逻辑值), 默认: false
%
%   功能描述:
%      将findCodeFiles函数找到的代码文件复制到指定目标目录。
%      支持两种模式：合并模式（所有文件复制到同一目录）和分类模式（按文件类型创建子目录）。
%
%   示例:
%       % 基本用法
%       [codeFiles, mapping] = findCodeFiles('CodeGen');
%       createCopyCodeFiles(codeFiles, mapping, 'TargetFolder');
%       
%       % 使用分类模式
%       createCopyCodeFiles(codeFiles, mapping, 'TargetFolder', 'combine', false);
%       
%       % 覆盖已存在文件
%       createCopyCodeFiles(codeFiles, mapping, 'TargetFolder', 'overwrite', true);
%
%   依赖:
%       findCodeFiles - 查找代码文件函数
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2025-10-09
%   版本: 2.0

%% 1. 输入参数验证
if nargin < 3
    error('至少需要提供三个参数：codeFiles, mapping, targetPath');
end

% 验证必需参数
validateattributes(codeFiles, {'cell'}, {'vector'}, mfilename, 'codeFiles', 1);
validateattributes(mapping, {'struct'}, {'scalar'}, mfilename, 'mapping', 2);
validateattributes(targetPath, {'char', 'string'}, {'scalartext'}, mfilename, 'targetPath', 3);

% 转换为字符串
targetPath = char(targetPath);

%% 2. 输入参数解析
p = inputParser;
p.FunctionName = mfilename;

% 添加可选参数
addParameter(p, 'combine', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
addParameter(p, 'showInfo', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
addParameter(p, 'overwrite', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));

% 解析输入
parse(p, varargin{:});

% 提取参数
combine = p.Results.combine;
showInfo = p.Results.showInfo;
overwrite = p.Results.overwrite;

%% 3. 创建目标目录
% 确保目标目录存在
if ~exist(targetPath, 'dir')
    try
        mkdir(targetPath);
        if showInfo
            fprintf('已创建目标目录: %s\n', targetPath);
        end
    catch ME
        error('创建目标目录失败: %s', ME.message);
    end
end

%% 4. 复制文件到目标目录
totalFiles = 0;
skippedFiles = 0;
failedFiles = 0;

try
    if combine
        % 合并模式：所有文件复制到同一目录
        if showInfo
            fprintf('使用合并模式：所有文件将复制到同一目录\n');
        end
        
        for i = 1:length(codeFiles)
            if ~isempty(codeFiles{i})
                % 复制该类型的所有文件到根目录
                for j = 1:length(codeFiles{i})
                    sourceFile = fullfile(codeFiles{i}(j).folder, codeFiles{i}(j).name);
                    targetFile = fullfile(targetPath, codeFiles{i}(j).name);
                    
                    % 检查目标文件是否已存在
                    if exist(targetFile, 'file') && ~overwrite
                        skippedFiles = skippedFiles + 1;
                        if showInfo
                            fprintf('跳过已存在文件: %s\n', codeFiles{i}(j).name);
                        end
                        continue;
                    end
                    
                    try
                        copyfile(sourceFile, targetFile);
                        totalFiles = totalFiles + 1;
                        if showInfo
                            fprintf('复制文件: %s -> %s\n', sourceFile, targetFile);
                        end
                    catch ME
                        failedFiles = failedFiles + 1;
                        warning('createCopyCodeFiles:copyFailed', '复制文件失败: %s\n错误: %s', sourceFile, ME.message);
                    end
                end
            end
        end
    else
        % 分类模式：按文件类型创建子目录
        if showInfo
            fprintf('使用分类模式：按文件类型创建子目录\n');
        end
        
        for i = 1:length(codeFiles)
            if ~isempty(codeFiles{i})
                % 为每种文件类型创建子目录
                typeDir = fullfile(targetPath, mapping.types{i});
                if ~exist(typeDir, 'dir')
                    mkdir(typeDir);
                    if showInfo
                        fprintf('已创建类型目录: %s\n', typeDir);
                    end
                end
                
                % 复制该类型的所有文件
                for j = 1:length(codeFiles{i})
                    sourceFile = fullfile(codeFiles{i}(j).folder, codeFiles{i}(j).name);
                    targetFile = fullfile(typeDir, codeFiles{i}(j).name);
                    
                    % 检查目标文件是否已存在
                    if exist(targetFile, 'file') && ~overwrite
                        skippedFiles = skippedFiles + 1;
                        if showInfo
                            fprintf('跳过已存在文件: %s\n', codeFiles{i}(j).name);
                        end
                        continue;
                    end
                    
                    try
                        copyfile(sourceFile, targetFile);
                        totalFiles = totalFiles + 1;
                        if showInfo
                            fprintf('复制文件: %s -> %s\n', sourceFile, targetFile);
                        end
                    catch ME
                        failedFiles = failedFiles + 1;
                        warning('createCopyCodeFiles:copyFailed', '复制文件失败: %s\n错误: %s', sourceFile, ME.message);
                    end
                end
            end
        end
    end
    
catch ME
    error('文件复制过程中发生错误: %s', ME.message);
end

%% 5. 显示操作结果
if showInfo
    fprintf('\n=== 文件复制操作完成 ===\n');
    fprintf('成功复制: %d 个文件\n', totalFiles);
    if skippedFiles > 0
        fprintf('跳过文件: %d 个文件（已存在且未设置覆盖）\n', skippedFiles);
    end
    if failedFiles > 0
        fprintf('失败文件: %d 个文件\n', failedFiles);
    end
    fprintf('目标目录: %s\n', targetPath);
end
