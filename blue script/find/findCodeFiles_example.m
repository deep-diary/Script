%% findCodeFiles 使用示例（增强版）
% 此文件展示如何使用增强后的 findCodeFiles 函数，包括自动复制功能

%% 基本用法：只查找文件
[codeFiles, mapping] = findCodeFiles('CodeGen');
fprintf('找到 %d 种文件类型，共 %d 个文件\n', length(mapping.types), sum(mapping.counts));

%% 自动复制到默认目录
% 使用默认目标目录 'TargetCodeFiles'
[codeFiles, mapping] = findCodeFiles('CodeGen', 'autoCopy', true);

%% 自动复制到指定目录
% 指定自定义目标目录
[codeFiles, mapping] = findCodeFiles('CodeGen', 'autoCopy', true, 'targetPath', 'MyCodeFiles');

%% 使用分类模式复制
% 按文件类型创建子目录
[codeFiles, mapping] = findCodeFiles('CodeGen', 'autoCopy', true, 'combine', false);

%% 查找特定文件类型并自动复制
% 只查找 C 和 H 文件
[codeFiles, mapping] = findCodeFiles('CodeGen', 'fileType', {'c', 'h'}, 'autoCopy', true);

%% 静默模式：不显示详细信息
[codeFiles, mapping] = findCodeFiles('CodeGen', 'autoCopy', true, 'showInfo', false);

%% 不覆盖已存在文件
[codeFiles, mapping] = findCodeFiles('CodeGen', 'autoCopy', true, 'overwrite', false);

%% 完整参数示例
[codeFiles, mapping] = findCodeFiles('CodeGen', ...
    'fileType', {'c', 'h', 'a2l'}, ...  % 查找的文件类型
    'autoCopy', true, ...               % 自动复制
    'targetPath', 'CustomTarget', ...   % 自定义目标目录
    'combine', false, ...               % 使用分类模式
    'overwrite', true, ...              % 覆盖已存在文件
    'showInfo', true, ...               % 显示详细信息
    'recursive', true);                 % 递归搜索

%% 错误处理示例
try
    % 尝试查找不存在的路径
    [codeFiles, mapping] = findCodeFiles('NonExistentPath', 'autoCopy', true);
catch ME
    fprintf('查找失败: %s\n', ME.message);
end

%% 参数说明
% sourcePath: 搜索路径（必需）
% 'fileType': 文件类型，默认 {'c', 'h', 'a2l'}
% 'showInfo': 是否显示信息，默认 true
% 'recursive': 是否递归搜索，默认 true
% 'targetPath': 目标复制路径，默认 'TargetCodeFiles'
% 'autoCopy': 是否自动复制，默认 false
% 'combine': 复制时是否合并，默认 true
% 'overwrite': 复制时是否覆盖，默认 true

%% 功能特点
% 1. 支持多种文件类型查找
% 2. 可选择递归或非递归搜索
% 3. 自动调用 createCopyCodeFiles 进行文件复制
% 4. 支持合并模式和分类模式
% 5. 智能处理已存在文件
% 6. 详细的错误处理和状态反馈
% 7. 与 createCopyCodeFiles 完美集成

%% 典型工作流程
% 1. 查找代码文件：findCodeFiles('CodeGen', 'autoCopy', true)
% 2. 文件自动复制到 'TargetCodeFiles' 目录
% 3. 返回文件列表和映射信息供后续使用
