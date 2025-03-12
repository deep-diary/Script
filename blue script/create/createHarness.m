function createHarness(path,varargin)
%%
% 目的: 为模块创建测试用力
% 输入：
% 返回：None
% 范例： createHarness(gcb,'lev1',{'SM123','SM456'},'lev2',{{'SM1','SM2'},{'SM4','SM6'}})
% 作者： Blue.ge
% 日期： 20240329
%%
    % 设置默认端口间距
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器

    addParameter(p,'lev1',{'SM123','SM456'});      % 设置变量名和默认参数
    addParameter(p,'lev2',{{'SM1','SM2'},{'SM4','SM5','SM6'}});      % 设置变量名和默认参数
    addParameter(p,'inName',{{'SM11','SM12'},{'SM14','SM15','SM16'}});      % 设置变量名和默认参数
    addParameter(p,'inValue',{{{10, 5},{8, 3, 2}},{6, 4},{4, 5, 8}});      % 设置变量名和默认参数
    addParameter(p,'rstName',{{'SM1','SM2'},{'SM4','SM5','SM6'}});      % 设置变量名和默认参数
    addParameter(p,'rstValue',{{{10,20},{10,20,20}},{{10,20},{10,20,20}}});      % 设置变量名和默认参数
    addParameter(p,'mask',0);      % 设置变量名和默认参数
    addParameter(p,'lastStep','Initialize');      % 设置变量名和默认参数
    addParameter(p,'nextStep','None');      % 设置变量名和默认参数
    addParameter(p,'tolerance',0.01);      % 设置变量名和默认参数
    addParameter(p,'waitTime',0.05);      % 设置变量名和默认参数
    addParameter(p,'usingAllPorts',false);      % 设置变量名和默认参数
    addParameter(p,'logValue',false);      % 设置变量名和默认参数


    
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    mask = p.Results.mask;
    inName = p.Results.inName;
    inValue = p.Results.inValue;
    lev1Arry = p.Results.lev1;
    lev2Arry = p.Results.lev2;
    rstName = p.Results.rstName;
    rstValue = p.Results.rstValue;
    lastStep = p.Results.lastStep;
    nextStep = p.Results.nextStep;
    tolerance = p.Results.tolerance;
    waitTime = p.Results.waitTime;
    usingAllPorts = p.Results.usingAllPorts;
    logValue = p.Results.logValue;
    
    %% 使用自带的端口信息
    if usingAllPorts
        [ModelName,PortsIn,PortsOut] = findModPorts(path, 'getType', 'Name');
        for i=1:length(inName{1})
            inName{i} = PortsIn;
            rstName{i} = PortsOut;
        end
    end
    

    if strcmp(lastStep, 'Initialize')  % 新创建
        createHarnessNew(path, ...
            'mask',mask,...
            'tolerance',tolerance,...
            'waitTime',waitTime,...
            'lev1',lev1Arry, ...
            'lev2',lev2Arry, ...
            'inName',inName, ...
            'rstName',rstName, ...
            'inValue',inValue, ...
            'rstValue',rstValue, ...
            'logValue',logValue ...
            )
    elseif strcmp(nextStep, 'None')  % 追加
        createHarnessAppendV2(path, lastStep,...
            'mask',mask,...
            'tolerance',tolerance,...
            'waitTime',waitTime,...
            'lev1',lev1Arry, ...
            'lev2',lev2Arry, ...
            'inName',inName, ...
            'rstName',rstName, ...
            'inValue',inValue, ...
            'rstValue',rstValue ...
            )
    else  % 插入
        createHarnessInsert(path, lastStep, nextStep,...   % nextStep
            'mask',mask,...
            'lev1',lev1Arry, ...
            'lev2',lev2Arry, ...
            'inName',inName, ...
            'rstName',rstName, ...
            'inValue',inValue, ...
            'rstValue',rstValue ...
            )
    end

end

  