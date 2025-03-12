function changeCfgRefAll()
%%
% 目的: 更改所有模型配置 
% 输入：
%       NA
% 返回：None
% 范例：changeCfgRefAll(),
% 说明：
% 作者： Blue.ge
% 日期： 20231101
%%
    clc
    subMods = {
        'TmRefriModeMgr','TmColtModeMgr','TmHvchCtrl',...   % 远飞
        'TmComprCtrl','TmRefriVlvCtrl','TmSovCtrl',...      % Blue
        'TmSigProces','TmPumpCtrl','TmColtVlvCtrl','TmEnergyMgr'...  % 江敏
        'TmDiag','TmAfCtrl'                                 % 冬清
        };
    load("config_combine.mat")

    cfg = 'TmVcThermal_Configuration_sub';
    
    for i=1:length(subMods)
        changeCfgRef(subMods{i},cfg)
    end

