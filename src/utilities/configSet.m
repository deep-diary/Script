function configSet(key, value, varargin)
%CONFIGSET 将参数保存到配置文件中
%   CONFIGSET(KEY, VALUE) 将参数保存到默认配置文件
%   CONFIGSET(KEY, VALUE, 'fileName', FILENAME) 将参数保存到指定文件
%   CONFIGSET(KEY, []) 从配置文件中删除指定参数
%
%   输入参数:
%       key     - 参数名称，字符串
%       value   - 参数值，任意类型。如果为空数组[]，则删除该参数
%       varargin - 名称-值对参数:
%           'fileName' - 配置文件名，字符串。默认为'config.mat'
%
%   示例:
%       % 保存参数到默认配置文件
%       configSet('Signals', [1, 2, 3])
%
%       % 保存参数到指定文件
%       configSet('Signals', [1, 2, 3], 'fileName', 'myConfig.mat')
%
%       % 删除参数
%       configSet('Signals', [])
%
%   另请参阅: configGet, configInit, save
%
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

    save(which(fileName), '-struct', 'data');
end 