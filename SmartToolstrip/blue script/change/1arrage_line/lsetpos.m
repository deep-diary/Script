function lsetpos(blockH, x, y, width, height)
% lsetpos(blockH, x, y, width, height)
% blockH 可以是 目标模块句柄，或者是 目标模块路径
% blockH 不能是 port 或者 line 的句柄
% width 和 height 必须 ≥ 0
 
% 入参合法性检查
% 如果 blockH 是句柄，则维度必须是1
% 如果 blockH 是目标模块路径，则是字符串
if ((length(blockH) > 1) && (~ischar(blockH)))
    errordlg('函数 lsetpos 的入参 blockH 的长度大于1','错误','creatmode');
end
if (width < 0)
    errordlg('错误信息：函数 lsetpos 的入参 width 小于0 ! 应 ≥ 0 ','错误','creatmode');
end
if (height < 0)
    errordlg('错误信息：函数 lsetpos 的入参 height 小于0 ! 应 ≥ 0 ','错误','creatmode');
end
 
set_param(blockH, 'Position', [x, y, x + width, y + height]);
 
end
 
 
