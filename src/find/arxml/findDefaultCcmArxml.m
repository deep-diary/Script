function resolved = findDefaultCcmArxml(varargin)
%FINDDEFAULTCCMARXML 将 ARXML 文件名解析为磁盘上的绝对路径
%
% 语法:
%   resolved = findDefaultCcmArxml()
%   resolved = findDefaultCcmArxml(arxmlFileName)
%   resolved = findDefaultCcmArxml(arxmlFileName, 'Name', Value, ...)
%
% 功能描述:
%   用于在仅知道文件名或相对写法时定位 ARXML。解析顺序:
%   1) 已是可访问路径则直接返回；
%   2) 当前工作目录 pwd 下拼接；
%   3) 无路径分量的裸文件名时尝试 which（需已将所在目录加入 MATLAB path）；
%   4) <repo>/data、<repo>/data/ccm、本函数所在目录下拼接。
%   不抛出错误；若均未命中，返回仍为输入形式的 char（由调用方配合 isfile 判断）。
%
% 输入参数:
%   arxmlFileName - (可选，首位) ARXML 文件名或相对/绝对路径 (char/string)
%                   默认: 'CCM_Internal_swc.arxml'
%
% 可选参数（Name-Value）:
%   'repoRoot' - 仓库根目录 (char/string)，默认空表示由 getRepoRoot 解析
%
% 输出参数:
%   resolved - 解析得到的 char 路径；未找到文件时可能仍为相对名或原输入
%
% 异常与边界行为:
%   本函数不 error（路径无效时由调用方报错）；inputParser 校验失败时 error。
%
% 示例:
%   % 示例1：默认 CCM 内部 SWC 描述文件（依赖 path 或仓库 data 布局）
%   f = findDefaultCcmArxml();
%
%   % 示例2：指定文件名并传入已知仓库根（测试或自定义布局）
%   f = findDefaultCcmArxml('My.arxml', 'repoRoot', 'D:\proj\Script');
%
% 参见: FINDPORTSINFOFROMARXML, GETREPOROOT
%
% 作者: blue.ge(葛维冬@Smart)
% 版本: 1.0
% 日期: 2026-04-10
% 变更记录:
%   2026-04-10 v1.0 从 findPortsInfoFromArxml 内 i_resolveArxmlFile 抽出为独立函数。

p = inputParser;
addOptional(p, 'arxmlFileName', 'CCM_Internal_swc.arxml', @(x) ischar(x) || isstring(x));
addParameter(p, 'repoRoot', '', @(x) ischar(x) || isstring(x));
parse(p, varargin{:});

arxmlIn = char(string(p.Results.arxmlFileName));
if isempty(strtrim(arxmlIn))
    arxmlIn = 'CCM_Internal_swc.arxml';
end

repoRoot = char(string(p.Results.repoRoot));
if isempty(strtrim(repoRoot))
    repoRoot = getRepoRoot();
end

resolved = arxmlIn;
if isfile(resolved)
    return;
end
if isfile(fullfile(pwd, resolved))
    resolved = fullfile(pwd, resolved);
    return;
end
if i_isBareFilename(resolved)
    w = which(resolved);
    if ~isempty(w)
        lines = splitlines(char(w));
        for k = 1:numel(lines)
            cand = strtrim(lines{k});
            if isempty(cand)
                continue;
            end
            if isfile(cand)
                resolved = cand;
                return;
            end
        end
    end
end
candidates = {
    fullfile(repoRoot, 'data', resolved)
    fullfile(repoRoot, 'data', 'ccm', resolved)
    fullfile(fileparts(mfilename('fullpath')), resolved)
    };
for i = 1:numel(candidates)
    if isfile(candidates{i})
        resolved = candidates{i};
        return;
    end
end

end

function tf = i_isBareFilename(f)
f = char(f);
tf = isempty(regexp(f, '[/\\]', 'once'));
end
