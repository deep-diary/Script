function portsChanged = changeModPortType(path)
%CHANGEMODPORTTYPE 根据信号名称自动更改端口数据类型
%   PORTSCHANGED = CHANGEMODPORTTYPE(PATH) 根据信号名称自动更改指定路径下模型的端口数据类型
%
%   输入参数:
%      path         - 模型路径 (字符串)
%
%   输出参数:
%      portsChanged - 已更改的端口名称列表 (元胞数组)
%
%   功能描述:
%      1. 查找模型中的所有输入输出端口
%      2. 根据端口名称自动判断数据类型
%      3. 如果当前数据类型与判断结果不一致，则更新数据类型
%      4. 返回所有更改的端口名称列表
%
%   示例:
%      % 基本用法
%      portsChanged = changeModPortType(gcs)
%
%   注意事项:
%      1. 使用前需要确保模型已打开
%      2. 数据类型更改会立即生效
%      3. 函数会返回所有更改的端口名称
%      4. 数据类型判断基于信号名称规则
%
%   参见: FINDMODPORTS, FINDNAMETYPE
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 20231020

    %% 初始化
    portsChanged = {};
    if strcmp(path, bdroot)
        PortsIn = find_system(path, 'BlockType', 'Inport');
        PortsOut = find_system(path, 'BlockType', 'Outport');
    else
        [~, PortsIn, PortsOut] = findModPorts(path);
    end

    %% 处理输入端口
    for i = 1:length(PortsIn)
        name = get_param(PortsIn{i}, 'Name');
        currentType = get_param(PortsIn{i}, 'OutDataTypeStr');

        % 根据信号名称判断数据类型
        [dataType, ~, ~, ~, ~] = findNameType(name);
        
        % 如果数据类型不一致，则更新
        if ~strcmp(currentType, dataType)
            portsChanged = [portsChanged, name];
            set_param(PortsIn{i}, 'OutDataTypeStr', dataType);
        end
    end

    %% 处理输出端口
    for i = 1:length(PortsOut)
        name = get_param(PortsOut{i}, 'Name');
        currentType = get_param(PortsOut{i}, 'OutDataTypeStr');

        % 根据信号名称判断数据类型
        [dataType, ~, ~, ~, ~] = findNameType(name);
        
        % 如果数据类型不一致，则更新
        if ~strcmp(currentType, dataType)
            portsChanged = [portsChanged, name];
            set_param(PortsOut{i}, 'OutDataTypeStr', dataType);
        end
    end
end
