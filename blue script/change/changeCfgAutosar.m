function changeCfgAutosar(modelName)
%%
% 目的: 改变autosar 配置
% 输入：
%       path: 模型名称
%   
% 返回：无
% 范例：changeCfgAutosar('TmSwArch')
% 说明：1. 分别打开2个模型后，执行此函数
% 作者： Blue.ge
% 日期： 20231201
%%

    
    % 载入 AUTOSAR 模型
%     modelName = 'subModRefPCMU'; % 替换为您的模型名称
    clc
    open_system(modelName);
    codeGenAutosarCfg
    autosar.api.create(modelName);
    
    %% 改配置参数
    % 获取模型的配置参数对象
    configSet = getActiveConfigSet(modelName);
    % 获取并显示所有配置参数
    allParams = get_param(configSet, 'ObjectParameters');
    disp(allParams);
%     set_param(configSet, 'SampleTimeConstraint', 'STIndependent'); % 'Unconstrained'
    set_param(configSet, 'SampleTimeConstraint', 'Unconstrained'); % 'Unconstrained'
    set_param(configSet, 'SaveWithDisabledLinksMsg', 'none');
    set_param(configSet, 'SaveWithParameterizedLinksMsg', 'none');
    set_param(configSet, 'UnconnectedInputMsg', 'none');
    set_param(configSet, 'UnconnectedOutputMsg', 'none');
    %%
    % 可选：保存更改
    save_system(modelName);

end
