function config = getConfig(varargin)
% getConfig 加载配置文件并返回指定参数或所有参数
%   config = getConfig('param', 'paramName', 'fileName', 'config.mat')
%   输入:
%       varargin - 可选参数:
%           'param' - 指定需要加载的参数名称（默认返回所有参数）
%           'fileName' - 配置文件名（默认'config.mat'）
%   输出:
%       config - 返回指定参数或所有参数
%   范例:
%       config = getConfig('param', 'Signals')
%   作者: Blue.ge
%   日期: 20250523

    p = inputParser;
    addParameter(p, 'param', '', @ischar);
    addParameter(p, 'fileName', 'config.mat', @ischar);
    parse(p, varargin{:});

    param = p.Results.param;
    fileName = p.Results.fileName;

    if exist(fileName, 'file')
        data = load(fileName);
        if isempty(param)
            config = data;
        else
            if isfield(data, param)
                config = data.(param);
            else
                error('参数 %s 不存在于配置文件中', param);
            end
        end
    else
        error('配置文件 %s 不存在', fileName);
    end
end 