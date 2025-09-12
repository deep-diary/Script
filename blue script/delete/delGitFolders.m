function delGitFolders(rootPath, varargin)
% delGitFolders - 删除指定目录下所有的.git文件夹
%
% 功能: 递归遍历指定目录，删除所有.git子文件夹，以优化工程路径加载性能
%
% 输入参数:
%   rootPath - 要搜索的根目录路径（字符串，必需）
%   varargin - 可选参数对
%     'confirm' - 是否在删除前确认（逻辑值，默认true）
%     'verbose' - 是否显示详细信息（逻辑值，默认true）
%     'dryrun' - 是否只显示将要删除的目录而不实际删除（逻辑值，默认false）
%
% 输出参数: 无
%
% 示例:
%   delGitFolders('D:\MyProject')
%   delGitFolders('D:\MyProject', 'confirm', false, 'verbose', true)
%   delGitFolders('D:\MyProject', 'dryrun', true)  % 只显示不删除
%
% 作者: Blue.ge
% 版本: 1.0
% 日期: 2024年

    % 输入参数解析
    p = inputParser;
    addRequired(p, 'rootPath', @(x) (ischar(x) || isstring(x)) && exist(x, 'dir'));
    addParameter(p, 'confirm', true, @islogical);
    addParameter(p, 'verbose', true, @islogical);
    addParameter(p, 'dryrun', false, @islogical);
    parse(p, rootPath, varargin{:});
    
    confirmDelete = p.Results.confirm;
    verbose = p.Results.verbose;
    dryrun = p.Results.dryrun;
    
    % 将字符串转换为字符数组（如果必要）
    if isstring(rootPath)
        rootPath = char(rootPath);
    end
    
    % 检查根目录是否存在
    if ~exist(rootPath, 'dir')
        error('delGitFolders:InvalidPath', '指定的路径不存在: %s', rootPath);
    end
    
    % 获取绝对路径
    rootPath = fullfile(rootPath);
    
    if verbose
        fprintf('开始搜索.git文件夹...\n');
        fprintf('搜索路径: %s\n', rootPath);
        if dryrun
            fprintf('模式: 预览模式（不会实际删除）\n');
        end
        fprintf('----------------------------------------\n');
    end
    
    % 查找所有.git文件夹
    gitDirs = findGitDirectories(rootPath);
    
    if isempty(gitDirs)
        if verbose
            fprintf('未找到.git文件夹。\n');
        end
        return;
    end
    
    % 显示找到的.git文件夹
    if verbose
        fprintf('找到 %d 个.git文件夹:\n', length(gitDirs));
        for i = 1:length(gitDirs)
            fprintf('  %d. %s\n', i, gitDirs{i});
        end
        fprintf('----------------------------------------\n');
    end
    
    % 确认删除
    if confirmDelete && ~dryrun
        response = input('确定要删除这些.git文件夹吗？(y/N): ', 's');
        if ~strcmpi(response, 'y') && ~strcmpi(response, 'yes')
            fprintf('操作已取消。\n');
            return;
        end
    end
    
    % 执行删除操作
    deletedCount = 0;
    failedDirs = {};
    
    for i = 1:length(gitDirs)
        currentDir = gitDirs{i};
        
        try
            if dryrun
                if verbose
                    fprintf('[预览] 将删除: %s\n', currentDir);
                end
            else
                % 使用MATLAB官方函数删除.git文件夹
                rmdir(currentDir, 's');
                deletedCount = deletedCount + 1;
                if verbose
                    fprintf('[成功] 已删除: %s\n', currentDir);
                end
            end
        catch ME
            failedDirs{end+1} = currentDir;
            if verbose
                fprintf('[失败] 无法删除: %s\n', currentDir);
                fprintf('        错误信息: %s\n', ME.message);
            end
        end
    end
    
    % 显示结果摘要
    if verbose
        fprintf('----------------------------------------\n');
        if dryrun
            fprintf('预览完成。共找到 %d 个.git文件夹将被删除。\n', length(gitDirs));
        else
            fprintf('删除完成。\n');
            fprintf('成功删除: %d 个.git文件夹\n', deletedCount);
            if ~isempty(failedDirs)
                fprintf('删除失败: %d 个.git文件夹\n', length(failedDirs));
                fprintf('失败的.git文件夹:\n');
                for i = 1:length(failedDirs)
                    fprintf('  - %s\n', failedDirs{i});
                end
            end
        end
    end
end

function gitDirs = findGitDirectories(rootPath)
% findGitDirectories - 递归查找所有.git文件夹
%
% 输入:
%   rootPath - 根目录路径
% 输出:
%   gitDirs - .git文件夹的完整路径列表（元胞数组）

    gitDirs = {};
    
    % 获取当前目录下的所有子目录
    try
        dirInfo = dir(rootPath);
        dirNames = {dirInfo([dirInfo.isdir]).name};
        
        % 移除 '.' 和 '..'
        dirNames = dirNames(~strcmp(dirNames, '.') & ~strcmp(dirNames, '..'));
        
        for i = 1:length(dirNames)
            currentPath = fullfile(rootPath, dirNames{i});
            
            % 检查当前目录是否包含.git文件夹
            gitPath = fullfile(currentPath, '.git');
            if exist(gitPath, 'dir')
                % 添加.git文件夹的完整路径
                gitDirs{end+1} = gitPath;
            end
            
            % 递归搜索子目录
            subGitDirs = findGitDirectories(currentPath);
            gitDirs = [gitDirs, subGitDirs];
        end
        
    catch ME
        % 如果无法访问目录，记录错误但继续处理其他目录
        warning('delGitFolders:DirectoryAccess', '无法访问目录: %s\n错误: %s', rootPath, ME.message);
    end
end
