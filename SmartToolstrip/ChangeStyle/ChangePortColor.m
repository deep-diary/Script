% clear
% Inport底色改为橘色
function ChangePortColor
InportCell = find_system(bdroot,'BlockType','Inport');  %获取顶层Inport模块路径
for i=1:length(InportCell)
    InportHandle = get_param(InportCell{i},'Handle');  %信号线句柄
    set_param(InportHandle,"BackgroundColor","orange");
end
% Outport底色改为蓝色
OutportCell = find_system(bdroot,'BlockType','Outport');  %获取顶层Inport模块路径
for i=1:length(OutportCell)
    OutportHandle = get_param(OutportCell{i},'Handle');  %信号线句柄
    set_param(OutportHandle,"BackgroundColor","lightBlue");
end
end

