function mdName = findNameMd(Name)
%%
    % 目的: 去掉数字前缀的模型名称
    % 输入：
    %       Name： 信号名称
    % 返回： mdName: 去掉数字前缀的模型名称
    % 范例： mdName = findNameMdOut('0123_Offcode1')
    % 说明： 比如当前模型名称是'0123_Offcode1', 则如下函数输出为'Offcode1'
    % 作者： Blue.ge
    % 日期： 20240409
%%
        clc
%         Name = '0123_Offcode1'; % for test only
        strList = split(Name,'_');
        mdName = strList{end};

end