function [data,X,Y,desc] = findExcel2DLutData(excelFileName, varargin)
%%
% 目的: 读取excel 二维表的数据。
% 输入：
%       excelFileName： 模板 excel 路径
%       name: 指定变量
% 返回：
%       data：   表格数据结构体，包含名称，数据
%       X:       X轴数据结构体，包含名称，数据
% 范例： [data,X,Y,desc] = findExcel2DLutData('TmRefriVlvCtrl_DD_PCMU.xlsx')
% 范例： [data,X,Y,desc] = findExcel2DLutData('TmRefriVlvCtrl_DD_PCMU.xlsx','name','mTmRefriVlvCtrl_X_s32BexvCompInletSHBattCoolFF')
% 说明：
% 作者： Blue.ge
% 日期： 20240712
%%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'name','');      % 设置变量名和默认参数
    addParameter(p,'sheet','2D');      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    name = p.Results.name;
    sheet = p.Results.sheet;
    %% 读取excel 数据
%     excelFileName = 'TmRefriVlvCtrl_DD_PCMU.xlsx';
%     sheet = '2D';
    % 使用 readtable 函数读取 Excel 表格中的数据
    % 读取Excel文件，包含第一行数据
    opts = detectImportOptions(excelFileName, 'Sheet', sheet);
    opts.DataRange = 'A1';
    for i=1:2  % length(opts.VariableTypes)
        opts.VariableTypes{i} = 'char';
    end
    dataTable = readtable(excelFileName, opts, 'Sheet', sheet, ...
        'ReadVariableNames',false, ...
        'ReadRowNames',false);
%     dataTable = readcell(excelFileName, 'Sheet', sheet);
    %% 解析并返回
    rows = size(dataTable,1);
    %% 单个变量解析
    idx=1;
    ro = 1;
    while ro<rows
        widX = dataTable{ro,3};
        widY = dataTable{ro+2,1}{1};
        widY = str2double(widY);
        nameX = dataTable{ro,2}{1};
        nameY = dataTable{ro+1,1}{1};
        nameData = dataTable{ro+1,2}{1};

        if strcmp(nameX,name) || strcmp(nameY,name) || strcmp(nameData,name)
            desc = dataTable{ro,1}{1};

            X.Name = nameX;
            X.Data = dataTable{ro+1,3:3+widX-1};
    
            Y.Name = nameY;
            yDCell = dataTable{ro+2:ro+2 + widY-1,2};
    
            yD = cellfun(@str2double, yDCell);
            Y.Data = yD;
    
            data.Name = nameData;
            data.Data = dataTable{ro+2:ro+2+widY-1,3:3+widX-1};
            return
        end

        % 更新idx
        ro = ro + widY + 3;
        idx = idx+1;
    end
    warning(['could not find the related name:' name])
    %% 正常全部解析
    idx=1;
    ro = 1;
    while ro<rows
        desc{idx} = dataTable{ro,1}{1};
        widX = dataTable{ro,3};
        widY = dataTable{ro+2,1}{1};
        widY = str2double(widY);

        X(idx).Name = dataTable{ro,2}{1};
        X(idx).Data = dataTable{ro+1,3:3+widX-1};

        Y(idx).Name = dataTable{ro+1,1}{1};
        yDCell = dataTable{ro+2:ro+2 + widY-1,2};

        % 将 cell 数组转换为数值数组
%         len = length(yDCell);
%         yD = zeros(1,len);
%         for j=1:length(yDCell)
%             yD(j) = str2double(yDCell{j});
%         end
        % 将 cell 数组转换为数值数组
        yD = cellfun(@str2double, yDCell);

        Y(idx).Data = yD;

        data(idx).Name = dataTable{ro+1,2}{1};
        data(idx).Data = dataTable{ro+2:ro+2+widY-1,3:3+widX-1};

        % 更新idx
        ro = ro + widY + 3;
        idx = idx+1;
    end
end


