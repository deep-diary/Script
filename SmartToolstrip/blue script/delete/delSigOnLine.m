function delSigOnLine(pathMd, varargin)
    % V1.0
    % 2023-9-5
    % Blue
    % MATLAB 2022b
    % Ŀ�ģ� ��ģ����������˿ڵ��ź��߽��з�����
    % ���룺 
    %   pathMd ģ��·��������Դ��ģ��·��A����ģ��B��������A��·������
    %   mode  ����������ͣ���ѡ��inport outport both partial��
    %   sigList  �ź��б�
    % ���أ� ��
    % ʹ��ʾ��  delSigOnLine(gcs)

    clc
    %% �����������
    p = inputParser;            % ���������������
    addParameter(p,'isEnableIn',true);      % ���ñ�������Ĭ�ϲ��� ��ѡ in, out
    addParameter(p,'isEnableOut',true);      % ���ñ�������Ĭ�ϲ��� ��ѡ in, out
    addParameter(p,'isPartial',false);      % 
    addParameter(p,'sigList',{});      % 

    parse(p,varargin{:});       % ������������н����������⵽ǰ��ı�������ֵ������±���ȡֵ
    isEnableIn = p.Results.isEnableIn;
    isEnableOut = p.Results.isEnableOut;
    isPartial = p.Results.isPartial;
    sigList = p.Results.sigList;


    %% �ҵ���Ч·��
    [ModelName, validPath] = findValidPath(pathMd);

    if isEnableIn
        InportCell = find_system(validPath,'SearchDepth',1,'BlockType','Inport');  %��ȡ����Inportģ��·��
        for i = 1:length(InportCell)  
            InportHandle = get_param(InportCell{i},'Handle');  %�ź��߾��
            LineHandleStruct = get(InportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Outport;
            
            if isPartial
                Name=get_param(LineHandle,'Name');  %����ź�������
                if ismember(Name,sigList)
                    set(LineHandle,'MustResolveToSignalObject',0)   %�����ź��߹���Simulink Signal Object
                end
            else
                set(LineHandle,'MustResolveToSignalObject',0)   %�����ź��߹���Simulink Signal Object
                set(LineHandle,'Name','')  %����ź�������
            end
        end
    end
    

    if isEnableOut
        OurportCell = find_system(validPath,'SearchDepth',1,'BlockType','Outport');  %��ȡ����Outportģ��·��
        for i = 1:length(OurportCell)  
            OutportHandle = get_param(OurportCell{i},'Handle');  %�ź��߾��
            LineHandleStruct = get(OutportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Inport;

            if isPartial
                Name=get_param(LineHandle,'Name');  %����ź�������
                if ismember(Name,sigList)
                    set(LineHandle,'MustResolveToSignalObject',0)   %�����ź��߹���Simulink Signal Object
                end
            else
                set(LineHandle,'MustResolveToSignalObject',0)   %�����ź��߹���Simulink Signal Object
                set(LineHandle,'Name','')  %����ź�������
            end
        end
    end

end