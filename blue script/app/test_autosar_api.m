%% 测试AUTOSAR API使用方式
% 此脚本用于测试和验证AUTOSAR API的正确使用方法

%% 1. 加载架构模型
modelName = 'CcmArch';
try
    archModel = autosar.arch.loadModel(modelName);
    fprintf('成功加载架构模型: %s\n', modelName);
catch ME
    fprintf('加载架构模型失败: %s\n', ME.message);
    return;
end

%% 2. 显示模型信息
fprintf('\n=== 架构模型信息 ===\n');
fprintf('模型名称: %s\n', archModel.Name);
fprintf('Simulink句柄: %f\n', archModel.SimulinkHandle);
fprintf('组件数量: %d\n', length(archModel.Components));
fprintf('组合数量: %d\n', length(archModel.Compositions));
fprintf('端口数量: %d\n', length(archModel.Ports));
fprintf('连接器数量: %d\n', length(archModel.Connectors));
fprintf('接口数量: %d\n', length(archModel.Interfaces));

%% 3. 测试组合访问
fprintf('\n=== 组合信息 ===\n');
compositions = archModel.Compositions;
fprintf('找到 %d 个组合:\n', length(compositions));

for i = 1:length(compositions)
    composition = compositions(i);
    fprintf('  组合 %d: %s\n', i, composition.Name);
    
    % 测试组件访问
    components = composition.Components;
    fprintf('    包含 %d 个组件:\n', length(components));
    
    for j = 1:length(components)
        component = components(j);
        fprintf('      组件 %d: %s\n', j, component.Name);
    end
end

%% 4. 测试属性访问方式
fprintf('\n=== 属性访问测试 ===\n');
if length(compositions) > 0
    composition = compositions(1);
    fprintf('测试组合属性访问:\n');
    
    % 方式1：直接属性访问
    try
        name1 = composition.Name;
        fprintf('  composition.Name: %s\n', name1);
    catch ME
        fprintf('  composition.Name 失败: %s\n', ME.message);
    end
    
    % 方式2：get函数访问
    try
        name2 = get(composition, 'Name');
        fprintf('  get(composition, ''Name''): %s\n', name2);
    catch ME
        fprintf('  get(composition, ''Name'') 失败: %s\n', ME.message);
    end
    
    % 测试组件属性访问
    if length(composition.Components) > 0
        component = composition.Components(1);
        fprintf('测试组件属性访问:\n');
        
        try
            compName1 = component.Name;
            fprintf('  component.Name: %s\n', compName1);
        catch ME
            fprintf('  component.Name 失败: %s\n', ME.message);
        end
        
        try
            compName2 = get(component, 'Name');
            fprintf('  get(component, ''Name''): %s\n', compName2);
        catch ME
            fprintf('  get(component, ''Name'') 失败: %s\n', ME.message);
        end
    end
end

%% 5. 测试find函数
fprintf('\n=== find函数测试 ===\n');
try
    % 测试不同的find函数调用方式
    fprintf('测试 find(archModel, ''Composition''):\n');
    comps1 = find(archModel, 'Composition');
    fprintf('  结果: %d 个组合\n', length(comps1));
catch ME
    fprintf('  find(archModel, ''Composition'') 失败: %s\n', ME.message);
end

try
    fprintf('测试 find(archModel, ''Component''):\n');
    comps2 = find(archModel, 'Component');
    fprintf('  结果: %d 个组件\n', length(comps2));
catch ME
    fprintf('  find(archModel, ''Component'') 失败: %s\n', ME.message);
end

%% 6. 推荐的使用方式
fprintf('\n=== 推荐的使用方式 ===\n');
fprintf('基于测试结果，推荐使用以下方式:\n');
fprintf('1. 访问组合: compositions = archModel.Compositions\n');
fprintf('2. 访问组件: components = composition.Components\n');
fprintf('3. 访问名称: name = object.Name (直接属性访问)\n');
fprintf('4. 避免使用: find(object, ''Type'') 可能有问题\n');

fprintf('\n测试完成！\n');
