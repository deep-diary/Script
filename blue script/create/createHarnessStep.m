function createHarnessStep(harnessName,lastStp, varargin)
%%
% 目的: 为模块追加测试用例
% 输入：
% 返回：None
% 范例： createHarnessAppend('harness','lev1',{'SM123','SM456'},'lev2',{{'SM1','SM2'},{'SM4','SM6'}})
% 作者： Blue.ge
% 日期： 20240509
%%
    % 设置默认端口间距
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器

%     addParameter(p,'lastStp','CompDischargeTProtect');      % 设置变量名和默认参数
    addParameter(p,'lev1',{'SM123','SM456'});      % 设置变量名和默认参数
    addParameter(p,'lev2',{{'SM1','SM2'},{'SM4','SM5','SM6'}});      % 设置变量名和默认参数
    addParameter(p,'inName',{{'SM11','SM12'},{'SM14','SM15','SM16'}});      % 设置变量名和默认参数
    addParameter(p,'inValue',{{{10, 5},{8, 3, 2}},{6, 4},{4, 5, 8}});      % 设置变量名和默认参数
    addParameter(p,'rstName',{{'SM1','SM2'},{'SM4','SM5','SM6'}});      % 设置变量名和默认参数
    addParameter(p,'rstValue',{{10,20},{10,20,20}});      % 设置变量名和默认参数
    addParameter(p,'mask',0);      % 设置变量名和默认参数
    addParameter(p,'tolerance',0.01);      % 设置变量名和默认参数
    addParameter(p,'waitTime',0.1);      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

%     lastStp = p.Results.lastStp;
    lev1Arry = p.Results.lev1;
    lev2Arry = p.Results.lev2;
    inName = p.Results.inName;
    inValue = p.Results.inValue;
    rstName = p.Results.rstName;
    rstValue = p.Results.rstValue;
    mask = p.Results.mask;
    tolerance = p.Results.tolerance;
    waitTime = p.Results.waitTime;

    seqPath = [harnessName,'/Test Sequence'];
    %% 一级逻辑
    for i=1:length(lev1Arry)
        
        % 检查上个步骤是否已经存在
        checkLastStp = sltest.testsequence.findStep(seqPath,...
    'Name',lastStp);
        if isempty(checkLastStp)
            error('The Provided lastStep is not existed')
        end
        % 检查添加的步骤是否存在
        checkNewStp = sltest.testsequence.findStep(seqPath,...
    'Name',lev1Arry{i});
        % 如果已经存在，则删除
        if ~isempty(checkNewStp)
            sltest.testsequence.deleteStep(seqPath,lev1Arry{i})
        end
        
        % 新建步骤
        action = 'endTest = false;';
        sltest.testsequence.addStepAfter(seqPath,...
        lev1Arry{i},lastStp,...
        'Action',action)

        lastStp = lev1Arry{i};
        %% 二级逻辑
        if isempty(lev2Arry)
            continue
        end
        lev = lev2Arry{i};
        if ~isempty(lev)
            lev{end+1}='End';
        end
        
        for j=1:length(lev)
            if j == length(lev)
                action = 'endTest = true;';
                stpName = [lev1Arry{i} '.' lev{j} ];
                sltest.testsequence.addStep(seqPath,...
                stpName,'Action',action)
            else
                inputNames = inName{i};
                inputValue = inValue{i}{j};  
                outputName = rstName{i};
                outputValue = rstValue{i}{j};
                
                outAction = createHarnessVerifyStatement(harnessName,outputName,outputValue, ...
                    'mask',mask, ...
                    'tolerance',tolerance,...
                    'waitTime',waitTime...
                );
                
                [isIncludeArr, inputPkg] = findHarnessInputType(inputValue);
                if isIncludeArr
                    %% 三级逻辑
                    disp('the input is an array');
                    % 添加标志位
                    action = 'endTest2 = false;';
                    stpName = [lev1Arry{i} '.' lev{j} ];
                    sltest.testsequence.addStep(seqPath,...
                    stpName,'Action',action)
                    % 添加子步骤
                    inTypes = length(inputPkg);
                    for k=1:inTypes
                        inAction = createHarnessInputStatement(inputNames,inputPkg{k});

                        action = [inAction,outAction];
                        stpName = [lev1Arry{i} '.' lev{j} '.' lev{j} '_' num2str(k)];
                        sltest.testsequence.addStep(seqPath,...
                        stpName,'Action',action)
                    end
                    action =  'endTest2 = true;';
                    stpName = [lev1Arry{i} '.' lev{j} '.' lev{j} '_' num2str(k+1)];
                    sltest.testsequence.addStep(seqPath,...
                    stpName,'Action',action)
                    
                else
                    disp('the input is not an array');
                    inAction = createHarnessInputStatement(inputNames,inputValue);
                   
                    action = [inAction,outAction];
                    stpName = [lev1Arry{i} '.' lev{j} ];
                    sltest.testsequence.addStep(seqPath,...
                    stpName,'Action',action)
                end
            end
        end
    end
end

  