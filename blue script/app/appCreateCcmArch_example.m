%% appCreateCcmArch 使用示例
% 此文件展示如何使用增强后的 appCreateCcmArch 函数

%% 基本用法
% 运行主脚本，会自动：
% 1. 读取Excel任务调度表格
% 2. 遍历tasks结构体
% 3. 为每个有任务的时间周期创建组合
% 4. 在组合内创建对应的组件
% 5. 生成实现模型和AUTOSAR代码

appCreateCcmArch;

%% 功能说明

%% 1. 结构体遍历
% tasks结构体包含以下字段：
% - tasks.task1ms
% - tasks.task2ms  
% - tasks.task5ms
% - tasks.task10ms
% - tasks.task20ms
% - tasks.task50ms
% - tasks.task100ms
% - tasks.task200ms
% - tasks.task500ms
% - tasks.task1000ms

% 遍历方式：
% taskFields = fieldnames(tasks);
% for i = 1:length(taskFields)
%     fieldName = taskFields{i};
%     taskList = tasks.(fieldName);
%     if ~isempty(taskList)
%         % 处理非空的任务列表
%     end
% end

%% 2. 动态组合创建
% 对于每个有任务的时间周期，会创建对应的组合：
% - Composition_5ms (如果task5ms不为空)
% - Composition_10ms (如果task10ms不为空)
% - Composition_1000ms (如果task1000ms不为空)
% 等等...

%% 3. 动态组件创建
% 在每个组合内，会为任务列表中的每个任务创建组件：
% 例如：CCMLoad_DiagRunnable -> CCMLoad_DiagArch
%       CCMAdcM_Runnable -> CCMAdcMArch
%       CCMBattery_Runnable -> CCMBatteryArch

%% 4. 输出示例
% 运行后会看到类似输出：
% 开始遍历tasks结构体，共 10 个时间周期
% 
% 处理 5ms 周期任务，共 1 个任务:
%   创建组合: Composition_5ms
%     任务: CCMLoad_DiagRunnable -> 组件: CCMLoad_DiagArch
%   在组合 Composition_5ms 中创建了 1 个组件
% 
% 处理 10ms 周期任务，共 3 个任务:
%   创建组合: Composition_10ms
%     任务: CCMAdcM_Runnable -> 组件: CCMAdcMArch
%     任务: CCMBattery_Runnable -> 组件: CCMBatteryArch
%     任务: CCMMotor_Runnable -> 组件: CCMMotorArch
%   在组合 Composition_10ms 中创建了 3 个组件
% 
% 总共创建了 4 个组件

%% 5. 文件结构
% 生成的文件夹结构：
% SubModelArch/
%   ├── CCMLoad_DiagArch.slx
%   ├── CCMAdcMArch.slx
%   ├── CCMBatteryArch.slx
%   └── CCMMotorArch.slx

%% 6. 自定义配置
% 可以修改以下参数：
% - swcAppend: 组件名称后缀（默认: 'Arch'）
% - modelName: 架构模型名称（默认: 'CcmArch'）
% - excelFile: Excel文件路径（默认: 'CCMtaskmappingV2.0.xlsx'）

%% 注意事项
% 1. 确保Excel文件存在且格式正确
% 2. 任务名称应该以'_Runnable'结尾
% 3. 空的任务列表会被跳过
% 4. 组件名称会自动添加后缀
% 5. 所有操作都有错误处理，单个失败不会影响整体流程
