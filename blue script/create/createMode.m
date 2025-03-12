function [createdInput, createdOutput] = createMode(path, varargin)
%%
% 目的: 统一一个函数，用于模型相关的批量操作，包括创建端口，goto, 接地等，同时还可以解析信号
% 输入：

% 返回：成功创建好的信号
% 范例： 

% 作者： Blue.ge
% 日期： 20240126
%%
    % 设置默认端口间距
    clc
 %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    
    % 函数本身参数
    addParameter(p,'inType','port');      % port, ground, from, const, none
    addParameter(p,'outType','port');      % port, term, goto, disp, none
    addParameter(p,'wid',400); 

    % createModPorts 参数
    addParameter(p,'mode','both');      % 设置变量名和默认参数
%     addParameter(p,'isDelSuffix',false);      % 设置变量名和默认参数
    addParameter(p,'suffixStr','');      % 设置变量名和默认参数
    addParameter(p,'findType','base');      % base or interface or None
    addParameter(p,'add','None');      % base or interface or None
    addParameter(p,'enFirstTrig',false);      % 设置变量名和默认参数

    % 信号解析参数
%     addParameter(p,'resolveSig',true);
    addParameter(p,'skipTrig',false);      % 设置变量名和默认参数
    addParameter(p,'isEnableIn',true);      % 设置变量名和默认参数 可选 in, out
    addParameter(p,'isEnableOut',true);      % 设置变量名和默认参数 可选 in, out
    addParameter(p,'resoveValue',true);
    addParameter(p,'logValue',false);      % 设置变量名和默认参数 可选  true, false
    addParameter(p,'testValue',false);      % 设置变量名和默认参数 可选  true, false
    addParameter(p,'dispName',true);      % 设置变量名和默认参数 可选  true, false
    
    % createModGoto 参数
    addParameter(p,'inList',{}); 
    addParameter(p,'outList',{}); 
    addParameter(p,'bkHalfLength',25); 

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    % 函数本身参数
    inType = p.Results.inType;
    outType = p.Results.outType;
    wid = p.Results.wid;

    % createModPorts 参数
    mode = p.Results.mode;
%     isDelSuffix = p.Results.isDelSuffix;
    suffixStr=p.Results.suffixStr;
    findType = p.Results.findType;
    enFirstTrig = p.Results.enFirstTrig;
    add = p.Results.add;



    % 信号解析参数
%     resolveSig = p.Results.resolveSig;
    skipTrig = p.Results.skipTrig;
    isEnableIn = p.Results.isEnableIn;
    isEnableOut = p.Results.isEnableOut;
    resoveValue = p.Results.resoveValue;
    logValue = p.Results.logValue;
    testValue = p.Results.testValue;
    dispName = p.Results.dispName;

    % createModGoto 参数  
    inList = p.Results.inList;
    outList = p.Results.outList;
    bkHalfLength = p.Results.bkHalfLength;


    %% deal with in
    disp([' %% the input type is ', inType])
    switch inType
        case 'port'
            [createdInput, createdOutput] = createModPorts(path, ...
                'mode','inport', ...
                'findType',findType,...
                'add', add,...
                'suffixStr',suffixStr, ...
                'enFirstTrig',enFirstTrig); 
        case 'from'
            [createdInput, createdOutput] = createModGoto(path, ...
                'mode','inport', ...
                'suffixStr',suffixStr, ...
                'inList', inList, ...
                'outList', outList, ...
                'bkHalfLength', bkHalfLength);
        case 'ground'
            [createdInput, createdOutput] = createModGroundTerm(path, ...
                'mode','inport');
        case 'const'
            [createdInput, createdOutput] = createModConstDisp(path, ...
                'mode','inport');
        case 'none'
        otherwise
            
    end

    %% deal with out
    switch outType
        case 'port'
            [createdInput, createdOutput] = createModPorts(path, ...
                'mode','outport', ...
                'findType',findType,...
                'add', add,...
                'suffixStr',suffixStr, ...
                'enFirstTrig',enFirstTrig); 
        case 'goto'
            [createdInput, createdOutput] = createModGoto(path, ...
                'mode','outport', ...
                'suffixStr',suffixStr, ...
                'inList', inList, ...
                'outList', outList,...
                'bkHalfLength', bkHalfLength);
        case 'term'
            [createdInput, createdOutput] = createModGroundTerm(path, ...
                'mode','outport');
        case 'disp'
            [createdInput, createdOutput] = createModConstDisp(path, ...
                'mode','outport');
        case 'none'
        otherwise
            
    end

        
    %% 解析信号
    createModSig(path, ...
        'skipTrig',skipTrig,...
        'isEnableIn',isEnableIn,...
        'isEnableOut',isEnableOut,...
        'resoveValue',resoveValue,...
        'logValue',logValue,...
        'testValue',testValue, ...
        'dispName', dispName)

    %% 改变模型大小
    changeModSize(path, ...
        'wid',wid)
end

  