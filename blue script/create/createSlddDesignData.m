function dictionaryObj = createSlddDesignData(modelName,varargin)
%%
% 目的: 根据模型名称，将所需的变量导入sldd中，前提是所有用到的变量，需要加载到工作空间中
% 输入：
%       Null
% 返回：mdName: 模型名
% 范例：dictionaryObj = createSlddDesignData('TmComprCtrl')
% 说明：需要成功编译模型后才可以执行
% 作者： Blue.ge
% 日期： 20240628
%%
    clc
        %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'slddPath','');      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    slddPath = p.Results.slddPath;

    %% 获取模型所需的变量
    % 清掉sldd 跟模型的绑定
    set_param(modelName,'DataDictionary','');

    % Find all variables and enumerated types used in model blocks
    usedTypesVars = Simulink.findVars(modelName,'IncludeEnumTypes',true);

    % Simulink.defineIntEnumType
    enumTypesDynamic = strcmp({usedTypesVars.SourceType},'dynamic class');

    sigParams = strcmp({usedTypesVars.SourceType},'base workspace');

    varsToImportIndex = sigParams | enumTypesDynamic;

    varNames = {usedTypesVars(varsToImportIndex).Name}'


    %% 将变量导入sldd
    slddPath = [modelName,'.sldd'];
    dictionaryObj = createSldd(modelName)  % 创建或者打开模型对应的sldd
    % Import to the dictionary the model variables defined in the base workspace, and clear the variables from the base workspace
    [importSuccess,importFailure] = importFromBaseWorkspace(dictionaryObj,...
     'varList',varNames,'clearWorkspaceVars',true);
    % Link the dictionary to the model
    set_param(modelName,'DataDictionary',[modelName,'.sldd']);
    
    saveChanges(dictionaryObj)
    save_system(modelName)

    %% 找到已经加载的枚举变量
%     % 获取当前工作区中定义的所有类
%     allClasses = meta.class.getAllClasses;
%     % 初始化一个空的cell数组来存储枚举类型的名称
%     enumTypes = {};
%     
%     % 遍历所有类，检查是否为枚举类型
%     for i = 1:length(allClasses)
%         if allClasses{i}.Enumeration
%             % 如果是枚举类型，将其名称添加到cell数组中
%             enumTypes{end+1} = allClasses{i}.Name;
%         end
%     end
%     
%     % 显示所有已加载的枚举类型
%     disp('Loaded Enumeration Types:');
%     disp(enumTypes);
%     [successfulMigrations, unsuccessfulMigrations] = ...
%     importEnumTypes(dictionaryObj,enumTypes)
    


