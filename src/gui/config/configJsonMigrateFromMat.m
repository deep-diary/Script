function info = configJsonMigrateFromMat(varargin)
%CONFIGJSONMIGRATEFROMMAT 一次性将 MAT 配置迁移到 JSON 配置
% 语法 (Syntax)
%   info = configJsonMigrateFromMat()
%   info = configJsonMigrateFromMat('Name', Value, ...)
%
% 功能描述 (Description)
%   读取 MAT 配置（默认 config.mat），按默认字段模板进行过滤与补齐，
%   写入 JSON 配置文件（默认 src/gui/config/smart_thermal_config.json）。
%   适合从旧 MAT 配置平滑迁移到可编辑 JSON。
%
% 输入参数 (Input Arguments)
%   无必选位置参数。
%
% 可选参数 (Name-Value)
%   'matFile'        - 迁移源 MAT 文件，默认: config.mat
%   'jsonFile'       - 迁移目标 JSON 文件，默认:
%                      <repo>/src/gui/config/smart_thermal_config.json
%   'overwriteJson'  - 目标 JSON 已存在时是否覆盖，默认: false
%   'backupMat'      - 是否为源 MAT 生成 .bak 备份，默认: true
%   'prettyPrint'    - JSON 写入是否尽量格式化，默认: true
%
% 输出参数 (Output Arguments)
%   info             - 迁移结果结构体，字段:
%                      success, matFile, jsonFile, backupFile, summaryText
%
% 异常与边界行为 (Errors/Warnings)
%   - matFile 不存在时 error。
%   - jsonFile 已存在且 overwriteJson=false 时 error。
%   - backupMat=true 且备份失败时 warning（不影响迁移）。
%
% 使用示例 (Examples)
%   % 示例1：默认迁移
%   R = configJsonMigrateFromMat();
%
%   % 示例2：指定输入输出并允许覆盖
%   R = configJsonMigrateFromMat('matFile', 'config.mat', ...
%       'jsonFile', fullfile(pwd, 'app_config.json'), 'overwriteJson', true);
%
% 参见 (See also)
%   CONFIGJSONINIT, CONFIGJSONGET, CONFIGJSONSET, LOAD, JSONENCODE
%
% 元信息
%   作者: blue.ge(葛维冬@Smart)
%   版本: 1.0
%   日期: 2026-04-17
%   变更记录:
%     2026-04-17 v1.0 首次创建：提供 MAT -> JSON 一次性迁移。

p = inputParser;
addParameter(p, 'matFile', 'config.mat', @(x)ischar(x) || isstring(x));
addParameter(p, 'jsonFile', i_defaultJsonFile(), @(x)ischar(x) || isstring(x));
addParameter(p, 'overwriteJson', false, @islogical);
addParameter(p, 'backupMat', true, @islogical);
addParameter(p, 'prettyPrint', true, @islogical);
parse(p, varargin{:});

matFile = char(string(p.Results.matFile));
jsonFile = char(string(p.Results.jsonFile));
overwriteJson = p.Results.overwriteJson;
backupMat = p.Results.backupMat;
prettyPrint = p.Results.prettyPrint;

if ~isfile(matFile)
    error('%s: MAT 文件不存在: %s', mfilename, matFile);
end
if isfile(jsonFile) && ~overwriteJson
    error('%s: JSON 已存在，且 overwriteJson=false: %s', mfilename, jsonFile);
end

defaults = i_defaultConfig();
raw = load(matFile);
cfg = i_mergeConfig(defaults, raw);

backupFile = '';
if backupMat
    backupFile = [matFile '.bak'];
    try
        copyfile(matFile, backupFile, 'f');
    catch ME
        warning('%s: MAT 备份失败(%s): %s', mfilename, ME.message, matFile);
        backupFile = '';
    end
end

i_writeJson(jsonFile, cfg, prettyPrint);

info = struct();
info.success = true;
info.matFile = matFile;
info.jsonFile = jsonFile;
info.backupFile = backupFile;
info.summaryText = sprintf([ ...
    '[configJsonMigrateFromMat] 迁移完成\n' ...
    'MAT: %s\n' ...
    'JSON: %s\n' ...
    '备份: %s\n' ...
    '字段数: %d'], ...
    matFile, jsonFile, i_orPlaceholder(backupFile), numel(fieldnames(cfg)));
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

function s = i_orPlaceholder(v)
if isempty(v)
    s = '(未生成)';
else
    s = v;
end
end
