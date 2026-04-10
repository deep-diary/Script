function dataTable = readExcelData(excelFileName, sheetName)
    % 使用 readtable 函数读取 Excel 表格中的数据
    dataTable = readtable(excelFileName, 'Sheet', sheetName);

    % 提取数据
%     data = struct('ModelName', dataTable.ModelName, ...
%                   'PortType', dataTable.PortType, ...
%                   'Name', dataTable.Name, ...
%                   'DataType', dataTable.DataType);

    % inportList=[];
    % outportList=[];
    % num=length(data);
    % for i=1:num
    %     if(strcmp(dataTable.PortType(i),'input'))
    %         inportList=[inportList,dataTable.Name(i)];
    %     elseif(strcmp(dataTable.PortType(i),'output'))
    %         outportList=[inportList,dataTable.Name(i)];
    %     end
    % end
    
%     inputNames = dataTable.Name(strcmp(dataTable.PortType, 'input'));
%     outputNames = dataTable.Name(strcmp(dataTable.PortType, 'output'));
end