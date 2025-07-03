function  creatTmBaseArch(varargin)
%%
% 目的: 将外部信号转换为base模块的输入信号，1. 信号名的转变； 2. 增加data storage 模块，用于信号隔离
% 输入：
%       NA
% 返回：NA
% 范例：creatTmBaseArch('mod','ref')
% 说明：1. 打开根路径，然后执行此函数
% 作者： Blue.ge
% 日期： 20231030
%%
    %% 1. 初始化
     clc
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'stpX',1500);  
    addParameter(p,'stpY',2500);     
    addParameter(p,'posOrg',[0 0 500 5000]);      
    addParameter(p,'mod','ref');   % sub or ref
    % 输入参数处理   
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    stpX = p.Results.stpX;
    stpY = p.Results.stpY;
    posOrg = p.Results.posOrg;
    mod = p.Results.mod;

    %% 2. 获取子模型位置
       
    baseMode = 'TmSwArch';
    pos=posOrg+[stpX * 4, 0, stpX * 4,  0];

    %% 3. 生成子模型
    root=gcs;
    path=[root,'/', baseMode];

    if strcmp(mod, 'sub')
        bk = add_block('built-in/SubSystem', path, ...
         'Name', baseMode, 'Position', pos); 
        % 将架构模型内容全部复制过来
        createModCopy('TmSwArch', path)
    else
        bk = add_block('built-in/ModelReference', path, ...
         'ModelName', baseMode, 'Position', pos); 
        open_system(baseMode)
        autosar.api.create(baseMode);
        codeGenAutosarCfg
    end

    changeModPos(path, pos)
    open_system(root)
    createModGoto(path, 'mode','both');  % 创建输入输出端口

%     %% 4. 改变所有子模型配置
%     open_system(path)
%     changeRefModStat() % 刷新子模型
%     changeCfgRefAll()  % 更改配置文件


    %% 5. 创建From 来匹配无用的输出goto
    open_system(root)
    
    creatFromBasedOnUselessGoto('posBase',[stpX * 9 0])

    %% 6. 创建 Goto 来匹配无用的From
    creatGotoBasedOnUselessFrom('posBase',[stpX * 10 0])

    save_system(bdroot, 'SaveDirtyReferencedModels','on')
end


