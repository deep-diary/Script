function [x, y, width, height] = lgetpos(blockH)
% [x, y, width, height] = lgetpos(目标模块句柄)
% 如果 目标模块句柄 是一个 port 的句柄，则 width 和 height 返回-1
 
% 入参合法性检查
if (length(blockH) > 1)
    errordlg('函数 lgetpos 的入参 blockH 的长度大于1','错误','creatmode');
end
 
pos = get_param(blockH, 'Position');
 
x = pos(1);
y = pos(2);
 
% 如果目标句柄是port的句柄，则pos只有两维，此时宽度和高度返回-1
if length(pos) == 4
    width = pos(3) - pos(1);
    height = pos(4) - pos(2);
else
    width = -1;
    height = -1;
end
 
end