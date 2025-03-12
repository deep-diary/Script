function [createdInputAll, createdOutputAll] = createModGotoAll(varargin)
%%
% 目的: 打开模型的某一层，本函数会对这一层中所有的模型或者引用模型创建输出输出goto, from
% 输入：
%       inportList: 限制创建的输入信号
%       outportList：限制创建的输出信号
%       isEnableInput：使能禁止输入，false则不创建输入信号
%       isEnableOutput：使能禁止输入，false则不创建输出信号
% 返回：成功创建好的信号
% 范例： createModGotoAll()

%%
    clc
        %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'mode','both');      % 设置变量名和默认参数
    addParameter(p,'inList',{}); 
    addParameter(p,'outList',{}); 
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    mode = p.Results.mode;
    inList = p.Results.inList;
    outList = p.Results.outList;


    modRef = find_system(gcs,'SearchDepth',1,'BlockType','ModelReference');  % ModelReference, SubSystem
    modSub = find_system(gcs,'SearchDepth',1,'BlockType','SubSystem');  % ModelReference, SubSystem
    models = [modRef;modSub];
    createdInputAll={};
    createdOutputAll={};
    for i=1:length(models)
        if strcmp(models{i},gcs)  % 去掉本身模型
            continue
        end
        sprintf('-----------------start dealing with:%s----------------- ', models{i});
        [createdInput, createdOutput] = createModGoto(models{i}, 'inList', inList, 'outList', outList, 'mode', mode);
        createdInputAll = [createdInputAll,createdInput];
        createdOutputAll = [createdOutputAll,createdOutput];
        sprintf('-----------------end dealing with:%s----------------- ', models{i});
    end
    createdInputAll=unique(createdInputAll);
    createdOutputAll=unique(createdOutputAll);

end

  