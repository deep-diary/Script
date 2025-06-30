function DisplayConstantValue
    obj = find_system(gcs,'BlockType','Constant');
    for i = 1: length(obj)
        hd = get_param(obj{i},'Handle');
        value = get_param(hd,'Value');
        if isempty(str2num(value))
            set_param(hd,'AttributesFormatString','%<Value>');
            Posn = get_param(hd,'Position');
            Posn(3) = Posn(1)+30;
            Posn(4) = Posn(2)+18;
            set_param(hd,'Position',Posn);
            set_param(hd,'BackgroundColor','cyan')
        end
        
    end
end