function [init, tasks, tasksAll] = readAutosarTasks(excelFile, sheetName)
%READAUTOSARTASKS 读取AUTOSAR任务调度表格
%   [INIT, TASKS] = READAUTOSARTASKS(EXCELFILE, SHEETNAME) 读取Excel文件中的AUTOSAR任务调度信息
%
%   输入参数:
%      excelFile  - Excel文件路径 (字符串)
%      sheetName  - 工作表名称 (字符串，可选，默认: 'Sheet1')
%
%   输出参数:
%      init       - 初始化函数列表 (元胞数组)
%      tasks      - 任务结构体，包含各周期的任务列表
%                   tasks.task1ms, tasks.task5ms, tasks.task10ms, 等
%      tasksAll   - 所有任务列表
%
%   功能描述:
%      读取Excel文件中的AUTOSAR任务调度表格，解析初始化函数和各周期的Runnable任务
%
%   示例:
%      [init, tasks, tasksAll] = readAutosarTasks('CCMtaskmappingV2.0.xlsx');
%      [init, tasks, tasksAll] = readAutosarTasks('CCMtaskmappingV2.0.xlsx', 'Sheet1');
%
%   作者: Blue.ge
%   日期: 2025-01-09
%   版本: 1.0

% 输入参数处理
if nargin < 1
    error('至少需要提供Excel文件路径');
end

if nargin < 2 || isempty(sheetName)
    sheetName = 'Sheet1';
end

% 检查Excel文件是否存在
if ~exist(excelFile, 'file')
    error('Excel文件不存在: %s', excelFile);
end

fprintf('正在读取Excel文件: %s (工作表: %s)\n', excelFile, sheetName);

%% 1. 读取Excel表格数据
try
    % 使用更简单的方式读取Excel文件，保留原始列名
    dataTable = readtable(excelFile, 'Sheet', sheetName, 'ReadVariableNames', true, 'VariableNamingRule', 'preserve');
    fprintf('成功读取Excel文件，共 %d 行 %d 列\n', height(dataTable), width(dataTable));
catch ME
    error('读取Excel文件失败: %s', ME.message);
end

%% 2. 解析初始化函数（第2列）
init = {};
initCol = 2;  % 初始化列固定为第2列

if initCol <= width(dataTable)
    initData = dataTable{:, initCol};
    for i = 1:length(initData)
        % 使用更安全的方式访问数据
        if iscell(initData)
            cellData = initData{i};
        else
            cellData = initData(i);
        end
        
        if ischar(cellData) && ~isempty(strtrim(cellData))
            init{end+1} = strtrim(cellData);
        end
    end
end

fprintf('解析到 %d 个初始化函数\n', length(init));

%% 3. 解析各周期任务
% 定义时间周期
timePeriods = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000];

% 初始化任务结构体
tasks = struct();
tasksAll = {};
for i = 1:length(timePeriods)
    period = timePeriods(i);
    fieldName = ['task' num2str(period) 'ms'];
    tasks.(fieldName) = {};
end

% 解析每个时间列（从第3列开始）
for i = 1:length(timePeriods)
    period = timePeriods(i);
    colIdx = i + 2;  % 第3列开始对应1ms
    
    if colIdx <= width(dataTable)
        fieldName = ['task' num2str(period) 'ms'];
        taskData = dataTable{:, colIdx};
        
        % 解析该列的任务
        for j = 1:length(taskData)
            % 使用更安全的方式访问数据
            if iscell(taskData)
                cellData = taskData{j};
            else
                cellData = taskData(j);
            end
            
            if ischar(cellData) && ~isempty(strtrim(cellData))
                tasks.(fieldName){end+1} = strtrim(cellData);
                tasksAll{end+1} = strtrim(cellData);
            end
        end
        
        fprintf('%dms: %d 个任务\n', period, length(tasks.(fieldName)));
    end
end

%% 4. 显示解析结果摘要
fprintf('\n=== 解析结果摘要 ===\n');
fprintf('初始化函数: %d 个\n', length(init));
for i = 1:length(timePeriods)
    period = timePeriods(i);
    fieldName = ['task' num2str(period) 'ms'];
    taskCount = length(tasks.(fieldName));
    if taskCount > 0
        fprintf('%dms任务: %d 个\n', period, taskCount);
    end
end

%% 验证初始化和任务列表是否一致
swcInit = strrep(init, '_Init', '');
swcRunnable = strrep(tasksAll, '_Runnable', '');

% 找到swcInit 和 swcRunnable 不相同的元素
diff = setdiff(swcInit, swcRunnable);
if ~isempty(diff)
    fprintf('初始化和任务列表不一致，有 %d 个不一致的元素\n', length(diff));
    fprintf('不一致的元素: %s\n', strjoin(diff, ', '));
end

fprintf('\n解析完成！\n');
end
