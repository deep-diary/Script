function [allFSlddList, allDataList] = findSlddSigPortFold(folderPath, varargin)
%FINDSLDDSIGPORTFOLD 批量获取目录下所有模型的输入输出信号数据并导出汇总表
%
%   [ALLFSLDDLIST, ALLDATALIST] = FINDSLDDSIGPORTFOLD(FOLDERPATH)
%   在指定目录 FOLDERPATH 下查找所有 .slx 模型文件，对每个模型调用
%   FINDSLDDSIGPORT 进行信号数据提取，并最终合并到一个总的 Excel 文件中。
%
%   [ALLFSLDDLIST, ALLDATALIST] = FINDSLDDSIGPORTFOLD()
%   若未指定目录，则通过 UI 选择一个目录后执行同样操作。
%
%   [ALLFSLDDLIST, ALLDATALIST] = FINDSLDDSIGPORTFOLD(FOLDERPATH, ...)
%   其余可选参数（除 'saveExcel' 外）将传递给 FINDSLDDSIGPORT，例如:
%       'overwrite'   - 是否覆盖现有文件（对最终总表无实际影响）
%       'projectList' - 项目列表 {'PCMU','VCU','XCU','CUSTOM'} 的子集
%
%   输出参数:
%       ALLFSLDDLIST  - 汇总 Excel 文件路径列表 (1x1 元胞数组)
%       ALLDATALIST   - 汇总后的信号数据表 (1x1 元胞数组, 内含 table)
%
%   作者: Blue.ge (批量脚本由 Cursor AI 协助生成)
%   日期: 2026-04-03
%

% 初始化输出
allFSlddList = {};
allDataList  = {};
combinedTbl  = table();

% 处理输入目录
if nargin < 1 || isempty(folderPath)
    % 无输入时，弹出 UI 选择目录
    folderPath = uigetdir(pwd, '请选择包含 .slx 模型的目录');
    if isequal(folderPath, 0)
        warning('%s: 未选择任何目录，函数结束。', mfilename);
        return;
    end
else
    % 验证输入类型
    validateattributes(folderPath, {'char','string'}, {'scalartext'}, mfilename, 'folderPath');
    folderPath = char(folderPath);
end

% 检查目录是否存在
if ~isfolder(folderPath)
    error('%s: 指定目录不存在: %s', mfilename, folderPath);
end

% 解析与单模型接口共享的可选参数（用于获取 projectList 等）
p = inputParser;
addParameter(p, 'overwrite', false, @islogical);
addParameter(p, 'projectList', {'CUSTOM'}, ...
    @(x) all(ismember(x, {'PCMU','VCU','XCU','CUSTOM'})));
addParameter(p, 'saveExcel', true, @islogical); % 在本函数中将被强制置为 false
parse(p, varargin{:});
projectList = p.Results.projectList;
overwrite   = p.Results.overwrite; %#ok<NASGU>

% 搜索目录下所有 .slx 模型文件（仅当前层级）
slxFiles = dir(fullfile(folderPath, '*.slx'));
if isempty(slxFiles)
    warning('%s: 目录中未找到任何 .slx 模型文件: %s', mfilename, folderPath);
    return;
end

% 遍历每个模型文件
for k = 1:numel(slxFiles)
    mdlFullPath = fullfile(folderPath, slxFiles(k).name);
    [~, mdlName, ext] = fileparts(mdlFullPath); %#ok<ASGLU>

    fprintf('Processing model %d/%d: %s\n', k, numel(slxFiles), mdlFullPath);

    % 调用单模型接口提取脚本（强制不保存单个 Excel），
    % 在单模型接口内部负责判断并加载模型
    try
        [~, dataList] = findSlddSigPort(mdlFullPath, ...
            'projectList', projectList, ...
            'saveExcel',  false);
    catch ME
        warning('%s: 处理模型 "%s" 时出错: %s', mfilename, mdlFullPath, ME.message);
        continue;
    end

    % 将当前模型各项目的数据合并到总表
    for ip = 1:numel(projectList)
        if ip > numel(dataList)
            continue;
        end
        projData = dataList{ip};
        if isempty(projData)
            continue;
        end

        % 兼容 findSlddSigPortData 返回的 cell 矩阵，以及 table / struct
        if istable(projData)
            tbl = projData;
        elseif isstruct(projData)
            tbl = struct2table(projData);
        elseif iscell(projData)
            % 按 findSlddSigPortData 的 17 列定义转换为 table
            varNames = {'ModelName','PortType','Name','DataType','CustomStorageClass', ...
                        'DefinitionFile','RTE_Interface','Dimensions','Details','ValueTable', ...
                        'Unit','IniValue','Min','Max','DataTypeSelect', ...
                        'CustomStorageClassSelect','DefinitionFile2'};
            try
                tbl = cell2table(projData, 'VariableNames', varNames);
            catch
                % 若维度不匹配等原因导致转换失败，则跳过该项目
                continue;
            end
        else
            % 其它类型暂不支持
            continue;
        end

        % 增加模型名和项目名标记列
        tbl.ModelName = repmat(string(mdlName), height(tbl), 1);
        tbl.Project   = repmat(string(projectList{ip}), height(tbl), 1);

        if isempty(combinedTbl)
            combinedTbl = tbl;
        else
            combinedTbl = [combinedTbl; tbl]; %#ok<AGROW>
        end
    end
end

% 保存总的 Excel
if isempty(combinedTbl)
    warning('%s: 未汇总到任何信号数据，总表未生成。', mfilename);
    return;
end

outFile = fullfile(folderPath, ...
    sprintf('SlddSignals_AllModels_%s.xlsx', datestr(now, 'yyyymmdd_HHMMSS')));

try
    writetable(combinedTbl, outFile, 'FileType', 'spreadsheet');
catch ME
    warning('%s: 写入汇总 Excel "%s" 失败: %s', mfilename, outFile, ME.message);
end

allFSlddList = {outFile};
allDataList  = {combinedTbl};

end
