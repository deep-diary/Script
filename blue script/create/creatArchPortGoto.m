function creatArchPortGoto()
%%
    % 目的: 根据interface 信号名，创建架构层的端口和goto
    % 输入：
    %       None
    % 返回： None
    % 范例： creatArchPortGoto()
    % 作者： Blue.ge
    % 日期： 20231027
%%
    clc
    excelFileName = 'interface template.xlsx';
    [~,~,sigInCommon] = readExcelInterface(excelFileName, 'Inports Common');
    [~,~,sigInDiag] = readExcelInterface(excelFileName, 'Inports Diag');
    [~,~,sigIn2F] = readExcelInterface(excelFileName, 'Inports 2F');
    [~,sigOutCommon,~] = readExcelInterface(excelFileName, 'Outports Common');
    [~,sigOutDiag,~] = readExcelInterface(excelFileName, 'Outports Diag');
    sigin = [sigInCommon;sigInDiag;sigIn2F];
    sigout = [sigOutCommon;sigOutDiag];
    %% 创建输入输出端口及对应的goto from 模块
    [numInputPorts, numOutputPorts] = createPortsGoto('outList', sigout, ...
        'posIn', [-1500 0], 'posOut', [1500*7+300 0]);  % 300 表述输出From和port的距离
end