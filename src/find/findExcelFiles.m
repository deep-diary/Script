function excelFiles = findExcelFiles(basePath)
%%
% 目的: 找到basepath 下面所有的PCMU sldd
% 输入：
%       basePath: 子模型根目录
% 返回：excelFiles: sldd 文件列表
% 范例：excelFiles = findExcelFiles('D:\Thermal\03_对外工作\02_PCMU热管理软件集成\Thermal_PCMU_23N5\SubModel')
% 说明：
% 作者： Blue.ge
% 日期： 20231020
%%
    clc
    % 初始化一个 cell 数组来存储 Excel 文件路径
    excelFiles = {};

    % 获取当前路径下的所有文件和文件夹
    dirData = dir(basePath);

    for i = 1:length(dirData)
        % 跳过当前目录（.）和父目录（..）
        if strcmp(dirData(i).name, '.') || strcmp(dirData(i).name, '..')
            continue;
        end

        % 构建完整的文件或文件夹路径
        fullPath = fullfile(basePath, dirData(i).name);

        if dirData(i).isdir
            % 如果是文件夹，递归查找文件
            subFolderExcelFiles = findExcelFiles(fullPath);
            excelFiles = [excelFiles, subFolderExcelFiles];
        elseif endsWith(dirData(i).name, 'PCMU.xlsx')
            % 如果是 Excel 文件，将其路径添加到 excelFiles 中
            excelFiles = [excelFiles, {fullPath}];
        end
    end
end
