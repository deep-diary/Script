function excelPath = getDefaultPortsInfoExcelPath(varargin)
%GETDEFAULTPORTSINFOEXCELPATH 解析仓库内默认 PortsInfo Excel 绝对路径
%
% 语法:
%   excelPath = getDefaultPortsInfoExcelPath()
%   excelPath = getDefaultPortsInfoExcelPath('Name', Value, ...)
%
% 功能描述:
%   供各 find* 工具在未显式传入 excelFile 时统一解析 PortsInfo 表路径。查找顺序:
%   1) <repo>/data/ccm/CCM_Internal_swc_PortsInfo.xlsx
%   2) <repo>/artifacts/CCM_Internal_swc_PortsInfo.xlsx
%   3) <repo>/artifacts 下按修改时间最新的 *PortsInfo*.xlsx
%   4) 当前工作目录 pwd 下按修改时间最新的 *PortsInfo*.xlsx
%
% 可选参数（Name-Value）:
%   'callerId' - 未找到文件时 error 前缀显示的函数名 (char/string)
%                默认: 本函数名；调用方宜传入 mfilename 以便定位调用栈
%
% 输出参数:
%   excelPath - 存在的 Excel 文件绝对路径 (char)
%
% 异常与边界行为:
%   - 以上路径均不可用时抛出 error，提示调用方显式传入 excelFile。
%
% 示例:
%   % 示例1：在工具函数内解析（推荐传入 mfilename）
%   f = getDefaultPortsInfoExcelPath('callerId', mfilename);
%
%   % 示例2：脚本中快速取默认表（错误前缀为 getDefaultPortsInfoExcelPath）
%   f = getDefaultPortsInfoExcelPath();
%
% 参见: GETREPOROOT, FINDPORTSINFOTOGJSON, FINDPORTCONNECTIONSIGNALS
%
% 作者: blue.ge(葛维冬@Smart)
% 版本: 1.0
% 日期: 2026-04-10
% 变更记录:
%   2026-04-10 v1.0 从各 find* 内联逻辑提取，统一默认 PortsInfo 路径解析。

p = inputParser;
addParameter(p, 'callerId', mfilename, @(x) ischar(x) || isstring(x));
parse(p, varargin{:});

tag = strtrim(char(string(p.Results.callerId)));
if isempty(tag)
    tag = mfilename;
end

repoRoot = getRepoRoot();

fixedFile = fullfile(repoRoot, 'data', 'ccm', 'CCM_Internal_swc_PortsInfo.xlsx');
if isfile(fixedFile)
    excelPath = fixedFile;
    return;
end

fixedArt = fullfile(repoRoot, 'artifacts', 'CCM_Internal_swc_PortsInfo.xlsx');
if isfile(fixedArt)
    excelPath = fixedArt;
    return;
end

excelPath = i_latestMatchingXlsx(fullfile(repoRoot, 'artifacts', '*PortsInfo*.xlsx'));
if ~isempty(excelPath)
    return;
end

excelPath = i_latestMatchingXlsx(fullfile(pwd, '*PortsInfo*.xlsx'));
if ~isempty(excelPath)
    return;
end

error('%s: 未找到默认 PortsInfo Excel，请传入 ''excelFile''。', tag);

end

function f = i_latestMatchingXlsx(pat)
f = '';
files = dir(pat);
if isempty(files)
    return;
end
[~, idx] = max([files.datenum]);
f = fullfile(files(idx).folder, files(idx).name);
end
