function creatLines(hArray)
%%
    % 目的: 自动连接多个模块的未连接端口
    % 输入：hArray - 各模块的句柄列表
    % 返回：无
    % 范例：creatLines([h1, h2, h3])
    % 作者：Blue.ge
    % 日期：20231031
%%
    clc

    % 获取模块的PortHandles
    PortHd = get_param(hArray, 'PortHandles');

    % 遍历并连接模块
    for i = 1:length(hArray) - 1
        % 连接第一个未连接的输出到下一个模块的第一个未连接的输入
        creatLinesPorts(PortHd{i}.Outport, PortHd{i+1}.Inport);
    end
end



