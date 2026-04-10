function out = findPortsInfoFromArxml(ArxmlFileName, varargin)
%% 【函数】从 ARXML 提取组件/端口/接口信息（支持分步与缓存模型）
%
% 目标：避免重复导入 ARXML 导致执行过慢，按“生成模型缓存 -> 导出端口 -> 可选导出接口”分步执行。
%
% 用法：
%   % 一键执行：若模型缓存已存在则跳过生成
%   out = findPortsInfoFromArxml('CCM_Internal_swc.arxml');
%
%   % 只生成模型缓存（后续可复用）
%   out = findPortsInfoFromArxml('CCM_Internal_swc.arxml', 'step', 'generateModels');
%
%   % 基于已生成的模型缓存导出端口表（最快）
%   out = findPortsInfoFromArxml('CCM_Internal_swc.arxml', 'step', 'exportPorts');
%
%   % 在导出端口表基础上，再补充导出接口信息（较慢，可选）
%   out = findPortsInfoFromArxml('CCM_Internal_swc.arxml', 'step', 'exportInterfaces');
%
% 可选参数：
%   'step'           - 'all'(默认) | 'generateModels' | 'exportPorts' | 'exportInterfaces'
%   'modelCacheDir'  - 模型缓存目录（默认：<repo>/cache/arxml_models_<arxmlBase>）
%   'excelFile'      - Excel 输出文件路径（默认：<repo>/artifacts/<arxmlBase>_PortsInfo.xlsx）
%   'portsSheet'     - 端口表 sheet 名（默认：'Ports'）
%   'ifSheet'        - 接口表 sheet 名（默认：'Interfaces'）
%   'skipIfExists'   - 生成模型时若已存在则跳过（默认：true）
%   'includeRunnable'- 是否包含以 Runnable 结尾端口（默认：false）
%   'exportInterface'- 在 'all' 步骤中是否导出接口表（默认：false）
%
% 输出 out 结构体：
%   out.modelCacheDir
%   out.excelFile
%   out.portTable
%   out.interfaceTable

if nargin < 1 || isempty(ArxmlFileName)
    ArxmlFileName = 'CCM_Internal_swc.arxml';
end
validateattributes(ArxmlFileName, {'char','string'}, {'scalartext'}, mfilename, 'ArxmlFileName');
ArxmlFileName = char(ArxmlFileName);

repoRoot = getRepoRoot();

% 允许只传文件名：当前工作目录 -> 函数目录 -> 仓库 data/ccm
if ~isfile(ArxmlFileName)
    if isfile(fullfile(pwd, ArxmlFileName))
        ArxmlFileName = fullfile(pwd, ArxmlFileName);
    else
        thisDir = fileparts(mfilename('fullpath'));
        candidate = fullfile(thisDir, ArxmlFileName);
        if isfile(candidate)
            ArxmlFileName = candidate;
        elseif isfile(fullfile(repoRoot, 'data', 'ccm', ArxmlFileName))
            ArxmlFileName = fullfile(repoRoot, 'data', 'ccm', ArxmlFileName);
        end
    end
end
if ~isfile(ArxmlFileName)
    error('%s: ARXML 文件不存在: %s', mfilename, ArxmlFileName);
end

[~, arxmlBase, ~] = fileparts(ArxmlFileName);

p = inputParser;
addParameter(p, 'step', 'all', @(x) ischar(x) || isstring(x));
addParameter(p, 'modelCacheDir', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'excelFile', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'portsSheet', 'Ports', @(x) ischar(x) || isstring(x));
addParameter(p, 'ifSheet', 'Interfaces', @(x) ischar(x) || isstring(x));
addParameter(p, 'skipIfExists', true, @islogical);
addParameter(p, 'includeRunnable', false, @islogical);
addParameter(p, 'exportInterface', false, @islogical);
parse(p, varargin{:});

step = lower(char(p.Results.step));
modelCacheDir = char(p.Results.modelCacheDir);
excelFile = char(p.Results.excelFile);
portsSheet = char(p.Results.portsSheet);
ifSheet = char(p.Results.ifSheet);
skipIfExists = p.Results.skipIfExists;
includeRunnable = p.Results.includeRunnable;
exportInterface = p.Results.exportInterface;

if isempty(modelCacheDir)
    modelCacheDir = fullfile(repoRoot, 'cache', ['arxml_models_' arxmlBase]);
end
if isempty(excelFile)
    excelFile = fullfile(repoRoot, 'artifacts', [arxmlBase '_PortsInfo.xlsx']);
end

out = struct('modelCacheDir', modelCacheDir, ...
    'excelFile', excelFile, ...
    'portTable', table(), ...
    'interfaceTable', table());

switch step
    case 'generatemodels'
        i_generateModelsFromArxml(ArxmlFileName, modelCacheDir, skipIfExists);
        return;
    case 'exportports'
        out.portTable = i_exportPortsFromModels(modelCacheDir, includeRunnable);
        i_writeExcelSheet(out.portTable, excelFile, portsSheet);
        return;
    case 'exportinterfaces'
        % 要导接口信息，必须先有端口表或至少有模型
        out.portTable = i_exportPortsFromModels(modelCacheDir, includeRunnable);
        i_writeExcelSheet(out.portTable, excelFile, portsSheet);
        out.interfaceTable = i_exportInterfacesFromModels(modelCacheDir);
        i_writeExcelSheet(out.interfaceTable, excelFile, ifSheet);
        return;
    case 'all'
        if ~isfolder(modelCacheDir) || isempty(dir(fullfile(modelCacheDir, '*.slx')))
            i_generateModelsFromArxml(ArxmlFileName, modelCacheDir, skipIfExists);
        end
        out.portTable = i_exportPortsFromModels(modelCacheDir, includeRunnable);
        i_writeExcelSheet(out.portTable, excelFile, portsSheet);
        if exportInterface
            out.interfaceTable = i_exportInterfacesFromModels(modelCacheDir);
            i_writeExcelSheet(out.interfaceTable, excelFile, ifSheet);
        end
        return;
    otherwise
        error('%s: 不支持的 step: %s', mfilename, step);
end

end

function name = i_getLastPathName(pathStr)
if isempty(pathStr)
    name = '';
    return;
end
parts = regexp(char(pathStr), '/', 'split');
name = strtrim(parts{end});
end

function i_generateModelsFromArxml(arxmlFile, modelCacheDir, skipIfExists)
if ~isfolder(modelCacheDir)
    mkdir(modelCacheDir);
end

impObj = arxml.importer(arxmlFile);
compPaths = impObj.getComponentNames;
if isempty(compPaths)
    warning('%s: importer 未获取到任何组件。', mfilename);
    return;
end

origFolder = pwd;
cleanupObj = onCleanup(@() cd(origFolder));
cd(modelCacheDir);

for i = 1:numel(compPaths)
    compPath = compPaths{i};
    compName = i_getLastPathName(compPath);
    outSlx = fullfile(modelCacheDir, [compName '.slx']);
    if skipIfExists && isfile(outSlx)
        continue;
    end
    fprintf('生成模型 %d/%d: %s\n', i, numel(compPaths), compName);
    try
        impObj.createComponentAsModel(compPath, ...
            'ModelPeriodicRunnablesAs', 'FunctionCallSubsystem');
        mdlName = bdroot;
        save_system(mdlName, outSlx);
        close_system(mdlName, 0);
    catch ME
        warning('%s: 生成模型 "%s" 失败: %s', mfilename, compName, ME.message);
        try
            if bdIsLoaded(bdroot)
                close_system(bdroot, 0);
            end
        catch
        end
    end
end

clear cleanupObj;
end

function portTable = i_exportPortsFromModels(modelCacheDir, includeRunnable)
slxFiles = dir(fullfile(modelCacheDir, '*.slx'));
if isempty(slxFiles)
    warning('%s: 未找到任何缓存模型(.slx): %s', mfilename, modelCacheDir);
    portTable = table();
    return;
end

rows = cell(0, 6);
for i = 1:numel(slxFiles)
    mdlFile = fullfile(modelCacheDir, slxFiles(i).name);
    [~, compName] = fileparts(mdlFile);
    fprintf('导出端口 %d/%d: %s\n', i, numel(slxFiles), compName);
    try
        load_system(mdlFile);
        mdlName = bdroot;

        inports = find_system(mdlName, 'SearchDepth', 1, 'BlockType', 'Inport');
        outports = find_system(mdlName, 'SearchDepth', 1, 'BlockType', 'Outport');

        for k = 1:numel(inports)
            pName = get_param(inports{k}, 'Name');
            if ~includeRunnable && endsWith(pName, 'Runnable')
                continue;
            end
            outDt = get_param(inports{k}, 'OutDataTypeStr');
            rows(end+1, :) = {compName, 'Input', pName, outDt, '', ''}; %#ok<AGROW>
        end

        for k = 1:numel(outports)
            pName = get_param(outports{k}, 'Name');
            outDt = get_param(outports{k}, 'OutDataTypeStr');
            rows(end+1, :) = {compName, 'Output', pName, outDt, '', ''}; %#ok<AGROW>
        end

        close_system(mdlName, 0);
    catch ME
        warning('%s: 模型 "%s" 导出端口失败: %s', mfilename, mdlFile, ME.message);
        try
            if bdIsLoaded(bdroot)
                close_system(bdroot, 0);
            end
        catch
        end
    end
end

portTable = cell2table(rows, 'VariableNames', ...
    {'ComponentName','PortDirection','PortName','OutDataTypeStr','InterfaceRef','InterfaceName'});
end

function ifTable = i_exportInterfacesFromModels(modelCacheDir)
slxFiles = dir(fullfile(modelCacheDir, '*.slx'));
if isempty(slxFiles)
    ifTable = table();
    return;
end

rows = cell(0, 3);
for i = 1:numel(slxFiles)
    mdlFile = fullfile(modelCacheDir, slxFiles(i).name);
    [~, compName] = fileparts(mdlFile);
    fprintf('导出接口 %d/%d: %s\n', i, numel(slxFiles), compName);
    try
        load_system(mdlFile);
        mdlName = bdroot;

        % 关键优化：不再用类别清单双重循环，直接扫描 Port 类别
        try
            arProps = autosar.api.getAUTOSARProperties(mdlName);
        catch
            close_system(mdlName, 0);
            continue;
        end

        try
            portPaths = find(arProps, [], 'Port', 'PathType', 'FullyQualified');
        catch
            close_system(mdlName, 0);
            continue;
        end

        for k = 1:numel(portPaths)
            try
                pName = i_getLastPathName(portPaths{k});
                ifRef = get(arProps, portPaths{k}, 'Interface');
                ifRef = char(string(ifRef));
                if isempty(pName) || isempty(ifRef)
                    continue;
                end
                rows(end+1, :) = {compName, pName, ifRef}; %#ok<AGROW>
            catch
            end
        end

        close_system(mdlName, 0);
    catch ME
        warning('%s: 模型 "%s" 导出接口失败: %s', mfilename, mdlFile, ME.message);
        try
            if bdIsLoaded(bdroot)
                close_system(bdroot, 0);
            end
        catch
        end
    end
end

ifTable = cell2table(rows, 'VariableNames', {'ComponentName','PortName','InterfaceRef'});
if ~isempty(ifTable)
    ifTable.InterfaceName = cellfun(@(s) i_getLastPathName(s), ifTable.InterfaceRef, 'UniformOutput', false);
end
end

function i_writeExcelSheet(T, excelFile, sheetName)
if isempty(T)
    return;
end
outDir = fileparts(excelFile);
if ~isempty(outDir) && ~isfolder(outDir)
    mkdir(outDir);
end
writetable(T, excelFile, 'FileType', 'spreadsheet', 'Sheet', sheetName);
end
