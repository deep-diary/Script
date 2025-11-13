function appCopyCode(varargin)
%APPCOPYCODE 复制模型代码文件到目标路径并可选择删除当前路径下的文件夹
%   APPCOPYCODE() 复制当前路径下的代码文件到 '../Src' 目录，并删除当前路径下的所有文件夹
%   APPCOPYCODE('Parameter', Value, ...) 使用指定参数执行复制操作
%
%   输入参数（名值对）:
%      'targetPath'      - 目标复制路径 (字符串), 默认值: '../Src'
%      'removeFolders'   - 是否删除当前路径下的文件夹 (逻辑值), 默认值: true
%      'fileType'        - 文件类型 (字符向量或字符向量元胞数组), 默认值: {'c', 'h', 'a2l'}
%      'showInfo'        - 是否显示代码文件信息 (逻辑值), 默认值: true
%      'recursive'       - 是否递归搜索子目录 (逻辑值), 默认值: true
%      'combine'         - 复制时是否合并文件到同一目录 (逻辑值), 默认值: true
%      'overwrite'       - 复制时是否覆盖已存在文件 (逻辑值), 默认值: true
%
%   功能描述:
%      检查当前路径是否只包含一个 .slx 模型文件，然后调用 findCodeFiles 函数
%      将代码文件复制到指定目标路径。可选择是否删除当前路径下的所有文件夹。
%
%   示例:
%      % 基本用法：复制到默认路径并删除文件夹
%      appCopyCode()
%      
%      % 复制到指定路径但不删除文件夹
%      appCopyCode('targetPath', './MyCode', 'removeFolders', false)
%      
%      % 只复制特定文件类型
%      appCopyCode('fileType', {'c', 'h'}, 'removeFolders', false)
%
%   参见: FINDCODEFILES, DIR, RMDIR
%
%   作者: Blue.ge（葛维冬）
%   版本: 1.1
%   日期: 20251113

    %% 输入参数处理
    p = inputParser;
    p.FunctionName = mfilename;
    
    % 定义参数
    addParameter(p, 'targetPath', '../Src', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'removeFolders', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'fileType', {'c', 'h', 'a2l'}, @(x) validateFileType(x));
    addParameter(p, 'showInfo', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'recursive', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'combine', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'overwrite', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    
    parse(p, varargin{:});
    
    targetPath = char(p.Results.targetPath);
    removeFolders = p.Results.removeFolders;
    fileType = p.Results.fileType;
    showInfo = p.Results.showInfo;
    recursive = p.Results.recursive;
    combine = p.Results.combine;
    overwrite = p.Results.overwrite;
    
    %% 判断是否是模型路径
    modelName = dir('*.slx');
    if length(modelName) ~= 1
        error('appCopyCode:invalidModelPath', ...
            '目标模型文件夹应该只包含 1 个 *.slx 文件，当前找到 %d 个文件', length(modelName));
    end
    
    if showInfo
        fprintf('找到模型文件: %s\n', modelName.name);
    end
    
    %% 执行复制
    try
        if showInfo
            fprintf('开始复制代码文件到目标路径: %s\n', targetPath);
        end
        
        findCodeFiles('.', ...
            'targetPath', targetPath, ...
            'fileType', fileType, ...
            'showInfo', showInfo, ...
            'recursive', recursive, ...
            'autoCopy', true, ...
            'combine', combine, ...
            'overwrite', overwrite);
            
    catch ME
        error('appCopyCode:copyFailed', '复制代码文件失败: %s', ME.message);
    end
    
    %% 删除本路径下的所有文件夹
    if removeFolders
        try
            if showInfo
                fprintf('\n开始删除当前路径下的文件夹...\n');
            end
            
            listing = dir('.');
            folderCount = 0;
            
            for i = 3:length(listing)
                item = listing(i);
                if item.isdir
                    folderCount = folderCount + 1;
                    if showInfo
                        fprintf('  正在删除文件夹: %s\n', item.name);
                    end
                    rmdir(fullfile(item.folder, item.name), 's');
                end
            end
            
            if showInfo
                if folderCount > 0
                    fprintf('成功删除 %d 个文件夹\n', folderCount);
                else
                    fprintf('当前路径下没有需要删除的文件夹\n');
                end
            end
            
        catch ME
            warning('appCopyCode:removeFailed', '删除文件夹时发生错误: %s', ME.message);
        end
    else
        if showInfo
            fprintf('\n跳过删除文件夹操作（removeFolders = false）\n');
        end
    end
    
    if showInfo
        fprintf('\n操作完成！©Blue.ge（葛维冬）@Smart \n');
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
                error('appCopyCode:invalidFileType', '文件类型必须是字符向量或字符向量元胞数组');
            end
        end
    else
        error('appCopyCode:invalidFileType', '文件类型必须是字符向量或字符向量元胞数组');
    end
end
