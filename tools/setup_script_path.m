function setup_script_path()
%SETUP_SCRIPT_PATH 将 src 与 third_party 加入 MATLAB 路径
%
% 语法:
%   setup_script_path()
%
% 功能描述:
%   在仓库根目录下执行一次，递归加入 src/ 与 third_party/，便于调用各工具函数。
%
% 副作用:
%   修改当前 MATLAB 会话 path。
%
% 作者: blue.ge(葛维冬@Smart)
% 版本: 1.0
% 日期: 2026-04-10

here = fileparts(mfilename('fullpath'));
root = fileparts(here);
addpath(genpath(fullfile(root, 'src')));
addpath(genpath(fullfile(root, 'third_party')));
fprintf('已添加路径: %s\\src 与 %s\\third_party\n', root, root);

end
