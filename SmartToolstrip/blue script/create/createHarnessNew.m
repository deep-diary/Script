function createHarnessNew(path, varargin)
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
    addParameter(p,'tolerance',0.01);      % 设置变量名和默认参数
    addParameter(p,'waitTime',0.1);      % 设置变量名和默认参数
    addParameter(p,'logValue',true);      % 设置变量名和默认参数
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    mask = p.Results.mask;
    inName = p.Results.inName;
    inValue = p.Results.inValue;
    lev1Arry = p.Results.lev1;
    lev2Arry = p.Results.lev2;
    rstName = p.Results.rstName;
    rstValue = p.Results.rstValue;
    tolerance = p.Results.tolerance;
    waitTime = p.Results.waitTime;
    logValue = p.Results.logValue;


    %% 创建harness
    model = bdroot;
    harnessNameRaw = get_param(path,'Name');
    harnessName = findNameMd(harnessNameRaw); % 去掉数字前缀

    harnessList = sltest.harness.find(path,...
   'SearchDepth',1,'Name',harnessName);
    if isempty(harnessList)
        try
            sltest.harness.create(path,'Name',harnessName,...
            'Source','Test Sequence')
        catch
            error(['the harness name already existed. pls change the model to a uniq name and try again!' ...
                'or simulation is failed'])
        end
    else
        try
            sltest.harness.close(path,harnessName)
        catch
        end
        sltest.harness.delete(path,harnessName)
        sltest.harness.create(path,'Name',harnessName,...
            'Source','Test Sequence')
    end


    sltest.harness.load(path,harnessName);

    %% 记录模型信号
    mdLogPath = [harnessName,'/',harnessNameRaw];
    createSigOnLine(mdLogPath,'logValue',logValue)

    %% 创建局部变量
    seqPath = [harnessName,'/Test Sequence'];
    sltest.testsequence.addSymbol(seqPath,'endTest',...
    'Data','Local');
    sltest.testsequence.editSymbol(seqPath,'endTest',...
        'DataType','boolean');
    sltest.testsequence.addSymbol(seqPath,'endTest2',...
    'Data','Local');
    sltest.testsequence.editSymbol(seqPath,'endTest2',...
        'DataType','boolean');

    %% 改变初值步骤的名称
    InitName = 'Initialize';
    sltest.testsequence.editStep(seqPath,'Run',...
    'Name',InitName);

    %% 创建测试架构
%     lev1Arry = {'SM123','SM456'};
%     lev2Arry = {{'SM1','SM2'},{'SM4','SM5','SM6'}};

    lev1Arry{end+1} = 'End';
    if ~isempty(lev2Arry)
        lev2Arry{end+1} = {};
    end
    
    lastStp = InitName;

    %% 添加测试步骤
    createHarnessStep(harnessName,lastStp, ...
        'tolerance',tolerance,...
        'waitTime',waitTime,...
        'lev1',lev1Arry, ...
        'lev2',lev2Arry, ...
        'inName',inName, ...
        'inValue',inValue, ...
        'rstName',rstName, ...
        'rstValue',rstValue, ...
        'mask',mask ...
        )

%     %% 一级逻辑
%     for i=1:length(lev1Arry)
%         if i == length(lev1Arry)
%             action = 'endTest = true;';
%         else
%             action = 'endTest = false;';
%         end
%         sltest.testsequence.addStepAfter(seqPath,...
%         lev1Arry{i},lastStp,...
%         'Action',action)
%         lastStp = lev1Arry{i};
%         %% 二级逻辑
%         if isempty(lev2Arry)
%             continue
%         end
%         lev = lev2Arry{i};
%         if ~isempty(lev)
%             lev{end+1}='End';
%         end
%         
%         for j=1:length(lev)
%             if j == length(lev)
%                 action = 'endTest = true;';
%                 stpName = [lev1Arry{i} '.' lev{j} ];
%                 sltest.testsequence.addStep(seqPath,...
%                 stpName,'Action',action)
%             else
%                 inputNames = inName{i};
%                 inputValue = inValue{i}{j};  
%                 outputName = rstName{i};
%                 outputValue = rstValue{i}{j};
%                 
%                 outAction = createHarnessVerifyStatement(harnessName,outputName,outputValue, ...
%                     'mask',mask);
%                 
%                 [isIncludeArr, inputPkg] = findHarnessInputType(inputValue);
%                 if isIncludeArr
%                     %% 三级逻辑
%                     disp('the input is an array');
%                     % 添加标志位
%                     action = 'endTest2 = false;';
%                     stpName = [lev1Arry{i} '.' lev{j} ];
%                     sltest.testsequence.addStep(seqPath,...
%                     stpName,'Action',action)
%                     % 添加子步骤
%                     inTypes = length(inputPkg);
%                     for k=1:inTypes
%                         inAction = createHarnessInputStatement(inputNames,inputPkg{k});
% 
%                         action = [inAction,outAction];
%                         stpName = [lev1Arry{i} '.' lev{j} '.' lev{j} '_' num2str(k)];
%                         sltest.testsequence.addStep(seqPath,...
%                         stpName,'Action',action)
%                     end
%                     action =  'endTest2 = true;';
%                     stpName = [lev1Arry{i} '.' lev{j} '.' lev{j} '_' num2str(k+1)];
%                     sltest.testsequence.addStep(seqPath,...
%                     stpName,'Action',action)
%                     
%                 else
%                     disp('the input is not an array');
%                     inAction = createHarnessInputStatement(inputNames,inputValue);
%                    
%                     action = [inAction,outAction];
%                     stpName = [lev1Arry{i} '.' lev{j} ];
%                     sltest.testsequence.addStep(seqPath,...
%                     stpName,'Action',action)
%                 end
%             end
%         end
%     end

    %% 添加默认转移条件
    sltest.testsequence.addTransition(seqPath,...
    InitName,'true',lev1Arry{1})

  
    for i=1:length(lev1Arry)-1
        sltest.testsequence.addTransition(seqPath,...
        lev1Arry{i},'endTest == true',lev1Arry{i+1})

        %% 二级逻辑
        if isempty(lev2Arry)
            continue
        end
        lev = lev2Arry{i};
        lev{end+1}='End';
        for j=1:length(lev)-1
            from = [lev1Arry{i} '.' lev{j} ];
            to = [lev1Arry{i} '.' lev{j+1} ];

            %% 三级逻辑
            inputValue = inValue{i}{j}; 
            [isIncludeArr, inputPkg] = findHarnessInputType(inputValue);
            if isIncludeArr
                % 二级转移逻辑
                sltest.testsequence.addTransition(seqPath,...
                from,'endTest2 == true',to) 

                inTypes = length(inputPkg);
                for k=1:inTypes
                    from = [lev1Arry{i} '.' lev{j} '.' lev{j} '_' num2str(k)];
                    to = [lev1Arry{i} '.' lev{j} '.' lev{j} '_' num2str(k+1)];
                    sltest.testsequence.addTransition(seqPath,...
                    from,'after(4,tick)',to) 
                end
            else
                % 二级转移逻辑
                sltest.testsequence.addTransition(seqPath,...
                from,'after(4,tick)',to)     
            end
        end
    end

    %% 删除测试架构
%     for i=1:length(lev1Arry)
%         sltest.testsequence.deleteStep(seqPath,lev1Arry{i})
%     end

    %%
    save_system(harnessName)
    save_system(model)
%    sltest.harness.open(path,harnessName);
%    sltest.harness.close(path,harnessName);
end

  