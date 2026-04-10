function updatedTable = changeSlddInitValueByName(slddTable, name, value)
%%
    % 目的: 根据信号名称，改变sldd初始值
    % 输入：
    %       slddTable: sldd 表格
    %        name: 信号名
    %        value: 信号值
    % 返回： updatedTable： 更新后的表格
    % 范例： updatedTable = changeIniValueByName(slddTable, name,value)
    % 作者： Blue.ge
    % 日期： 20240318
%%
%     clc

    %%
    % 找到名称匹配的行
    idx = find(strcmp(slddTable.Name, name));

    % 如果找到，更新IniValue列
    if ~isempty(idx)
        len = length(idx);

        % 如果有重复的
        if len>1 
            disp(['there is dump idx: ', num2str(idx'),' ----> ', name])
%             idx = idx(end);
        end
        % 更新sldd
        for i=1:len
            % 如果是浮点数则保留4位小数
            if any(mod(value,1)~=0)
                value = round(value,4);
            end
            slddTable.IniValue{idx(i)} = value;
        end      
    else
        warning([name, ' not found.']);
    end
    
    % 返回更新后的表格
    updatedTable = slddTable;
end
