function root = getRepoRoot()
%GETREPOROOT 返回仓库根目录（存在 README.md 的目录）
%
% 语法:
%   root = getRepoRoot()
%
% 功能描述:
%   从当前文件位置向上查找 README.md，用于在任意子目录下的函数中定位
%   仓库根路径，从而读写 data/、cache/、artifacts/ 等固定目录。
%
% 输出参数:
%   root - 仓库根目录绝对路径 (char)
%
% 异常与边界行为:
%   - 若未找到 README.md，则返回本函数所在目录的上一级启发路径。
%
% 作者: blue.ge(葛维冬@Smart)
% 版本: 1.0
% 日期: 2026-04-10
% 变更记录:
%   2026-04-10 v1.0  首次创建，用于目录重构后的路径解析。

here = fileparts(mfilename('fullpath'));
d = here;
for k = 1:30
    if isfile(fullfile(d, 'README.md'))
        root = d;
        return;
    end
    nd = fileparts(d);
    if strcmp(nd, d)
        break;
    end
    d = nd;
end
root = fileparts(here);

end
