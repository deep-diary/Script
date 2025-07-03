function Data = findSlddDebugTempData(ModelName, dataTable, type)
% 目的: 构建Debug Parameter 表格，便于保存到excel
% 输入：
%       dataTable: 需要标定的信号列表
%       type: [Inport, Outport]
% 返回： Data: 满足sldd格式的data矩阵
% 范例： Data = findSlddDebugTempData(dataTable, 'Inport')
% 作者： Blue.ge
% 日期： 20231011
%%
    clc
    sz = size(dataTable);
    len = sz(1);
    % 这里的17表示数据有17列
    Data=cell(2 * len,17);
    NAStr = 'NA';


    for i=1:len
        
        if strcmp(type, 'inport')
            sigList = dataTable.SigOut;
            name = sigList{i};
            nameSWI = ['c' name(2:end) '_swi'];
            nameDBI = ['c' name(2:end) '_dbi'];
        elseif strcmp(type, 'outport')
            sigList = dataTable.SigIn;
            name = sigList{i};
            nameSWI = ['c' name(2:end) '_sw'];
            nameDBI = ['c' name(2:end) '_db'];
        end
        if strcmp(NAStr, name)
            continue
        end
        [dataType, ~, StgClsParamPCMU, ~, ~] = findNameType(name);
        if isempty(dataType) || strcmp(dataType,'Inherit: auto')
            dataType = dataTable.SigType{i};
            [~, StgClsParamPCMU, ~, ~] = findStgClsBasedOnType(dataType);
        end
        Data{2*i-1,1} = ModelName;  % ModelName
        Data{2*i-1,2} = type;  % PortType
        Data{2*i-1,3} = nameDBI;  % Name
        Data{2*i-1,4} = dataType;  % DataType
        Data{2*i-1,5} = StgClsParamPCMU;  % CustomStorageClass
        Data{2*i-1,6} = [ModelName '.c'];  % DefinitionFile
        Data{2*i-1,7} = '';  % RTE_Interface
        Data{2*i-1,8} = '';  % Dimensions
        Data{2*i-1,9} = '';  % Details
        Data{2*i-1,10} = '';  % ValueTable
        Data{2*i-1,11} = '';  % Unit
        Data{2*i-1,12} = 0;  % IniValue
        Data{2*i-1,13} = '';  % Min
        Data{2*i-1,14} = '';  % Max
        Data{2*i-1,15} = '';  % DataTypeSelect
        Data{2*i-1,16} = '';  % CustomStorageClassSelect
        Data{2*i-1,17} = '';  % DefinitionFile

        Data(2*i, :) = Data(2*i-1, :);
        Data{2*i,3} = nameSWI;  % Name
        Data{2*i,4} = 'boolean';  % DataType
%         Data{2*i,12} = 0;  % IniValue
    end
end