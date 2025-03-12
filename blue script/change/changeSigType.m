function changeSigType(sigName, type, varargin)
%%
    % 目的: 改变端口的信号类型
    % 输入：
    %        sig： 信号名称
    %        type： 信号类型
    %        all： 是否在全局进行改变
    % 返回： 
    % 范例： changeSigType('sTmIn_n_s32ElacCmprActl', 'single', 'all', true)
    % 作者： Blue.ge
    % 日期： 20240109
    %%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'all',true);      % 设置变量名和默认参数
    
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    allLev = p.Results.all;

    %%
%     sigName = 'sFindBlowLevel_D_u8HvacFlowLevel';
%     type = 'uint8';
    if allLev
        ports = find_system(bdroot,'BlockType','Inport', 'Name', sigName);  % 'SearchDepth',1,
    else
        ports = find_system(gcs,'BlockType','Inport', 'Name', sigName);  % 'SearchDepth',1,
    end
    for i =1: length(ports)
        set_param(ports{i}, 'OutDataTypeStr', type)
    end