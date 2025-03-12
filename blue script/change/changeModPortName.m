function portsChanged = changeModPortName(path, old, new)
%%
% 目的: 批量改变path对应模型的端口名称
% 输入：
%       Null
% 返回：Null
% 范例：changeModPortName(gcb, 'TmComprCtrl', 'SM123')
% 说明：批量改变端口名称
% 作者： Blue.ge
% 日期： 20231207
%%
    clc
%     path = gcs  % for debug only
    portsChanged = {}
    [ModelName,PortsIn,PortsOut] = findModPorts(path);

    %% 输入端口
    for i=1:length(PortsIn)
        name = get_param(PortsIn{i}, 'Name');
        
        %       将name 中的org 替换成tar
        name = strrep(name, old, new);
        set_param(PortsIn{i}, 'Name', name)
        portsChanged = [portsChanged,name];
    end

    %% 输出端口
    for i=1:length(PortsOut)
        name = get_param(PortsOut{i}, 'Name');
        %       将name 中的org 替换成tar
        name = strrep(name, old, new);
        set_param(PortsOut{i}, 'Name', name)
        portsChanged = [portsChanged,name];
    end
end
