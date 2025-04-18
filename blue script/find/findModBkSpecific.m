function [bkIn, bkOut] = findModBkSpecific(path, varargin)
%FINDMODBKSPECIFIC 查找模型中特定类型的模块
%   [BKIN, BKOUT] = FINDMODBKSPECIFIC(PATH) 查找指定模型中的特定模块
%   [BKIN, BKOUT] = FINDMODBKSPECIFIC(PATH, 'condition', CONDITION) 指定查找条件
%
%   输入参数:
%      path      - 模型路径 (字符串)
%      condition - 查找条件 (字符串)
%                 可选值: 'useless' - 查找接地和终止模块
%                        'unconnected' - 查找未连接的端口
%
%   输出参数:
%      bkIn  - 输入端口名称列表 (元胞数组)
%      bkOut - 输出端口名称列表 (元胞数组)
%
%   功能描述:
%      1. 获取模型的所有输入输出模块
%      2. 根据条件筛选特定类型的模块
%      3. 返回符合条件的端口名称
%
%   示例:
%      % 查找未使用的模块
%      [bkIn, bkOut] = findModBkSpecific(gcb, 'condition', 'useless')
%
%      % 查找未连接的端口
%      [bkIn, bkOut] = findModBkSpecific(gcb, 'condition', 'unconnected')
%
%   注意事项:
%      1. 输入参数必须是有效的模型路径
%      2. condition参数必须是'useless'或'unconnected'
%      3. 返回的是端口名称而不是模块句柄
%
%   作者: Blue.ge
%   版本: 1.1
%   日期: 20231117

    %% 参数解析
    p = inputParser;
    addParameter(p, 'condition', 'useless', @(x) any(validatestring(x, {'useless', 'unconnected'})));
    parse(p, varargin{:});
    condition = p.Results.condition;

    try
        %% 获取模型信息
        [bkInAll, bkOutAll] = findModBkConnected(path);
        [~, PortsIn, PortsOut] = findModPorts(path);
        
        % 初始化输出
        bkIn = {};
        bkOut = {};

        %% 处理输入端口
        for i = 1:length(bkInAll)
            h = bkInAll(i);
            portName = get_param(PortsIn{i}, 'Name');

            if strcmp(condition, 'useless')
                if h == -1
                    continue;
                end
                blockType = get_param(h, 'BlockType');
                if strcmp(blockType, 'Ground')
                    bkIn = [bkIn, portName];
                end
            else % unconnected
                if h ~= -1
                    continue;
                end
                bkIn = [bkIn, portName];
            end
        end
        % 显示提示信息
        fprintf('输入端口-%s:\n', condition);
        for i = 1:length(bkIn)
            fprintf('    %s\n', bkIn{i});
        end
        %% 处理输出端口
        for i = 1:length(bkOutAll)
            h = bkOutAll(i);
            portName = get_param(PortsOut{i}, 'Name');

            if strcmp(condition, 'useless')
                if h == -1
                    continue;
                end
                blockType = get_param(h, 'BlockType');
                if strcmp(blockType, 'Terminator')
                    bkOut = [bkOut, portName];
                end
            else % unconnected
                if h ~= -1
                    continue;
                end
                bkOut = [bkOut, portName];
            end
        end
        % 显示提示信息
        fprintf('输出端口-%s:\n', condition);
        for i = 1:length(bkOut)
            fprintf('    %s\n', bkOut{i});
        end


    catch ME
        error('查找特定模块失败: %s', ME.message);
    end
end


