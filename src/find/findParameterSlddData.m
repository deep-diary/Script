function [DataPCMU, DataVCU] = findParameterSlddData(ModelName, parameters)
% 目的: 构建Parameter 表格，便于保存到excel
% 输入：
%       parameters: 模型中所有的parameter
% 返回： DataPCMU: 满足sldd格式的DataPCMU矩阵,DataVCU: 满足sldd格式的DataVCU矩阵
% 范例： [DataPCMU, DataVCU] = getParameterSlddData(ModelName, parameters)
% 作者： Blue.ge
% 日期： 20231027
%%
    clc
    len = length(parameters);

    % 这里的17表示数据有17列
    % pcmu DATA
    DataPCMU=cell(len,17);
    % vcu DATA
    DataVCU=cell(len,17);

    for i=1:len
        name = parameters{i};
        % 信号初始化
        Details = '';
        Unit = '';
        Min = '';
        Max = '';
        RTE_Interface =  '';
        try % 存在工作空间中
            paramValue = evalin('base', name);
            
            type = paramValue.DataType;
            Dimensions = mat2str(paramValue.Dimensions);
            IniValue = mat2str(paramValue.Value);
            Details = paramValue.Description;
            Unit = paramValue.Unit;
            Min = paramValue.Min;
            Max = paramValue.Max;
            
        catch % 不存在工作空间中
            if endsWith(name, '_X')
                tbName = name(1:end-2);
                lookups = find_system(bdroot,'FollowLinks','on','BlockType','Lookup_n-D', 'Table', tbName);
                try
                    [X,Y] = findTableInputType(lookups{1});
                    type = X.dataType;
                catch
                end
            elseif endsWith(name, '_Y')
                lookups = find_system(bdroot,'FollowLinks','on','BlockType','Lookup_n-D', 'Table', tbName);
                try
                    [X,Y] = findTableInputType(lookups{1});
                    type = Y.dataType;
                catch
                end
            else
                [type, ~, ~, ~, ~] = findNameType(name);
            end

            Dimensions = -1;
            IniValue = 0;
        end
        [~, StgClsParamPCMU, ~, StgClsParamVCU] = findStgClsBasedOnType(type);


        DataPCMU{i,1} = ModelName;  % ModelName
        DataPCMU{i,2} = 'Local';  % PortType
        DataPCMU{i,3} = parameters{i};  % Name
        DataPCMU{i,4} = type;  % DataType
        DataPCMU{i,5} = StgClsParamPCMU;  % StorageClassParamPCMUs
        DataPCMU{i,6} = [ModelName,'.c'];  % DefinitionFile
        DataPCMU{i,7} = RTE_Interface;  % RTE_Interface
        DataPCMU{i,8} = Dimensions;  % Dimensions
        DataPCMU{i,9} = Details;  % Details
        DataPCMU{i,10} = '';  % ValueTable
        DataPCMU{i,11} = Unit;  % Unit
        DataPCMU{i,12} = IniValue;  % IniValue
        DataPCMU{i,13} = Min;  % Min
        DataPCMU{i,14} = Max;  % Max
        DataPCMU{i,15} = '';  % DataTypeSelect
        DataPCMU{i,16} = '';  % CustomStorageClassSelect
        DataPCMU{i,17} = '';  % DefinitionFile


%         deal with VCU data
        DataVCU(i,:) = DataPCMU(i,:);
        DataVCU{i,5} = StgClsParamVCU;
    end
end