function findSldd(pathMd)
%%
    % 目的: 获取模型的sldd, 包括signal 和parameter, 保存到excel中，用于生成sldd
    % 输入：
    %       pathMd： 模型路径
    % 返回： null
    % 范例： 打开模型，执行 findSldd(bdroot)
    % 作者： Blue.ge
    % 日期： 20231026
%%
    
    clc
%     pathMd = 'TmComprCtrlDev'; % debug only
    [DataPCMU, DataVCU] = findSlddSig(pathMd);
    [DataPCMU, DataVCU] = findSlddParam(pathMd);
end