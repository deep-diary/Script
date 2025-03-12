function NameSigLoc = findNameSigLoc(Name)
%%
    % 目的: 根据输出信号名，再本模型下所有的from 中，找到内部信号名
    % 输入：
    %       Name： 输出信号名称
    % 返回： NameSigLoc: 模型最终输出信号
    % 范例： NameSigLoc = findNameSigLoc('sTmRefriVlvCtrl_Te_s32TargetSH')
    % 说明： 比如当前信号名称是'sTmRefriVlvCtrl_Te_s32TargetSH', 则如下函数输出为'rSigProces_Te_s32TargetSH'
    % 作者： Blue.ge
    % 日期： 20240531
%%
        clc
        %% 输入参数处理

        %% 确定信号前缀
        strList = split(Name,'_');
        if length(strList) > 3
            error('SigName should format like rMdName_B_SigName or SigName')
        end
        
        sig = strList{end};


        %% 找到所有没有匹配的from
        uselessFrom = findUselessFrom();
        for i=1:length(uselessFrom)
            nameFrom = get_param(uselessFrom{i}, 'GotoTag');
            if contains(nameFrom, sig)
                NameSigLoc = nameFrom;
                break;
            end
        end
end