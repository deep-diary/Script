function [codeFiles, fileTypeMapping] = findCodeFiles(sourcePath, varargin)
%FINDCODEFILES 查找模型中的代码文件并按类型分类
%   [CODEFILES, FILETYPEMAPPING] = FINDCODEFILES(SOURCEPATH) 在指定路径中查找所有代码文件
%   [CODEFILES, FILETYPEMAPPING] = FINDCODEFILES(SOURCEPATH, 'Parameter', Value, ...) 使用指定参数查找代码文件
%
%   输入参数:
%      sourcePath        - 搜索路径 (字符串)
%      
%   输入参数（名值对）:
%      'fileType'        - 文件类型 (字符向量或字符向量元胞数组), 默认值: {'c', 'h', 'a2l'}
%      'showInfo'        - 是否显示代码文件信息 (逻辑值), 默认值: true
%      'recursive'       - 是否递归搜索子目录 (逻辑值), 默认值: true
%
%   输出参数:
%      codeFiles         - 按文件类型分类的代码文件列表 (元胞数组)
%                          codeFiles{1} 包含第一种文件类型的文件
%                          codeFiles{2} 包含第二种文件类型的文件
%                          ...以此类推
%      fileTypeMapping   - 文件类型映射 (结构体)
%                          fileTypeMapping.types 包含所有文件类型
%                          fileTypeMapping.counts 包含每种类型的文件数量
%
%   功能描述:
%      查找指定路径中符合条件的代码文件，按文件类型分类返回。
%      支持递归搜索子目录，可以选择是否显示找到的代码文件的详细信息。
%      返回的元胞数组便于后续将不同类别的代码拷贝到不同的文件夹中。
%
%   示例:
%      [codeFiles, mapping] = findCodeFiles('CodeGen')
%      [codeFiles, mapping] = findCodeFiles('CodeGen', 'fileType', {'c', 'h'}, 'showInfo', true)
%      [codeFiles, mapping] = findCodeFiles('CodeGen', 'recursive', false)
%      
%      % 使用示例：将C文件拷贝到特定文件夹
%      if ~isempty(codeFiles{1})  % C文件
%          copyFilesToFolder(codeFiles{1}, 'C_Files_Folder');
%      end
%
%   参见: DIR, FULLFILE, INPUTPARSER
%
%   作者: Blue.ge
%   版本: 2.1
%   日期: 20250912

    %% 输入参数验证
    narginchk(1, inf);
    validateattributes(sourcePath, {'char', 'string'}, {'scalartext'}, mfilename, 'sourcePath', 1);
    
    % 检查路径是否存在
    if ~isfolder(sourcePath)
        error('findCodeFiles:invalidPath', '指定的路径不存在: %s', sourcePath);
    end
    
    %% 输入参数处理
    p = inputParser;
    p.FunctionName = mfilename;
    
    % 定义参数
    addParameter(p, 'fileType', {'c', 'h', 'a2l'}, @(x) validateFileType(x));
    addParameter(p, 'showInfo', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'recursive', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    
    parse(p, varargin{:});
    
    fileType = p.Results.fileType;
    showInfo = p.Results.showInfo;
    recursive = p.Results.recursive;
    
    % 确保fileType是元胞数组
    if ischar(fileType) || isstring(fileType)
        fileType = {char(fileType)};
    end
    
    % 为用户友好的格式添加通配符
    for i = 1:length(fileType)
        if ~startsWith(fileType{i}, '*')
            fileType{i} = ['*.' fileType{i}];
        end
    end
    
    %% 查找代码文件
    numFileTypes = length(fileType);
    codeFiles = cell(1, numFileTypes);
    fileCounts = zeros(1, numFileTypes);
    
    try
        for i = 1:numFileTypes
            if showInfo
                fprintf('正在查找文件类型: %s\n', fileType{i});
            end
            
            % 根据是否递归选择搜索方式
            if recursive
                searchPattern = fullfile(sourcePath, '**', fileType{i});
            else
                searchPattern = fullfile(sourcePath, fileType{i});
            end
            
            % 查找文件
            currentFiles = dir(searchPattern);
            
            % 过滤掉目录
            currentFiles = currentFiles(~[currentFiles.isdir]);
            
            % 去重（基于完整路径）
            if ~isempty(currentFiles)
                fullPaths = arrayfun(@(x) fullfile(x.folder, x.name), currentFiles, 'UniformOutput', false);
                [~, uniqueIdx] = unique(fullPaths);
                currentFiles = currentFiles(uniqueIdx);
            end
            
            % 存储到对应的元胞数组位置
            codeFiles{i} = currentFiles;
            fileCounts(i) = length(currentFiles);
        end
        
    catch ME
        error('findCodeFiles:searchError', '搜索文件时发生错误: %s', ME.message);
    end
    
    %% 创建文件类型映射
    fileTypeMapping = struct();
    % 保存用户友好的文件类型（去掉*号）
    userFriendlyTypes = cell(1, length(fileType));
    for i = 1:length(fileType)
        if startsWith(fileType{i}, '*.')
            userFriendlyTypes{i} = fileType{i}(3:end);  % 去掉 '*.' 前缀
        else
            userFriendlyTypes{i} = fileType{i};
        end
    end
    fileTypeMapping.types = userFriendlyTypes;
    fileTypeMapping.counts = fileCounts;
    
    %% 显示代码文件信息
    if showInfo
        totalFiles = sum(fileCounts);
        if totalFiles == 0
            fprintf('未找到匹配的文件。\n');
        else
            fprintf('找到 %d 个文件，按类型分类:\n', totalFiles);
            for i = 1:numFileTypes
                if fileCounts(i) > 0
                    fprintf('  %s: %d 个文件\n', userFriendlyTypes{i}, fileCounts(i));
                    for j = 1:length(codeFiles{i})
                        fprintf('    %s\n', fullfile(codeFiles{i}(j).folder, codeFiles{i}(j).name));
                    end
                end
            end
        end
    end
end

%% 辅助函数
function validateFileType(x)
    % 验证文件类型参数
    if isempty(x)
        return;
    end
    
    if ischar(x) || isstring(x)
        % 单个字符串
        validateattributes(x, {'char', 'string'}, {'scalartext'});
    elseif iscell(x)
        % 元胞数组
        validateattributes(x, {'cell'}, {'vector'});
        for i = 1:length(x)
            if ~ischar(x{i}) && ~isstring(x{i})
                error('findCodeFiles:invalidFileType', '文件类型必须是字符向量或字符向量元胞数组');
            end
        end
    else
        error('findCodeFiles:invalidFileType', '文件类型必须是字符向量或字符向量元胞数组');
    end
end