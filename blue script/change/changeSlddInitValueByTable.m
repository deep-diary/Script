function updatedTable = changeSlddInitValueByTable(slddPath)
%%
    % 目的: 根据sldd 中的表格，改变sldd初始值
    % 输入：
    %       slddTable: sldd 表格
    % 返回： updatedTable： 更新后的表格
    % 范例： updatedTable = changeSlddInitValueByTable('TmRefriVlvCtrl_DD_PCMU.xlsx')
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

    %% 读取sldd 中的1维表
    [data,X,desc] = findExcel1DLutData(slddPath);
    for i=1:length(data)
        slddTable = changeSlddInitValueByName(slddTable, data(i).Name, mat2str(data(i).Data));
%         slddTable = changeSlddInitValueByName(slddTable, X(i).Name, mat2str(X(i).Data));
        slddTable = changeSlddInitValueByName(slddTable, [data(i).Name '_X'], mat2str(X(i).Data));
    end
    %% 读取sldd 中的2维表
    [data,X,Y,desc] = findExcel2DLutData(slddPath);
    for i=1:length(data)
        slddTable = changeSlddInitValueByName(slddTable, data(i).Name, mat2str(data(i).Data));
%         slddTable = changeSlddInitValueByName(slddTable, X(i).Name, mat2str(X(i).Data));
%         slddTable = changeSlddInitValueByName(slddTable, Y(i).Name, mat2str(Y(i).Data));
        slddTable = changeSlddInitValueByName(slddTable, [data(i).Name '_X'], mat2str(X(i).Data));  % 使用_
        slddTable = changeSlddInitValueByName(slddTable, [data(i).Name '_Y'], mat2str(Y(i).Data));
    end

    %% 保存更新后的sldd
    writetable(slddTable, which(slddPath), 'Sheet', 'Parameters', 'WriteMode', 'overwrite');
end
