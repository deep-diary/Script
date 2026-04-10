function outPath = findSlddCombine(subPath, fileName)
%%
    % 目的: 合并所有子模型的sldd
    % 输入：
    %       subPath 子模型路径
    % 返回： outPath： 合并后的excel路径
    % 范例： outPath = findSlddCombine('SubModel', 'PCMU_SLDD_All.xlsx')
    % 作者： Blue.ge
    % 日期： 20231031
%%
    clc
    %  1. 找到 subPath路径下所有包含'PCMU'的excel文件
    %  2. 遍历每个文件，其中每个文件中分别有2个sheet, 分别为 Signals 和 Parameters
    %  3. 将每个表格中的 Signals 合并到 SignalsAll 中， Parameters 合并到 ParametersAll 中
    %  4.
    %  将SignalsAll，ParametersAll的数据，分别以2个sheet在当前路径下保存成一个新的文件，命名为PCMU_SLDD.xslx,
    %  其中sheet名字分别为 Signals 和 Parameters
    %  5. 将保存的路径赋值给outPath， 作为返回值
    %  subPath = 'D:\Thermal\03_对外工作\02_PCMU热管理软件集成\Thermal_PCMU_23N5\SubModel';

    %% 删除原来的sldd
%     fileName = 'PCMU_SLDD_All.xlsx';
    path = fullfile(pwd, subPath, fileName);
    % 检查文件是否已成功删除
    if exist(path, 'file') == 0
        disp('文件不存在。');
    else
        disp('文件已经存在，准备删除。');
        delete(path)
    end

    %% 初始化综合表
    excelFiles = findExcelFiles(subPath);

    if isempty(excelFiles)
        error('未找到包含''PCMU''的Excel文件。');
    end

    % 2. 初始化存储 Signals 和 Parameters 的表格
    signalsAll = table();
    parametersAll = table();



    %% 读取并写入综合表
    for i = 1:length(excelFiles)
        filePath = excelFiles{i};
        % 读取 Excel 文件的 Signals 和 Parameters 表格

        % 此时所有数据都被存储为 cell 类型
        opts = detectImportOptions(filePath, 'ReadVariableNames', true, 'Sheet', 'Signals');
        for j=1:length(opts.VariableTypes)
            opts.VariableTypes{j} = 'char';
        end
        
        signalsTable = readtable(filePath, opts,'ReadVariableNames', true, 'Sheet', 'Signals');
        parametersTable = readtable(filePath,opts, 'ReadVariableNames', true, 'Sheet', 'Parameters');
        signalsTable = signalsTable(:,1:14);
        parametersTable = parametersTable(:,1:14);

        % 合并到总表
        signalsAll = [signalsAll; signalsTable];
        parametersAll = [parametersAll; parametersTable];
    end

    %% 保存合并后的数据到新的 Excel 文件
    % 清楚第9列， 也就是Detail 列， 如果不清空，会导致生成的a2ll 有中文字符
    signalsAll{:, 9} = repmat({''}, height(signalsAll), 1); % 使用repmat生成与表格行数相同的空字符串cell数组
    parametersAll{:, 9} = repmat({''}, height(parametersAll), 1); % 使用repmat生成与表格行数相同的空字符串cell数组
    
    outPath = fullfile(subPath, fileName);
    writetable(signalsAll, outPath, 'Sheet', 'Signals', 'WriteMode','overwritesheet');
    writetable(parametersAll, outPath, 'Sheet', 'Parameters', 'WriteMode','overwritesheet');
end

