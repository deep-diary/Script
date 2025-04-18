function changeCfgRef(mdName, cfg)
%CHANGECFGREF 更改模型的配置引用设置
%   CHANGECFGREF(MDNAME, CFG) 为指定模型设置配置引用
%
%   输入参数:
%      mdName       - 模型名称 (字符串)
%      cfg          - 配置文件名称 (字符串)
%
%   功能描述:
%      1. 加载指定的配置文件
%      2. 为模型创建或更新配置引用
%      3. 激活新的配置引用
%      4. 保存并关闭模型
%
%   示例:
%      % 基本用法
%      changeCfgRef('TmComprCtrl', 'TmVcThermal_Configuration_sub')
%
%   注意事项:
%      1. 使用前需要确保配置文件存在
%      2. 配置文件应为.mat格式
%      3. 函数会自动保存并关闭模型
%      4. 如果配置引用已存在，将更新其源文件
%
%   参见: SIMULINK.CONFIGSETREF, SETACTIVECONFIGSET
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 20231031

    %% 加载配置文件
    refName = 'Reference_PCMU';
    try
        load(cfg);
    catch
        warning('"TmVcThermal_Configuration_sub.mat" is not found!');
    end

    %% 加载模型
    h = load_system(mdName);

    %% 配置模型引用
    k = getConfigSet(mdName, refName);
    
    if isempty(k)
        % 创建新的配置引用
        configRef = Simulink.ConfigSetRef;
        set_param(configRef, 'Name', refName);
        set_param(configRef, 'SourceName', cfg);
        attachConfigSet(mdName, configRef);
    else
        % 更新现有配置引用
        set_param(k, 'SourceName', cfg);
    end
    
    % 激活配置引用
    setActiveConfigSet(mdName, refName);

    %% 保存并关闭模型
    save_system(h, 'SaveDirtyReferencedModels', 'on');
    close_system(h);
    
    disp([mdName ' 模型 Configration配置完成']);
end

