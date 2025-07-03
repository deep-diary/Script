function portsChanged = changeModPortName(path, old, new, varargin)
%CHANGEMODPORTNAME 批量改变模型的端口名称
%   PORTSCHANGED = CHANGEMODPORTNAME(PATH, OLD, NEW) 使用默认参数改变所有端口名称
%   PORTSCHANGED = CHANGEMODPORTNAME(PATH, OLD, NEW, 'Parameter', Value, ...) 使用指定参数
%
%   输入参数:
%      path         - 模型路径 (字符串)
%      old          - 需要替换的旧名称 (字符串)
%      new          - 替换后的新名称 (字符串)
%
%   可选参数（名值对）:
%      'changeIn'   - 是否改变输入端口名称, 默认值: true
%      'changeOut'  - 是否改变输出端口名称, 默认值: true
%
%   输出参数:
%      portsChanged - 已更改的端口名称列表 (元胞数组)
%
%   功能描述:
%      1. 查找模型中的所有输入输出端口
%      2. 根据指定的旧名称和新名称替换端口名称
%      3. 可选择性地只处理输入端口或输出端口
%      4. 返回所有更改的端口名称列表
%
%   示例:
%      % 基本用法（改变所有端口）
%      portsChanged = changeModPortName(gcb, 'TmComprCtrl', 'SM123')
%
%      % 只改变输入端口
%      portsChanged = changeModPortName(gcb, 'TmComprCtrl', 'SM123', ...
%          'changeIn', true, 'changeOut', false)
%
%   注意事项:
%      1. 使用前需要确保模型已打开
%      2. 端口名称更改会立即生效
%      3. 函数会返回所有更改的端口名称
%
%   参见: FINDMODPORTS
%
%   作者: Blue.ge
%   版本: 1.1
%   日期: 20231207

    %% 参数解析
    p = inputParser;
    addParameter(p, 'changeIn', true);
    addParameter(p, 'changeOut', true);
    parse(p, varargin{:});
    
    changeIn = p.Results.changeIn;
    changeOut = p.Results.changeOut;

    %% 初始化
    portsChanged = {};
    [ModelName, PortsIn, PortsOut] = findModPorts(path);

    %% 处理输入端口
    if changeIn
        for i = 1:length(PortsIn)
            name = get_param(PortsIn{i}, 'Name');
            name = strrep(name, old, new);
            set_param(PortsIn{i}, 'Name', name);
            portsChanged = [portsChanged, name];
        end
    end

    %% 处理输出端口
    if changeOut
        for i = 1:length(PortsOut)
            name = get_param(PortsOut{i}, 'Name');
            name = strrep(name, old, new);
            set_param(PortsOut{i}, 'Name', name);
            portsChanged = [portsChanged, name];
        end
    end
end
