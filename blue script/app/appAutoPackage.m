function appAutoPackage(mainScript, packageName)
%APP_AUTO_PACKAGE 自动分析依赖并创建独立运行包
%   APP_AUTO_PACKAGE(MAINSCRIPT) 分析主脚本的依赖并创建打包
%   APP_AUTO_PACKAGE(MAINSCRIPT, PACKAGENAME) 指定打包名称
%
%   输入参数:
%       MAINSCRIPT - 主脚本文件路径，例如 'appAutosar2Ert.m'
%       PACKAGENAME - 打包目录名称，默认为 'AutoPackage'
%
%   示例:
%       appAutoPackage('appAutosar2Ert.m')
%       appAutoPackage('appAutosar2Ert.m', 'MyPackage')

    if nargin < 1
        error('请提供主脚本文件路径');
    end
    
    if nargin < 2
        packageName = 'AutoPackage';
    end
    
    fprintf('========================================\n');
    fprintf('    自动依赖分析和打包工具\n');
    fprintf('========================================\n');
    fprintf('主脚本: %s\n', mainScript);
    fprintf('打包名称: %s\n', packageName);
    fprintf('----------------------------------------\n');
    
    % 验证主脚本是否存在
    if ~exist(mainScript, 'file')
        error('主脚本文件不存在: %s', mainScript);
    end
    
    % 分析依赖关系
    fprintf('正在分析依赖关系...\n');
    [dependencies, products] = analyze_script_dependencies(mainScript);
    
    % 创建打包目录
    packagePath = fullfile(pwd, packageName);
    if exist(packagePath, 'dir')
        rmdir(packagePath, 's');
    end
    mkdir(packagePath);
    
    % 复制文件
    fprintf('正在复制文件...\n');
    [copiedFiles, failedFiles] = copy_dependencies(dependencies, packagePath);
    
    % 创建辅助文件
    create_package_files(packagePath, mainScript, dependencies, products, copiedFiles, failedFiles);
    
    % 显示结果
    display_results(packagePath, copiedFiles, failedFiles, products);
    
end

function [dependencies, products] = analyze_script_dependencies(mainScript)
%ANALYZE_SCRIPT_DEPENDENCIES 分析脚本的依赖关系

    dependencies = {};
    products = [];
    
    try
        % 使用MATLAB内置函数分析依赖
        [fList, pList] = matlab.codetools.requiredFilesAndProducts(mainScript);
        
        % 过滤掉MATLAB内置函数和工具箱函数
        dependencies = filter_dependencies(fList);
        products = pList;
        
        fprintf('找到 %d 个依赖文件\n', length(dependencies));
        fprintf('需要 %d 个工具箱\n', length(products));
        
    catch ME
        fprintf('自动依赖分析失败: %s\n', ME.message);
        fprintf('尝试手动分析...\n');
        
        % 手动分析依赖
        dependencies = manual_dependency_analysis(mainScript);
    end
    
end

function filteredDeps = filter_dependencies(dependencies)
%FILTER_DEPENDENCIES 过滤依赖文件，只保留项目文件

    filteredDeps = {};
    projectRoot = pwd;
    
    for i = 1:length(dependencies)
        depFile = dependencies{i};
        
        % 检查是否是项目内的文件
        if contains(depFile, projectRoot)
            % 转换为相对路径
            relativePath = strrep(depFile, [projectRoot filesep], '');
            filteredDeps{end+1} = relativePath;
        end
    end
    
end

function dependencies = manual_dependency_analysis(mainScript)
%MANUAL_DEPENDENCY_ANALYSIS 手动分析依赖关系

    dependencies = {};
    processedFiles = {};
    filesToProcess = {mainScript};
    
    while ~isempty(filesToProcess)
        currentFile = filesToProcess{1};
        filesToProcess(1) = [];
        
        if ismember(currentFile, processedFiles)
            continue;
        end
        
        processedFiles{end+1} = currentFile;
        dependencies{end+1} = currentFile;
        
        % 分析当前文件的依赖
        fileDeps = get_file_dependencies(currentFile);
        
        for i = 1:length(fileDeps)
            depFile = fileDeps{i};
            if ~ismember(depFile, processedFiles) && ~ismember(depFile, filesToProcess)
                filesToProcess{end+1} = depFile;
            end
        end
    end
    
end

function deps = get_file_dependencies(filePath)
%GET_FILE_DEPENDENCIES 获取单个文件的依赖关系

    deps = {};
    
    if ~exist(filePath, 'file')
        return;
    end
    
    try
        % 读取文件内容
        fid = fopen(filePath, 'r', 'n', 'UTF-8');
        if fid == -1
            return;
        end
        
        content = fread(fid, '*char')';
        fclose(fid);
        
        % 查找函数调用模式
        functionPatterns = {
            '(\w+)\s*\(',           % functionName(
            '^(\w+)\s*$',           % functionName at line start
            '(\w+)\s*\([^)]*\)',    % functionName(...)
        };
        
        for i = 1:length(functionPatterns)
            matches = regexp(content, functionPatterns{i}, 'tokens');
            for j = 1:length(matches)
                if ~isempty(matches{j})
                    funcName = matches{j}{1};
                    if ~isempty(funcName)
                        % 查找对应的.m文件
                        funcFile = find_function_file(funcName);
                        if ~isempty(funcFile) && ~ismember(funcFile, deps)
                            deps{end+1} = funcFile;
                        end
                    end
                end
            end
        end
        
    catch ME
        fprintf('分析文件依赖时出错 %s: %s\n', filePath, ME.message);
    end
    
end

function funcFile = find_function_file(funcName)
%FIND_FUNCTION_FILE 查找函数对应的文件

    funcFile = '';
    
    % 在项目目录中查找
    searchDirs = {
        'blue script',
        'config',
        'Lib',
        'Files'
    };
    
    for i = 1:length(searchDirs)
        if exist(searchDirs{i}, 'dir')
            % 递归搜索所有.m文件
            mFiles = find_files_by_pattern(searchDirs{i}, '*.m');
            
            for j = 1:length(mFiles)
                [~, fileName] = fileparts(mFiles{j});
                if strcmp(fileName, funcName)
                    funcFile = mFiles{j};
                    return;
                end
            end
        end
    end
    
    % 检查是否是内置函数
    if exist(funcName, 'builtin') || exist(funcName, 'file')
        % 内置函数，不需要复制
        return;
    end
    
end

function files = find_files_by_pattern(directory, pattern)
%FIND_FILES_BY_PATTERN 递归查找匹配模式的文件

    files = {};
    
    if ~exist(directory, 'dir')
        return;
    end
    
    % 获取目录内容
    dirContents = dir(directory);
    
    for i = 1:length(dirContents)
        item = dirContents(i);
        
        if item.isdir && ~strcmp(item.name, '.') && ~strcmp(item.name, '..')
            % 递归搜索子目录
            subFiles = find_files_by_pattern(fullfile(directory, item.name), pattern);
            files = [files, subFiles];
        elseif ~item.isdir && endsWith(item.name, '.m')
            % 检查是否匹配模式
            if isempty(pattern) || contains(item.name, pattern(2:end-1))
                files{end+1} = fullfile(directory, item.name);
            end
        end
    end
    
end

function [copiedFiles, failedFiles] = copy_dependencies(dependencies, packagePath)
%COPY_DEPENDENCIES 复制依赖文件到打包目录

    copiedFiles = {};
    failedFiles = {};
    
    for i = 1:length(dependencies)
        sourceFile = dependencies{i};
        
        if exist(sourceFile, 'file')
            % 保持相对目录结构
            targetFile = fullfile(packagePath, sourceFile);
            targetDir = fileparts(targetFile);
            
            if ~exist(targetDir, 'dir')
                mkdir(targetDir);
            end
            
            try
                copyfile(sourceFile, targetFile);
                copiedFiles{end+1} = sourceFile;
                fprintf('  ✓ %s\n', sourceFile);
            catch ME
                failedFiles{end+1} = sourceFile;
                fprintf('  ✗ 复制失败: %s - %s\n', sourceFile, ME.message);
            end
        else
            fprintf('  ! 文件不存在: %s\n', sourceFile);
        end
    end
    
end

function create_package_files(packagePath, mainScript, dependencies, products, copiedFiles, failedFiles)
%CREATE_PACKAGE_FILES 创建打包辅助文件

    % 创建启动脚本
    create_startup_script(packagePath, mainScript);
    
    % 创建README文件
    create_readme_file(packagePath, mainScript, dependencies, products, copiedFiles, failedFiles);
    
    % 创建示例脚本
    create_example_script(packagePath, mainScript);
    
    % 创建依赖分析报告
    create_dependency_report(packagePath, dependencies, products, copiedFiles, failedFiles);
    
end

function create_startup_script(packagePath, mainScript)
%CREATE_STARTUP_SCRIPT 创建启动脚本

    startupFile = fullfile(packagePath, 'start_package.m');
    [~, mainName] = fileparts(mainScript);
    
    fid = fopen(startupFile, 'w', 'n', 'UTF-8');
    if fid == -1
        return;
    end
    
    fprintf(fid, 'function start_package()\n');
    fprintf(fid, '%%START_PACKAGE 启动独立运行包\n');
    fprintf(fid, '%%   自动添加路径并启动主函数\n\n');
    fprintf(fid, '    fprintf(''========================================\\n'');\n');
    fprintf(fid, '    fprintf(''    启动独立运行包\\n'');\n');
    fprintf(fid, '    fprintf(''========================================\\n'');\n\n');
    fprintf(fid, '    % 获取当前脚本所在目录\n');
    fprintf(fid, '    scriptDir = fileparts(mfilename(''fullpath''));\n\n');
    fprintf(fid, '    % 添加所有子目录到路径\n');
    fprintf(fid, '    addpath(genpath(scriptDir));\n\n');
    fprintf(fid, '    fprintf(''路径已添加，可以运行主函数\\n'');\n');
    fprintf(fid, '    fprintf(''主函数: %s\\n'');\n', mainName);
    fprintf(fid, '    fprintf(''使用方法: %s(参数)\\n'');\n', mainName);
    fprintf(fid, '    fprintf(''========================================\\n'');\n\n');
    fprintf(fid, 'end\n');
    
    fclose(fid);
    
end

function create_readme_file(packagePath, mainScript, dependencies, products, copiedFiles, failedFiles)
%CREATE_README_FILE 创建README文件

    readmeFile = fullfile(packagePath, 'README.md');
    [~, mainName] = fileparts(mainScript);
    
    fid = fopen(readmeFile, 'w', 'n', 'UTF-8');
    if fid == -1
        return;
    end
    
    fprintf(fid, '# %s 独立运行包\n\n', mainName);
    fprintf(fid, '这是一个包含%s函数及其所有依赖的独立运行包。\n\n', mainName);
    
    fprintf(fid, '## 使用方法\n\n');
    fprintf(fid, '### 方法1: 使用启动脚本（推荐）\n');
    fprintf(fid, '```matlab\n');
    fprintf(fid, 'start_package();\n');
    fprintf(fid, '%s(参数);\n', mainName);
    fprintf(fid, '```\n\n');
    
    fprintf(fid, '### 方法2: 手动添加路径\n');
    fprintf(fid, '```matlab\n');
    fprintf(fid, 'addpath(genpath(pwd));\n');
    fprintf(fid, '%s(参数);\n', mainName);
    fprintf(fid, '```\n\n');
    
    fprintf(fid, '## 包含的文件\n\n');
    fprintf(fid, '### 成功复制的文件 (%d个):\n', length(copiedFiles));
    for i = 1:length(copiedFiles)
        fprintf(fid, '- %s\n', copiedFiles{i});
    end
    
    if ~isempty(failedFiles)
        fprintf(fid, '\n### 复制失败的文件 (%d个):\n', length(failedFiles));
        for i = 1:length(failedFiles)
            fprintf(fid, '- %s\n', failedFiles{i});
        end
    end
    
    fprintf(fid, '\n## 需要的工具箱\n\n');
    for i = 1:length(products)
        fprintf(fid, '- %s\n', products(i).Name);
    end
    
    fprintf(fid, '\n## 注意事项\n\n');
    fprintf(fid, '1. 确保MATLAB版本兼容\n');
    fprintf(fid, '2. 确保所需的工具箱已安装\n');
    fprintf(fid, '3. 确保所有依赖文件存在\n');
    fprintf(fid, '4. 确保有足够的磁盘空间\n\n');
    
    fclose(fid);
    
end

function create_example_script(packagePath, mainScript)
%CREATE_EXAMPLE_SCRIPT 创建示例脚本

    exampleFile = fullfile(packagePath, 'run_example.m');
    [~, mainName] = fileparts(mainScript);
    
    fid = fopen(exampleFile, 'w', 'n', 'UTF-8');
    if fid == -1
        return;
    end
    
    fprintf(fid, 'function run_example()\n');
    fprintf(fid, '%%RUN_EXAMPLE 运行%s示例\n', mainName);
    fprintf(fid, '%%   演示如何使用%s函数\n\n', mainName);
    fprintf(fid, '    fprintf(''========================================\\n'');\n');
    fprintf(fid, '    fprintf(''    %s 示例\\n'');\n', mainName);
    fprintf(fid, '    fprintf(''========================================\\n'');\n\n');
    fprintf(fid, '    %% 添加路径\n');
    fprintf(fid, '    addpath(genpath(pwd));\n\n');
    fprintf(fid, '    %% 示例用法\n');
    fprintf(fid, '    fprintf(''示例: 运行%s函数\\n'');\n', mainName);
    fprintf(fid, '    try\n');
    fprintf(fid, '        %% 在这里添加具体的函数调用示例\n');
    fprintf(fid, '        %% %s(参数);\n', mainName);
    fprintf(fid, '        fprintf(''请根据实际需要修改此示例\\n'');\n');
    fprintf(fid, '    catch ME\n');
    fprintf(fid, '        fprintf(''执行出错: %%s\\n'', ME.message);\n');
    fprintf(fid, '    end\n\n');
    fprintf(fid, '    fprintf(''========================================\\n'');\n');
    fprintf(fid, '    fprintf(''    示例完成\\n'');\n');
    fprintf(fid, '    fprintf(''========================================\\n'');\n\n');
    fprintf(fid, 'end\n');
    
    fclose(fid);
    
end

function create_dependency_report(packagePath, dependencies, products, copiedFiles, failedFiles)
%CREATE_DEPENDENCY_REPORT 创建依赖分析报告

    reportFile = fullfile(packagePath, 'dependency_report.txt');
    
    fid = fopen(reportFile, 'w', 'n', 'UTF-8');
    if fid == -1
        return;
    end
    
    fprintf(fid, '依赖分析报告\n');
    fprintf(fid, '============\n');
    fprintf(fid, '生成时间: %s\n\n', datestr(now));
    
    fprintf(fid, '依赖文件列表 (%d个):\n', length(dependencies));
    fprintf(fid, '====================\n');
    for i = 1:length(dependencies)
        fprintf(fid, '%d. %s\n', i, dependencies{i});
    end
    
    fprintf(fid, '\n需要的工具箱 (%d个):\n', length(products));
    fprintf(fid, '==================\n');
    for i = 1:length(products)
        fprintf(fid, '- %s\n', products(i).Name);
    end
    
    fprintf(fid, '\n成功复制的文件 (%d个):\n', length(copiedFiles));
    fprintf(fid, '==================\n');
    for i = 1:length(copiedFiles)
        fprintf(fid, '- %s\n', copiedFiles{i});
    end
    
    if ~isempty(failedFiles)
        fprintf(fid, '\n复制失败的文件 (%d个):\n', length(failedFiles));
        fprintf(fid, '==================\n');
        for i = 1:length(failedFiles)
            fprintf(fid, '- %s\n', failedFiles{i});
        end
    end
    
    fclose(fid);
    
end

function display_results(packagePath, copiedFiles, failedFiles, products)
%DISPLAY_RESULTS 显示打包结果

    fprintf('\n========================================\n');
    fprintf('    打包完成\n');
    fprintf('========================================\n');
    fprintf('打包目录: %s\n', packagePath);
    fprintf('成功复制: %d 个文件\n', length(copiedFiles));
    if ~isempty(failedFiles)
        fprintf('复制失败: %d 个文件\n', length(failedFiles));
    end
    fprintf('需要工具箱: %d 个\n', length(products));
    
    fprintf('\n使用方法:\n');
    fprintf('1. 将整个文件夹发送给其他人\n');
    fprintf('2. 在MATLAB中运行 start_package.m\n');
    fprintf('3. 或者直接运行主函数\n');
    fprintf('========================================\n');
    
end
