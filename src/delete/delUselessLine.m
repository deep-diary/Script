function delUselessLine(path, varargin)
%DELUSELESSLINE 删除无用的信号线
%   DELUSELESSLINE(PATH) 删除指定路径下的无用信号线（仅本层）
%   DELUSELESSLINE(PATH, 'recursive', true) 递归删除所有子系统的无用信号线
%   DELUSELESSLINE(PATH, 'recursive', false) 仅删除本层的无用信号线（默认）
%
%   输入参数:
%      path      - 要处理的模型或子系统路径 (字符串)
%
%   可选参数（名值对）:
%      'recursive' - 是否递归删除所有子系统的无用信号线，默认值: false
%                    true: 删除所有子系统的无用信号线
%                    false: 仅删除本层的无用信号线
%
%   功能描述:
%      1. 查找指定路径下所有未连接的信号线
%      2. 根据recursive参数决定删除范围
%      3. 删除找到的无用信号线
%
%   示例:
%      % 删除本层无用信号线
%      delUselessLine('myModel');
%      
%      % 递归删除所有无用信号线
%      delUselessLine('myModel', 'recursive', true);
%      
%      % 明确指定仅删除本层
%      delUselessLine('myModel', 'recursive', false);
%
%   注意事项:
%      1. 函数会永久删除未连接的信号线，请谨慎使用
%      2. 建议在删除前保存模型
%      3. 递归模式下会处理所有子系统和子模型
%
%   参见: find_system, delete_line
%
%   作者: Blue.ge
%   版本: 2.0
%   日期: 20250911

    %% 输入验证
    if nargin < 1
        error('必须提供路径参数');
    end
    
    if isempty(path)
        error('路径参数不能为空');
    end
    
    % 确保输入为字符向量
    if isstring(path)
        path = char(path);
    end
    
    % 验证路径是否存在
    if ~exist(path, 'file') && ~bdIsLoaded(path)
        error('指定的路径不存在或模型未加载: %s', path);
    end
    
    %% 解析可选参数
    p = inputParser;
    p.FunctionName = mfilename;
    addParameter(p, 'recursive', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    
    parse(p, varargin{:});
    recursive = p.Results.recursive;
    
    %% 执行删除操作
    try
        if recursive
            % 递归删除所有子系统的无用信号线
            fprintf('正在递归删除所有无用信号线...\n');
            unconnectedLines = find_system(path, 'findall', 'on', 'Type', 'Line', 'Connected', 'off');
        else
            % 仅删除本层的无用信号线
            fprintf('正在删除本层无用信号线...\n');
            unconnectedLines = find_system(path, 'SearchDepth', 1, 'findall', 'on', 'Type', 'Line', 'Connected', 'off');

        end
        delete_line(unconnectedLines);
        fprintf('无用信号线删除完成\n');
        
    catch ME
        error('删除无用信号线失败: %s', ME.message);
    end
end

