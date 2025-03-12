function [sigCnts, paramCnts] = findSlddLoad(path, varargin)
%%
% 目的: 导入sldd 到工作空间
% 输入：
%       path: sldd path 或者 模型名称，如果是模型名称，需要指定mode这个参数
% 可选： mode: 'PCMU' or 'VCU'， 默认为'PCMU'
%       eclude: {'Inport','Outport'}，默认{}, 可以同时指定多个
% 返回： sigCnts：成功导入的信号数量；paramCnts：成功导入的参数数量
% 范例： [sigCnts, paramCnts] = findSlddLoad('TmComprCtrl_DD_PCMU.xlsx')
%       [sigCnts, paramCnts] = findSlddLoad('TmComprCtrl', 'mode','PCMU')
% 作者： Blue.ge
% 日期： 20240205

    %% 清空命令区
    clc    
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'mode','PCMU');      % 设置变量名和默认参数
    addParameter(p,'eclude',{});      % 设置变量名和默认参数
    
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    mode = p.Results.mode;
    eclude = p.Results.eclude;
    
    %% 校验路径
    % 检查文件扩展名是否为Excel格式
    isExcelFile = endsWith(path, '.xls') || endsWith(path, '.xlsx');
    
    % 显示结果
    if isExcelFile
        disp('The path points to an Excel file.');
    else
        disp('The path does not point to an Excel file.');
        path = [path, '_DD_', mode,'.xlsx'];
    end

    if isempty(which(path))
        error('the path have not included into the project. try to add the sldd path to the project first')
    end

    %% 根据路径解析sldd 是属于PCMU 还是VCU
    if contains(path, 'PCMU')
        disp('This file is PCMU sldd format.');
        mode = 'PCMU';
    elseif contains(path, 'VCU')
        disp('This file is VCU sldd format.');
        mode = 'VCU';
    else
        error('this file name should contain either PCMU or VCU!')
    end

    %% 加载sldd
    if strcmp(mode, 'PCMU')
        sigCnts = findSlddLoadSigPCMU(path,'eclude',eclude);
        paramCnts = findSlddLoadParamPCMU(path,'eclude',eclude);
    elseif strcmp(mode, 'VCU')
        sigCnts = findSlddLoadSigVCU(path,'eclude',eclude);
        paramCnts = findSlddLoadParamVCU(path,'eclude',eclude);
    else
        error('pls the input the right mode parameters, the chooses are only: PCMU, VCU')
    end

end
