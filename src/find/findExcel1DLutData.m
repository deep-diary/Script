function [data,X,desc] = findExcel1DLutData(excelFileName, varargin)
%%
% 目的: 读取excel 一维表的数据。
% 输入：
%       excelFileName： 模板 excel 路径
%       name: 指定变量
% 返回：
%       data：   表格数据结构体，包含名称，数据
%       X:       X轴数据结构体，包含名称，数据
% 范例： [data,X,desc] = findExcel1DLutData('TmRefriVlvCtrl_DD_PCMU.xlsx')
% 范例： [data,X,desc] = findExcel1DLutData('TmRefriVlvCtrl_DD_PCMU.xlsx','name','rTmRefriVlvCtrl_Te_s32BexvControlErr')
% 说明：
% 作者： Blue.ge
% 日期： 20240712
%%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'name','');      % 设置变量名和默认参数
    addParameter(p,'sheet','1D');      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    name = p.Results.name;
    sheet = p.Results.sheet;
    %% 读取excel 数据
%     excelFileName = 'TmRefriVlvCtrl_DD_PCMU.xlsx';
%     sheet = '1D';
    % 使用 readtable 函数读取 Excel 表格中的数据
    % 读取Excel文件，包含第一行数据
    opts = detectImportOptions(excelFileName, 'Sheet', sheet);
    opts.DataRange = 'A1';
    dataTable = readtable(excelFileName, opts, 'Sheet', sheet, ...
        'ReadVariableNames',false, ...
        'ReadRowNames',false);
%     dataTable = readcell(excelFileName, 'Sheet', sheet);
    %% 解析并返回
    rows = size(dataTable,1)
    %% 单个变量解析
    if ~isempty(name)
        for i=1:4:rows
            wid = dataTable{i,2};
            desc = dataTable{i,1}{1};
            if strcmp(dataTable{i+1,1}{1},name) || strcmp(dataTable{i+2,1}{1},name)
                X.Name = dataTable{i+1,1}{1};
                X.Data = dataTable{i+1,2:2+wid-1};
                data.Name = dataTable{i+2,1}{1};
                data.Data = dataTable{i+2,2:2+wid-1};
                return
            end
        end
        disp(['could not find the value' name])
    end
    %% 正常全部解析
    for i=1:4:rows
        idx = (i-1)/4+1;
        desc{idx} = dataTable{i,1}{1};
        wid = dataTable{i,2};

        X(idx).Name = dataTable{i+1,1}{1};
        X(idx).Data = dataTable{i+1,2:2+wid-1};
        data(idx).Name = dataTable{i+2,1}{1};
        data(idx).Data = dataTable{i+2,2:2+wid-1};
    end
end


