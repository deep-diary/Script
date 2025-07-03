function ChangeConstantColorSize
%% 显示Constant名称,修改大小颜色
    obj = find_system(bdroot,'BlockType','Constant');
    for i = 1: length(obj)
        hd = get_param(obj{i},'Handle');
        Posn = get_param(hd,'Position');
        Posn(3) = Posn(1)+30;
        Posn(4) = Posn(2)+15;
        Value = get_param(hd,'Value');
        set_param(hd,'Position',Posn);
        if isempty(regexp(Value, '^\d+$', 'once'))
            set_param(hd,'AttributesFormatString','%<Value>');
            set_param(hd,'BackgroundColor','green')
        end
    end
    
end
