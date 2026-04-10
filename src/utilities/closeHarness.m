% 获取当前所有打开的模型
% openModels = find_system('type', 'block_diagram');

% 获取模型的所有 Harness
harnesses = sltest.harness.find(bdroot);

% 关闭每个 Harness
for j = 1:length(harnesses)
    harnessName = harnesses(j).name;
    if harnesses(j).isOpen
        fprintf('Closing harness: %s\n', harnessName);
%             sltest.harness.close(openModels{i}, harnessName);
    end
end

