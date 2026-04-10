function dataTable = readSldd(path, varargin)
%%
% 目的: 导入sldd表格中的Signal
% 输入：
%       path: sldd path
% 返回： loadedCnt: 成功导入的数据条数
% 范例： dataTable = readSldd('TmSovCtrl_DD_XCU.xlsx')
% 作者： Blue.ge
% 日期： 20240201
%% 
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'eclude',{'Inport'});      % 设置变量名和默认参数
    addParameter(p,'sheet','Signals');      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    eclude = p.Results.eclude;
    sheet = p.Results.sheet;

    %% 简单判断路径是否存在
    if strcmp(path, '')
        error('pls input the right file path!')
    end

    %% 导入数据

    opts_alt = detectImportOptions(path,'ExpectedNumVariables',14,'Sheet',sheet); % ,'DataRange',"A1:N10000"
    opts_alt.VariableNames = ["ModelName", "PortType", "Name", "DataType", "CustomStorageClass", "DefinitionFile", "RTE_Interface", "Dimensions", "Details", "ValueTable", "Unit", "IniValue", "Min", "Max"];
    opts_alt.VariableTypes = ["categorical", "categorical", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string"];
    opts_alt = setvaropts(opts_alt, ["Name", "RTE_Interface", "Details", "ValueTable", "Unit", "IniValue"], "WhitespaceRule", "preserve");
    opts_alt = setvaropts(opts_alt, ["ModelName", "PortType", "Name", "DataType", "CustomStorageClass", "DefinitionFile", "RTE_Interface", "Details", "ValueTable", "Unit", "IniValue","Min","Max"], "EmptyFieldRule", "auto");
    

    % 导入数据
    dataTable = readtable(path, opts_alt, "UseExcel", false);


    %% 解析数据
    sz = size(dataTable);

    fprintf('----开始解析Single, 共计%d条----\r\n',sz(1));

    %% 生成枚举变量


    
end
