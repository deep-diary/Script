function [dataTable,sigin,sigout] = readExcelInterface(excelFileName, sheetName)
%%
% 目的: 读取Interface 数据。
% 输入：
%       excelFileName： 模板 excel 路径
%       sheetName：     表格中的sheet 名字
% 返回：
%       data: 全部有用信息
%       sigin: 输入输出模块的debug输入， 
%       sigout: 输入输出模块的debug输出， 
% 范例：[data,sigin,sigout] = readExcelInterfaceIn(excelFileName, 'Inports'),
% 说明：
% 作者： Blue.ge
% 日期： 20231011
%%
    % 获取选中的模型
    clc
    % 使用 readtable 函数读取 Excel 表格中的数据
    dataTable = readtable(excelFileName, 'Sheet', sheetName);

    % 提取数据

%     data = struct('InterfaceName', dataTable.InterfaceName, ...
%           'SiginName', dataTable.SigoutName, ...
%           'Description', dataTable.Description);

    sigin = dataTable.SigIn;
    sigout = dataTable.SigOut;
    

end