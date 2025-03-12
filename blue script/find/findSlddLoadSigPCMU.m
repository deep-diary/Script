function loadedCnt = findSlddLoadSigPCMU(path, varargin)
%%
% 目的: 导入sldd表格中的Signal
% 输入：
%       path: sldd path
% 返回： loadedCnt: 成功导入的数据条数
% 范例： findSlddLoadSigPCMU('TmComprCtrl_DD_PCMU.xlsx')
% 作者： Blue.ge
% 日期： 20240201
%% 
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'eclude',{'Inport'});      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    eclude = p.Results.eclude;

    %% 简单判断路径是否存在
    if strcmp(path, '')
        error('pls input the right file path!')
    end

    %% 导入数据
    try
        opts_alt = detectImportOptions(path,'ExpectedNumVariables',17,'Sheet',"Signals"); % ,'DataRange',"A1:Q10000"
        opts_alt.VariableNames = ["ModelName", "PortType", "Name", "DataType", "CustomStorageClass", "DefinitionFile", "RTE_Interface", "Dimensions", "Details", "ValueTable", "Unit", "IniValue", "Min", "Max", "DataTypeSelect", "CustomStorageClassSelect", "DefinitionFile1"];
        opts_alt.VariableTypes = ["categorical", "categorical", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string"];
        opts_alt = setvaropts(opts_alt, ["Name", "RTE_Interface", "Details", "ValueTable", "Unit", "IniValue", "DataTypeSelect", "CustomStorageClassSelect", "DefinitionFile1"], "WhitespaceRule", "preserve");
        opts_alt = setvaropts(opts_alt, ["ModelName", "PortType", "Name", "DataType", "CustomStorageClass", "DefinitionFile", "RTE_Interface", "Details", "ValueTable", "Unit", "IniValue", "DataTypeSelect", "CustomStorageClassSelect", "DefinitionFile1","Min","Max"], "EmptyFieldRule", "auto");
    catch
        opts_alt = detectImportOptions(path,'ExpectedNumVariables',14,'Sheet',"Signals"); % ,'DataRange',"A1:N10000"
        opts_alt.VariableNames = ["ModelName", "PortType", "Name", "DataType", "CustomStorageClass", "DefinitionFile", "RTE_Interface", "Dimensions", "Details", "ValueTable", "Unit", "IniValue", "Min", "Max"];
        opts_alt.VariableTypes = ["categorical", "categorical", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string"];
        opts_alt = setvaropts(opts_alt, ["Name", "RTE_Interface", "Details", "ValueTable", "Unit", "IniValue"], "WhitespaceRule", "preserve");
        opts_alt = setvaropts(opts_alt, ["ModelName", "PortType", "Name", "DataType", "CustomStorageClass", "DefinitionFile", "RTE_Interface", "Details", "ValueTable", "Unit", "IniValue","Min","Max"], "EmptyFieldRule", "auto");
    end

    % 导入数据
    combineddataS1 = readtable(path, opts_alt, "UseExcel", false);


    %% 解析数据
    sz = size(combineddataS1);
    fprintf('----开始解析Single, 共计%d条----\r\n',sz(1));
    loadedCnt = 0;
    for i=1:sz(1)
        fprintf('----正在解析Single, %d/%d----\r\n',i,sz(1));
        sig_attributes = combineddataS1(i,:);
        % 判断是否需要排除这个数据
        if ismember(sig_attributes.PortType, eclude)
            continue
        end

        sig_create_station = strcat(sig_attributes.Name, '=' ,'AUTOSAR4.Signal',';');
        sig_datatype_assign = strcat(sig_attributes.Name,'.DataType','=','"',sig_attributes.DataType,'"',';');
        sig_storageclass_assign = strcat(sig_attributes.Name,'.CoderInfo.StorageClass','=','"','Custom','"',';');
        sig_customstorageclass_assign = strcat(sig_attributes.Name,'.CoderInfo.CustomStorageClass','=','"',sig_attributes.CustomStorageClass,'"',';');
        sig_dimensions_assign = strcat(sig_attributes.Name,'.Dimensions','=',sig_attributes.Dimensions,';');
        sig_description_assign = strcat(sig_attributes.Name,'.Description','=','"',sig_attributes.Details.erase(char(10)),'"',';');
        sig_unit_assign = strcat(sig_attributes.Name,'.Unit','=','"',sig_attributes.Unit,'"',';');
        sig_initialvalue_assign = strcat(sig_attributes.Name,'.InitialValue','=','"',sig_attributes.IniValue,'"',';');
        sig_minvalue_assign = strcat(sig_attributes.Name,'.Min','=',sig_attributes.Min,';');
        sig_maxvalue_assign = strcat(sig_attributes.Name,'.Max','=',sig_attributes.Max,';');
        if sig_attributes.Name == ""
            continue;
        end
        evalin('base',sig_create_station);
        evalin('base',sig_datatype_assign);
        evalin('base',sig_storageclass_assign);
        evalin('base',sig_customstorageclass_assign);
        evalin('base',sig_dimensions_assign);
        evalin('base',sig_description_assign);
        evalin('base',sig_unit_assign);
        if sig_attributes.IniValue ~= ""
            evalin('base',sig_initialvalue_assign);
        end
        if sig_attributes.Min ~= ""
            evalin('base',sig_minvalue_assign);
        end
        if sig_attributes.Max ~= ""
            evalin('base',sig_maxvalue_assign);
        end
        loadedCnt = loadedCnt + 1;
    end
    fprintf('----结束解析 Signal, 共计导入%d/%d条----\r\n',loadedCnt, sz(1));
    clear combineddataS1;
    clear i;
    clear sig_attributes;
end
