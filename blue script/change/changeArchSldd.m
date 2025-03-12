function outPath = changeArchSldd(dcmPath, slddPath)
%%
    % 目的: 根据DCM数据，改变模型sldd
    % 输入：
    %       dcmPath: DCM path
    %       slddPath: SLDD path
    % 返回： outPath： 更新后的excel路径
    % 范例： outPath = changeArchSldd('HY11_PCMU_Tm_OTA2_V5011225_All.DCM', 'PCMU_SLDD_All.xlsx')
    % 作者： Blue.ge
    % 日期： 20240124
%%
    clc
    %% test
%     slddPath = 'PCMU_SLDD.xlsx';
%     dcmPath = 'VcThermal_23N5_V120_2101222.DCM';
    %% 读取sldd
    filePath = slddPath;
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

    %% 读取DCM
    paramsArr = findDCMParam(dcmPath);

    %% 更新sldd
    updatedParametersTable = changeSlddInitValue(parametersTable, ...
        paramsArr,...
        'type',{'const','axis','wert','tab','map'});


    %% 保存sldd

    % 保存合并后的数据到新的 Excel 文件
    outPath = which(filePath);
%     writetable(signalsAll, outPath, 'Sheet', 'Signals', 'WriteMode', 'overwrite');
    writetable(updatedParametersTable, outPath, 'Sheet', 'Parameters', 'WriteMode', 'overwrite');

    %% 创建1D,2D表格
    saveSlddTableByInitValue(outPath,updatedParametersTable, 'dataType','1D')
    saveSlddTableByInitValue(outPath,updatedParametersTable, 'dataType','2D')
end

