function [portList, sigList, gotoFromList] = findNameSigRelated(Name,varargin)
%%
    % 目的: 根据信号名，找到跟其相关的信号路径
    % 输入：
    %       Name： 输出信号名称
    % 返回： NameSigLoc: 模型最终输出信号
    % 范例： [portList, sigList, gotoFromList] = findNameSigRelated('rLowSidePress_X_s32ExvPoseKp')
    % 说明： 比如当前信号名称是'rLowSidePress_X_s32ExvPoseKp', 则如下函数输出跟此信号相关的路径
    % 作者： Blue.ge
    % 日期： 20240603
%%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'all',true);      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    allLev = p.Results.all;
    %% 确定信号前缀
    strList = split(Name,'_');
    if length(strList) > 3
        error('SigName should format like rMdName_B_SigName or SigName')
    end
    
    sigTail = strList{end};
    %%
    portList = {};
    gotoFromList = {};
    sigList = [];

    if allLev
        % 找到所有输入输出端口
        pInports = find_system(bdroot,'BlockType','Inport');  % 'SearchDepth',1,
        pOutports = find_system(bdroot,'BlockType','Outport');  % 'SearchDepth',1,

        paths = [pInports;pOutports]
        for i=1:length(paths)
            name = get_param(paths{i},'Name');
            if contains(name, sigTail)
                portList{end+1} = paths{i};
            end
        end

        % 找到所有信号
        signalHandles = findResolvedSignals(bdroot);
        for i=1:length(signalHandles)
            name = get_param(signalHandles(i),'Name');
            if contains(name, sigTail)
                sigList(end+1) = signalHandles(i);
            end
        end
        % 找到所有goto,from
        pGoto = find_system(bdroot,'BlockType','Goto');  % 'SearchDepth',1,
        pFrom = find_system(bdroot,'BlockType','From');  % 'SearchDepth',1,
        paths = [pGoto;pFrom]
        for i=1:length(paths)
            name = get_param(paths{i},'GotoTag');
            if contains(name, sigTail)
                gotoFromList{end+1} = paths{i};
            end
        end
    else
        % 找到所有输入输出端口
        pInports = find_system(bdroot,'SearchDepth',1,'BlockType','Inport');  % 'SearchDepth',1,
        pOutports = find_system(bdroot,'SearchDepth',1,'BlockType','Outport');  % 'SearchDepth',1,

        paths = [pInports;pOutports]
        for i=1:length(paths)
            name = get_param(paths{i},'Name');
            if contains(name, sigTail)
                portList{end+1} = paths{i};
            end
        end

        % 找到所有信号
        signalHandles = findResolvedSignals(gcs);
        for i=1:length(signalHandles)
            name = get_param(signalHandles(i),'Name');
            if contains(name, sigTail)
                sigList{end+1} = signalHandles(i);
            end
        end
        % 找到所有goto,from
        pGoto = find_system(bdroot,'SearchDepth',1,'BlockType','Goto');  % 'SearchDepth',1,
        pFrom = find_system(bdroot,'SearchDepth',1,'BlockType','From');  % 'SearchDepth',1,
        paths = [pGoto;pFrom]
        for i=1:length(paths)
            name = get_param(paths{i},'GotoTag')
            if contains(name, sigTail)
                gotoFromList{end+1} = paths{i};
            end
        end
    end
end