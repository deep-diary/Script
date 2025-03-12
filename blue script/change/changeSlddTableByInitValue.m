function updatedTable = changeSlddTableByInitValue(slddPath)
%%
    % 目的: 根据sldd 中的表格，改变sldd初始值
    % 输入：
    %       slddTable: sldd 表格
    % 返回： updatedTable： 更新后的表格
    % 范例： updatedTable = changeSlddTableByInitValue('TmRefriVlvCtrl_DD_PCMU.xlsx')
    % 作者： Blue.ge
    % 日期： 20240802
    %%
    clc
%     slddPath = 'TmRefriVlvCtrl_DD_PCMU.xlsx';
    %% 
        %% 读取sldd
    filePath = slddPath;
    % 读取 Excel 文件的 Signals 和 Parameters 表格

    % 此时所有数据都被存储为 cell 类型
    opts = detectImportOptions(filePath, 'ReadVariableNames', true, 'Sheet', 'Parameters');
    for j=1:length(opts.VariableTypes)
        opts.VariableTypes{j} = 'char';
    end
    slddTable = readtable(filePath,opts, 'ReadVariableNames', true, 'Sheet', 'Parameters');
    slddTable = slddTable(:,1:14);

    %% 创建1D,2D表格
    saveSlddTableByInitValue(filePath,slddTable, 'dataType','1D')
    saveSlddTableByInitValue(filePath,slddTable, 'dataType','2D')
end
