function createCodePkg(verName, varargin)
%%
% 目的: 将生成的代码，整理成代码包发给新能源
% 输入：
%       Null
% 返回：NA
% 范例：createCodePkg('VcThermal_23N7_V131_3090508')
% 说明：NA
% 作者： Blue.ge
% 日期： 20240510

%%
    clc
%% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'SOFT_VERSION','3090508');      % 设置变量名和默认参数
    addParameter(p,'INTERFACE_VERISON','V131');      % 设置变量名和默认参数
    addParameter(p,'STAGE','23N7');      % 设置变量名和默认参数
    addParameter(p,'DCM_NAME','NA');      % 设置变量名和默认参数
    addParameter(p,'path','CodeGen');      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    SOFT_VERSION = p.Results.SOFT_VERSION;
    STAGE = p.Results.STAGE;
    DCM_NAME = p.Results.DCM_NAME;
    INTERFACE_VERISON = p.Results.INTERFACE_VERISON;
    path = p.Results.path;

%% 1. 根据软件版本，新建文件夹
    proj = currentProject;
    rootPath = proj.RootFolder;
%     verName = ['VcThermal_' STAGE '_' INTERFACE_VERISON '_' SOFT_VERSION];
    
    folderName = fullfile(rootPath,'CodePackage',verName);
    if ~exist(folderName, 'dir')
        mkdir(folderName);
        disp(['创建文件夹: ' folderName]);
    else
        disp(['文件夹已存在: ' folderName]);
    end
%     cd(folderName)
%% 2. 新建src,h,a2l文件夹，并复制所有的.c, .h, .a2l文件到其中
    srcPath = fullfile(folderName,'src');
    hPath = fullfile(folderName,'h');
    a2lPath = fullfile(folderName,'a2l');
    if ~exist(srcPath, 'dir')
        mkdir(srcPath);
    end
    if ~exist(hPath, 'dir')
        mkdir(hPath);
    end
    if ~exist(a2lPath, 'dir')
        mkdir(a2lPath);
    end

    sourcePath = fullfile(rootPath,path);

    sourceSrc = dir(fullfile(sourcePath,'**\*.c'));
    sourceH = dir(fullfile(sourcePath,'**\*.h'));
    sourceA2l = dir(fullfile(sourcePath,'**\*.a2l'));
    % 复制.c
    for i=1:length(sourceSrc)
        T = sourceSrc(i,1);
        copyfile([T.folder '\' T.name],srcPath);
        disp(['DD复制源：' T.folder '\' T.name]);
    end
    % 复制.h
    eludeFile = {'Rte_VcThermal.h', 'Rte_Type.h'};
    for i=1:length(sourceH)
        T = sourceH(i,1);
        if any(strcmp(T.name, eludeFile))  % 这几个文件不复制
            continue
        end
        copyfile([T.folder '\' T.name],hPath);
        disp(['DD复制源：' T.folder '\' T.name]);
    end
    % 复制.a2l
    for i=1:length(sourceA2l)
        T = sourceA2l(i,1);
        copyfile([T.folder '\' T.name],a2lPath);
        disp(['DD复制源：' T.folder '\' T.name]);
    end

%% 4. 复制DCM 和软件变更记录到软件包中
    if ~strcmp(DCM_NAME, 'NA')
        DCMPath = fullfile(rootPath,'Files',DCM_NAME);
        if exist(DCMPath,'file')
            copyfile(DCMPath,folderName);
        end
    end

