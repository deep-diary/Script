function deletedSig = delInportRelLineAndBlock(portPath, blockType)
%%
% 目的: portPath 是输入端口路径，现在这个输入端口通过信号线跟一个Block连接
% 输入：
%       portPath: 输入端口路径
%       blockType: 相连接的模块类别
% 返回：deletedSig 成功删除后，对应的信号名，如果删除失败，则返回空
% 范例： deletedSig = delInportRelLineAndBlock(portPath, 'Terminator')
% 作者： Blue.ge
% 日期： 20231019
%%
    clc

    deletedSig='';
    h = get_param(portPath, 'Handle');
    portHandle = get_param(h, 'PortHandles');
    lineHandle = get_param(portHandle.Outport, 'Line');
    
    if lineHandle~=-1
        
        % 获取信号线连接的 Block
        dstBlock = get_param(lineHandle, 'DstBlockHandle');
        
        % 判断连接的 Block 是否是 Terminator
        if strcmp(get_param(dstBlock, 'BlockType'), blockType)
            % 删除 Terminator
            delete_block(dstBlock);
            % 删除信号线
            delete_line(lineHandle);
            deletedSig = get_param(h, 'Name');
        end

    end
end






