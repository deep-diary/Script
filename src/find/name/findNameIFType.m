function type = findNameIFType(name)
%%
    % 目的: 根据信号名，获取对应的Interface信号类型
    % 输入：
    %       name： 信号名称
    % 返回： type: 信号类型
    % 范例： type = findNameIFType('IDT_AD4CoolReqForBkpUD_Ref')
    % 作者： Blue.ge
    % 日期： 20231108
%%
    try 
        paramValue = evalin('base', ['IDT_' name '_Ref']);
        type = paramValue.BaseType;
    catch
        disp(['Unrecognized function or variable: ', 'IDT_' name '_Ref'])
        type = 'Inherit: auto';
    end
    

end