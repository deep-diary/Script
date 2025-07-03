function updatedTable = changeSlddInitValue(slddTable, paramArrs, varargin)
%%
    % 目的: 根据信号名称，改变sldd初始值
    % 输入：
    %       slddTable: sldd 表格

    % 返回： updatedTable： 更新后的表格
    % 范例： updatedTable = changeIniValueByName(slddTable, paramArrs, 'type',{'const'})
    % 作者： Blue.ge
    % 日期： 20240124
%%
%     clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'types',{'const','axis','wert','tab','map'});      % const axis wert tab map

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取

    types = p.Results.types;

    %% 标定量类型循环
    for j=1:length(types)
        paramArr = paramArrs{j};
        type = types{j};

        %% 标定量替换
        len = length(paramArr);
        for i=1:len
%             disp([type, '---->', num2str(i)])
            switch type
                case 'const'
                    slddTable = changeSlddInitValueByName(slddTable, paramArr(i).name, paramArr(i).wert);
                case 'axis'
                    slddTable = changeSlddInitValueByName(slddTable, paramArr(i).name, mat2str(paramArr(i).x));
                case 'wert'
                    slddTable = changeSlddInitValueByName(slddTable, paramArr(i).name, paramArr(i).wert);
                case 'tab'
                    slddTable = changeSlddInitValueByName(slddTable, paramArr(i).name, mat2str(paramArr(i).wert));
                    slddTable = changeSlddInitValueByName(slddTable, paramArr(i).nameX, mat2str(paramArr(i).x));
                case 'map'
                    slddTable = changeSlddInitValueByName(slddTable, paramArr(i).name, mat2str(paramArr(i).wert));
                    slddTable = changeSlddInitValueByName(slddTable, paramArr(i).nameX, mat2str(paramArr(i).x));
                    slddTable = changeSlddInitValueByName(slddTable, paramArr(i).nameY, mat2str(paramArr(i).y));
                    
                otherwise
            end
        end
    end

    
    % 返回更新后的表格
    updatedTable = slddTable;
end
