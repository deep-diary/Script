function [bkIn, bkOut] = findModBkConnected(pathMd)
%FINDMODBKCONNECTED 查找与模型相连的输入输出模块
%   [BKIN, BKOUT] = FINDMODBKCONNECTED(PATHMD) 查找指定模型路径的输入输出模块
%
%   输入参数:
%      pathMd - 模型路径 (字符串)
%
%   输出参数:
%      bkIn  - 输入模块句柄列表 (数组)
%      bkOut - 输出模块句柄列表 (数组)
%
%   功能描述:
%      1. 获取模型的端口信息
%      2. 查找输入端口连接的模块
%      3. 查找输出端口连接的模块
%      4. 处理触发和使能端口
%
%   示例:
%      % 基本用法
%      [bkIn, bkOut] = findModBkConnected(gcb)
%
%   注意事项:
%      1. 如果端口未连接，对应位置返回-1
%      2. 支持处理触发和使能端口
%      3. 输入参数必须是有效的模型路径
%
%   作者: Blue.ge
%   版本: 1.1
%   日期: 20231116

    %% 参数检查
    if ~ischar(pathMd)
        error('输入参数必须是字符串类型的模型路径');
    end

    try
        %% 获取模型句柄和端口信息
        h = get_param(pathMd, 'Handle');
        ports = get_param(h, 'Ports');
        portConnectivity = get_param(h, 'PortConnectivity');
        
        % 获取输入输出端口数量
        nIn = ports(1);
        nOut = ports(2);
        
        % 初始化输出数组
        bkIn = zeros(1, nIn);
        bkOut = zeros(1, nOut);
        
        %% 处理输入端口
        for i = 1:nIn
            con = portConnectivity(i);
            if con.SrcBlock
                bkIn(i) = con.SrcBlock;
            else
                bkIn(i) = -1;
            end
        end
        
        %% 检查触发和使能端口
        nTrig = 0;
        if sum(ports(3:end)) > 0
            nTrig = 1;
        end
        
        %% 处理输出端口
        for i = 1:nOut
            con = portConnectivity(nIn + nTrig + i);
            if con.DstBlock
                bkOut(i) = con.DstBlock;
            else
                bkOut(i) = -1;
            end
        end
        
    catch ME
        error('查找模块连接失败: %s', ME.message);
    end
end


