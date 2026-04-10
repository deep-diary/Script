function [SigMatch, SigDismatch] = createModBus(mdPath,  varargin)
%%
% 目的: 为模型生成输入输出bus, 
% 输入：
%       模型路径
% 返回：None
% 范例：[SigMatch, SigDismatch] = createModBus(gcb);
% 说明：1. 鼠标点击在子模型上，2. 在命令窗口运行此函数
% 作者： Blue.ge
% 日期： 20240513
%%
    %% 参数处理
%      clc
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'selectorPath','NA');  
    addParameter(p,'creatorPath','NA');  
    addParameter(p,'mode','both');   % selector  creator
   
    % 输入参数处理   
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    selectorPath = p.Results.selectorPath;
    creatorPath = p.Results.creatorPath;
    mode = p.Results.mode;
    %%

    SigMatch = {};
    SigDismatch = {};
    if strcmp(mode, 'selector')
        [SigMatch, SigDismatch] = createModBusSelector(mdPath,  selectorPath);
    elseif strcmp(mode, 'creator')
        createModBusCreator(mdPath,  creatorPath);
    else
        [SigMatch, SigDismatch] = createModBusSelector(mdPath,  selectorPath);
        createModBusCreator(mdPath,  creatorPath);
%         error('the choose are only belongs to : selector  creator')
    end
    
end
