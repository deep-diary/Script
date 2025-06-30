% clear
% Check Switch模块首个输入传递条件是否为不等于0，阈值是否为0，输出最大值最小值限值是否为空
function CheckSwitchAddDivideDataTypeSet
InportCell = find_system(bdroot,'BlockType','Switch');  %获取顶层Inport模块路径
for i=1:length(InportCell)
    InportHandle = get_param(InportCell{i},'Handle');  %信号线句柄
    Criteria_sw = get_param(InportHandle,"Criteria");
    Threshold_sw = get_param(InportHandle,"Threshold");
    OutMin_Sw = get_param(InportHandle,"OutMin");
    OutMax_Sw = get_param(InportHandle,"OutMax");

    if Criteria_sw ~= "u2 ~= 0"
        warning([InportCell{i},' Criteria is not "u2 ~= 0"']);
        
    end

    if Threshold_sw ~= "0"
        warning([InportCell{i},' Threshold is not "0"']);
    end

    if OutMin_Sw ~= "[]"
        warning([InportCell{i},' OutMin is not "[]"']);
    end

    if OutMax_Sw ~= "[]"
        warning([InportCell{i},' OutMax is not "[]"']);
    end

end

% Check Add模块输出最大值最小值限值是否为空
InportCell = find_system(bdroot,'BlockType','Sum');  %获取顶层Inport模块路径
for i=1:length(InportCell)
    InportHandle = get_param(InportCell{i},'Handle');  %信号线句柄
    OutMin_sum = get_param(InportHandle,"OutMin");
    OutMax_sum = get_param(InportHandle,"OutMax");

    if OutMin_sum ~= "[]"
        warning([InportCell{i},' OutMin is not "[]"']);
    end

    if OutMax_sum ~= "[]"
        warning([InportCell{i},' OutMax is not "[]"']);
    end

end

% Check Divide模块输出最大值最小值限值是否为空
InportCell = find_system(bdroot,'BlockType','Product');  %获取顶层Inport模块路径
for i=1:length(InportCell)
    InportHandle = get_param(InportCell{i},'Handle');  %信号线句柄
    OutMin_Prdct = get_param(InportHandle,"OutMin");
    OutMax_Prdct = get_param(InportHandle,"OutMax");

    if OutMin_Prdct ~= "[]"
        warning([InportCell{i},' OutMin is not "[]"']);
    end

    if OutMax_Prdct ~= "[]"
        warning([InportCell{i},' OutMax is not "[]"']);
    end

end

% Check Data Type Conversion模块输出最大值最小值限值是否为空,输出输出类型是否为非继承
InportCell = find_system(bdroot,'BlockType','DataTypeConversion');  %获取顶层Inport模块路径
for i=1:length(InportCell)
    InportHandle = get_param(InportCell{i},'Handle');  %信号线句柄
    OutMin_DT = get_param(InportHandle,"OutMin");
    OutMax_DT = get_param(InportHandle,"OutMax");   
    OutDataTypeStr_DT = get_param(InportHandle,"OutDataTypeStr");
    if OutMin_DT ~= "[]"
        warning([InportCell{i},' OutMin is not "[]"']);
    end

    if OutMax_DT ~= "[]"
        warning([InportCell{i},' OutMax is not "[]"']);
    end

    if OutDataTypeStr_DT == "Inherit: Inherit via back propagation"
        warning([InportCell{i},' OutDataType Should not be "Inherit: Inherit via back propagation"']);
    end
end


end