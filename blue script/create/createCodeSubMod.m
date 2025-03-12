function createCodeSubMod(mdName, varargin)
%%
% 目的: 将生成的代码，整理成代码包发给新能源
% 输入：
%       Null
% 返回：NA
% 范例：createCodeSubMod('TmComprCtrl','type','VCU')
% 说明：NA
% 作者： Blue.ge
% 日期： 20240510

%%
    clc
%% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'type','VCU');      % 'PCMU', 'VCU'

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    type = p.Results.type;

%% 1. 根据软件版本，新建文件夹
    proj = currentProject;
    rootPath = proj.RootFolder;
    mdFold = findModPrefix(mdName);
    folderName = fullfile(rootPath,'SubModel',mdFold,['Code_' type]);

    if ~exist(folderName, 'dir')
        mkdir(folderName);
        disp(['创建文件夹: ' folderName]);
    else
        rmdir(folderName,'s')
        mkdir(folderName);
        disp(['文件夹已存在: ' folderName]);
    end

%% 2. 新建src,h,a2l文件夹，并复制所有的.c, .h, .a2l文件到其中

    sourcePath = fullfile(rootPath,'CodeGen','slprj/ert/',mdName);

    sourceSrc = dir(fullfile(sourcePath,'**\*.c'));
    sourceH = dir(fullfile(sourcePath,'**\*.h'));
    % 复制.c
    for i=1:length(sourceSrc)
        T = sourceSrc(i,1);
        copyfile([T.folder '\' T.name],folderName);
        disp(['DD复制源：' T.folder '\' T.name]);
    end
    % 复制.h
%     eludeFile = {'Rte_VcThermal.h', 'Rte_Type.h'};
    for i=1:length(sourceH)
        T = sourceH(i,1);
%         if any(strcmp(T.name, eludeFile))  % 这几个文件不复制
%             continue
%         end
        copyfile([T.folder '\' T.name],folderName);
        disp(['DD复制源：' T.folder '\' T.name]);
    end



