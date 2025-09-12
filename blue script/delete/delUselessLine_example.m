%% delUselessLine 使用示例
% 此文件展示了如何使用优化后的 delUselessLine 函数

%% 基本用法 - 仅删除本层无用信号线
fprintf('=== 基本用法示例 ===\n');
% 假设有一个名为 'myModel' 的模型
% delUselessLine('myModel');

%% 递归删除所有无用信号线
fprintf('\n=== 递归删除示例 ===\n');
% 删除模型及其所有子系统中的无用信号线
% delUselessLine('myModel', 'recursive', true);

%% 明确指定仅删除本层
fprintf('\n=== 明确指定本层删除示例 ===\n');
% 明确指定仅删除本层的无用信号线
% delUselessLine('myModel', 'recursive', false);

%% 处理子系统
fprintf('\n=== 处理子系统示例 ===\n');
% 处理特定子系统
% delUselessLine('myModel/SubSystem1', 'recursive', true);

%% 批量处理多个模型
fprintf('\n=== 批量处理示例 ===\n');
% 批量处理多个模型
models = {'model1', 'model2', 'model3'};
for i = 1:length(models)
    try
        fprintf('处理模型: %s\n', models{i});
        % delUselessLine(models{i}, 'recursive', true);
        fprintf('  模型 %s 处理完成\n', models{i});
    catch ME
        fprintf('  模型 %s 处理失败: %s\n', models{i}, ME.message);
    end
end

%% 安全使用建议
fprintf('\n=== 安全使用建议 ===\n');
fprintf('1. 使用前请保存模型\n');
fprintf('2. 可以先在测试模型上验证效果\n');
fprintf('3. 递归模式会处理所有子系统，请谨慎使用\n');
fprintf('4. 建议在版本控制下使用，以便回滚\n');

fprintf('\n示例完成！\n');
