function [deletedLines, success] = delFileTargetLine(filename, text, varargin)
%DELFILETARGETLINE 删除文件中包含指定文本的行
%
%   [DELETEDLINES, SUCCESS] = DELFILETARGETLINE(FILENAME, TEXT) 删除指定文件中
%   包含TEXT的所有行，并返回删除的行数和操作是否成功。
%
%   [DELETEDLINES, SUCCESS] = DELFILETARGETLINE(FILENAME, TEXT, Name, Value) 
%   使用一个或多个名称-值对参数指定其他选项。
%
%   INPUTS:
%       FILENAME - 文件名，指定为字符向量或字符串标量。函数会自动搜索MATLAB路径
%       TEXT     - 要删除的文本，指定为字符向量或字符串标量
%
%   Name-Value Arguments:
%       'Overwrite' - 是否覆盖原文件，指定为逻辑标量
%                     true: 覆盖原文件（默认: false）
%                     false: 仅预览修改结果，不保存
%       'CreateBackup' - 是否创建备份文件，指定为逻辑标量
%                        true: 创建备份文件（默认: true）
%                        false: 不创建备份文件
%
%   OUTPUTS:
%       DELETEDLINES - 删除的行数，返回为双精度标量
%       SUCCESS      - 操作是否成功，返回为逻辑标量
%
%   EXAMPLES:
%       % 预览删除效果（不保存文件）
%       [numDeleted, success] = delFileTargetLine('PrkgClimaEgyMgr_defineIntEnumTypes.m', "'HeaderFile', 'Rte_Type.h'");
%
%       % 删除并保存文件（创建备份）
%       [numDeleted, success] = delFileTargetLine('PrkgClimaEgyMgr_defineIntEnumTypes.m', "'HeaderFile', 'Rte_Type.h'", ...
%                                                 'Overwrite', true);
%
%       % 删除文件但不创建备份
%       [numDeleted, success] = delFileTargetLine('config.m', 'TODO', 'Overwrite', true, 'CreateBackup', false);
%
%   See also: FILEREAD, FOPEN, STRSPLIT, CONTAINS
%
%   Author: Blue.ge
%   Date: 2025-09-17
%   Version: 1.0

%% Demo: 
% test.m 文件中的原内容
% Simulink.defineIntEnumType( 'CarModSts1', ...
%    {'CarModNorm','CarModTrnsp','CarModFcy','CarModCrash','CarModDyno'}, ...
%    [0 1 2 3 5], ...
%    'DefaultValue', 'CarModNorm', ...
%    'StorageType', 'uint8', ...
%    'HeaderFile', 'Rte_Type.h', ...
%    'AddClassNameToEnumNames', true);

% test.m 文件中的内容删除后
% 删除 'HeaderFile', 'Rte_Type.h', ...
% text = "'HeaderFile', 'Rte_Type.h'";
% 调用 delFileTargetLine('test.m ', text, 'overwrite', true)
% 删除后内容
% Simulink.defineIntEnumType( 'CarModSts1', ...
%    {'CarModNorm','CarModTrnsp','CarModFcy','CarModCrash','CarModDyno'}, ...
%    [0 1 2 3 5], ...
%    'DefaultValue', 'CarModNorm', ...
%    'StorageType', 'uint8', ...
%    'AddClassNameToEnumNames', true);

    % 输入参数验证
    narginchk(2, inf);
    
    % 解析输入参数
    p = inputParser;
    addRequired(p, 'filename', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addRequired(p, 'text', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'Overwrite', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'CreateBackup', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    
    parse(p, filename, text, varargin{:});
    
    filename = char(p.Results.filename);
    targetText = char(p.Results.text);
    overwrite = p.Results.Overwrite;
    createBackup = p.Results.CreateBackup;
    
    % 获取文件的完整路径
    if isfile(filename)
        % 如果输入的是完整路径
        filePath = filename;
    else
        % 如果输入的是文件名，使用which查找
        filePath = which(filename);
        if isempty(filePath)
            error('delFileTargetLine:FileNotFound', '文件 "%s" 在MATLAB路径中未找到', filename);
        end
    end
    
    % 验证文件确实存在
    if ~isfile(filePath)
        error('delFileTargetLine:FileNotFound', '文件 "%s" 不存在', filePath);
    end
    
    % 读取文件内容
    try
        fileContent = fileread(filePath);
    catch ME
        error('delFileTargetLine:ReadError', '读取文件失败: %s', ME.message);
    end
    
    % 将文件内容按行分割
    lines = strsplit(fileContent, '\n', 'CollapseDelimiters', false);
    
    % 查找包含目标文本的行
    linesToKeep = true(size(lines));
    deletedLines = 0;
    deletedLineNumbers = [];
    
    for i = 1:length(lines)
        if contains(lines{i}, targetText)
            linesToKeep(i) = false;
            deletedLines = deletedLines + 1;
            deletedLineNumbers = [deletedLineNumbers, i];
        end
    end
    
    % 初始化返回值
    success = false;
    
    % 显示删除信息
    if deletedLines > 0
        fprintf('找到并删除 %d 行包含文本 "%s" 的内容\n', deletedLines, targetText);
    else
        fprintf('未找到包含文本 "%s" 的行\n', targetText);
        success = true; % 没有找到匹配行也算成功
        return;
    end
    
    % 保留不包含目标文本的行
    filteredLines = lines(linesToKeep);
    
    % 重新组合文件内容
    newContent = strjoin(filteredLines, '\n');
    
    % 根据overwrite参数决定是否保存
    if overwrite
        try
            % 创建备份文件（如果需要）
            if createBackup
                [fileDir, fileName, fileExt] = fileparts(filePath);
                backupPath = fullfile(fileDir, [fileName, '_backup', fileExt]);
                copyfile(filePath, backupPath);
                fprintf('已创建备份文件: %s\n', backupPath);
            end
            
            % 写入修改后的内容
            fid = fopen(filePath, 'w', 'n', 'UTF-8');
            if fid == -1
                error('delFileTargetLine:WriteError', '无法打开文件进行写入');
            end
            
            fprintf(fid, '%s', newContent);
            fclose(fid);
            
            fprintf('文件 "%s" 已成功更新\n', filePath);
            success = true;
            
        catch ME
            error('delFileTargetLine:WriteError', '写入文件失败: %s', ME.message);
        end
    else
        % 显示待删除的行
        fprintf('\n待删除的行:\n');
        fprintf('========================================\n');
        if ~isempty(deletedLineNumbers)
            for i = 1:length(deletedLineNumbers)
                lineNum = deletedLineNumbers(i);
                fprintf('第%d行: %s\n', lineNum, lines{lineNum});
            end
        else
            fprintf('无待删除的行\n');
        end
        fprintf('========================================\n');
        fprintf('使用 ''Overwrite'', true 参数来保存修改\n');
        success = true; % 预览模式也算成功
    end
end

