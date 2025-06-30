function createdEnums = createEnumFromExcel(varargin)
% createEnumFromExcel  从Excel模板批量创建Simulink枚举类型
%
%   createEnumFromExcel('template', 'Template.xlsx', 'sheet', 'EnumDefinition')
%
%   范例: 
%       createdEnums = createEnumFromExcel()
%   Excel模板需包含列：EnumName, EnumValue, Value, Description

    %% 输入参数解析
    p = inputParser;
    addParameter(p, 'template', 'Template', @ischar);
    addParameter(p, 'sheet', 'EnumDefinition', @ischar);
    parse(p, varargin{:});
    template = p.Results.template;
    sheet = p.Results.sheet;

    %% 读取Excel数据
    data = readtable(template, 'Sheet', sheet);

    %% 获取所有唯一枚举类型
    enumNames = unique(data.EnumName);

    %% 批量创建枚举类型
    createdEnums = {};

    for i = 1:numel(enumNames)
        enumName = enumNames{i};
%         loadedEnums = findEnumTypes();
%         % 判断是否已存在
%         if any(strcmp(enumName, loadedEnums))
%             disp([enumName '已经存在'])
%             continue;
%         end
        items = data(strcmp(data.EnumName, enumName), :);

        names  = items.EnumValue';
        values = items.Value';
        % 处理Description，防止为空
        if ismember('Description', items.Properties.VariableNames)
            descs = items.Description';
            if iscell(descs)
                descs(cellfun(@(x) isempty(x)||all(isspace(x)), descs)) = {''};
            end
        else
            descs = repmat({''}, size(names));
        end

        % 只用主描述，不能直接传cell数组
        mainDesc = ['Auto-generated enum: ' enumName];

        Simulink.defineIntEnumType(enumName, names, values, ...
            'Description', mainDesc, ...
            'AddClassNameToEnumNames', false);
        createdEnums{end+1} = enumName; %#ok<AGROW>
    end
    if ~isempty(createdEnums)
        fprintf('创建的枚举类型有：\n');
        fprintf('  %s\n', createdEnums{:});
    else
        fprintf('本次未创建新的枚举类型。\n');
    end
end

