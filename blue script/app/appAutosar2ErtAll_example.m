%% appAutosar2ErtAll 使用示例
% 此文件展示了如何使用优化后的 appAutosar2ErtAll 函数

%% 基本用法
fprintf('=== 基本用法示例 ===\n');
[success, results, codePaths] = appAutosar2ErtAll();

%% 使用不同参数
fprintf('\n=== 使用不同参数示例 ===\n');
[success, results, codePaths] = appAutosar2ErtAll('autosarMode', 'halfTail', 'combine', false, 'verbose', true);

%% 静默模式（不显示详细输出）
fprintf('\n=== 静默模式示例 ===\n');
[success, results, codePaths] = appAutosar2ErtAll('verbose', false);

%% 遇到错误时停止
fprintf('\n=== 遇到错误时停止示例 ===\n');
[success, results, codePaths] = appAutosar2ErtAll('skipErrors', false);

%% 结果分析
fprintf('\n=== 结果分析示例 ===\n');
if success
    fprintf('所有模型转换成功！\n');
    fprintf('成功转换 %d 个模型\n', sum([results.success]));
    
    % 显示每个模型的详细信息
    for i = 1:length(results)
        fprintf('模型 %d: %s - %s\n', i, results(i).modelName, ...
                results(i).success ? '成功' : '失败');
        if results(i).success
            fprintf('  代码根目录: %s\n', results(i).codePaths.root);
            fprintf('  总文件数: %d\n', results(i).summary.totalFiles);
        else
            fprintf('  错误信息: %s\n', results(i).errorMsg);
        end
    end
    
    % 如果有合并的代码路径
    if ~isempty(fieldnames(codePaths))
        fprintf('\n合并后的代码路径:\n');
        fprintf('  根目录: %s\n', codePaths.root);
        fprintf('  C文件目录: %s\n', codePaths.c);
        fprintf('  H文件目录: %s\n', codePaths.h);
        fprintf('  A2L文件目录: %s\n', codePaths.a2l);
    end
else
    fprintf('部分模型转换失败\n');
    failedModels = results(~[results.success]);
    for i = 1:length(failedModels)
        fprintf('失败模型: %s - %s\n', failedModels(i).modelName, failedModels(i).errorMsg);
    end
end

fprintf('\n示例完成！\n');
