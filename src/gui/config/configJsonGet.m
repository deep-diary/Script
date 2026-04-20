function out = configJsonGet(varargin)
%CONFIGJSONGET 读取 JSON 配置（支持按键获取）
% 语法 (Syntax)
%   cfg = configJsonGet()
%   val = configJsonGet('stage')
%   val = configJsonGet('stage', '23N7')
%   val = configJsonGet('key', 'stage')
%   val = configJsonGet('key', 'stage', 'defaultValue', '23N7')
%
% 功能描述 (Description)
%   从 JSON 配置文件读取配置。可读取全量结构体，或按 key 读取单个字段值。
%   支持自动初始化（文件不存在时自动调用 configJsonInit）。
%
% 输入参数 (Input Arguments)
%   无必选位置参数。
%
% 可选参数 (Name-Value)
%   'key'          - 字段名（为空时返回整结构体），默认: ''
%   'defaultValue' - 指定 key 但不存在时返回的默认值，默认: []
%   'jsonFile'     - JSON 配置路径，默认:
%                    <repo>/src/gui/config/smart_thermal_config.json
%   'autoInit'     - 文件不存在时是否自动初始化，默认: true
%
% 输出参数 (Output Arguments)
%   out            - 全量配置结构体，或指定 key 的值
%
% 异常与边界行为 (Errors/Warnings)
%   - autoInit=false 且文件不存在时 error。
%   - key 不存在时返回 defaultValue，并 warning。
%
% 使用示例 (Examples)
%   % 示例1：读取全部配置
%   cfg = configJsonGet();
%
%   % 示例2：位置参数读取（兼容旧习惯）
%   stage = configJsonGet('stage', '23N7');
%
%   % 示例3：Name-Value 读取
%   stage = configJsonGet('key', 'stage', 'defaultValue', '23N7');
%
% 参见 (See also)
%   CONFIGJSONINIT, CONFIGJSONSET, CONFIGJSONMIGRATEFROMMAT
%
% 元信息
%   作者: blue.ge(葛维冬@Smart)
%   版本: 1.1
%   日期: 2026-04-17
%   变更记录:
%     2026-04-17 v1.1 支持位置参数调用：configJsonGet('key') / configJsonGet('key', defaultValue)。
%     2026-04-17 v1.0 首次创建：支持全量与按键读取。

[keyPos, defaultPos, restArgs] = i_extractPositionalArgs(varargin{:});

p = inputParser;
addParameter(p, 'key', keyPos, @(x)ischar(x) || isstring(x));
addParameter(p, 'defaultValue', defaultPos);
addParameter(p, 'jsonFile', i_defaultJsonFile(), @(x)ischar(x) || isstring(x));
addParameter(p, 'autoInit', true, @islogical);
parse(p, restArgs{:});

key = char(string(p.Results.key));
defaultValue = p.Results.defaultValue;
jsonFile = char(string(p.Results.jsonFile));
autoInit = p.Results.autoInit;

if ~isfile(jsonFile)
    if autoInit
        configJsonInit('jsonFile', jsonFile);
    else
        error('%s: JSON 配置文件不存在: %s', mfilename, jsonFile);
    end
end

txt = fileread(jsonFile);
cfg = jsondecode(txt);

if isempty(key)
    out = cfg;
    return;
end

if isfield(cfg, key)
    out = cfg.(key);
else
    warning('%s: 字段 "%s" 不存在，返回 defaultValue。', mfilename, key);
    out = defaultValue;
end
end

function p = i_defaultJsonFile()
thisFile = mfilename('fullpath');
thisDir = fileparts(thisFile);
p = fullfile(thisDir, 'smart_thermal_config.json');
end

function [keyPos, defaultPos, restArgs] = i_extractPositionalArgs(varargin)
keyPos = '';
defaultPos = [];
restArgs = varargin;
if isempty(varargin)
    return;
end

% 若首参是已知 Name-Value 名，则按纯 Name-Value 解析
if i_isKnownNameToken(varargin{1})
    return;
end

% 兼容位置参数: configJsonGet('key') / configJsonGet('key', defaultValue)
if ischar(varargin{1}) || isstring(varargin{1})
    keyPos = char(string(varargin{1}));
    restArgs = varargin(2:end);
    if numel(varargin) >= 2 && ~i_isKnownNameToken(varargin{2})
        defaultPos = varargin{2};
        restArgs = varargin(3:end);
    end
end
end

function tf = i_isKnownNameToken(x)
tf = false;
if ~(ischar(x) || isstring(x))
    return;
end
token = char(string(x));
tf = any(strcmpi(token, {'key', 'defaultvalue', 'jsonfile', 'autoinit'}));
end
