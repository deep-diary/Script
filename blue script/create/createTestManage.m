function createTestManage(modeFold,varargin)
%%
% 目的: 为模块创建测试管理器
% 输入：
% 返回：None
% 范例： createTestManage('04_TmRefriVlvCtrl') 
% 范例： createTestManage('06_TmComprCtrl') 
% 范例： createTestManage('05_TmSovCtrl')  
% 作者： Blue.ge
% 日期： 20240418

    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器

    addParameter(p,'exportReport',true);      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    exportReport = p.Results.exportReport;


    %% 创建test文件相关路径
%     modeFold = '04_TmRefriVlvCtrl';
%     modeFold = '06_TmComprCtrl';
    modeFold = '05_TmSovCtrl';
    
    proj = currentProject;
    rootPath = proj.RootFolder;
    subPath = fullfile(rootPath,'SubModel',modeFold);
    if ~exist(subPath, 'dir')
        error('wrong sub model path')
    end
    
    % model ='TmComprCtrl';
    model = modeFold(4:end);
    fileName = [model '.mldatx'];
    
    testPath = fullfile(subPath,fileName);
    
    %% 从模型中导入harness
    
    % % Create test file
    % testfile = sltest.testmanager.TestFile(testPath);
    % 
    % % Create test suite
    % testsuite = sltest.testmanager.TestSuite(testfile,'Speed')
    % 
    % % Create test case
    % testcase = sltest.testmanager.TestCase(testsuite,'simulation',...
    % 				'Filter')
    % 
    % tcObj = sltest.testmanager.createTestForComponent(...
    % 'TestFile',testfile, ...
    % 'Component','TmComprCtrl/2F','UseComponentInputs', ...
    % false,'HarnessOptions',{'Name','F2', ...
    % 'Source','Test Sequence','SynchronizationMode', ...
    % 'SyncOnOpen'});
    % 
    % % Clear test file from Test Manager
    % sltest.testmanager.clear;
    % 
    % % Close Test Manager
    % sltest.testmanager.close;
    
    if ~exist(testPath, 'file')
        % Clear test file from Test Manager
        sltest.testmanager.clear;
        
        % Close Test Manager
        sltest.testmanager.close;
        testFile = sltest.testmanager.createTestsFromModel...
        (testPath,model,'simulation');
    end
    
    sltest.testmanager.load(testPath);
    sltest.testmanager.view;
    
    % ts = getTestSuites(testFile);
    % tc = getTestCases(ts(1));
    
    % in = sltest.harness.SimulationInput(ts(1).Name,...
    %             'offcode0');  
    
    %% 运行测试用例
    % ro = sltest.testmanager.run("Tags","Speed")
%     sltest.testmanager.clearResults
    
    % Import results set from a file
    ro = sltest.testmanager.getResultSets;
    if isempty(ro)
        ro = sltest.testmanager.run;
    end
    
    %% 导出报告
    reportName = [model '.pdf'];
    reportPath = fullfile(subPath,reportName);
    sltest.testmanager.report(ro,reportPath,...
	    'Author','Blue.ge',...
	    'Title',model,...
	    'IncludeMLVersion',true,...
	    'IncludeTestResults',0, ...
        'IncludeCoverageResult',true,...
        'IncludeMATLABFigures',false,...
        'IncludeComparisonSignalPlots',false,...
        'IncludeSimulationSignalPlots',true...
        );
    
    % % Get the results set object from Test Manager
    % result = sltest.testmanager.getResultSets
    % 
    % % Export the results set object to a file
    % sltest.testmanager.exportResults(result,'results.mldatx')

end