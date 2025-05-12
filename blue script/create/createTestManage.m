function createTestManage(modelName, varargin)
%CREATETESTMANAGE 为模块创建测试管理器
%   createTestManage(modelName) 为指定模块创建测试管理器，包括测试文件、
%   测试套件和测试用例的创建，以及测试运行和报告导出功能。
%
%   输入参数:
%       modelName - 模块名称，例如'TmRefriVlvCtrl'
%
%   可选参数:
%       'run' - 是否运行测试，默认为false
%       'clear' - 是否清除测试结果，默认为false
%       'export' - 是否导出测试结果，默认为false
%
%   示例:
%       createTestManage('TmRefriVlvCtrl')
%       createTestManage('TmComprCtrl', 'run', true, 'export', true)
%       createTestManage('TmComprCtrl', 'clear', true)
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-04-18
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        
        % 添加参数及其验证
        addParameter(p, 'run', false, @islogical);
        addParameter(p, 'clear', false, @islogical);
        addParameter(p, 'export', false, @islogical);
        
        parse(p, varargin{:});
        
        % 获取参数值
        run = p.Results.run;
        clear = p.Results.clear;
        export = p.Results.export;
        
        %% 验证模块路径
        proj = currentProject;

        [subPath,name,ext]=fileparts(which(modelName))
        
        if ~exist(subPath, 'dir')
            error('错误的子模块路径: %s', subPath);
        end
        
        %% 设置测试文件路径
        fileName = [model, '.mldatx'];
        testPath = fullfile(subPath, fileName);
        
        %% 创建或加载测试文件
        try
            if ~exist(testPath, 'file')
                % 清除测试管理器
                sltest.testmanager.clear;
                sltest.testmanager.close;
                
                % 从模型创建测试
                fprintf('正在从模型 %s 创建测试...\n', model);
                testFile = sltest.testmanager.createTestsFromModel(testPath, model, 'simulation');
            else
                fprintf('正在加载现有测试文件...\n');
                sltest.testmanager.load(testPath);
            end
            
            % 显示测试管理器
            sltest.testmanager.view;
            
        catch ME
            error('创建/加载测试文件时发生错误: %s', ME.message);
        end
        
        %% 运行测试用例
        if clear
            try
                fprintf('正在清除测试结果...\n');
                sltest.testmanager.clearResults;
            catch ME
                warning(ME.identifier, '清除测试结果时发生错误: %s', ME.message);
            end
        end
        
        if run
            try
                fprintf('正在运行测试...\n');
                ro = sltest.testmanager.run;
            catch ME
                warning(ME.identifier, '运行测试时发生错误: %s', ME.message);
            end
        end
        
        %% 导出报告
        if export
            try
                fprintf('正在导出测试报告...\n');
                ro = sltest.testmanager.getResultSets;
                reportName = [model, '.pdf'];
                reportPath = fullfile(subPath, reportName);
                
                sltest.testmanager.report(ro, reportPath, ...
                    'Author', 'Blue.ge', ...
                    'Title', model, ...
                    'IncludeMLVersion', true, ...
                    'IncludeTestResults', 0, ...
                    'IncludeCoverageResult', true, ...
                    'IncludeMATLABFigures', false, ...
                    'IncludeComparisonSignalPlots', false, ...
                    'IncludeSimulationSignalPlots', true);
                
                fprintf('测试报告已导出到: %s\n', reportPath);
            catch ME
                warning(ME.identifier, '导出测试报告时发生错误: %s', ME.message);
            end
        end
        
        fprintf('测试管理器操作完成\n');
        
    catch ME
        error('测试管理器操作过程中发生错误: %s', ME.message);
    end
    
    %% 保留的参考代码
    % 以下代码作为参考，可以通过设置控制开关启用
    
    % 示例1: 手动创建测试文件
    % if false % 控制开关
    %     % Create test file
    %     testfile = sltest.testmanager.TestFile(testPath);
    %     
    %     % Create test suite
    %     testsuite = sltest.testmanager.TestSuite(testfile,'Speed');
    %     
    %     % Create test case
    %     testcase = sltest.testmanager.TestCase(testsuite,'simulation','Filter');
    % end
    
    % 示例2: 为特定组件创建测试
    % if false % 控制开关
    %     tcObj = sltest.testmanager.createTestForComponent(...
    %         'TestFile', testfile, ...
    %         'Component', [model, '/2F'], ...
    %         'UseComponentInputs', false, ...
    %         'HarnessOptions', {'Name', 'F2', ...
    %                           'Source', 'Test Sequence', ...
    %                           'SynchronizationMode', 'SyncOnOpen'});
    % end
    
    % 示例3: 获取测试套件和测试用例
    % if false % 控制开关
    %     ts = getTestSuites(testFile);
    %     tc = getTestCases(ts(1));
    %     
    %     in = sltest.harness.SimulationInput(ts(1).Name, 'offcode0');
    % end
    
    % 示例4: 导出测试结果
    % if false % 控制开关
    %     result = sltest.testmanager.getResultSets;
    %     sltest.testmanager.exportResults(result, 'results.mldatx');
    % end
end