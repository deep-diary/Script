function [validInports, validOutports] = delUselessPort(path, varargin)
%DELUSELESSPORT 删除模型中无用的输入输出端口及其相连模块
%   [validInports, validOutports] = delUselessPort(path) 删除当前路径下无用的端口
%   [validInports, validOutports] = delUselessPort(path, 'UselessInBlock', 'Terminator', 'UselessOutBlock', 'Ground')
%   删除指定类型的无用端口
%
%   输入参数:
%       path - 模型路径，可以是gcs或bdroot
%       'UselessInBlock' - 要删除的输入端口连接的模块类型，默认为'Terminator'
%       'UselessOutBlock' - 要删除的输出端口连接的模块类型，默认为'Ground'
%
%   输出参数:
%       validInports - 保留的有效输入端口列表
%       validOutports - 保留的有效输出端口列表
%
%   示例:
%       [validInports, validOutports] = delUselessPort(gcs)
%       [validInports, validOutports] = delUselessPort(gcs, 'UselessInBlock', 'Terminator')
%
%   作者: Blue.ge
%   日期: 20231020
%   修改: 20240321

%% 参数解析
p = inputParser;
addParameter(p, 'UselessInBlock', 'Terminator', @ischar);
addParameter(p, 'UselessOutBlock', 'Ground', @ischar);
parse(p, varargin{:});

%% 初始化变量
validInports = {};
validOutports = {};
[~, PortsIn, PortsOut] = findModPorts(path);

%% 处理输入端口
validInports = processPorts(PortsIn, p.Results.UselessInBlock, 'in');

%% 处理输出端口
validOutports = processPorts(PortsOut, p.Results.UselessOutBlock, 'out');

%% 删除无用连线
delUselessLine(gcs);

end

%% 辅助函数
function validPorts = processPorts(ports, uselessBlockType, portType)
%PROCESSPORTS 处理端口列表，删除无用端口
%   处理输入或输出端口列表，删除连接到指定类型模块的端口
%   以及被注释的模块连接的端口

validPorts = {};

for i = 1:length(ports)
    [hPort, hLine, hBlock] = findPortLineBlock(ports{i});
    
    % 检查端口连接状态
    if hLine == -1 || hBlock == -1
        % 未连接的端口直接删除
        delete_block(hPort);
        continue;
    end
    
    % 获取连接模块的属性
    bk = get(hBlock);
    isUseless = strcmp(bk.BlockType, uselessBlockType) || ...
                strcmp(bk.Commented, 'on');
    
    if isUseless
        % 删除无用端口及其连接
        delete_block([hBlock hPort]);
        delete_line(hLine);
        fprintf('已删除%s端口: %s\n', portType, ports{i});
    else
        % 保留有效端口
        validPorts = [validPorts, ports{i}];
    end
end

end
