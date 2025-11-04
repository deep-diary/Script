function createMergeArxmlList(varargin)
%CREATEMERGEARXMLLIST 将多个ARXML文件合并为一个ARXML文件
%   CREATEMERGEARXMLLIST(ARXMLLIST) 将指定的ARXML文件列表合并为一个文件
%   CREATEMERGEARXMLLIST(..., 'OutputFile', OUTPUTFILE, 'FolderPath', PATH, ...) 使用名值对指定参数
%   CREATEMERGEARXMLLIST('FolderPath', true) 通过UI对话框选择文件夹
%
%   输入参数（均为可选）:
%      arxmlList    - ARXML文件路径列表 (位置参数，字符向量元胞数组或字符串数组，当FolderPath不为空时被忽略)
%
%   可选参数（名值对）:
%      'FolderPath' - 文件夹路径或布尔值 (字符向量、字符串或逻辑值，默认: '')
%                        - 字符/字符串: 指定文件夹路径
%                        - true: 通过UI对话框选择文件夹
%                        - false或空: 不使用文件夹模式
%      'OutputFile' - 输出文件路径 (字符向量或字符串，默认: 'merged.arxml')
%      'BaseFile'   - 基础文件路径，其他文件将合并到此文件中 (字符向量或字符串)
%      'Validate'   - 是否验证合并结果 (逻辑值，默认: true)
%      'Backup'     - 是否备份现有输出文件 (逻辑值，默认: true)
%      'Verbose'    - 是否显示详细输出 (逻辑值，默认: true)
%
%   功能描述:
%      将多个ARXML文件合并为一个完整的ARXML文件。支持以下合并策略：
%      1. 如果指定FolderPath，自动读取文件夹内所有.arxml文件进行合并
%      2. 如果指定BaseFile，将其他文件合并到基础文件中
%      3. 如果未指定BaseFile，将第一个文件作为基础，其他文件合并到其中
%      4. 自动处理AR-PACKAGE结构，避免重复和冲突
%      5. 支持XML格式验证和错误检查
%
%   示例:
%      % 基本用法（通过UI选择文件夹）
%      createMergeArxmlList('FolderPath', true);
% 
%      % 指定文件
%      createMergeArxmlList('arxmlList', {'SdbRxSigProc.arxml','PrkgClimaActvMgr.arxml'});
%
%      % 指定文件夹路径
%      createMergeArxmlList('FolderPath', 'arxml_folder');
%
%      % 指定输出文件名
%      createMergeArxmlList('FolderPath', true, 'OutputFile', 'my_merged');
%
%      % 使用文件列表
%      arxmlFiles = {'ActvnCoorrForEcuAndCom.arxml', 'AirDirecCtrlMgr.arxml'};
%      createMergeArxmlList(arxmlFiles, 'OutputFile', 'merged.arxml');
%
%      % 指定基础文件
%      createMergeArxmlList('FolderPath', 'arxml_folder', 'BaseFile', 'base.arxml');
%
%   作者: Blue.ge
%   日期: 20250101
%   版本: 2.0

% 创建输入解析器
p = inputParser;

% 只使用名值对参数（无位置参数）
addParameter(p, 'FolderPath', '', @(x) isempty(x) || ischar(x) || isstring(x) || islogical(x));
addParameter(p, 'OutputFile', 'merged', @(x) isempty(x) || ischar(x) || isstring(x));
addParameter(p, 'arxmlList', '', @(x) isempty(x) || iscell(x) || ischar(x) || isstring(x));
addParameter(p, 'BaseFile', '', @(x) isempty(x) || ischar(x) || isstring(x));
addParameter(p, 'Validate', true, @(x) islogical(x) && isscalar(x));
addParameter(p, 'Backup', true, @(x) islogical(x) && isscalar(x));
addParameter(p, 'Verbose', true, @(x) islogical(x) && isscalar(x));

% 解析输入
parse(p, varargin{:});

% 提取参数
arxmlList = p.Results.arxmlList;
folderPathInput = p.Results.FolderPath;
outputFile = char(p.Results.OutputFile);
baseFile = char(p.Results.BaseFile);
validateResult = p.Results.Validate;
backupFile = p.Results.Backup;
verbose = p.Results.Verbose;

%  outputFile 增加当前时间+后缀
outputFile = [outputFile, '_', datestr(datetime('now'),'yyyymmdd_HHMMSS'), '.arxml'];

% 处理 FolderPath 参数（支持布尔值和路径字符串）
folderPath = '';
if islogical(folderPathInput)
    if folderPathInput
        % 通过 UI 对话框选择文件夹
        folderPath = uigetdir(pwd, '请选择包含ARXML文件的文件夹');
        if isequal(folderPath, 0) || isempty(folderPath) || (ischar(folderPath) && strcmp(folderPath, '0'))
            error('createMergeArxmlList:FolderSelectionCancelled', '用户取消了文件夹选择');
        end
        folderPath = char(folderPath);
        if verbose
            fprintf('选择的文件夹: %s\n', folderPath);
        end
    end
    % false 或空值，不设置 folderPath
elseif ~isempty(folderPathInput)
    folderPath = char(folderPathInput);
end

% 转换 arxmlList 数据类型
if ~isempty(arxmlList) && ~iscell(arxmlList)
    arxmlList = {char(arxmlList)};
elseif ~isempty(arxmlList)
    arxmlList = cellfun(@char, arxmlList, 'UniformOutput', false);
end

% 验证arxmlList和FolderPath参数（至少要有一个）
if isempty(arxmlList) && isempty(folderPath)
    error('createMergeArxmlList:EmptyList', '必须指定arxmlList或FolderPath参数，两者不能同时为空');
end

% 验证arxmlList中的文件路径
if ~isempty(arxmlList)
    for i = 1:length(arxmlList)
        if ~(ischar(arxmlList{i}) || isstring(arxmlList{i}))
            error('createMergeArxmlList:InvalidFileType', '文件路径必须是字符向量或字符串');
        end
    end
end

%% 1. 参数验证和预处理
if verbose
    fprintf('=== ARXML文件合并工具 ===\n');
end

% 处理文件夹路径参数
if ~isempty(folderPath)
    if verbose
        fprintf('使用文件夹模式: %s\n', folderPath);
    end
    
    % 验证文件夹存在
    if ~exist(folderPath, 'dir')
        error('createMergeArxmlList:FolderNotFound', '指定文件夹不存在: %s', folderPath);
    end
    
    % 读取文件夹内所有.arxml文件
    arxmlList = getArxmlFilesFromFolder(folderPath, verbose);
    
    if isempty(arxmlList)
        error('createMergeArxmlList:NoArxmlFiles', '文件夹内未找到.arxml文件: %s', folderPath);
    end
    
    if verbose
        fprintf('从文件夹读取到 %d 个ARXML文件\n', length(arxmlList));
    end
else
    if verbose
        fprintf('使用文件列表模式\n');
        fprintf('输入文件数量: %d\n', length(arxmlList));
    end
    
    % 验证所有输入文件存在
    for i = 1:length(arxmlList)
        if ~exist(arxmlList{i}, 'file')
            error('createMergeArxmlList:FileNotFound', 'ARXML文件不存在: %s', arxmlList{i});
        end
    end
end

% 确保输出文件使用绝对路径
if ~isempty(outputFile)
    % 检查是否为绝对路径（Windows 或 Unix）
    isAbsolute = (length(outputFile) >= 2 && outputFile(2) == ':') || ...  % Windows: C:\
                 (outputFile(1) == filesep);                                 % Unix/Mac: /
    
    if ~isAbsolute
        % 相对路径，转换为绝对路径
        outputFile = fullfile(pwd, outputFile);
    end
end

if verbose
    fprintf('输出文件: %s\n', outputFile);
end

% 处理基础文件
if ~isempty(baseFile)
    if ~exist(baseFile, 'file')
        error('createMergeArxmlList:BaseFileNotFound', '基础文件不存在: %s', baseFile);
    end
    if verbose
        fprintf('使用基础文件: %s\n', baseFile);
    end
else
    baseFile = arxmlList{1};
    if verbose
        fprintf('使用第一个文件作为基础: %s\n', baseFile);
    end
end

% 备份现有输出文件（仅在文件存在时）
if backupFile
    try
        if exist(outputFile, 'file')
            backupName = [outputFile, '.backup.', datestr(now, 'yyyymmdd_HHMMSS')];
            copyfile(outputFile, backupName);
            if verbose
                fprintf('已备份现有文件到: %s\n', backupName);
            end
        end
    catch ME
        if verbose
            fprintf('警告: 无法备份现有文件: %s\n', ME.message);
        end
    end
end

%% 2. 读取基础文件
try
    if verbose
        fprintf('\n步骤1: 读取基础文件...\n');
    end
    
    baseContent = readArxmlFile(baseFile, verbose);
    if verbose
        fprintf('基础文件读取完成，大小: %d 字符\n', length(baseContent));
    end
    
catch ME
    error('createMergeArxmlList:BaseFileReadError', '读取基础文件失败: %s', ME.message);
end

%% 3. 合并其他文件
try
    if verbose
        fprintf('\n步骤2: 合并其他文件...\n');
        fprintf('总文件数: %d\n', length(arxmlList));
        fprintf('基础文件: %s\n', baseFile);
    end
    
    mergedContent = baseContent;
    mergedCount = 0;
    skippedCount = 0;
    failedCount = 0;
    
    for i = 1:length(arxmlList)
        currentFile = arxmlList{i};
        
        if verbose
            fprintf('  处理文件 %d/%d: %s\n', i, length(arxmlList), currentFile);
        end
        
        % 跳过基础文件
        if strcmp(currentFile, baseFile)
            if verbose
                fprintf('    跳过基础文件\n');
            end
            skippedCount = skippedCount + 1;
            continue;
        end
        
        try
            % 读取当前文件
            currentContent = readArxmlFile(currentFile, false);
            
            % 合并内容
            mergedContent = mergeArxmlContent(mergedContent, currentContent, verbose);
            mergedCount = mergedCount + 1;
            
            if verbose
                fprintf('    合并成功\n');
            end
            
        catch ME
            failedCount = failedCount + 1;
            if verbose
                fprintf('    警告: 文件合并失败 - %s\n', ME.message);
            end
        end
    end
    
    if verbose
        fprintf('\n合并统计:\n');
        fprintf('  总文件数: %d\n', length(arxmlList));
        fprintf('  基础文件: %d (跳过)\n', skippedCount);
        fprintf('  成功合并: %d\n', mergedCount);
        fprintf('  合并失败: %d\n', failedCount);
        fprintf('  实际处理: %d\n', mergedCount + failedCount);
    end
    
catch ME
    error('createMergeArxmlList:MergeError', '文件合并失败: %s', ME.message);
end

%% 4. 保存合并结果
try
    if verbose
        fprintf('\n步骤3: 保存合并结果...\n');
    end
    
    % 确保输出目录存在
    [outputDir, ~, ~] = fileparts(outputFile);
    if ~isempty(outputDir) && ~exist(outputDir, 'dir')
        mkdir(outputDir);
        if verbose
            fprintf('    创建输出目录: %s\n', outputDir);
        end
    end
    
    % 写入文件
    writeArxmlFile(outputFile, mergedContent, verbose);
    
    if verbose
        fprintf('文件保存完成: %s\n', outputFile);
        
        % 显示文件信息
        fileInfo = dir(outputFile);
        fprintf('文件大小: %d 字节\n', fileInfo.bytes);
    end
    
catch ME
    error('createMergeArxmlList:SaveError', '保存文件失败: %s', ME.message);
end

%% 5. 验证合并结果
if validateResult
    try
        if verbose
            fprintf('\n步骤4: 验证合并结果...\n');
        end
        
        validateMergedArxml(outputFile, verbose);
        
        if verbose
            fprintf('验证完成，合并结果有效\n');
        end
        
    catch ME
        if verbose
            fprintf('警告: 验证失败 - %s\n', ME.message);
        end
    end
end

if verbose
    fprintf('\n=== 合并完成 ===\n');
    fprintf('输出文件: %s\n', outputFile);
    
    % 显示文件信息
    if exist(outputFile, 'file')
        fileInfo = dir(outputFile);
        fprintf('文件大小: %d 字节 (%.2f MB)\n', fileInfo.bytes, fileInfo.bytes / 1024 / 1024);
        fprintf('创建时间: %s\n', fileInfo.date);
    end
    
    fprintf('\n最终统计:\n');
    fprintf('  输入文件总数: %d\n', length(arxmlList));
    fprintf('  基础文件: 1 (作为合并基础)\n');
    fprintf('  合并文件数: %d\n', mergedCount);
    if validateResult
        fprintf('  验证结果: 通过\n');
    else
        fprintf('  验证结果: 跳过\n');
    end
end

end % 主函数结束

%% 辅助函数


function content = readArxmlFile(filePath, verbose)
%READARXMLFILE 读取ARXML文件内容
    if verbose
        fprintf('    读取文件: %s\n', filePath);
    end
    
    try
        content = fileread(filePath);
        
        % 基本XML格式检查
        if isempty(regexp(content, '<\?xml', 'once'))
            warning('createMergeArxmlList:NoXmlDeclaration', '文件可能不是有效的XML格式: %s', filePath);
        end
        
    catch ME
        error('createMergeArxmlList:FileReadError', '读取文件失败: %s', ME.message);
    end
end

function mergedContent = mergeArxmlContent(baseContent, mergeContent, verbose)
%MERGEARXMLCONTENT 合并ARXML内容
    if verbose
        fprintf('      合并ARXML内容...\n');
    end
    
    try
        % 使用XML解析器来正确处理ARXML结构
        % 创建临时文件来解析XML
        tempBaseFile = tempname;
        tempMergeFile = tempname;
        
        % 写入临时文件
        fid1 = fopen(tempBaseFile, 'w', 'n', 'UTF-8');
        fwrite(fid1, baseContent, 'char');
        fclose(fid1);
        
        fid2 = fopen(tempMergeFile, 'w', 'n', 'UTF-8');
        fwrite(fid2, mergeContent, 'char');
        fclose(fid2);
        
        % 解析XML文件
        baseDoc = xmlread(tempBaseFile);
        baseRoot = baseDoc.getDocumentElement();
        
        mergeDoc = xmlread(tempMergeFile);
        mergeRoot = mergeDoc.getDocumentElement();
        
        % 清理临时文件
        delete(tempBaseFile);
        delete(tempMergeFile);
        
        % 获取基础文件中的AR-PACKAGES节点
        basePackages = baseRoot.getElementsByTagName('AR-PACKAGES').item(0);
        if isempty(basePackages)
            error('createMergeArxmlList:NoBasePackages', '基础文件中未找到AR-PACKAGES节点');
        end
        
        % 获取要合并文件中的顶级AR-PACKAGE节点
        mergePackages = mergeRoot.getElementsByTagName('AR-PACKAGES').item(0);
        if isempty(mergePackages)
            if verbose
                fprintf('      未找到AR-PACKAGES节点\n');
            end
            mergedContent = baseContent;
            return;
        end
        
        % 复制顶级AR-PACKAGE节点，处理重复元素
        packageList = mergePackages.getChildNodes();
        copiedCount = 0;
        
        for i = 0:packageList.getLength()-1
            node = packageList.item(i);
            if strcmp(char(node.getNodeName()), 'AR-PACKAGE')
                % 获取包名称
                shortNameNodes = node.getElementsByTagName('SHORT-NAME');
                packageName = '';
                if shortNameNodes.getLength() > 0
                    packageName = char(shortNameNodes.item(0).getTextContent());
                end
                
                % 检查是否已存在同名包
                existingPackage = findExistingPackage(basePackages, packageName);
                
                if ~isempty(existingPackage)
                    % 合并到现有包中，避免重复
                    if verbose
                        fprintf('        合并到现有包: %s\n', packageName);
                    end
                    mergePackageContents(existingPackage, node, verbose);
                else
                    % 克隆节点并导入到基础文档
                    importedNode = baseDoc.importNode(node, true);
                    basePackages.appendChild(importedNode);
                    copiedCount = copiedCount + 1;
                    
                    if verbose
                        fprintf('        添加新包: %s\n', packageName);
                    end
                end
            end
        end
        
        % 将修改后的文档转换回字符串
        mergedContent = xmlwrite(baseDoc);
        
        if verbose
            fprintf('      成功合并 %d 个AR-PACKAGE元素\n', copiedCount);
        end
        
    catch ME
        % 如果XML解析失败，回退到正则表达式方法
        if verbose
            fprintf('      XML解析失败，使用正则表达式方法: %s\n', ME.message);
        end
        
        mergedContent = mergeArxmlContentRegex(baseContent, mergeContent, verbose);
    end
end

function mergedContent = mergeArxmlContentRegex(baseContent, mergeContent, verbose)
%MERGEARXMLCONTENTREGEX 使用正则表达式合并ARXML内容（备用方法）
    try
        % 提取完整的顶级AR-PACKAGE元素
        % 匹配从<AR-PACKAGE开始到对应的</AR-PACKAGE>结束的完整块
        packagePattern = '<AR-PACKAGE[^>]*>.*?</AR-PACKAGE>';
        packages = regexp(mergeContent, packagePattern, 'match', 'dotall');
        
        if isempty(packages)
            if verbose
                fprintf('      未找到AR-PACKAGE元素\n');
            end
            mergedContent = baseContent;
            return;
        end
        
        % 在基础文件中找到插入位置
        % 查找最后一个</AR-PACKAGE>标签，在其后插入新的包
        insertPattern = '(\s*</AR-PACKAGE>)(\s*</AR-PACKAGES>)';
        insertMatch = regexp(baseContent, insertPattern, 'match');
        
        if isempty(insertMatch)
            error('createMergeArxmlList:NoInsertionPoint', '在基础文件中未找到插入位置');
        end
        
        % 构建合并内容
        packageContent = '';
        for i = 1:length(packages)
            % 为每个包添加适当的缩进（8个空格）
            indentedPackage = regexprep(packages{i}, '^', '        ', 'lineanchors');
            packageContent = [packageContent, indentedPackage, newline];
        end
        
        % 合并内容，保持正确的XML结构
        mergedContent = regexprep(baseContent, insertPattern, ['$1' newline packageContent '$2']);
        
        if verbose
            fprintf('      成功合并 %d 个AR-PACKAGE元素（正则表达式方法）\n', length(packages));
        end
        
    catch ME
        error('createMergeArxmlList:ContentMergeError', '内容合并失败: %s', ME.message);
    end
end

function writeArxmlFile(filePath, content, verbose)
%WRITEARXMLFILE 写入ARXML文件
    if verbose
        fprintf('    写入文件: %s\n', filePath);
    end
    
    try
        fid = fopen(filePath, 'w', 'n', 'UTF-8');
        if fid == -1
            error('createMergeArxmlList:FileOpenError', '无法打开文件进行写入: %s', filePath);
        end
        
        fwrite(fid, content, 'char');
        fclose(fid);
        
    catch ME
        if fid ~= -1
            fclose(fid);
        end
        error('createMergeArxmlList:FileWriteError', '写入文件失败: %s', ME.message);
    end
end

function validateMergedArxml(filePath, verbose)
%VALIDATEMERGEDARXML 验证合并后的ARXML文件
    if verbose
        fprintf('    验证XML格式...\n');
    end
    
    try
        % 使用MATLAB的xmlread验证XML格式
        doc = xmlread(filePath);
        
        % 统计元素数量
        packages = doc.getElementsByTagName('AR-PACKAGE');
        components = doc.getElementsByTagName('APPLICATION-SW-COMPONENT-TYPE');
        implementations = doc.getElementsByTagName('SWC-IMPLEMENTATION');
        
        if verbose
            fprintf('    AR-PACKAGE数量: %d\n', packages.getLength());
            fprintf('    APPLICATION-SW-COMPONENT-TYPE数量: %d\n', components.getLength());
            fprintf('    SWC-IMPLEMENTATION数量: %d\n', implementations.getLength());
        end
        
    catch ME
        error('createMergeArxmlList:ValidationError', 'XML验证失败: %s', ME.message);
    end
end

function existingPackage = findExistingPackage(basePackages, packageName)
%FINDDEXISTINGPACKAGE 查找已存在的同名包
    existingPackage = [];
    
    if isempty(packageName)
        return;
    end
    
    packageList = basePackages.getChildNodes();
    for i = 0:packageList.getLength()-1
        node = packageList.item(i);
        if strcmp(char(node.getNodeName()), 'AR-PACKAGE')
            shortNameNodes = node.getElementsByTagName('SHORT-NAME');
            if shortNameNodes.getLength() > 0
                existingName = char(shortNameNodes.item(0).getTextContent());
                if strcmp(existingName, packageName)
                    existingPackage = node;
                    return;
                end
            end
        end
    end
end

function mergePackageContents(existingPackage, newPackage, verbose)
%MERGEPACKAGECONTENTS 合并包内容，处理重复元素
    try
        % 获取现有包的ELEMENTS节点
        existingElements = existingPackage.getElementsByTagName('ELEMENTS').item(0);
        if isempty(existingElements)
            return;
        end
        
        % 获取新包的ELEMENTS节点
        newElements = newPackage.getElementsByTagName('ELEMENTS').item(0);
        if isempty(newElements)
            return;
        end
        
        % 获取现有包中所有元素的UUID映射
        existingUuids = getElementUuidMap(existingElements);
        
        % 遍历新包中的元素
        newElementList = newElements.getChildNodes();
        mergedCount = 0;
        skippedCount = 0;
        
        for i = 0:newElementList.getLength()-1
            element = newElementList.item(i);
            if element.getNodeType() == element.ELEMENT_NODE
                % 获取元素的UUID
                uuidAttr = element.getAttribute('UUID');
                if ~isempty(uuidAttr)
                    uuid = char(uuidAttr);
                    
                    % 检查UUID是否已存在
                    if isKey(existingUuids, uuid)
                        if verbose
                            elementName = char(element.getNodeName());
                            fprintf('          跳过重复元素: %s (UUID: %s)\n', elementName, uuid);
                        end
                        skippedCount = skippedCount + 1;
                    else
                        % 导入新元素
                        importedElement = existingPackage.getOwnerDocument().importNode(element, true);
                        existingElements.appendChild(importedElement);
                        existingUuids(uuid) = true;
                        mergedCount = mergedCount + 1;
                        
                        if verbose
                            elementName = char(element.getNodeName());
                            fprintf('          添加新元素: %s\n', elementName);
                        end
                    end
                else
                    % 没有UUID的元素，直接添加
                    importedElement = existingPackage.getOwnerDocument().importNode(element, true);
                    existingElements.appendChild(importedElement);
                    mergedCount = mergedCount + 1;
                    
                    if verbose
                        elementName = char(element.getNodeName());
                        fprintf('          添加无UUID元素: %s\n', elementName);
                    end
                end
            end
        end
        
        if verbose
            fprintf('          合并结果: 添加 %d 个元素，跳过 %d 个重复元素\n', mergedCount, skippedCount);
        end
        
    catch ME
        if verbose
            fprintf('          警告: 包内容合并失败: %s\n', ME.message);
        end
    end
end

function uuidMap = getElementUuidMap(elementsNode)
%GETELEMENTUUIDMAP 获取元素节点的UUID映射
    uuidMap = containers.Map();
    
    elementList = elementsNode.getChildNodes();
    for i = 0:elementList.getLength()-1
        element = elementList.item(i);
        if element.getNodeType() == element.ELEMENT_NODE
            uuidAttr = element.getAttribute('UUID');
            if ~isempty(uuidAttr)
                uuid = char(uuidAttr);
                uuidMap(uuid) = true;
            end
        end
    end
end

function arxmlFiles = getArxmlFilesFromFolder(folderPath, verbose)
%GETARXMLFILESFROMFOLDER 从文件夹中获取所有ARXML文件
    if verbose
        fprintf('    扫描文件夹: %s\n', folderPath);
    end
    
    try
        % 获取文件夹内所有文件
        files = dir(folderPath);
        arxmlFiles = {};
        
        for i = 1:length(files)
            file = files(i);
            
            % 跳过目录和隐藏文件
            if file.isdir || strcmp(file.name(1), '.')
                continue;
            end
            
            % 检查是否为.arxml文件
            [~, ~, ext] = fileparts(file.name);
            if strcmpi(ext, '.arxml')
                fullPath = fullfile(folderPath, file.name);
                arxmlFiles{end+1} = fullPath;
                
                if verbose
                    fprintf('      找到ARXML文件: %s\n', file.name);
                end
            end
        end
        
        % 按文件名排序
        if ~isempty(arxmlFiles)
            [~, sortIdx] = sort(arxmlFiles);
            arxmlFiles = arxmlFiles(sortIdx);
        end
        
        if verbose
            fprintf('    共找到 %d 个ARXML文件\n', length(arxmlFiles));
        end
        
    catch ME
        error('createMergeArxmlList:FolderScanError', '扫描文件夹失败: %s', ME.message);
    end
end
