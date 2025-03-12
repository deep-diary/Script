function dictionaryObj = createSldd(modelName,varargin)
%%
% 目的: 根据模型名称，创建并绑定sldd, 如果未指定sldd路径，则sldd位于模型同目录下
% 输入：
%       Null
% 返回：mdName: 模型名
% 范例：createSldd('TmComprCtrl')
% 说明为模型创建并绑定sldd
% 作者： Blue.ge
% 日期： 20240628
%%
    clc
        %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'slddPath','');      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    slddPath = p.Results.slddPath;

    %% 创建sldd
    dictionaryName = [modelName '.sldd'];
    % Load the target model
    modPath = which(modelName);
    if isempty(modPath)
        error('could not find the valid model in the project path')
    end
    load_system(modelName)
    [filepath,name,ext] = fileparts(modPath)  % get the model fold path
    % Identify all model variables that are defined in the base workspace
    % 清掉sldd 跟模型的绑定
    set_param(modelName,'DataDictionary','');
    if isempty(slddPath)
        slddPath = fullfile(filepath,dictionaryName)
    end
    Simulink.data.dictionary.closeAll
    if ~exist(slddPath,"file")
                % Create the data dictionary
        dictionaryObj = Simulink.data.dictionary.create(slddPath);
    else
        dictionaryObj = Simulink.data.dictionary.open(slddPath);
    end

    %% 跟模型绑定sldd
    % Link the dictionary to the model
    set_param(modelName,'DataDictionary',dictionaryName);
    
    saveChanges(dictionaryObj)

    save_system(modelName)


