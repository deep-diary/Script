function createHarnessLoop(harnessName, parent, varargin)
%%
% 目的: 为测试模块创建循环
% 输入：
% 返回：None
% 范例： createHarnessLoop('TAmbLimit', 'End.LoopDemo','cnt',10)
% 作者： Blue.ge
% 日期： 20240329
%%
    % 设置默认端口间距
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'cnt',10);      % 设置变量名和默认参数
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    cnt = p.Results.cnt;

    %% 创建局部变量
    seqPath = [harnessName,'/Test Sequence'];

    % 判断testsequence是否已经存在i了, 如果不存在，则执行如下逻
    sigExist = sltest.testsequence.findSymbol(seqPath,'Name','i','Kind','Data');

    if isempty(sigExist)
        sltest.testsequence.addSymbol(seqPath,'i',...
        'Data','Local');
        sltest.testsequence.editSymbol(seqPath,'i',...
            'DataType','uint16');
    end

    %% 创建循环路径
    loopStart = [parent '.loopStart'];
    loopStep = [parent '.loopStep'];
    loopFinished = [parent '.loopFinished'];
    loopEnd = [parent '.loopEnd'];

    sltest.testsequence.addStep(seqPath,loopStart,'Action','i=1;')
    sltest.testsequence.addStep(seqPath,loopStep,'Action','% add code here')
    sltest.testsequence.addStep(seqPath,loopFinished,'Action','i=i+1;')
    sltest.testsequence.addStep(seqPath,loopEnd,'Action','endTest = true;')

    sltest.testsequence.addTransition(seqPath,loopStart,'after(1,tick)',loopStep)
    sltest.testsequence.addTransition(seqPath,loopStep,'after(2,tick)',loopFinished)
    sltest.testsequence.addTransition(seqPath,loopFinished,['i~=' num2str(cnt+1)],loopStep)
    sltest.testsequence.addTransition(seqPath,loopFinished,['i==' num2str(cnt+1)],loopEnd)
    
end

  