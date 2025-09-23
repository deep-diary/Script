function start_package()
%START_PACKAGE 启动独立运行包
%   自动添加路径并启动主函数

    fprintf('========================================\n');
    fprintf('    启动独立运行包\n');
    fprintf('========================================\n');

        scriptDir = fileparts(mfilename('fullpath'));

        addpath(genpath(scriptDir));

    fprintf('路径已添加，可以运行主函数\n');
    fprintf('主函数: appAutosar2Ert\n');
    fprintf('使用方法: appAutosar2Ert(参数)\n');
    fprintf('========================================\n');

end
