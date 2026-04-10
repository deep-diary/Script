function [codePaths, summary] = createCodeMod(mdName, varargin)
%CREATECODEMOD 创建模型代码包
%   [CODEPATHS, SUMMARY] = CREATECODEMOD(MDNAME) 为指定的模型创建代码包，并将生成的代码文件整理到相应的目录中。
%   [CODEPATHS, SUMMARY] = CREATECODEMOD(MDNAME, 'Parameter', Value, ...) 使用指定参数创建代码包
%
%   输入参数:
%       mdName - 模型名称，例如 'PrkgClimaEgyMgr'
%
%   可选参数:
%       'type' - 控制器类型，可选值为 'autosar', 'ert', 'autosarharness', 'ertharness'，默认为 'ert'
%       'codeGenPath' - 代码生成根路径，默认为 'CodeGen'
%       'fileTypes' - 要复制的文件类型，默认为 {'c', 'h', 'a2l'}
%       'codeFolder' - 目标代码文件夹名称，默认为 'Src'
%       'combine' - 是否合并所有文件到同一目录，默认为 false
%       'showInfo' - 是否显示详细信息，默认为 true
%
%   输出参数:
%       codePaths - 每个文件类型的目标路径 (结构体)
%                  codePaths.c      - C文件目标路径
%                  codePaths.h      - H文件目标路径
%                  codePaths.a2l    - A2L文件目标路径
%                  codePaths.root   - 根目录路径
%       summary   - 执行摘要 (结构体)
%                  summary.modelName    - 模型名称
%                  summary.totalFiles   - 总文件数
%                  summary.fileTypes    - 文件类型列表
%                  summary.fileCounts   - 各类型文件数量
%                  summary.success      - 执行是否成功
%
%   示例:
%       [codePaths, summary] = createCodeMod('PrkgClimaEgyMgr')
%       [codePaths, summary] = createCodeMod('PrkgClimaEgyMgr', 'type', 'autosar')
%       [codePaths, summary] = createCodeMod('PrkgClimaEgyMgr', 'combine', true)
%       
%       % 使用返回值
%       fprintf('C文件路径: %s\n', codePaths.c);
%       fprintf('H文件路径: %s\n', codePaths.h);
%       fprintf('总文件数: %d\n', summary.totalFiles);
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-05-10
%   版本: 2.1

    %% 输入参数验证
    narginchk(1, inf);
    validateattributes(mdName, {'char', 'string'}, {'scalartext'}, mfilename, 'mdName', 1);
    
    %% 初始化返回值
    codePaths = struct();
    summary = struct();
    summary.modelName = char(mdName);
    summary.success = false;
    summary.totalFiles = 0;
    summary.fileTypes = {};
    summary.fileCounts = [];
    
    %% 输入参数处理
    p = inputParser;
    p.FunctionName = mfilename;
    
    addParameter(p, 'type', 'ert', @(x) any(validatestring(x, {'autosar', 'ert', 'autosarharness', 'ertharness'})));
    addParameter(p, 'codeGenPath', 'CodeGen', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'fileTypes', {'c', 'h', 'a2l'}, @(x) validateFileTypes(x));
    addParameter(p, 'codeFolder', 'Src', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'combine', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'showInfo', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    
    parse(p, varargin{:});
    
    type = p.Results.type;
    codeGenPath = p.Results.codeGenPath;
    fileTypes = p.Results.fileTypes;
    codeFolder = p.Results.codeFolder;
    combine = p.Results.combine;
    showInfo = p.Results.showInfo;
    
    try
        %% 1. 验证模型文件存在
        mdPath = which(mdName);
        if isempty(mdPath)
            error('createCodeMod:modelNotFound', '找不到模型文件: %s', mdName);
        end
        
        if showInfo
            fprintf('找到模型文件: %s\n', mdPath);
        end
        
        %% 2. 创建目标文件夹
        [fold, ~, ~] = fileparts(mdPath);
        codeRoot = fullfile(fold, '../', codeFolder);
        
        % 如果文件夹存在则删除重建
        if exist(codeRoot, 'dir')
            rmdir(codeRoot, 's');
            if showInfo
                fprintf('删除已存在的文件夹: %s\n', codeRoot);
            end
        end
        mkdir(codeRoot);
        if showInfo
            fprintf('创建文件夹: %s\n', codeRoot);
        end
        
        %% 3. 确定源代码路径
        sourcePath = getSourcePath(codeGenPath, type, mdName);

        
        % 验证源路径是否存在
        if ~exist(sourcePath, 'dir')
            error('createCodeMod:sourcePathNotFound', '源代码路径不存在: %s', sourcePath);
        end
        
        if showInfo
            fprintf('源代码路径: %s\n', sourcePath);
        end
        
        %% 4. 获取源代码文件
        [codeFiles, mapping] = findCodeFiles(sourcePath, 'fileType', fileTypes, 'showInfo', showInfo);
        
        %% 5. 复制文件到目标目录
        totalFiles = 0;
        
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
                        targetFile = fullfile(codeRoot, codeFiles{i}(j).name);
                        
                        try
                            copyfile(sourceFile, targetFile);
                            totalFiles = totalFiles + 1;
                            if showInfo
                                fprintf('复制文件: %s -> %s\n', sourceFile, targetFile);
                            end
                        catch ME
                            warning('createCodeMod:copyFailed', '复制文件失败: %s\n错误: %s', sourceFile, ME.message);
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
                    typeDir = fullfile(codeRoot, mapping.types{i});
                    if ~exist(typeDir, 'dir')
                        mkdir(typeDir);
                    end
                    
                    % 复制该类型的所有文件
                    for j = 1:length(codeFiles{i})
                        sourceFile = fullfile(codeFiles{i}(j).folder, codeFiles{i}(j).name);
                        targetFile = fullfile(typeDir, codeFiles{i}(j).name);
                        
                        try
                            copyfile(sourceFile, targetFile);
                            totalFiles = totalFiles + 1;
                            if showInfo
                                fprintf('复制文件: %s -> %s\n', sourceFile, targetFile);
                            end
                        catch ME
                            warning('createCodeMod:copyFailed', '复制文件失败: %s\n错误: %s', sourceFile, ME.message);
                        end
                    end
                end
            end
        end
        
        %% 6. 记录路径信息
        codePaths.root = codeRoot;
        
        if combine
            % 合并模式：所有文件类型都指向根目录
            for i = 1:length(mapping.types)
                codePaths.(mapping.types{i}) = codeRoot;
            end
        else
            % 分类模式：每种文件类型有独立的子目录
            for i = 1:length(mapping.types)
                codePaths.(mapping.types{i}) = fullfile(codeRoot, mapping.types{i});
            end
        end
        
        %% 7. 更新摘要信息
        summary.success = true;
        summary.totalFiles = totalFiles;
        summary.fileTypes = mapping.types;
        summary.fileCounts = mapping.counts;
        
        %% 8. 显示结果摘要
        if showInfo
            fprintf('\n=== 代码包创建完成 ===\n');
            fprintf('目标目录: %s\n', codeRoot);
            fprintf('总文件数: %d\n', totalFiles);
            fprintf('文件类型分布:\n');
            for i = 1:length(mapping.types)
                if mapping.counts(i) > 0
                    fprintf('  %s: %d 个文件 -> %s\n', mapping.types{i}, mapping.counts(i), codePaths.(mapping.types{i}));
                end
            end
        end
        
    catch ME
        % 更新摘要信息为失败状态
        summary.success = false;
        summary.totalFiles = 0;
        summary.fileTypes = {};
        summary.fileCounts = [];
        
        if showInfo
            fprintf('\n=== 代码包创建失败 ===\n');
            fprintf('错误信息: %s\n', ME.message);
        end
        
        % 重新抛出错误，保持原有的错误处理行为
        error('createCodeMod:executionError', '创建代码包时发生错误: %s', ME.message);
    end
end

%% 辅助函数
function sourcePath = getSourcePath(codeGenPath, type, mdName)
    % 根据类型确定源代码路径
    switch type
        case 'ert'
            sourcePath = codeGenPath;
        case 'autosar'
            sourcePath = fullfile(codeGenPath, 'slprj', 'autosar', mdName);
        case 'autosarharness'
            sourcePath = fullfile(codeGenPath, 'slprj', 'autosarharness', mdName);
        case 'ertharness'
            sourcePath = fullfile(codeGenPath, 'slprj', 'ertharness', mdName);
        otherwise
            error('createCodeMod:invalidType', '不支持的类型: %s', type);
    end
    
    % 获取项目路径并添加防错处理
    try
        proj = currentProject;
        if isempty(proj)
            error('createCodeMod:noProject', '当前没有打开的项目');
        end
        projPath = proj.RootFolder;
        
        % 验证项目路径是否存在
        if ~exist(projPath, 'dir')
            error('createCodeMod:invalidProjectPath', '项目路径不存在: %s', projPath);
        end
        
        % 组合完整路径
        sourcePath = fullfile(projPath, sourcePath);
        
    catch ME
        if contains(ME.message, 'noProject') || contains(ME.message, 'invalidProjectPath')
            % 如果没有项目或项目路径无效，尝试使用当前工作目录
            warning('createCodeMod:usingCurrentDir', '无法获取项目路径，使用当前工作目录: %s', ME.message);
            projPath = pwd;
            sourcePath = fullfile(projPath, sourcePath);
        else
            % 其他错误直接抛出
            rethrow(ME);
        end
    end
end

function validateFileTypes(x)
    % 验证文件类型参数
    if isempty(x)
        return;
    end
    
    if ischar(x) || isstring(x)
        validateattributes(x, {'char', 'string'}, {'scalartext'});
    elseif iscell(x)
        validateattributes(x, {'cell'}, {'vector'});
        for i = 1:length(x)
            if ~ischar(x{i}) && ~isstring(x{i})
                error('createCodeMod:invalidFileTypes', '文件类型必须是字符向量或字符向量元胞数组');
            end
        end
    else
        error('createCodeMod:invalidFileTypes', '文件类型必须是字符向量或字符向量元胞数组');
    end
end



