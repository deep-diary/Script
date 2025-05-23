function setConfig(key, value, varargin)
% setConfig 将参数保存到配置文件中
%   setConfig(key, value, 'fileName', 'config.mat')
%   输入:
%       key - 参数名称
%       value - 参数值
%       varargin - 可选参数:
%           'fileName' - 配置文件名（默认'config.mat'）
%   范例:
%       setConfig('Signals', [1, 2, 3])
%   作者: Blue.ge
%   日期: 20250523

    p = inputParser;
    addParameter(p, 'fileName', 'config.mat', @ischar);
    parse(p, varargin{:});

    fileName = p.Results.fileName;

    if exist(fileName, 'file')
        data = load(fileName);
    else
        data = struct();
    end

    if isempty(value)
        if isfield(data, key)
            data = rmfield(data, key);
        end
    else
        data.(key) = value;
    end

    save(fileName, '-struct', 'data');
end 