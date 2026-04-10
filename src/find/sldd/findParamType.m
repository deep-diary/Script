function findParamType(input)
    if ischar(input)
        % 输入变量是字符串路径
        disp('Input is a string path.');
        % 进行字符串路径相关的操作
    elseif isobject(input)
        % 输入变量是对象（包括句柄对象）
        disp('Input is an object (handle).');
        % 进行对象相关的操作
    else
        % 输入变量既不是字符串也不是对象
        disp('Input is neither a string nor an object.');
    end
end
