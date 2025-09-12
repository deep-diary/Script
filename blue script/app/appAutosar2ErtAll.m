function [overallSuccess, results, consolidatedCodePaths] = appAutosar2ErtAll(varargin)
%APPAUTOSAR2ERTALL 将所有AUTOSAR模型转换为ERT模型
%   [OVERALLSUCCESS, RESULTS, CONSOLIDATEDCODEPATHS] = APPAUTOSAR2ERTALL() 将所有AUTOSAR模型转换为ERT模型
%   [OVERALLSUCCESS, RESULTS, CONSOLIDATEDCODEPATHS] = APPAUTOSAR2ERTALL('Parameter', Value, ...) 使用指定参数转换所有模型
%
%   输入参数:
%      无
%
%   可选参数（名值对）:
%      'autosarMode' - AUTOSAR信号名解析模式，可选值: 'deleteTail', 'halfTail', 'justHalf', 'modelHalf'
%                      默认值: 'modelHalf'
%      'combine'     - 是否合并所有代码文件到同一目录，默认值: true
%      'skipErrors'  - 是否跳过错误继续处理其他模型，默认值: true
%      'verbose'     - 是否显示详细输出，默认值: true
%
%   输出参数:
%      overallSuccess     - 整体转换是否成功 (逻辑值)
%      results           - 转换结果详情 (结构体数组)
%                         results(i).modelName  - 模型名称
%                         results(i).success    - 是否成功
%                         results(i).errorMsg   - 错误信息
%                         results(i).codePaths  - 代码路径信息
%                         results(i).summary    - 代码生成摘要
%      consolidatedCodePaths - 合并后的代码路径信息 (结构体)
%                             consolidatedCodePaths.root - 合并根目录
%                             consolidatedCodePaths.c    - C文件目录
%                             consolidatedCodePaths.h    - H文件目录
%                             consolidatedCodePaths.a2l  - A2L文件目录
%
%   功能描述:
%      1. 扫描SubModel目录下的所有子模型
%      2. 逐个调用appAutosar2Ert函数转换每个模型
%      3. 收集所有转换结果和错误信息
%      4. 可选择将所有代码文件合并到统一目录
%      5. 提供详细的转换统计和结果汇总
%
%   示例:
%      % 基本用法
%      [success, results, codePaths] = appAutosar2ErtAll();
%      
%      % 使用不同参数
%      [success, results, codePaths] = appAutosar2ErtAll('autosarMode', 'halfTail', 'combine', false);
%      
%      % 检查结果
%      if success
%          fprintf('所有模型转换成功！\n');
%          fprintf('成功转换 %d 个模型\n', sum([results.success]));
%      else
%          fprintf('部分模型转换失败\n');
%          failedModels = results(~[results.success]);
%          for i = 1:length(failedModels)
%              fprintf('失败模型: %s - %s\n', failedModels(i).modelName, failedModels(i).errorMsg);
%          end
%      end
%
%   注意事项:
%      1. 使用前需要确保配置文件存在
%      2. 配置文件应为.mat格式
%      3. 函数具有完整的错误处理，单个模型失败不会影响其他模型
%      4. 如果配置引用已存在，将更新其源文件
%      5. 合并模式下，所有代码文件将按类型分类存储
%
%   参见: appAutosar2Ert
%
%   作者: Blue.ge
%   版本: 2.0
%   日期: 20250911

    %% 初始化和输入验证
    overallSuccess = false;
    results = struct('modelName', {}, 'success', {}, 'errorMsg', {}, 'codePaths', {}, 'summary', {});
    consolidatedCodePaths = struct();
    
    %% 解析可选参数
    p = inputParser;
    p.FunctionName = mfilename;
    
    validModes = {'deleteTail', 'halfTail', 'justHalf', 'modelHalf'};
    addParameter(p, 'autosarMode', 'modelHalf', @(x) any(validatestring(x, validModes)));
    addParameter(p, 'combine', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'skipErrors', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'verbose', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    
    parse(p, varargin{:});
    autosarMode = p.Results.autosarMode;
    combine = p.Results.combine;
    skipErrors = p.Results.skipErrors;
    verbose = p.Results.verbose;
    
    %% 获取项目路径
    try
        proj = currentProject; 
        rootPath = proj.RootFolder;
        subPath = fullfile(rootPath,'SubModel');
        codePackagePath = fullfile(rootPath,'CodePackage');
        
        % 验证必要路径
        if ~exist(subPath, 'dir')
            error('子模型路径不存在: %s', subPath);
        end
        
        if verbose
            fprintf('=== 开始批量AUTOSAR到ERT转换 ===\n');
            fprintf('项目根路径: %s\n', rootPath);
            fprintf('子模型路径: %s\n', subPath);
            fprintf('AUTOSAR模式: %s\n', autosarMode);
            fprintf('合并模式: %s\n', mat2str(combine));
            fprintf('跳过错误: %s\n', mat2str(skipErrors));
        end
        
    catch ME
        error('初始化失败: %s', ME.message);
    end
    
    %% 扫描子模型目录
    try
        mdNames = dir(subPath);
        % 过滤出目录（跳过 . 和 ..）
        modelDirs = mdNames([mdNames.isdir] & ~strcmp({mdNames.name}, '.') & ~strcmp({mdNames.name}, '..'));
        
        if isempty(modelDirs)
            warning('在子模型目录中未找到任何模型');
            overallSuccess = true; % 没有模型也算成功
            return;
        end
        
        totalModels = length(modelDirs);
        if verbose
            fprintf('找到 %d 个模型待转换\n', totalModels);
        end
        
    catch ME
        error('扫描子模型目录失败: %s', ME.message);
    end
    
    %% 初始化结果存储
    results = struct('modelName', {}, 'success', {}, 'errorMsg', {}, 'codePaths', {}, 'summary', {});
    successCount = 0;
    errorCount = 0;
    
    %% 遍历所有子模型进行转换
    for i = 1:totalModels
        mdName = modelDirs(i).name;
        
        if verbose
            fprintf('\n--- 处理模型 %d/%d: %s ---\n', i, totalModels, mdName);
        end
        
        try
            % 调用单个模型转换函数
            [success, errorMsg, codePaths, summary] = appAutosar2Ert(mdName, ...
                'autosarMode', autosarMode, 'combine', false);
            
            % 记录结果
            results(i).modelName = mdName;
            results(i).success = success;
            results(i).errorMsg = errorMsg;
            results(i).codePaths = codePaths;
            results(i).summary = summary;
            
            if success
                successCount = successCount + 1;
                if verbose
                    fprintf('✓ 模型 "%s" 转换成功\n', mdName);
                end
            else
                errorCount = errorCount + 1;
                if verbose
                    fprintf('✗ 模型 "%s" 转换失败: %s\n', mdName, errorMsg);
                end
                
                if ~skipErrors
                    error('模型 "%s" 转换失败，停止批量转换', mdName);
                end
            end
            
        catch ME
            errorCount = errorCount + 1;
            results(i).modelName = mdName;
            results(i).success = false;
            results(i).errorMsg = sprintf('转换异常: %s', ME.message);
            results(i).codePaths = struct();
            results(i).summary = struct();
            
            if verbose
                fprintf('✗ 模型 "%s" 转换异常: %s\n', mdName, ME.message);
            end
            
            if ~skipErrors
                rethrow(ME);
            end
        end
    end
    
    %% 代码合并（如果启用）
    if combine && successCount > 0
        try
            if verbose
                fprintf('\n--- 开始合并代码文件 ---\n');
            end
            
            % 创建合并目录
            if exist(codePackagePath, 'dir')
                rmdir(codePackagePath, 's');
            end
            mkdir(codePackagePath);
            
            % 创建子目录
            cDir = fullfile(codePackagePath, 'c');
            hDir = fullfile(codePackagePath, 'h');
            a2lDir = fullfile(codePackagePath, 'a2l');
            mkdir(cDir);
            mkdir(hDir);
            mkdir(a2lDir);
            
            % 合并所有成功的代码文件
            for i = 1:length(results)
                if results(i).success && ~isempty(results(i).codePaths)
                    copyCodeFiles(results(i).codePaths, codePackagePath, cDir, hDir, a2lDir, results(i).modelName, verbose);
                end
            end
            
            % 设置合并后的路径信息
            consolidatedCodePaths.root = codePackagePath;
            consolidatedCodePaths.c = cDir;
            consolidatedCodePaths.h = hDir;
            consolidatedCodePaths.a2l = a2lDir;
            
            if verbose
                fprintf('✓ 代码文件合并完成\n');
                fprintf('合并根目录: %s\n', codePackagePath);
            end
            
        catch ME
            warning(ME.identifier, '代码合并失败: %s', ME.message);
            consolidatedCodePaths = struct();
        end
    end
    
    %% 确定整体成功状态
    overallSuccess = (errorCount == 0) || (successCount > 0 && skipErrors);
    
    %% 输出最终统计
    if verbose
        fprintf('\n=== 批量转换完成 ===\n');
        fprintf('总模型数: %d\n', totalModels);
        fprintf('成功转换: %d\n', successCount);
        fprintf('转换失败: %d\n', errorCount);
        if overallSuccess
            fprintf('整体状态: 成功\n');
        else
            fprintf('整体状态: 失败\n');
        end
        
        if errorCount > 0
            fprintf('\n失败的模型:\n');
            failedResults = results(~[results.success]);
            for i = 1:length(failedResults)
                fprintf('  - %s: %s\n', failedResults(i).modelName, failedResults(i).errorMsg);
            end
        end
        
        if combine && overallSuccess
            fprintf('代码合并目录: %s\n', codePackagePath);
        end
        
        fprintf('========================\n');
    end
end

%% 辅助函数：复制代码文件
function copyCodeFiles(sourcePaths, ~, cDir, hDir, a2lDir, modelName, verbose)
    % 复制C文件
    if isfield(sourcePaths, 'c') && exist(sourcePaths.c, 'dir')
        cFiles = dir(fullfile(sourcePaths.c, '*.c'));
        for j = 1:length(cFiles)
            sourceFile = fullfile(sourcePaths.c, cFiles(j).name);
            targetFile = fullfile(cDir, [modelName '_' cFiles(j).name]);
            copyfile(sourceFile, targetFile);
        end
        if verbose && ~isempty(cFiles)
            fprintf('  复制了 %d 个C文件\n', length(cFiles));
        end
    end
    
    % 复制H文件
    if isfield(sourcePaths, 'h') && exist(sourcePaths.h, 'dir')
        hFiles = dir(fullfile(sourcePaths.h, '*.h'));
        for j = 1:length(hFiles)
            sourceFile = fullfile(sourcePaths.h, hFiles(j).name);
            targetFile = fullfile(hDir, [modelName '_' hFiles(j).name]);
            copyfile(sourceFile, targetFile);
        end
        if verbose && ~isempty(hFiles)
            fprintf('  复制了 %d 个H文件\n', length(hFiles));
        end
    end
    
    % 复制A2L文件
    if isfield(sourcePaths, 'a2l') && exist(sourcePaths.a2l, 'dir')
        a2lFiles = dir(fullfile(sourcePaths.a2l, '*.a2l'));
        for j = 1:length(a2lFiles)
            sourceFile = fullfile(sourcePaths.a2l, a2lFiles(j).name);
            targetFile = fullfile(a2lDir, [modelName '_' a2lFiles(j).name]);
            copyfile(sourceFile, targetFile);
        end
        if verbose && ~isempty(a2lFiles)
            fprintf('  复制了 %d 个A2L文件\n', length(a2lFiles));
        end
    end
end
