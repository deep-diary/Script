%% 测试 createCodeMod 函数
% 这个脚本用于测试优化后的 createCodeMod 函数

clear; clc;

fprintf('=== 测试 createCodeMod 函数 ===\n\n');

try
    % 测试1：基本功能测试
    fprintf('测试1：基本功能测试\n');
    fprintf('----------------------------------------\n');
    
    % 注意：这里需要替换为实际存在的模型名称
    testModelName = 'testModel';  % 请根据实际情况修改
    
    % 检查模型是否存在
    if isempty(which(testModelName))
        fprintf('警告: 模型 %s 不存在，跳过实际测试\n', testModelName);
        fprintf('请将 testModelName 修改为实际存在的模型名称\n\n');
    else
        % 测试默认参数
        createCodeMod(testModelName);
        
        % 测试指定类型
        createCodeMod(testModelName, 'type', 'ert');
        
        % 测试指定文件类型
        createCodeMod(testModelName, 'type', 'ert', 'fileTypes', {'c', 'h'});
        
        % 测试合并模式
        createCodeMod(testModelName, 'combine', true);
        
        % 测试自定义代码文件夹
        createCodeMod(testModelName, 'codeFolder', 'GeneratedCode', 'combine', true);
        
        % 测试静默模式
        createCodeMod(testModelName, 'showInfo', false);
    end
    
    % 测试2：参数验证测试
    fprintf('\n\n测试2：参数验证测试\n');
    fprintf('----------------------------------------\n');
    
    % 测试无效的模型名称
    try
        createCodeMod('');
        fprintf('错误：应该抛出异常但没有\n');
    catch ME
        fprintf('正确捕获异常: %s\n', ME.message);
    end
    
    % 测试无效的类型
    try
        createCodeMod('testModel', 'type', 'invalid_type');
        fprintf('错误：应该抛出异常但没有\n');
    catch ME
        fprintf('正确捕获异常: %s\n', ME.message);
    end
    
    % 测试3：功能演示
    fprintf('\n\n测试3：功能演示\n');
    fprintf('----------------------------------------\n');
    
    fprintf('createCodeMod 函数的主要功能:\n');
    fprintf('1. 自动查找模型文件\n');
    fprintf('2. 创建分类的代码目录结构（或合并模式）\n');
    fprintf('3. 按文件类型复制代码文件\n');
    fprintf('4. 提供详细的执行信息\n');
    fprintf('5. 支持多种代码生成类型\n');
    fprintf('6. 支持项目路径自动检测和防错处理\n');
    fprintf('7. 支持合并模式将所有文件放在同一目录\n');
    
    fprintf('\n支持的代码生成类型:\n');
    fprintf('- ert: Embedded Coder\n');
    fprintf('- autosar: AUTOSAR\n');
    fprintf('- autosarharness: AUTOSAR Harness\n');
    fprintf('- ertharness: ERT Harness\n');
    
    fprintf('\n=== 测试完成 ===\n');
    
catch ME
    fprintf('测试过程中发生错误: %s\n', ME.message);
    fprintf('错误位置: %s (第 %d 行)\n', ME.stack(1).file, ME.stack(1).line);
end
