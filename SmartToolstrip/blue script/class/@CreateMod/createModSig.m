function createModSig(pathMd, varargin)
%%
% Ŀ��: ��ģ����������˿ڵ��ź��߽��н��������䶨���ȫ�ֱ���
% ���룺
%       pathMd ģ��·����
%       mode  ����������ͣ���ѡ��inport  outport  both��
% ���أ�Null
% ������ 
% createModSig(gcs,'skipTrig',true,'isEnableIn',true,'isEnableOut',true,...
% 'resolveValue',false,'logValue',false,'testValue',false)
% ���ߣ� Blue.ge
% ���ڣ� 2023-9-5
%%
    clc
    %% �����������
    p = inputParser;            % ���������������
    addParameter(p,'skipTrig',true);      % ���ñ�������Ĭ�ϲ���
    addParameter(p,'isEnableIn',true);      % ���ñ�������Ĭ�ϲ��� ��ѡ true, false
    addParameter(p,'isEnableOut',true);      % ���ñ�������Ĭ�ϲ��� ��ѡ  true, false
    addParameter(p,'resolveValue',true);      % ���ñ�������Ĭ�ϲ��� ��ѡ  true, false
    addParameter(p,'logValue',false);      % ���ñ�������Ĭ�ϲ��� ��ѡ  true, false
    addParameter(p,'testValue',false);      % ���ñ�������Ĭ�ϲ��� ��ѡ  true, false
    addParameter(p,'dispName',true);      % ���ñ�������Ĭ�ϲ��� ��ѡ  true, false
    addParameter(p,'mode','both');      % ���ñ�������Ĭ�ϲ���
    parse(p,varargin{:});       % ������������н����������⵽ǰ��ı�������ֵ������±���ȡֵ


    skipTrig = p.Results.skipTrig;
    isEnableIn = p.Results.isEnableIn;
    isEnableOut = p.Results.isEnableOut;
    resolveValue = p.Results.resolveValue;
    logValue = p.Results.logValue;
    testValue = p.Results.testValue;
    dispName = p.Results.dispName;
    mode = p.Results.mode;

    % �źŽ���������Ҫ�����ź���
    if resolveValue
        dispName =true;
    end
    isEnableIn = false;
    isEnableOut = false;
   

    if strcmp(mode, 'inport')
        isEnableIn=true;
    end
    if strcmp(mode, 'outport')
        isEnableOut=true;
    end
    if strcmp(mode, 'both')
        isEnableIn=true;
        isEnableOut=true;
    end

    %% �ҵ�ģ�Ͷ˿�
    PortHandles = get_param(pathMd, 'PortHandles');
    inports = PortHandles.Inport;
    outports = PortHandles.Outport;
    %% �ҵ���Ч·��
    [ModelName, validPath] = findValidPath(pathMd);
    hPath = get_param(validPath, 'Handle');
    InportCell = find_system(hPath,'SearchDepth',1,'BlockType','Inport');  %��ȡ����Inportģ��·��
    OutportCell = find_system(hPath,'SearchDepth',1,'BlockType','Outport');  %��ȡ����Outportģ��·��
    %% �����ź�
    if isEnableIn
        for i = 1:length(inports)  % ����trig �˿�
            InportName = get_param(InportCell(i),'Name');  %����ģ������;  %����ģ������
            hLineOut = get_param(inports(i), 'Line');
            hLineIn = get_param(InportCell(i), 'LineHandles').Outport;
            hLine = [hLineOut hLineIn];
            if dispName
                set(hLine,'Name',InportName)  %�����ź�������Ϊ����ģ������
            else
                set(hLine,'Name','')  %�����ź�������Ϊ����ģ������
            end
            set(hLine,'MustResolveToSignalObject',resolveValue)   %�����ź��߹���Simulink Signal Object
            set(hLine,'DataLogging',logValue) 
            set(hLine,'TestPoint',testValue)
        end
    end
        
    if isEnableOut
        for i = 1:length(outports)  
            OutportName = get_param(OutportCell(i),'Name');  %����ģ������
            hLineOut = get_param(outports(i), 'Line');
            hLineIn = get_param(OutportCell(i), 'LineHandles').Outport;
            hLine = [hLineOut hLineIn];
            if dispName
                set(hLine,'Name',OutportName)  %�����ź�������Ϊ����ģ������
            else
                set(hLine,'Name','')  %�����ź�������Ϊ����ģ������
            end
            set(hLine,'MustResolveToSignalObject',resolveValue)   %�����ź��߹���Simulink Signal Object
            set(hLine,'DataLogging',logValue) 
            set(hLine,'TestPoint',testValue)
        end
    end
end