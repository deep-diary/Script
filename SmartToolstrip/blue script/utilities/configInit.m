function config = configInit(varargin)
%CONFIGINIT 初始化配置文件
%   CONFIG = CONFIGINIT() 使用默认参数初始化配置文件
%   CONFIG = CONFIGINIT('fileName', FILENAME) 使用默认参数初始化指定文件
%
%   输入参数:
%       varargin - 名称-值对参数:
%           'fileName' - 配置文件名，字符串。默认为'config.mat'
%
%   输出参数:
%       config - 包含初始化参数的结构体
%
%   示例:
%       % 使用默认文件名初始化
%       config = configInit()
%
%       % 使用指定文件名初始化
%       config = configInit('fileName', 'myConfig.mat')
%
%   另请参阅: configGet, configSet
%
%   作者: Blue.ge
%   日期: 20250623

    % 解析输入参数
    p = inputParser;
    addParameter(p, 'fileName', 'config.mat', @ischar);
    parse(p, varargin{:});
    fileName = p.Results.fileName;

    % 默认参数
    defaultConfig = struct(...
        'stage', '23N7', ...
        'vername', 'VcThermal_23N7_V136_7080519', ...
        'dcm_name', 'HY11_PCMU_Tm_OTA3_V6060416_All.DCM', ...
        'soft_version', '7080519', ...
        'dcm_file', 'HY11_PCMU_Tm_OTA3_V6070519_All.DCM', ...
        'interface_version', 'V136', ...
        'com_used_model', {{}}, ...
        'template_file', 'TemplateSigInSigOut.xlsx' ...
    );

    % 如果文件已存在，加载现有配置
    if exist(fileName, 'file')
        existingConfig = load(fileName);
        % 合并现有配置和默认配置
        config = mergeConfigs(defaultConfig, existingConfig);
    else
        config = defaultConfig;
    end

    % 保存配置
    save(fileName, '-struct', 'config');
end

function mergedConfig = mergeConfigs(defaultConfig, existingConfig)
% 合并默认配置和现有配置
    mergedConfig = defaultConfig;
    fields = fieldnames(existingConfig);
    for i = 1:length(fields)
        field = fields{i};
        if isfield(defaultConfig, field)
            mergedConfig.(field) = existingConfig.(field);
        end
    end
end

