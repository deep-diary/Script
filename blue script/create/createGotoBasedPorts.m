function [numInputPorts, numOutputPorts] = createGotoBasedPorts(path, varargin)
%CREATEGOTOBASEDPORTS 为输入输出端口创建对应的Goto和From模块
%   [numInputPorts, numOutputPorts] = createGotoBasedPorts(path) 为指定路径下的
%   输入输出端口创建对应的Goto和From模块，并进行连线。
%
%   输入参数:
%       path - 模型路径，例如 gcs
%
%   可选参数:
%       'FiltUnconnected' - 是否过滤未连接的端口，默认为true
%
%   输出参数:
%       numInputPorts - 创建的输入端口数量
%       numOutputPorts - 创建的输出端口数量
%
%   示例:
%       [numIn, numOut] = createGotoBasedPorts(gcs)
%       [numIn, numOut] = createGotoBasedPorts(gcs, 'FiltUnconnected', false)
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2023-04-29
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        addParameter(p, 'FiltUnconnected', true, @islogical);
        parse(p, varargin{:});
        
        filtUnconnected = p.Results.FiltUnconnected;
        
        %% 整理端口位置
        changePortPos('isEnableIn', true, 'isEnableOut', true);
        
        %% 获取端口信息
        [modelName, portsIn, portsOut] = findModPorts(path, ...
            'getType', 'Handle', ...
            'FiltUnconnected', filtUnconnected);
        
        %% 初始化计数器
        numInputPorts = 0;
        numOutputPorts = 0;
        
        %% 处理输入端口
        for i = 1:length(portsIn)
            numInputPorts = numInputPorts + 1;
            portHandle = portsIn{i};
            portName = get_param(portHandle, 'Name');
            portPos = get_param(portHandle, 'Position');
            
            % 创建Goto模块
            gotoPos = portPos + [300 0 300 0];
            gotoBlock = add_block('built-in/Goto', ...
                [path '/Goto'], ...
                'MakeNameUnique', 'on', ...
                'Position', gotoPos);
            set_param(gotoBlock, 'GotoTag', portName);
            
            % 创建连线
            creatLines([portHandle, gotoBlock]);
            
            fprintf('已为输入端口 %s 创建Goto模块\n', portName);
        end
        
        %% 处理输出端口
        for i = 1:length(portsOut)
            numOutputPorts = numOutputPorts + 1;
            portHandle = portsOut{i};
            portName = get_param(portHandle, 'Name');
            portPos = get_param(portHandle, 'Position');
            
            % 创建From模块
            fromPos = portPos + [-300 0 -300 0];
            fromBlock = add_block('built-in/From', ...
                [path '/From'], ...
                'MakeNameUnique', 'on', ...
                'Position', fromPos);
            set_param(fromBlock, 'GotoTag', portName);
            
            % 创建连线
            creatLines([fromBlock, portHandle]);
            
            fprintf('已为输出端口 %s 创建From模块\n', portName);
        end
        
        fprintf('创建完成: %d 个输入端口, %d 个输出端口\n', ...
            numInputPorts, numOutputPorts);
        
    catch ME
        error('创建Goto/From模块时发生错误: %s', ME.message);
    end
end

