function changeCfgRefAll()
%CHANGECFGREFALL 批量更改所有子模型的配置引用
%   CHANGECFGREFALL() 为所有子模型设置相同的配置引用
%
%   功能描述:
%      1. 加载配置文件
%      2. 遍历所有子模型
%      3. 为每个子模型设置配置引用
%      4. 显示处理进度
%
%   示例:
%      % 基本用法
%      changeCfgRefAll()
%
%   注意事项:
%      1. 使用前需要确保配置文件存在
%      2. 配置文件应为.mat格式
%      3. 子模型列表包括:
%         - 远飞负责的模块: TmRefriModeMgr, TmColtModeMgr, TmHvchCtrl
%         - Blue负责的模块: TmComprCtrl, TmRefriVlvCtrl, TmSovCtrl
%         - 江敏负责的模块: TmSigProces, TmPumpCtrl, TmColtVlvCtrl, TmEnergyMgr
%         - 冬清负责的模块: TmDiag, TmAfCtrl
%      4. 函数会自动保存所有模型的更改
%
%   参见: CHANGECFGREF
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 20231101

    %% 定义子模型列表
    subMods = {
        'TmRefriModeMgr', 'TmColtModeMgr', 'TmHvchCtrl',...   % 远飞
        'TmComprCtrl', 'TmRefriVlvCtrl', 'TmSovCtrl',...      % Blue
        'TmSigProces', 'TmPumpCtrl', 'TmColtVlvCtrl', 'TmEnergyMgr',...  % 江敏
        'TmDiag', 'TmAfCtrl'                                 % 冬清
    };

    %% 加载配置文件
    load("config_combine.mat");
    cfg = 'TmVcThermal_Configuration_sub';
    
    %% 处理每个子模型
    for i = 1:length(subMods)
        fprintf('正在处理模型: %s\n', subMods{i});
        changeCfgRef(subMods{i}, 'ConfigFile', cfg, 'CloseModel', true);
    end
    
    disp('所有模型配置完成');
end

