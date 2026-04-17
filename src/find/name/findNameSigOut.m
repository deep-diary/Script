function NameSigOut = findNameSigOut(Name, nameMd, varargin)
%%
    % 目的: 根据信号名，获取对应的输出
    % 输入：
    %       Name： 信号名称
    % 返回： NameSigOut: 模型最终输出信号
    % 范例： NameSigOut = findNameSigOut('rSigProces_Te_s32TargetSH', 'TmRefriVlvCtrl')
    % 说明： 比如当前信号名称是'rSigProces_Te_s32TargetSH', 则如下函数输出为'sTmRefriVlvCtrl_Te_s32TargetSH'
    % 作者： Blue.ge
    % 日期： 20240531
%%
        clc
        %% 输入参数处理
%         p = inputParser;            % 函数的输入解析器
%         addParameter(p,'mode','tail');      % pre: 将前缀替换成模型名称, tail：将模型名称添加到后缀
%         
%         parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
%     
%         mode = p.Results.mode;
        %% 确定信号前缀
        strList = split(Name,'_');
        if length(strList) > 3
            error('SigName should format like rMdName_B_SigName or SigName')
        end

        if strcmp(strList{2}, 'B')
            prefix = 'y';
        else
            prefix = 's';
        end        
        %% 信号重组
        strList{1} = [prefix,nameMd];
        NameSigOut = join(strList,"_");
        NameSigOut = NameSigOut{1};
end