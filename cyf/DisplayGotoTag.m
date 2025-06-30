function DisplayGotoTag
%% 显示Goto的GotoTag,修改大小颜色
    obj = find_system(bdroot,'BlockType','Goto');
    for i = 1: length(obj)
        hd = get_param(obj{i},'Handle');
        value = get_param(hd,'GotoTag');
        if isempty(str2num(value))
            set_param(hd,'AttributesFormatString','%<GotoTag>');
            Posn = get_param(hd,'Position');
            Posn(3) = Posn(1)+30;
            Posn(4) = Posn(2)+15;
            set_param(hd,'Position',Posn);
            set_param(hd,'BackgroundColor','magenta')
        end
        
    end
%% 显示From的GotoTag,修改大小颜色
    obj = find_system(bdroot,'BlockType','From');
    for i = 1: length(obj)
        hd = get_param(obj{i},'Handle');
        value = get_param(hd,'GotoTag');
        if isempty(str2num(value))
            set_param(hd,'AttributesFormatString','%<GotoTag>');
            Posn = get_param(hd,'Position');
            Posn(3) = Posn(1)+30;
            Posn(4) = Posn(2)+15;
            set_param(hd,'Position',Posn);
            set_param(hd,'BackgroundColor','yellow')
        end
        
    end
    
end