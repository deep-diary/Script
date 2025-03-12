function [data,dataComIn,dataComOut] = findExcelOfficialInterface(excelFileName)
%%
% 目的: 读取释放的Interface 数据。
% 输入：
%       excelFileName： 模板 excel 路径
% 返回：
%       data: 全部有用信息
%       dataComIn: 所有输入信号，titleList = {'Name', 'Type', 'Width', 'Unit', 'Description', 'Initial'}
%       dataComOut: 所有输出信号，titleList = {'Name', 'Type', 'Width', 'Unit', 'Description', 'Initial'}
% 范例： [data dataComIn dataComOut] = findExcelOfficialInterface('PCMU_23N5&23R3_Interface_V12.0 - base.xlsx'),
% 说明：
% 作者： Blue.ge
% 日期： 20231013
%%
    clc
%     excelFileName = 'PCMU_23N5&23R3_Interface_V12.0 - base.xlsx';
    sheetList = {'CAN-Input', 'CAN-Output', 'LIN-Input', 'LIN-Output', ...
    'PCMU-Input', 'PCMU-Output', 'PCMU_NVMVariable', 'DID'};

    % 使用 readtable 函数读取 Excel 表格中的数据
    dataTable = readtable(excelFileName, 'Sheet', sheetList{1});
%     Port_InputSignals  Type  Width  Unit  Description  Initial
    CANInput = dataTable(:, [2,6:10]);

    dataTable = readtable(excelFileName, 'Sheet', sheetList{2});
%     Port_InputSignals  Type  Width  Unit  Description  Initial
    CANOutput = dataTable(:, [2,6:10]);


    dataTable = readtable(excelFileName, 'Sheet', sheetList{3});
%     Port_InputSignals  Type  Width  Unit  Description  Initial
    LINInput = dataTable(:, [2,6:10]);

    dataTable = readtable(excelFileName, 'Sheet', sheetList{4});
%     Port_InputSignals  Type  Width  Unit  Description  Initial
    LINOutput = dataTable(:, [2,6:10]);

    dataTable = readtable(excelFileName, 'Sheet', sheetList{5});
%     Port_InputSignals  Type  Width  Unit  Description  Initial
    PCMUInput = dataTable(:, [2 7 8 11 13 15]);

    dataTable = readtable(excelFileName, 'Sheet', sheetList{6});
%     Port_InputSignals  Type  Width  Unit  Description  Initial
    PCMUOutput = dataTable(:, [2 7 8 11 13 15]);

    dataTable = readtable(excelFileName, 'Sheet', sheetList{7});
%     Port_InputSignals  Type  Width  Unit  Description  Initial
    NVM = dataTable(:, [3 20 18 22 19 21]);

    dataTable = readtable(excelFileName, 'Sheet', sheetList{8});
%     Port_InputSignals  Type  Width  Unit  Description  Initial
    DID = dataTable(:, [3,5:9]);
    
    data = struct( ...
                'CANInput', CANInput, ...
                'CANOutput', CANOutput, ...
                'LINInput',LINInput, ...
                'LINOutput',LINOutput, ...
                'PCMUInput', PCMUInput, ...
                'PCMUOutput', PCMUOutput, ...
                'NVM',NVM, ...
                'DID',DID);
    % 共有属性：[Name, Type, Width, Unit Description, Initial]
    titleList = {'Name', 'Type', 'Width', 'Unit', 'Description', 'Initial'}
    dataList = {'CANInput', 'CANOutput', 'LINInput', 'LINOutput', 'PCMUInput', 'PCMUOutput', 'NVM', 'DID'}
    CANInput.Properties.VariableNames = titleList;
    CANOutput.Properties.VariableNames = titleList;
    LINInput.Properties.VariableNames = titleList;
    LINOutput.Properties.VariableNames = titleList;
    PCMUInput.Properties.VariableNames = titleList;
    PCMUOutput.Properties.VariableNames = titleList;
    NVM.Properties.VariableNames = titleList;
    DID.Properties.VariableNames = titleList;

    dataComIn = [CANInput;LINInput;PCMUInput;NVM];
    dataComOut = [CANOutput;LINOutput;PCMUOutput;NVM; DID];
 %     modelData = [CANInput.Port_InputSignals,CANInput.Type,CANInput.Width,CANInput.Unit,CANInput.Description,CANInput.Initial,]

end

