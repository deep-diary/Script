function createHarnessInsert(path,lastStep, nextStep, varargin)
%%
% 目的: 为模块追加测试用例
% 输入：
% 返回：None
% 范例： createHarnessInsert('harness','lev1',{'SM123','SM456'},'lev2',{{'SM1','SM2'},{'SM4','SM6'}})
% 作者： Blue.ge
% 日期： 20240409
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
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    mask = p.Results.mask;
    inName = p.Results.inName;
    inValue = p.Results.inValue;
    lev1Arry = p.Results.lev1;
    lev2Arry = p.Results.lev2;
    rstName = p.Results.rstName;
    rstValue = p.Results.rstValue;


    %% 创建harness
    % 默认已经创建并加载
    harnessList = sltest.harness.find(path,'SearchDepth',1);
    if length(harnessList)>=1
        harnessName = harnessList(1).name;
    else
        error('there is no harness or more than 1 harness')
    end
    sltest.harness.load(path,harnessName);
    %% 创建局部变量
    seqPath = [harnessName,'/Test Sequence'];
    % 默认已经创建

    %% 创建测试架构
%     lev1Arry = {'SM123','SM456'};
%     lev2Arry = {{'SM1','SM2'},{'SM4','SM5','SM6'}};

    if ~isempty(lev2Arry)
        lev2Arry{end+1} = {};
    end
    
    lastStp = lastStep;

    %% 添加测试步骤
    createHarnessStep(harnessName,lastStp, ...
        'lev1',lev1Arry, ...
        'lev2',lev2Arry, ...
        'inName',inName, ...
        'inValue',inValue, ...
        'rstName',rstName, ...
        'rstValue',rstValue, ...
        'mask',mask ...
        )

    %% 添加默认转移条件
    lev1Arry{end+1} = nextStep; % 一级步骤跳转到最后

    sltest.testsequence.editTransition(seqPath,...  % 改变之前的步骤
    lastStep,1,...
    'NextStep',lev1Arry{1},...
    'Condition','endTest == true')
    
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

    %%
    save_system(harnessName)
%     sltest.harness.close(path,harnessName);
end

