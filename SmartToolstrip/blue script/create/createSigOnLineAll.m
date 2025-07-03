function createSigOnLineAll()
%%
    % 目的: 为架构层解析所有子模型及引用模型的信号
    % 输入：
    %       None
    % 返回： None
    % 范例： createSigOnLineAll()
    % 作者： Blue.ge
    % 日期： 20231112
%%
    clc
    TmIn = 'TmIn';
    subMods = {
        'TmRefriModeMgr','TmColtModeMgr','TmHvchCtrl',...   % 远飞
        'TmComprCtrl','TmRefriVlvCtrl','TmSovCtrl',...      % Blue
        'TmSigProces','TmPumpCtrl','TmColtVlvCtrl','TmEnergyMgr'...  % 江敏
        'TmDiag','TmAfCtrl', ...                                 % 冬清
        'TmBase2Out' % 输出转换
        };
    TmOut = 'TmOut';

    root = gcs;

    
    % 为Interface的输入解析信号
    path = [root, '/', TmIn];
    createSigOnLine(path, 'mode','outport', 'skipTrig',false)
    % 为所有次层模型解析信号
    for i=1:length(subMods)
        path = [root, '/', subMods{i}];
        createSigOnLine(path, 'mode','both', 'skipTrig',true)
    end
    % 为Interface的输出解析信号
    path = [root, '/', TmOut];
    createSigOnLine(path, 'mode','inport', 'skipTrig',false)
        
end
