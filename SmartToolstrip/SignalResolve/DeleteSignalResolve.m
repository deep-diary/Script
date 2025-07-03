% ���ܣ�ȡ����ѡ��ϵͳ��������˿��ź��ߵ�Signal���Ͷ���
% �汾��V1.1
% ���ߣ�Chen Yuanfei
% ���ڣ�2025-6-25
function DeleteSignalResolve
InportCell = find_system(gcs,'SearchDepth',1,'BlockType','Inport');  %��ȡ����Inportģ��·��
for i = 1:length(InportCell)  
    InportHandle = get_param(InportCell{i},'Handle');  %�ź��߾��
    LineHandleStruct = get(InportHandle,'LineHandles');
    LineHandle = LineHandleStruct.Outport;
    set(LineHandle,'MustResolveToSignalObject',0)
%     set(LineHandle,'Name','')  %����ź�������
end

OurportCell = find_system(gcs,'SearchDepth',1,'BlockType','Outport');  %��ȡ����Outportģ��·��
for i = 1:length(OurportCell)  
    OutportHandle = get_param(OurportCell{i},'Handle');  %�ź��߾��
    LineHandleStruct = get(OutportHandle,'LineHandles');
    LineHandle = LineHandleStruct.Inport;
    set(LineHandle,'MustResolveToSignalObject',0)
%     set(LineHandle,'Name','')  %����ź�������
end
end