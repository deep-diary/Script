function portsChanged = changeModPortType(path)
%%
% 目的: 根据信号名称，改变path对应模型的端口数据类型
% 输入：
%       Null
% 返回：Null
% 范例：changeModPortType(gcs)
% 说明：找到路径中模型的输入输出端口
% 作者： Blue.ge
% 日期： 20231020
%%
    clc
%     path = gcs  % for debug only
    portsChanged = {}
    [ModelName,PortsIn,PortsOut] = findModPorts(path);

    %% 输入端口
    for i=1:length(PortsIn)
        name = get_param(PortsIn{i}, 'Name');
        type = get_param(PortsIn{i}, 'OutDataTypeStr');

        [dataType, ~, ~, ~, ~] = findNameType(name);
        if ~strcmp(type, dataType)
            portsChanged = [portsChanged, name];
            set_param(PortsIn{i}, 'OutDataTypeStr', dataType)
        end

    end

    %% 输出端口
    for i=1:length(PortsOut)
        name = get_param(PortsOut{i}, 'Name');
        type = get_param(PortsOut{i}, 'OutDataTypeStr');

        [dataType, ~, ~, ~, ~] = findNameType(name);
        if ~strcmp(type, dataType)
            portsChanged = [portsChanged, name];
            set_param(PortsOut{i}, 'OutDataTypeStr', dataType)
        end

    end
end
