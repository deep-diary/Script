function delGcsAll()
%%
    % 目的: 删除本层内所有东西
    % 输入：
    %        Null  
    % 返回： Null
    % 范例： delGcsAll()
    % 引用： Null  
    % 作者： Blue.ge
    % 日期： 20231108
    %%
    clc
    blocks = find_system(gcs, 'SearchDepth', 1, 'Type', 'Block');
    delete_block(blocks)
    delUselessLine(gcs)
end
