function config = configGet(varargin)
%CONFIGGET 从配置文件中加载参数
%   CONFIG = CONFIGGET() 加载默认配置文件并返回所有参数
%   CONFIG = CONFIGGET('param', PARAMNAME) 加载指定参数
%   CONFIG = CONFIGGET('fileName', FILENAME) 从指定文件加载所有参数
%   CONFIG = CONFIGGET('param', PARAMNAME, 'fileName', FILENAME) 从指定文件加载指定参数
%
%   输入参数:
%       varargin - 名称-值对参数:
%           'param'    - 需要加载的参数名称，字符串。如果未指定，返回所有参数
%           'fileName' - 配置文件名，字符串。默认为'config.mat'
%
%   输出参数:
%       config - 返回的参数值。如果指定了param，返回该参数的值；
%               如果未指定param，返回包含所有参数的结构体
%
%   示例:
%       % 加载所有参数
%       allConfig = configGet()
%
%       % 加载指定参数
%       signals = configGet('param', 'Signals')
%
%       % 从指定文件加载参数
%       config = configGet('fileName', 'myConfig.mat')
%
%   另请参阅: configSet, configInit, load
%
%   作者: Blue.ge
%   日期: 20250523

    p = inputParser;
    addParameter(p, 'param', '', @ischar);
    addParameter(p, 'fileName', 'config.mat', @ischar);
    parse(p, varargin{:});

    param = p.Results.param;
    fileName = p.Results.fileName;


    config = '';
    if exist(fileName, 'file')
        data = load(fileName);
        if isempty(param)
            config = data;
        else
            if isfield(data, param)
                config = data.(param);
            else
                warning('参数 %s 不存在于配置文件中', param);
            end
        end
    else
        error('配置文件 %s 不存在', fileName);
    end
end 