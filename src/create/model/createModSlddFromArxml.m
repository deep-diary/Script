function createModSlddFromArxml(arxml_name)
% createModSlddFromArxml  从ARXML文件批量导入组件并生成SLDD数据字典
%
%   createModSlddFromArxml('CDM ARMXL CCM SMART 25N1 V3C 20250619.arxml')
%
%   输入参数：
%       arxml_name - ARXML文件名（字符串，必填）
%
%   本函数会自动遍历ARXML中的所有Application Component，
%   并为每个组件生成独立的SLDD数据字典文件。

    %% 输入参数校验
    if nargin < 1 || ~ischar(arxml_name)
        error('请输入有效的ARXML文件名（字符串）。');
    end
    if ~exist(arxml_name, 'file')
        error('指定的ARXML文件不存在: %s', arxml_name);
    end

    %% 导入ARXML文件
    try
        importerObj = arxml.importer({arxml_name});
    catch ME
        error('ARXML导入失败: %s', ME.message);
    end

    %% 获取所有Application Component
    application_components = importerObj.getComponentNames;
    nums = numel(application_components);
    if nums == 0
        warning('未在ARXML中找到任何Application Component。');
        return;
    end

    %% 批量处理每个组件
    for i = 1:nums
        % 显示完成度百分比
        progress = round((i / nums) * 100, 1);
        swc_name = application_components{i};
        fprintf('处理进度: %.1f%% (%d/%d) - 正在处理组件: %s\n', progress, i, nums, swc_name);
        try
            % 提取组件名称
            swc_parts = strsplit(swc_name, '/');
            component_name = swc_parts{end};
            sldd_name = [component_name, '.sldd'];
            % 创建模型并生成SLDD
            importerObj.createComponentAsModel(swc_name, ...
                'ModelPeriodicRunnablesAs', 'FunctionCallSubsystem', ...
                'DataDictionary', sldd_name);
            save_system(gcs, component_name);
            close_system(gcs, 0);
        catch ME
            warning('处理组件 %s 时发生错误: %s', swc_name, ME.message);
        end
    end
end


% save with different name in order not to get into conflict with next section
