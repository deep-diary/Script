function sigName = findNameInput(portName,suffix)
% 目的: 去掉输入信号名字的后缀
% 输入：
%       portName: arxml端口名称
% 返回： sigName: 信号名
% 范例： sigName = findNameInput('yGlHwDrvDiag_B_Sov4SGflgin','in')
% 作者： Blue.ge
% 日期： 20240204
%%
    clc    
    if endsWith(portName,suffix)
        sigName=extractBefore(portName,length(portName)-length(suffix)+1);
    end
    sigName = strtrim(sigName); % 去掉前面的空格