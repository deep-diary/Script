% ���ܣ�ȡ����ѡ��ϵͳ��������˿��ź��ߵ�Signal���Ͷ����ź���
% ʾ��:
%      params = DeleteSignalResolveAndName('port','Inport','DeleteName',true)
%      params = DeleteSignalResolveAndName('port','both','DeleteName',false)
% �汾��V2.0
% ���ߣ�Chen Yuanfei
% ���ڣ�2025-6-26
% �������������

function DeleteSignalResolveAndName(varargin)
p = inputParser;
expectedShapes = {'Inport','Outport','both'};
addParameter(p, 'port', 'both',@(x) any(validatestring(x,expectedShapes)));
addParameter(p, 'DeleteName', true, @islogical);

% �����������
parse(p, varargin{:});

% ��ȡ����ֵ
port = p.Results.port;
DeleteName = p.Results.DeleteName;

switch port

    case 'Inport'

        InportCell = find_system(gcs,'SearchDepth',1,'BlockType','Inport');  %��ȡ����Inportģ��·��
        for i = 1:length(InportCell)
            InportHandle = get_param(InportCell{i},'Handle');  %�ź��߾��
            LineHandleStruct = get(InportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Outport;
            set(LineHandle,'MustResolveToSignalObject',0)

            if DeleteName == true
                set(LineHandle,'Name','')  %����ź�������
            end
        end

    case 'Outport'

        OurportCell = find_system(gcs,'SearchDepth',1,'BlockType','Outport');  %��ȡ����Outportģ��·��
        for i = 1:length(OurportCell)
            OutportHandle = get_param(OurportCell{i},'Handle');  %�ź��߾��
            LineHandleStruct = get(OutportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Inport;
            set(LineHandle,'MustResolveToSignalObject',0)

            if DeleteName == true
                set(LineHandle,'Name','')  %����ź�������
            end
        end

    otherwise
        InportCell = find_system(gcs,'SearchDepth',1,'BlockType','Inport');  %��ȡ����Inportģ��·��
        for i = 1:length(InportCell)
            InportHandle = get_param(InportCell{i},'Handle');  %�ź��߾��
            LineHandleStruct = get(InportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Outport;
            set(LineHandle,'MustResolveToSignalObject',0)

            if DeleteName == true
                set(LineHandle,'Name','')  %����ź�������
            end
        end

        OurportCell = find_system(gcs,'SearchDepth',1,'BlockType','Outport');  %��ȡ����Outportģ��·��
        for i = 1:length(OurportCell)
            OutportHandle = get_param(OurportCell{i},'Handle');  %�ź��߾��
            LineHandleStruct = get(OutportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Inport;
            set(LineHandle,'MustResolveToSignalObject',0)

            if DeleteName == true
                set(LineHandle,'Name','')  %����ź�������
            end
        end
end
end
