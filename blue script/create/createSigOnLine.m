function createSigOnLine(pathMd, varargin)
%%
% Ŀ��: ��ģ����������˿ڵ��ź��߽��н��������䶨���ȫ�ֱ���
% ���룺
%       pathMd ģ��·����
%       mode  ����������ͣ���ѡ��inport  outport  both��
% ���أ�Null
% ������ 
% createSigOnLine(gcs,'skipTrig',true,'isEnableIn',true,'isEnableOut',true,...
% 'resoveValue',false,'logValue',false,'testValue',false)
% ���ߣ� Blue.ge
% ���ڣ� 2023-9-5
%%
    clc
    %% �����������
    p = inputParser;            % ���������������
    addParameter(p,'skipTrig',false);      % ���ñ�������Ĭ�ϲ���
    addParameter(p,'isEnableIn',true);      % ���ñ�������Ĭ�ϲ��� ��ѡ true, false
    addParameter(p,'isEnableOut',true);      % ���ñ�������Ĭ�ϲ��� ��ѡ  true, false
    addParameter(p,'resoveValue',false);      % ���ñ�������Ĭ�ϲ��� ��ѡ  true, false
    addParameter(p,'logValue',false);      % ���ñ�������Ĭ�ϲ��� ��ѡ  true, false
    addParameter(p,'testValue',false);      % ���ñ�������Ĭ�ϲ��� ��ѡ  true, false
    parse(p,varargin{:});       % ������������н����������⵽ǰ��ı�������ֵ������±���ȡֵ


    skipTrig = p.Results.skipTrig;
    isEnableIn = p.Results.isEnableIn;
    isEnableOut = p.Results.isEnableOut;
    resoveValue = p.Results.resoveValue;
    logValue = p.Results.logValue;
    testValue = p.Results.testValue;

        %% �ҵ���Ч·��
    [ModelName, validPath] = findValidPath(pathMd);

    if isEnableIn
        start=1;
        if skipTrig
            start = 2; % ����trig�ź�
        end
        InportCell = find_system(validPath,'SearchDepth',1,'BlockType','Inport');  %��ȡ����Inportģ��·��
        for i = start:length(InportCell)  % ����trig �˿�
            InportName = get_param(InportCell{i},'Name');  %����ģ������
            InportHandle = get_param(InportCell{i},'Handle');  %�ź��߾��
            LineHandleStruct = get(InportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Outport;
            set(LineHandle,'Name',InportName)  %�����ź�������Ϊ����ģ������
            set(LineHandle,'MustResolveToSignalObject',resoveValue)   %�����ź��߹���Simulink Signal Object
            set(LineHandle,'DataLogging',logValue) 
            set(LineHandle,'TestPoint',testValue)
        end
    end
        
    if isEnableOut
        OurportCell = find_system(validPath,'SearchDepth',1,'BlockType','Outport');  %��ȡ����Outportģ��·��
        for i = 1:length(OurportCell)  
            OutportName = get_param(OurportCell{i},'Name');  %����ģ������
            OutportHandle = get_param(OurportCell{i},'Handle');  %�ź��߾��
            LineHandleStruct = get(OutportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Inport;
            set(LineHandle,'Name',OutportName)  %�����ź�������Ϊ����ģ������
            set(LineHandle,'MustResolveToSignalObject',resoveValue)   %�����ź��߹���Simulink Signal Object
            set(LineHandle,'DataLogging',logValue) 
            set(LineHandle,'TestPoint',testValue)
        end
    end
end