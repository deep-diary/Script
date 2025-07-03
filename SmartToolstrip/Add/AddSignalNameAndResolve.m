% ���ܣ�������������˿�������ź�������������ΪSignal���Ͷ���
% ʾ��:
%      params = AddSignalNameAndResolve('port','Inport','resolve',true)
%      params = AddSignalNameAndResolve('port','both','resolve',false)
% �汾��V2.0
% ���ߣ�Chen Yuanfei
% ���ڣ�2025-6-26
function AddSignalNameAndResolve(varargin)
% �������������
p = inputParser;
expectedShapes = {'Inport','Outport','both'};
addParameter(p, 'port', 'both',@(x) any(validatestring(x,expectedShapes)));
addParameter(p, 'resolve', true, @islogical);

% �����������
parse(p, varargin{:});

% ��ȡ����ֵ
port = p.Results.port;
resolve = p.Results.resolve;

switch port

    case 'Inport'

        InportCell = find_system(gcs,'SearchDepth',1,'BlockType','Inport');  %��ȡ����Inportģ��·��
        for i = 1:length(InportCell)
            InportName = get_param(InportCell{i},'Name');  %����ģ������
            InportHandle = get_param(InportCell{i},'Handle');  %�ź��߾��
            LineHandleStruct = get(InportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Outport;
            set(LineHandle,'Name',InportName)  %�����ź�������Ϊ����ģ������
            if resolve == true
                set(LineHandle,'MustResolveToSignalObject',1)   %�����ź��߹���Simulink Signal Object
            end
        end
    case 'Outport'

        OurportCell = find_system(gcs,'SearchDepth',1,'BlockType','Outport');  %��ȡ����Outportģ��·��
        for i = 1:length(OurportCell)
            OutportName = get_param(OurportCell{i},'Name');  %����ģ������
            OutportHandle = get_param(OurportCell{i},'Handle');  %�ź��߾��
            LineHandleStruct = get(OutportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Inport;
            set(LineHandle,'Name',OutportName)  %�����ź�������Ϊ����ģ������
            if resolve == true
                set(LineHandle,'MustResolveToSignalObject',1)   %�����ź��߹���Simulink Signal Object
            end
        end
    otherwise
        InportCell = find_system(gcs,'SearchDepth',1,'BlockType','Inport');  %��ȡ����Inportģ��·��
        for i = 1:length(InportCell)
            InportName = get_param(InportCell{i},'Name');  %����ģ������
            InportHandle = get_param(InportCell{i},'Handle');  %�ź��߾��
            LineHandleStruct = get(InportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Outport;
            set(LineHandle,'Name',InportName)  %�����ź�������Ϊ����ģ������

            if resolve == true
                set(LineHandle,'MustResolveToSignalObject',1)   %�����ź��߹���Simulink Signal Object
            end
        end

        OurportCell = find_system(gcs,'SearchDepth',1,'BlockType','Outport');  %��ȡ����Outportģ��·��
        for i = 1:length(OurportCell)
            OutportName = get_param(OurportCell{i},'Name');  %����ģ������
            OutportHandle = get_param(OurportCell{i},'Handle');  %�ź��߾��
            LineHandleStruct = get(OutportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Inport;
            set(LineHandle,'Name',OutportName)  %�����ź�������Ϊ����ģ������
            if resolve == true
                set(LineHandle,'MustResolveToSignalObject',1)   %�����ź��߹���Simulink Signal Object
            end
        end
end

% %% ����װģ������ź������Signal����
% blockCell = find_system(gcs,'SearchDepth',1,'MaskType','Signal_In');
% for i = 1:length(blockCell)
%     blockHandle = get_param(blockCell{i},'Handle');
%     LineHandleStruct = get_param(blockHandle,'LineHandles');
%     LineHandle = LineHandleStruct.Outport;
%     blockConn = get_param(blockCell{i},'PortConnectivity');
% %     InportHandle = blockConn.SrcBlock;
% %     SrcName = get_param(InportHandle,'Name');
%     InportHandle = blockConn.DstBlock;
%     DstName = get_param(InportHandle,'Name');
% %     set(LineHandle,'Name',SrcName);
%     set(LineHandle,'Name',DstName);
%     set(LineHandle,'MustResolveToSignalObject',1)   %�����ź��߹���Simulink Signal Object
% 
% end
end
