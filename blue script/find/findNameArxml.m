function sigName = findNameArxml(portName)
% 目的:
% 根据arxmal格式提取字符串,yGlHwDrvDiag_B_Sov4SGflgin_yGlHwDrvDiag_B_Sov4SGflgin_read
% --> yGlHwDrvDiag_B_Sov4SGflgin
% 输入：
%       portName: arxml端口名称
% 返回： sigName: 信号名
% 范例： sigName = findNameArxml('yGlHwDrvDiag_B_Sov4SGflgin_yGlHwDrvDiag_B_Sov4SGflgin_read')
% 作者： Blue.ge
% 日期： 20231010
%%
    clc

    if endsWith(portName, '_read')
        portName = portName(1:end-5);
        % 计算所需信号长度
        signalLength = (length(portName) - 1) / 2;
        % 提取前 signalLength 个字符
        sigName = portName(1:signalLength);
    elseif endsWith(portName, '_write')
        portName = portName(1:end-6);
            % 计算所需信号长度
        signalLength = (length(portName) - 1) / 2;
        % 提取前 signalLength 个字符
        sigName = portName(1:signalLength);
    else
        sigName = portName;
        warning('this is not the autosar interface name; which only end with _read or _write')
    end
    

