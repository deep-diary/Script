function config = configGet(param,varargin)
%CONFIGGET 从配置文件中加载参数
%   CONFIG = CONFIGGET() 加载默认配置文件并返回所有参数
%   CONFIG = CONFIGGET(PARAMNAME) 加载指定参数，如果参数不存在则返回所有参数
%   CONFIG = CONFIGGET('fileName', FILENAME) 从指定文件加载所有参数
%   CONFIG = CONFIGGET(PARAMNAME, 'fileName', FILENAME) 从指定文件加载指定参数
%
%   输入参数:
%       varargin - 名称-值对参数:
%           'param'    - 需要加载的参数名称，字符串。如果未指定，返回所有参数
%           'fileName' - 配置文件名，字符串。默认为'config.mat'
%
%   输出参数:
%       config - 返回的参数值。如果指定了param且存在，返回该参数的值；
%               如果指定了param但不存在，或未指定param，返回包含所有参数的结构体
%
%   示例:
%       % 加载所有参数
%       allConfig = configGet()
%
%       % 加载指定参数
%       signals = configGet('Signals')
%
%       % 从指定文件加载参数
%       config = configGet('fileName', 'myConfig.mat')
%
%   另请参阅: configSet, configInit, load
%
%   作者: Blue.ge
%   日期: 20250523

    p = inputParser;
    addParameter(p, 'fileName', 'config.mat', @ischar);
    parse(p, varargin{:});

    fileName = p.Results.fileName;

    if ~exist(fileName, 'file')
        error('配置文件 %s 不存在', fileName);
    end

    data = load(fileName);
    
    % 如果没有指定参数，返回所有配置
    if nargin == 0 || isempty(param)
        config = data;
        return;
    end
    
    % 如果指定了参数
    if isfield(data, param)
        config = data.(param);
    else
        warning('参数 %s 不存在于配置文件中，返回所有配置', param);
        config = data;
    end
end 