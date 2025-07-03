function createModCopy(srcModel, destPath)
%%
% 目的: 将一个模型，复制到另外一个路径下面
% 输入：
%       srcModel: 源模型名称
%       destPath: 目标路径
% 返回：无
% 范例：createModCopy('TmSwArch', 'VcThermal_23N5_V120_1128_Ref/VcThermal_50ms_sys/VcThermal_50ms_sys/TmSwArch')
% 说明：1. 分别打开2个模型后，执行此函数
% 作者： Blue.ge
% 日期： 20231
%%

    % 打开源模型和目标模型
    pathParts = strsplit(srcModel, '/');
    srcTopModelName = pathParts{1};
    open_system(srcTopModelName);

    % 目标模型顶层名称
    % 通过分割路径获取顶层模型名称
    pathParts = strsplit(destPath, '/');
    destTopModelName = pathParts{1};
    open_system(destPath);

    % 复制源模型内容到一个新的子系统
    Simulink.BlockDiagram.copyContentsToSubSystem(srcModel, destPath);

    % 保存并关闭顶层模型
    save_system(destTopModelName);

    % 关闭模型
%     close_system(srcModel);
%     close_system(topModelName);

end
