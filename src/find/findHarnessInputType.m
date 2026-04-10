function [isIncludeArr, inputPkg] = findHarnessInputType(input)
%%
    % 目的: 找到输入元组是否包含数组，如果包含，则返回1，不包含，则返回0
    % 输入：
    %       input： 输入内容
    % 返回： DCM 各种数据类型结构体
    % 范例： [isIncludeArr, inputPkg] = findHarnessInputType({[1 2 3], [4 5], 6})
    % 范例： [isIncludeArr, inputPkg] = findHarnessInputType({1, 2, 6})
    % 作者： Blue.ge
    % 日期： 20240410
%%
    clc
    %% 检查是否包含数组
    isIncludeArr = 0;
    for i=1:length(input)
        el = input{i};
        if isnumeric(el) && numel(el) > 1
            isIncludeArr = 1;
            break
        end
    end
    %% 打散输入信号
    inputPkg{1} = input; % 打包成一个元素
    inputPkg = createHarnessInput(inputPkg);
end





