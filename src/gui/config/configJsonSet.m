function cfg = configJsonSet(key, value, varargin)
%CONFIGJSONSET 写入 JSON 配置（支持删除字段）
% 语法 (Syntax)
%   cfg = configJsonSet('stage', '23N7')
%   cfg = configJsonSet('stage', '23N7', 'jsonFile', 'app_config.json')
%   cfg = configJsonSet('stage', []) % 删除字段
%
% 功能描述 (Description)
%   将单个键值写入 JSON 配置文件。若传入空数组 []，则删除该字段。
%   文件不存在时可自动初始化后再写入。
%
% 输入参数 (Input Arguments)
%   key            - 目标字段名（char/string）
%   value          - 字段值；[] 表示删除字段
%
% 可选参数 (Name-Value)
%   'jsonFile'     - JSON 配置路径，默认:
%                    <repo>/src/gui/config/smart_thermal_config.json
%   'autoInit'     - 文件不存在时是否自动初始化，默认: true
%   'prettyPrint'  - JSON 写入是否尽量格式化，默认: true
%
% 输出参数 (Output Arguments)
%   cfg            - 写入后的完整配置结构体
%
% 异常与边界行为 (Errors/Warnings)
%   - key 非法（空或非文本）时 error。
%   - autoInit=false 且文件不存在时 error。
%   - MATLAB 版本不支持 PrettyPrint 时，自动回退紧凑 JSON，并 warning。
%
% 使用示例 (Examples)
%   % 示例1：写入字段
%   cfg = configJsonSet('dcm_file', 'HB11_CCM_VP_V2.02_20260413_change.DCM');
%
%   % 示例2：删除字段
%   cfg = configJsonSet('legacy_key', []);
%
% 参见 (See also)
%   CONFIGJSONGET, CONFIGJSONINIT, JSONENCODE, JSONDECODE
%
% 元信息
%   作者: blue.ge(葛维冬@Smart)
%   版本: 1.0
%   日期: 2026-04-17
%   变更记录:
%     2026-04-17 v1.0 首次创建：支持单键写入与删除字段。

validateattributes(key, {'char', 'string'}, {'nonempty'}, mfilename, 'key');
key = char(string(key));

p = inputParser;
addParameter(p, 'jsonFile', i_defaultJsonFile(), @(x)ischar(x) || isstring(x));
addParameter(p, 'autoInit', true, @islogical);
addParameter(p, 'prettyPrint', true, @islogical);
parse(p, varargin{:});

jsonFile = char(string(p.Results.jsonFile));
autoInit = p.Results.autoInit;
prettyPrint = p.Results.prettyPrint;

if ~isfile(jsonFile)
    if autoInit
        configJsonInit('jsonFile', jsonFile, 'prettyPrint', prettyPrint);
    else
        error('%s: JSON 配置文件不存在: %s', mfilename, jsonFile);
    end
end

txt = fileread(jsonFile);
cfg = jsondecode(txt);

if isempty(value)
    if isfield(cfg, key)
        cfg = rmfield(cfg, key);
    end
else
    cfg.(key) = value;
end

i_writeJson(jsonFile, cfg, prettyPrint);
end

function i_writeJson(jsonFile, cfg, prettyPrint)
txt = '';
if prettyPrint
    try
        txt = jsonencode(cfg, 'PrettyPrint', true);
    catch
        txt = '';
    end
end
if isempty(txt)
    txt = jsonencode(cfg);
    if prettyPrint
        warning('%s: 当前版本可能不支持 PrettyPrint，已写入紧凑 JSON。', mfilename);
    end
end

fid = fopen(jsonFile, 'w');
if fid < 0
    error('%s: 无法写入 JSON 文件: %s', mfilename, jsonFile);
end
cleanupObj = onCleanup(@() fclose(fid));
fwrite(fid, txt, 'char');
clear cleanupObj;
end

function p = i_defaultJsonFile()
thisFile = mfilename('fullpath');
thisDir = fileparts(thisFile);
p = fullfile(thisDir, 'smart_thermal_config.json');
end
