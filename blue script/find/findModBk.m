function [bkIn, bkOut] = findModBk(pathMd)
%%
% 目的: 找到路径中模型的输入输出模块
% 输入：
%       pathMd：模型路径
% 返回：bkIn: 输入模块列表，bkOut: 输出模块列表
% 范例：[bkIn, bkOut] = findModBk(gcb)
% 说明：找到路径中模型的输入输出端口
% 作者： Blue.ge
% 日期：20231116
%%
    clc
%     pathMd = gcb; % for debug only
    h = get_param(pathMd, 'Handle');
    ports = get_param(h, 'Ports');
    portConnectivity = get_param(h, 'PortConnectivity');
    nIn = ports(1);
    nOut = ports(2);

    bkIn = zeros(1,nIn);
    bkOut = zeros(1,nOut);

    %% get the in block
    for i=1:nIn
        con = portConnectivity(i);
        if con.SrcBlock
            bkIn(i) = con.SrcBlock;
        else
            bkIn(i) = -1;
        end
    end
    %% check the model have some other ports like trig and enable
    nTrig = 0;
    if sum(ports(3:end)) >0
        nTrig=1;
    end
    %% get the out block
    for i=1:nOut
        con = portConnectivity(nIn+ nTrig + i);
        if con.DstBlock
            bkOut(i) = con.DstBlock;
        else
            bkOut(i) = -1;
        end
    end


end


