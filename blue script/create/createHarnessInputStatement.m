function inAction = createHarnessInputStatement(names,values)
%%
% 目的: 为模块追加测试用例
% 输入：
% 返回：None
% 范例： inAction = createHarnessInputStatement({'SM11', 'SM12'},{10, 5.0})
% 作者： Blue.ge
% 日期： 20240410
%%
    % 设置默认端口间距
    clc
    %% 输入参数处理


    %%  合并输入
%     names = {'SM11', 'SM12'};
%     values = {10, 5.0};
    len = length(names);
    inAction = sprintf('%% input statement\n');
    for i = 1:len
        % Check if the value is an integer
%         if isinteger(values{i})
%             % If it's an integer, use %d format specifier
%             statement = sprintf('%s = %d;\n', names{i}, values{i});
%         else
%             % If it's not an integer, use %f format specifier
%             statement = sprintf('%s = %f;\n', names{i}, values{i});
%         end

        value = values{i};
        % 判断变量是否是数字
        if isnumeric(value)
            % 将数字转换成字符串
            value = num2str(value);
        end

        % 判断变量是否是逻辑
        if islogical(value)
            % 将数字转换成字符串
            if value
                value = 'true';
            else
                value = 'false';
            end
        end
        statement = sprintf('%s = %s;\n', names{i}, value);
        inAction = [inAction statement];
    end
    disp(inAction);
    
end

  
