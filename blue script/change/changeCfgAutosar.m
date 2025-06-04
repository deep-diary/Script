function changeCfgAutosar(modelName)
%CHANGECFGAUTOSAR 配置AUTOSAR模型的参数设置
%   CHANGECFGAUTOSAR(MODELNAME) 配置指定AUTOSAR模型的参数设置
%
%   输入参数:
%      modelName    - 模型名称 (字符串)
%
%   功能描述:
%      1. 打开指定的AUTOSAR模型
%      2. 配置代码生成参数
%      3. 创建AUTOSAR API
%      4. 设置模型配置参数
%      5. 保存模型更改
%
%   示例:
%      % 基本用法
%      changeCfgAutosar('TmComprCtrl')
%
%   注意事项:
%      1. 使用前需要确保模型文件存在
%      2. 配置参数包括:
%         - SampleTimeConstraint: 设置为'Unconstrained'
%         - SaveWithDisabledLinksMsg: 设置为'none'
%         - SaveWithParameterizedLinksMsg: 设置为'none'
%         - UnconnectedInputMsg: 设置为'none'
%         - UnconnectedOutputMsg: 设置为'none'
%      3. 函数会自动保存模型更改
%
%   参见: CODEGENAUTOSARCFG, AUTOSAR.API.CREATE
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 20231201

    %% 打开模型并初始化AUTOSAR配置
    open_system(modelName);
%     autosar.api.create(modelName);
    codeGenAutosarCfg;
    autosar.api.create(modelName);
    
    %% 配置模型参数
    % 获取模型的配置参数对象
    configSet = getActiveConfigSet(modelName);

    % 获取并显示所有配置参数
    allParams = get_param(configSet, 'ObjectParameters');
    disp(allParams);
    
    % 设置模型配置参数
    set_param(configSet, 'SampleTimeConstraint', 'Unconstrained');
    set_param(configSet, 'SaveWithDisabledLinksMsg', 'none');
    set_param(configSet, 'SaveWithParameterizedLinksMsg', 'none');
    set_param(configSet, 'UnconnectedInputMsg', 'none');
    set_param(configSet, 'UnconnectedOutputMsg', 'none');
    
    %% 保存更改
    save_system(modelName);
end
