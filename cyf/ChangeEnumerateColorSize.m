function ChangeEnumerateColorSize
%% 显示Goto的GotoTag,修改大小颜色
    obj = find_system(bdroot,'MaskType','Enumerated Constant');
    for i = 1: length(obj)
        hd = get_param(obj{i},'Handle');
        Posn = get_param(hd,'Position');
        Posn(3) = Posn(1)+110;
        Posn(4) = Posn(2)+22;
        set_param(hd,'Position',Posn);
        set_param(hd,'BackgroundColor','cyan')

    end
    
end