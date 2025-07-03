function createCodePkg(verName, varargin)
%CREATECODEPKG 创建代码包并整理生成的文件
%   createCodePkg(verName) 根据指定的版本名称创建代码包，并将生成的代码文件(默认根目录下的CodeGen)整理到相应的目录中。
%
%   输入参数:
%       verName - 版本名称，例如 'VcThermal_23N7_V131_3090508'
%
%   可选参数:
%       'SOFT_VERSION' - 软件版本号，默认为 '3090508'
%       'INTERFACE_VERSION' - 接口版本号，默认为 'V131'
%       'STAGE' - 开发阶段，默认为 '23N7'
%       'DCM_NAME' - DCM文件名，默认为 'NA'
%       'path' - 源代码路径，默认为 'CodeGen'
%
%   示例:
%       createCodePkg('VcThermal_23N7_V131_6666666')
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-05-10
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        addParameter(p, 'SOFT_VERSION', '3090508');
        addParameter(p, 'INTERFACE_VERSION', 'V131');
        addParameter(p, 'STAGE', '23N7');
        addParameter(p, 'DCM_NAME', 'NA');
        addParameter(p, 'path', 'CodeGen');
        
        parse(p, varargin{:});
        
        % 获取解析后的参数
        softVersion = p.Results.SOFT_VERSION;
        stage = p.Results.STAGE;
        dcmName = p.Results.DCM_NAME;
        interfaceVersion = p.Results.INTERFACE_VERSION;
        sourcePath = p.Results.path;
        
        %% 1. 创建版本文件夹
        proj = currentProject;
        rootPath = proj.RootFolder;
        folderName = fullfile(rootPath, 'CodePackage', verName);
        
        if ~exist(folderName, 'dir')
            mkdir(folderName);
            fprintf('创建文件夹: %s\n', folderName);
        else
            fprintf('文件夹已存在: %s\n', folderName);
        end
        
        %% 2. 创建并初始化子文件夹
        subFolders = {'src', 'h', 'a2l'};
        for i = 1:length(subFolders)
            subFolderPath = fullfile(folderName, subFolders{i});
            if ~exist(subFolderPath, 'dir')
                mkdir(subFolderPath);
                fprintf('创建子文件夹: %s\n', subFolderPath);
            end
        end
        
        %% 3. 复制源代码文件
        sourceBasePath = fullfile(rootPath, sourcePath);
        
        % 定义文件类型和对应的目标文件夹
        fileTypes = {
            {'*.c', 'src'}, 
            {'*.h', 'h'}, 
            {'*.a2l', 'a2l'}
        };
        
        % 定义需要排除的.h文件
        excludeFiles = {'Rte_VcThermal.h', 'Rte_Type.h'};
        
        % 复制文件
        for i = 1:length(fileTypes)
            fileType = fileTypes{i}{1};
            targetFolder = fileTypes{i}{2};
            
            sourceFiles = dir(fullfile(sourceBasePath, '**', fileType));
            for j = 1:length(sourceFiles)
                file = sourceFiles(j);
                sourceFile = fullfile(file.folder, file.name);
                targetFile = fullfile(folderName, targetFolder, file.name);
                
                % 对于.h文件，检查是否需要排除
                if strcmp(fileType, '*.h') && any(strcmp(file.name, excludeFiles))
                    continue;
                end
                
                copyfile(sourceFile, targetFile);
                fprintf('复制文件: %s -> %s\n', sourceFile, targetFile);
            end
        end
        
        %% 4. 复制DCM和软件变更记录
        if ~strcmp(dcmName, 'NA')
            dcmPath = fullfile(rootPath, 'Files', dcmName);
            if exist(dcmPath, 'file')
                copyfile(dcmPath, folderName);
                fprintf('复制DCM文件: %s -> %s\n', dcmPath, folderName);
            else
                warning('DCM文件不存在: %s', dcmPath);
            end
        end
        
        fprintf('代码包创建完成: %s\n', folderName);
        
    catch ME
        error('创建代码包时发生错误: %s', ME.message);
    end
end

