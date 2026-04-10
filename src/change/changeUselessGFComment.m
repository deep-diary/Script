function changeUselessGFComment(stat)
%%
% 目的: 改变无用的goto from的注释状态
% 输入：
%       stat: 可选 on off
% 返回：成功创建好的信号
% 范例： createPortsGoto(inportList, []),
% 作者： Blue.ge
% 日期： 20230928
%%
    clc
    uselessGoto = findUselessGoto();
    uselessFrom = findUselessFrom();
    for i=1:length(uselessGoto)
        set_param(uselessGoto{i},'Commented', stat)
    end

    for i=1:length(uselessFrom)
        set_param(uselessFrom{i},'Commented', stat)
    end
end