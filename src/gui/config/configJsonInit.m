function config = configJsonInit(varargin)
%CONFIGJSONINIT 初始化 JSON 配置文件（可选从 MAT 迁移）
% 语法 (Syntax)
%   config = configJsonInit()
%   config = configJsonInit('Name', Value, ...)
%
% 功能描述 (Description)
%   初始化 Smart Thermal 的 JSON 配置文件。若目标 JSON 已存在，则加载并补齐默认字段；
%   若不存在，可按需从 MAT 配置迁移后写入。该函数用于建立可读可编辑的配置基线。
%
% 输入参数 (Input Arguments)
%   无必选位置参数。
%
% 可选参数 (Name-Value)
%   'jsonFile'          - JSON 文件路径，默认:
%                         <repo>/src/gui/config/smart_thermal_config.json
%   'matFile'           - 迁移来源 MAT 文件，默认: config.mat
%   'migrateIfMatExists'- JSON 不存在时，若 MAT 存在则自动迁移，默认: true
%   'overwrite'         - 是否覆盖已存在 JSON，默认: false
%   'prettyPrint'       - JSON 写入是否尽量格式化，默认: true
%
% 输出参数 (Output Arguments)
%   config              - 初始化后的配置结构体（已补齐默认字段）
%
% 异常与边界行为 (Errors/Warnings)
%   - 当 JSON 路径不可写时 error。
%   - 当 MAT 存在但读取失败时 warning，并回退到默认配置初始化。
%   - 当 MATLAB 版本不支持 PrettyPrint 时，自动回退紧凑 JSON，并 warning。
%
% 使用示例 (Examples)
%   % 示例1：使用默认路径初始化
%   C = configJsonInit();
%
%   % 示例2：指定路径并强制覆盖
%   C = configJsonInit('jsonFile', fullfile(pwd, 'app_config.json'), 'overwrite', true);
%
% 参见 (See also)
%   CONFIGJSONGET, CONFIGJSONSET, CONFIGJSONMIGRATEFROMMAT, JSONENCODE, JSONDECODE
%
% 元信息
%   作者: blue.ge(葛维冬@Smart)
%   版本: 1.0
%   日期: 2026-04-17
%   变更记录:
%     2026-04-17 v1.0 首次创建：支持默认初始化与可选 MAT 自动迁移。

p = inputParser;
addParameter(p, 'jsonFile', i_defaultJsonFile(), @(x)ischar(x) || isstring(x));
addParameter(p, 'matFile', 'config.mat', @(x)ischar(x) || isstring(x));
addParameter(p, 'migrateIfMatExists', true, @islogical);
addParameter(p, 'overwrite', false, @islogical);
addParameter(p, 'prettyPrint', true, @islogical);
parse(p, varargin{:});

jsonFile = char(string(p.Results.jsonFile));
matFile = char(string(p.Results.matFile));
migrateIfMatExists = p.Results.migrateIfMatExists;
overwrite = p.Results.overwrite;
prettyPrint = p.Results.prettyPrint;

defaults = i_defaultConfig();

if isfile(jsonFile) && ~overwrite
    config = i_readJsonWithDefaults(jsonFile, defaults);
    i_writeJson(jsonFile, config, prettyPrint);
    return;
end

config = defaults;
if migrateIfMatExists && isfile(matFile)
    try
        src = load(matFile);
        config = i_mergeConfig(defaults, src);
    catch ME
        warning('%s: MAT 迁移失败(%s)，回退默认配置。', mfilename, ME.message);
    end
end

i_writeJson(jsonFile, config, prettyPrint);
end

function cfg = i_defaultConfig()
cfg = struct( ...
    'stage', '23N7', ...
    'vername', 'VcThermal_23N7_V136_7080519', ...
    'dcm_name', 'HY11_PCMU_Tm_OTA3_V6060416_All.DCM', ...
    'soft_version', '7080519', ...
    'dcm_file', 'HY11_PCMU_Tm_OTA3_V6070519_All.DCM', ...
    'interface_version', 'V136', ...
    'com_used_model', {{}}, ...
    'com_used_controllers', {{}}, ...
    'active_controller', '', ...
    'template_file', 'TemplateSigInSigOut.xlsx', ...
    'GotoWid', '30', ...
    'GotoHeight', '14', ...
    'GotoColor', 'green', ...
    'FromColor', 'red', ...
    'PortWid', '30', ...
    'PortHeight', '14', ...
    'InportColor', 'blue', ...
    'OutportColor', 'magenta');
end

function cfg = i_readJsonWithDefaults(jsonFile, defaults)
txt = fileread(jsonFile);
raw = jsondecode(txt);
cfg = i_mergeConfig(defaults, raw);
end

function merged = i_mergeConfig(defaults, src)
merged = defaults;
if ~isstruct(src)
    return;
end
f = fieldnames(defaults);
for i = 1:numel(f)
    k = f{i};
    if isfield(src, k)
        merged.(k) = src.(k);
    end
end
end

function i_writeJson(jsonFile, cfg, prettyPrint)
jsonFile = char(string(jsonFile));
jsonDir = fileparts(jsonFile);
if ~isempty(jsonDir) && ~isfolder(jsonDir)
    mkdir(jsonDir);
end

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
