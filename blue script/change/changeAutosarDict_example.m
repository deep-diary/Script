%% changeAutosarDict 使用示例
% 此文件展示如何使用优化后的 changeAutosarDict 函数（支持可选参数）

%% 基本用法 - 使用默认参数
% changeAutosarDict('PrkgClimaActvMgrArch');

%% 指定所有可选参数
% changeAutosarDict('PrkgClimaActvMgrArch', 'Suffix', 'Arch', 'RunnablePeriod', 0.2);

%% 只指定后缀，使用默认周期
% changeAutosarDict('PrkgClimaActvMgrArch', 'Suffix', 'Model');

%% 只指定周期，使用默认后缀
% changeAutosarDict('PrkgClimaActvMgrArch', 'RunnablePeriod', 0.1);

%% 使用不同的后缀和周期
% changeAutosarDict('MyModelArch', 'Suffix', 'Arch', 'RunnablePeriod', 0.05);

%% 错误处理示例
try
    changeAutosarDict('PrkgClimaActvMgrArch', 'Suffix', 'Arch', 'RunnablePeriod', 0.2);
    fprintf('AUTOSAR数据字典修改成功！\n');
catch ME
    fprintf('错误: %s\n', ME.message);
end

%% 简化逻辑说明
% 函数采用简化的处理逻辑：
% 1. 打开模型后，先删除所有现有模块（保持模型结构干净）
% 2. 重新创建Constant和Terminator模块并连线
% 3. 继续执行AUTOSAR配置和代码生成
% 4. 支持重复运行，每次都会重新初始化模型结构

%% 参数说明
% model: 模型名称（必需参数）
% 'Suffix': 模型后缀（可选，默认为 'Arch'）
% 'RunnablePeriod': 运行周期（可选，默认为 0.2）

%% 支持的调用方式
% 1. changeAutosarDict('ModelName')
% 2. changeAutosarDict('ModelName', 'Suffix', 'CustomSuffix')
% 3. changeAutosarDict('ModelName', 'RunnablePeriod', 0.1)
% 4. changeAutosarDict('ModelName', 'Suffix', 'Custom', 'RunnablePeriod', 0.05)
% 5. changeAutosarDict('ModelName', 'RunnablePeriod', 0.1, 'Suffix', 'Custom')
