function posNew = changeModPos(pathMd, pos)
%%
    % 目的: 改变模型到特定的位置
    % 输入：
    %        pos： 新位置起始点 
    % 返回： newPos: 模型新位置
    % 范例： posNew = changeModPos(gcb, [1500 0])
    % 作者： Blue.ge
    % 日期： 20231113
    %%
    clc
    changeModSize(pathMd)
    h = get_param(pathMd, 'Handle');

    posOrg = get(h).Position;
    wid = posOrg(3) - posOrg(1);
    height = posOrg(4) - posOrg(2);
    posNew = [pos(1) pos(2) pos(1)+wid pos(2)+height];
    set_param(h, 'Position', posNew);

end