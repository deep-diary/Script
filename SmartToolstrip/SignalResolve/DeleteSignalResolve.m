% 功能：取消所选子系统输入输出端口信号线的Signal类型对象
% 版本：V1.1
% 作者：Chen Yuanfei
% 日期：2025-6-25
function DeleteSignalResolve
InportCell = find_system(gcs,'SearchDepth',1,'BlockType','Inport');  %获取顶层Inport模块路径
for i = 1:length(InportCell)  
    InportHandle = get_param(InportCell{i},'Handle');  %信号线句柄
    LineHandleStruct = get(InportHandle,'LineHandles');
    LineHandle = LineHandleStruct.Outport;
    set(LineHandle,'MustResolveToSignalObject',0)
%     set(LineHandle,'Name','')  %清除信号线名称
end

OurportCell = find_system(gcs,'SearchDepth',1,'BlockType','Outport');  %获取顶层Outport模块路径
for i = 1:length(OurportCell)  
    OutportHandle = get_param(OurportCell{i},'Handle');  %信号线句柄
    LineHandleStruct = get(OutportHandle,'LineHandles');
    LineHandle = LineHandleStruct.Inport;
    set(LineHandle,'MustResolveToSignalObject',0)
%     set(LineHandle,'Name','')  %清除信号线名称
end
end