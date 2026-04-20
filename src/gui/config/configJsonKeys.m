function keys = configJsonKeys(varargin)
%CONFIGJSONKEYS 获取 JSON 配置的键名列表
% 语法 (Syntax)
%   keys = configJsonKeys()
%   keys = configJsonKeys('Name', Value, ...)
%
% 功能描述 (Description)
%   读取 JSON 配置并返回顶层字段名列表，便于在 App Designer 列表框、下拉框中直接显示。
%
% 输入参数 (Input Arguments)
%   无必选位置参数。
%
% 可选参数 (Name-Value)
%   'jsonFile'   - JSON 配置路径，默认:
%                  <repo>/src/gui/config/smart_thermal_config.json
%   'autoInit'   - 文件不存在时是否自动初始化，默认: true
%   'asString'   - 是否返回 string 列向量，默认: true
%   'sortKeys'   - 是否按字母排序，默认: true
%
% 输出参数 (Output Arguments)
%   keys         - 键名列表
%                  - asString=true: string(N,1)
%                  - asString=false: cellstr(N,1)
%
% 异常与边界行为 (Errors/Warnings)
%   - autoInit=false 且文件不存在时 error。
%   - 配置为空 struct 时返回空列表。
%
% 使用示例 (Examples)
%   % 示例1：获取并排序（默认）
%   keys = configJsonKeys();
%
%   % 示例2：用于 UI 列表框
%   app.ConfigKeyListBox.Items = cellstr(configJsonKeys());
%
% 参见 (See also)
%   CONFIGJSONGET, CONFIGJSONINIT, FIELDNAMES
%
% 元信息
%   作者: blue.ge(葛维冬@Smart)
%   版本: 1.0
%   日期: 2026-04-17
%   变更记录:
%     2026-04-17 v1.0 首次创建：返回 JSON 配置键名列表。

p = inputParser;
addParameter(p, 'jsonFile', i_defaultJsonFile(), @(x)ischar(x) || isstring(x));
addParameter(p, 'autoInit', true, @islogical);
addParameter(p, 'asString', true, @islogical);
addParameter(p, 'sortKeys', true, @islogical);
parse(p, varargin{:});

jsonFile = char(string(p.Results.jsonFile));
autoInit = p.Results.autoInit;
asString = p.Results.asString;
sortKeys = p.Results.sortKeys;

cfg = configJsonGet('jsonFile', jsonFile, 'autoInit', autoInit);
if ~isstruct(cfg)
    if asString
        keys = strings(0, 1);
    else
        keys = cell(0, 1);
    end
    return;
end

f = fieldnames(cfg);
if isempty(f)
    if asString
        keys = strings(0, 1);
    else
        keys = cell(0, 1);
    end
    return;
end

if sortKeys
    f = sort(f);
end

if asString
    keys = string(f);
else
    keys = f;
end
keys = keys(:);
end

function p = i_defaultJsonFile()
thisFile = mfilename('fullpath');
thisDir = fileparts(thisFile);
p = fullfile(thisDir, 'smart_thermal_config.json');
end
