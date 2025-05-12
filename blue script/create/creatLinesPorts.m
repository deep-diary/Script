function creatLinesPorts(outports, inports)
    % 连接第一个未连接的输出端口到第一个未连接的输入端口
    for i = 1:length(outports)
        if get_param(outports(i), 'Line') == -1 % 未连接的输出端口
            for j = 1:length(inports)
                if get_param(inports(j), 'Line') == -1 % 未连接的输入端口
                    add_line(path, outports(i), inports(j), 'autorouting', 'on');
                    return; % 一旦连接，退出函数
                end
            end
        end
    end
end