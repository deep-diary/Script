function loadedCnt = findSlddLoadParamVCU(path, varargin)
%%
% 目的: 导入sldd表格中的Parameter
% 输入：
%       path: sldd path
% 返回： loadedCnt: 成功导入的数据条数
% 范例： findSlddLoadParamVCU('TmComprCtrl_DD_VCU.xlsx')
% 作者： Blue.ge
% 日期： 20240201
%% 
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'exclude',{'Inport'});      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    exclude = p.Results.exclude;

    %% 简单判断路径是否存在
    if strcmp(path, '')
        error('pls input the right file path!')
    end

    %% 导入数据
    try
        opts_alt = detectImportOptions(path,'ExpectedNumVariables',17,'Sheet',"Parameters");
        opts_alt.VariableNames = ["ModelName", "PortType", "Name", "DataType", "CustomStorageClass", "DefinitionFile", "RTE_Interface", "Dimensions", "Details", "ValueTable", "Unit", "IniValue", "Min", "Max", "DataTypeSelect", "CustomStorageClassSelect", "DefinitionFile1"];
        opts_alt.VariableTypes = ["categorical", "categorical", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string"];
        opts_alt = setvaropts(opts_alt, ["Name", "RTE_Interface", "Details", "ValueTable", "Unit", "IniValue", "DataTypeSelect", "CustomStorageClassSelect", "DefinitionFile1"], "WhitespaceRule", "preserve");
        opts_alt = setvaropts(opts_alt, ["ModelName", "PortType", "Name", "DataType", "CustomStorageClass", "DefinitionFile", "RTE_Interface", "Details", "ValueTable", "Unit", "IniValue", "DataTypeSelect", "CustomStorageClassSelect", "DefinitionFile1","Min","Max"], "EmptyFieldRule", "auto");
    catch
        opts_alt = detectImportOptions(path,'ExpectedNumVariables',14,'Sheet',"Parameters");
        opts_alt.VariableNames = ["ModelName", "PortType", "Name", "DataType", "CustomStorageClass", "DefinitionFile", "RTE_Interface", "Dimensions", "Details", "ValueTable", "Unit", "IniValue", "Min", "Max"];
        opts_alt.VariableTypes = ["categorical", "categorical", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string"];
        opts_alt = setvaropts(opts_alt, ["Name", "RTE_Interface", "Details", "ValueTable", "Unit", "IniValue"], "WhitespaceRule", "preserve");
        opts_alt = setvaropts(opts_alt, ["ModelName", "PortType", "Name", "DataType", "CustomStorageClass", "DefinitionFile", "RTE_Interface", "Details", "ValueTable", "Unit", "IniValue","Min","Max"], "EmptyFieldRule", "auto");
    end

%             opts = spreadsheetImportOptions("NumVariables", 17);
%             
%             % 指定工作表和范围
%             opts.Sheet = "Parameters";
%             opts.DataRange = "A1:Q5000";
%             
%             % 指定列名称和类型
%             opts.VariableNames = ["ModelName", "PortType", "Name", "DataType", "CustomStorageClass", "DefinitionFile", "RTE_Interface", "Dimensions", "Details", "ValueTable", "Unit", "IniValue", "Min", "Max", "DataTypeSelect", "CustomStorageClassSelect", "DefinitionFile1"];
%             opts.VariableTypes = ["categorical", "categorical", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string"];
%             
%             % 指定变量属性
%             opts = setvaropts(opts, ["Name", "RTE_Interface", "Details", "ValueTable", "Unit", "IniValue", "DataTypeSelect", "CustomStorageClassSelect", "DefinitionFile1"], "WhitespaceRule", "preserve");
%             opts = setvaropts(opts, ["ModelName", "PortType", "Name", "DataType", "CustomStorageClass", "DefinitionFile", "RTE_Interface", "Details", "ValueTable", "Unit", "IniValue", "DataTypeSelect", "CustomStorageClassSelect", "DefinitionFile1","Min","Max"], "EmptyFieldRule", "auto");
%             
    % 导入数据
    combineddataS1 = readtable(path, opts_alt, "UseExcel", false);
    
    
    %% 清除临时变量
    clear opts_alt
    %% 解析数据
    sz = size(combineddataS1);
    fprintf('----开始解析 Parameter, 共计%d条----\r\n',sz(1));
    loadedCnt = 0;
    for i=1:sz(1)
        fprintf('----正在解析 Parameter, %d/%d----\r\n',i,sz(1));
        para_attributes = combineddataS1(i,:);

        % 判断是否需要排除这个数据
        if ismember(para_attributes.PortType, exclude)
            continue
        end

        para_create_station = strcat(para_attributes.Name, '=' , 'GeelyPack.Parameter',';');
        para_datatype_assign = strcat(para_attributes.Name,'.DataType','=','"',para_attributes.DataType,'"',';');
        para_storageclass_assign = strcat(para_attributes.Name,'.CoderInfo.StorageClass','=','"','Custom','"',';');
        if para_attributes.CustomStorageClass == 'MacroConstIn_Lotus'
            para_attributes.CustomStorageClass = 'MacroConstIn';
        end
        para_customstorageclass_assign = strcat(para_attributes.Name,'.CoderInfo.CustomStorageClass','=','"',para_attributes.CustomStorageClass,'"',';');
        para_dimensions_assign = strcat(para_attributes.Name,'.Dimensions','=',para_attributes.Dimensions,';');
        para_description_assign = strcat(para_attributes.Name,'.Description','=','"',para_attributes.Details.erase(char(10)),'"',';');
        para_unit_assign = strcat(para_attributes.Name,'.Unit','=','"',para_attributes.Unit,'"',';');
        para_initialvalue_assign = strcat(para_attributes.Name,'.Value','=',para_attributes.IniValue,';');
        para_minvalue_assign = strcat(para_attributes.Name,'.Min','=',para_attributes.Min,';');
        para_maxvalue_assign = strcat(para_attributes.Name,'.Max','=',para_attributes.Max,';');

%         para_definationfile_assign = strcat(para_attributes.Name,'.CoderInfo.CustomAttributes.DefinitionFile','=','"',para_attributes.DefinitionFile,'"',';');
%         para_headerfile_assign = strcat(para_attributes.Name,'.CoderInfo.CustomAttributes.HeaderFile','=','"',para_attributes.DefinitionFile1,'"',';');
%         para_Owner_assign = strcat(para_attributes.Name,'.CoderInfo.CustomAttributes.Owner','=','"',para_attributes.ModelName,'"',';');
        
        try
            if para_attributes.Name == ""
                continue;
            end
            evalin('base',para_create_station);
            evalin('base',para_datatype_assign);
            evalin('base',para_storageclass_assign);
            evalin('base',para_customstorageclass_assign);
            %         eval(para_dimensions_assign);
            evalin('base',para_description_assign);
            evalin('base',para_unit_assign);
            
            if para_attributes.IniValue ~= ""
                evalin('base',para_initialvalue_assign);
                loadedCnt = loadedCnt + 1;
            end
            if para_attributes.Min ~= ""
                evalin('base',para_minvalue_assign);
            end
            if para_attributes.Max ~= ""
                evalin('base',para_maxvalue_assign);
            end

%             evalin('base',para_definationfile_assign);
%             evalin('base',para_headerfile_assign);
%             evalin('base',para_Owner_assign);
            
        end
    end

    fprintf('----结束解析Parameter, 共计导入%d/%d条----\r\n',loadedCnt, sz(1));
    clear combineddataS1;
    clear i;
    clear para_attributes;

end
