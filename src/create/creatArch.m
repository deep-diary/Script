function creatArch()
%%
    % 目的: 创建整个架构模型，基于goto from 方案
    % 输入：
    %       name： 信号名称
    % 返回： type: 信号类型及PCMU, VCU的storage class
    % 范例： creatArch()
    % 作者： Blue.ge
    % 日期： 20231009
%%
    clc

%     delGcsAll()  % 删除整个架构
    subMods = {
        'TmRefriModeMgr','TmColtModeMgr','TmHvchCtrl',...   % 远飞
        'TmComprCtrl','TmRefriVlvCtrl','TmSovCtrl',...      % Blue
        'TmSigProces','TmPumpCtrl','TmColtVlvCtrl','TmEnergyMgr'...  % 江敏
        'TmDiag','TmAfCtrl'                                 % 冬清
        };
    baseMode = {'TmSwArch'}
    stpX = 1500;
    stpY = 2500;
    posOrg=[0 0 500 5000];
    root = gcs;

    %% 创建Interface 输入
    open_system(root)
    creatIFIn('pos',[0,0])

    %% 创建子模型
    open_system(root)
    creatTmBase()

    %% 创建输出转换
    open_system(root)
    pos=posOrg+[stpX * 7, stpY * 0, stpX * 7,  stpY * 0];
    nums = creatTmOut('posMod',pos);

    %% 创建Interface输出
    open_system(root)
    %     pos=posOrg+[stpX * 8, stpY * 0, stpX * 8,  stpY * 0];
    creatIFOut()


    %% 创建From 来匹配无用的输出goto
    creatFromBasedOnUselessGoto('posBase',[stpX * 9 0])

    %% 创建 Goto 来匹配无用的From
    creatGotoBasedOnUselessFrom('posBase',[stpX * 10 0])
    %% 改变配置
    changeCfgRefAll()
end