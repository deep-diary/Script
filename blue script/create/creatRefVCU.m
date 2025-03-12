function creatRefVCU(modelName,varargin)
%%
    % 目的: 创建VCU配置的模型引用
    % 输入：modelName： 模型名称
    % 返回： None
    % 范例： creatRefVCU('TmSovCtrl')  % TmComprCtrl  RefTest
    % 作者： Blue.ge
    % 日期： 20240204
%%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'SLDD','None');      % 设置变量名和默认参数
    addParameter(p,'DCM','None');      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    SLDD = p.Results.SLDD;
    DCM = p.Results.DCM;
    %% 加载sldd
    slddPathArch = 'TmSwArch_DD_VCU.xlsx';

    % 指定模型sldd 路径
    if strcmp(SLDD, 'None')
        slddPathMod = [modelName,'_DD_VCU.xlsx'];
    else
        slddPathMod = SLDD;
    end
    % 是否根据DCM更新SLDD
    if ~strcmp(DCM, 'None')
        changeArchSldd(DCM, slddPathMod);
    end


    %% 加载sldd

    findSlddLoad(slddPathArch)
    findSlddLoad(slddPathMod)

    cTmSwArch_t_s32SampleTime = Simulink.Parameter(0.1);
    cTmSwArch_t_s32SampleTime.DataType = 'single';
    %% 打开引用模型
    refModelName = 'subModRefVCU';
%     autosar.api.delete(refModelName);
    % 检查模型是否存在
    if exist([refModelName '.slx'], 'file')
        % 如果模型存在，则直接打开
        open_system(refModelName);
    else
        % 如果模型不存在，则创建并打开新模型
        new_system(refModelName);
        save_system(refModelName);
        open_system(refModelName);
    end

    delGcsAll()

    %% 模型生成位置
    stpX = 0;
    posOrg = [0 0 500 5000];
    pos=posOrg+[stpX * 4, 0, stpX * 4,  0];

    %% 3. 生成子模型
    root=gcs;
    path=[root,'/', modelName];

    bk = add_block('built-in/ModelReference', path, ...
     'ModelName', modelName, 'Position', pos); 
   
    changeModPos(path, pos)

    %% 配置autosar
    changeCfgErt(modelName)
    changeCfgErt(refModelName)

    %% 进入到仿真目录
%     proj = currentProject;
%     rootPath = proj.RootFolder;
%     simPath = fullfile(rootPath,'Simulation', 'subModRef');
%     if ~exist(simPath, 'dir')
%         mkdir(simPath);
%         disp(['创建文件夹: ' simPath]);
%     end
%     cd(simPath);

    %% 删除代码生成目录
    proj = currentProject;
    rootPath = proj.RootFolder;
    codeFold = 'CodeGen';
    fLists = dir(codeFold);
    for i=3:length(fLists)
        T = fLists(i);
        path = fullfile(rootPath,codeFold,T.name);
        if T.isdir
            rmdir(path,'s')
        else
            delete(path)
        end
    end

end

