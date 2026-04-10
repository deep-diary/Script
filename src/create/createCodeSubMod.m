function createCodeSubMod(mdName, varargin)
%CREATECODESUBMOD 创建子模型代码包
%   createCodeSubMod(mdName) 为指定的模型创建代码包，并将生成的代码文件整理到相应的目录中。
%
%   输入参数:
%       mdName - 模型名称，例如 'TmSovCtrl'
%
%   可选参数:
%       'type' - 控制器类型，可选值为 'VCU' 或 'PCMU'，默认为 'VCU'
%
%   示例:
%       createCodeSubMod('TmSovCtrl')
%       createCodeSubMod('TmSovCtrl', 'type', 'PCMU')
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-05-10
%   版本: 1.1

    try
        %% 输入参数处理
        % 提醒此脚本已经弃用，后续请用createCodeMod代替
        warning('此脚本已经弃用，后续请用createCodeMod代替');

        p = inputParser;
        addParameter(p, 'type', 'VCU', @(x) any(validatestring(x, {'VCU', 'PCMU','XCU'})));
        parse(p, varargin{:});
        
        ctrlType = p.Results.type;
        
        %% 1. 创建目标文件夹
        proj = currentProject;
        rootPath = proj.RootFolder;
        mdPath = which(mdName)
        [fold,name,ext] = fileparts(mdPath);
        
%         folderName = fullfile(fold, ['Code_' ctrlType]);
        folderName = fullfile(fold, 'Code');
        
        % 如果文件夹存在则删除重建
        if exist(folderName, 'dir')
            rmdir(folderName, 's');
            fprintf('删除已存在的文件夹: %s\n', folderName);
        end
        mkdir(folderName);
        fprintf('创建文件夹: %s\n', folderName);
        
        %% 2. 获取源代码文件
        if strcmp(ctrlType, 'VCU')
            sourcePath = fullfile(rootPath, 'CodeGen', 'slprj/ert/', mdName);
            sourceSrc = dir(fullfile(sourcePath, '**\*.c'));
            sourceH = dir(fullfile(sourcePath, '**\*.h'));
        else % PCMU
            sourcePath1 = fullfile(rootPath, 'CodeGen', 'slprj/autosar', mdName);
            sourcePath2 = fullfile(rootPath, 'CodeGen', 'slprj/autosar/_sharedutils');
            
            % 获取两个路径下的所有.c和.h文件
            sourceSrc = [dir(fullfile(sourcePath1, '**\*.c')); ...
                        dir(fullfile(sourcePath2, '**\*.c'))];
            sourceH = [dir(fullfile(sourcePath1, '**\*.h')); ...
                      dir(fullfile(sourcePath2, '**\*.h'))];
        end
        
        % 打印文件列表
        fprintf('\n源代码文件列表:\n');
        fprintf('C文件:\n');
        cellfun(@(x) fprintf('  %s\n', x), {sourceSrc.name});
        fprintf('\n头文件:\n');
        cellfun(@(x) fprintf('  %s\n', x), {sourceH.name});
        
        %% 3. 复制文件
        % 复制.c文件
        for i = 1:length(sourceSrc)
            file = sourceSrc(i);
            sourceFile = fullfile(file.folder, file.name);
            copyfile(sourceFile, folderName);
            fprintf('复制C文件: %s\n', sourceFile);
        end
        
        % 复制.h文件
        for i = 1:length(sourceH)
            file = sourceH(i);
            sourceFile = fullfile(file.folder, file.name);
            copyfile(sourceFile, folderName);
            fprintf('复制头文件: %s\n', sourceFile);
        end
        
        fprintf('\n代码包创建完成: %s\n', folderName);
        
    catch ME
        error('创建子模型代码包时发生错误: %s', ME.message);
    end
end



