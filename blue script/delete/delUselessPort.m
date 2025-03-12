function [validInports, validOutports] = delUselessPort(path)
%%
    % 目的: 删除哪些无用的端口，比如接ground 和 terminator的，还有接的那些block已经注释掉了的
    % 输入：
    %        Null  
    % 返回： validInports: 有效的输入信号， validOutports: 有效的输出信号
    % 范例： [validInports, validOutports] = delUselessPort(gcs)
    % 引用： Null  
    % 作者： Blue.ge
    % 日期： 20231020
    %%
    clc
    validInports = {};
    validOutports = {};
    [ModelName,PortsIn,PortsOut] = findModPorts(path);
    %% 处理输入信号
    for i = 1:length(PortsIn)
        [hPort, hLine, hBlock] = findPortLineBlock(PortsIn{i});
        % 判断是否未无效的端口
        useless=false;
        bk = get(hBlock);
        bkType = bk.BlockType;
        commented = bk.Commented;
        if strcmp(bkType, 'Ground') || strcmp(bkType, 'Terminator')
            disp('useless port')
            useless = true;
        elseif strcmp(commented, 'on')
            disp('useless port')
            useless = true;
        else
            validInports = [validInports, PortsIn{i}];
        end

        if useless
            % 删除 Terminator
            delete_block([hBlock hPort]);
            % 删除信号线
            delete_line(hLine);
        end

    end

    %% 处理输出信号
    for i = 1:length(PortsOut)
        [hPort, hLine, hBlock] = findPortLineBlock(PortsOut{i});
        % 判断是否未无效的端口
        useless=false;
        bk = get(hBlock);
        bkType = bk.BlockType;
        commented = bk.Commented;
        if strcmp(bkType, 'Ground') || strcmp(bkType, 'Terminator')
            disp('useless port')
            useless = true;
        elseif strcmp(commented, 'on')
            disp('useless port')
            useless = true;
        else
            validOutports = [validOutports, PortsOut{i}];
        end

        if useless
            % 删除 Terminator
            delete_block([hBlock hPort]);
            % 删除信号线
            delete_line(hLine);
        end

    end
end
