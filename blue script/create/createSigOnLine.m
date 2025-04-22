function createSigOnLine(pathMd, varargin)
%CREATESIGONLINE ��ģ����������˿ڵ��ź����Ͻ����ź�����
%   createSigOnLine(pathMd) ��ָ��ģ��·���µ���������˿��ź��߽������ã�
%   �����ź����ơ��������á����ݼ�¼�Ͳ��Ե�ȡ�
%
%   �������:
%       pathMd - ģ��·��
%
%   ��ѡ����:
%       'skipTrig' - �Ƿ����������źţ�Ĭ��Ϊfalse
%       'isEnableIn' - �Ƿ�������˿ڣ�Ĭ��Ϊtrue
%       'isEnableOut' - �Ƿ�������˿ڣ�Ĭ��Ϊtrue
%       'resoveValue' - �Ƿ����ΪSimulink�źŶ���Ĭ��Ϊfalse
%       'logValue' - �Ƿ��¼���ݣ�Ĭ��Ϊfalse
%       'testValue' - �Ƿ�����Ϊ���Ե㣬Ĭ��Ϊfalse
%
%   ʾ��:
%       createSigOnLine(gcs)
%       createSigOnLine(gcs, 'skipTrig', true, 'isEnableIn', true, 'isEnableOut', true, ...
%                      'resoveValue', false, 'logValue', false, 'testValue', false)
%
%   ����: ��ά�� (Blue Ge)
%   ����: 2023-09-05
%   �汾: 1.1

    try
        %% �����������
        p = inputParser;
        
        % ��Ӳ���������֤
        addParameter(p, 'skipTrig', false, @islogical);
        addParameter(p, 'isEnableIn', true, @islogical);
        addParameter(p, 'isEnableOut', true, @islogical);
        addParameter(p, 'resoveValue', true, @islogical);
        addParameter(p, 'logValue', false, @islogical);
        addParameter(p, 'testValue', false, @islogical);
        
        parse(p, varargin{:});
        
        % ��ȡ����ֵ
        skipTrig = p.Results.skipTrig;
        isEnableIn = p.Results.isEnableIn;
        isEnableOut = p.Results.isEnableOut;
        resoveValue = p.Results.resoveValue;
        logValue = p.Results.logValue;
        testValue = p.Results.testValue;
        
        %% ��֤ģ��·��
        [modelName, validPath] = findValidPath(pathMd);
        if isempty(validPath)
            error('��Ч��ģ��·��: %s', pathMd);
        end
        
        fprintf('��ʼ����ģ�� %s ���ź�������\n', modelName);
        
        %% ��������˿��ź���
        if isEnableIn
            try
                % ��ȡ����˿�
                inportCell = find_system(validPath, 'SearchDepth', 1, 'BlockType', 'Inport');
                if isempty(inportCell)
                    fprintf('����: δ�ҵ�����˿�\n');
                else
                    % ȷ����ʼ����
                    startIdx = 1;
                    if skipTrig
                        startIdx = 2;
                        fprintf('������һ�������ź�\n');
                    end
                    
                    % ����ÿ������˿�
                    for i = startIdx:length(inportCell)
                        try
                            % ��ȡ�˿���Ϣ
                            portName = get_param(inportCell{i}, 'Name');
                            portHandle = get_param(inportCell{i}, 'Handle');
                            
                            % ��ȡ�������ź�������
                            lineHandles = get(portHandle, 'LineHandles');
                            if ~isempty(lineHandles.Outport)
                                set(lineHandles.Outport, ...
                                    'Name', portName, ...
                                    'MustResolveToSignalObject', resoveValue, ...
                                    'DataLogging', logValue, ...
                                    'TestPoint', testValue);
                                fprintf('����������˿� %s ���ź���\n', portName);
                            end
                        catch ME
                            fprintf('����: ��������˿� %s ʱ��������: %s\n', ...
                                get_param(inportCell{i}, 'Name'), ME.message);
                        end
                    end
                end
            catch ME
                error('��������˿�ʱ��������: %s', ME.message);
            end
        end
        
        %% ��������˿��ź���
        if isEnableOut
            try
                % ��ȡ����˿�
                outportCell = find_system(validPath, 'SearchDepth', 1, 'BlockType', 'Outport');
                if isempty(outportCell)
                    fprintf('����: δ�ҵ�����˿�\n');
                else
                    % ����ÿ������˿�
                    for i = 1:length(outportCell)
                        try
                            % ��ȡ�˿���Ϣ
                            portName = get_param(outportCell{i}, 'Name');
                            portHandle = get_param(outportCell{i}, 'Handle');
                            
                            % ��ȡ�������ź�������
                            lineHandles = get(portHandle, 'LineHandles');
                            if ~isempty(lineHandles.Inport)
                                set(lineHandles.Inport, ...
                                    'Name', portName, ...
                                    'MustResolveToSignalObject', resoveValue, ...
                                    'DataLogging', logValue, ...
                                    'TestPoint', testValue);
                                fprintf('����������˿� %s ���ź���\n', portName);
                            end
                        catch ME
                            fprintf('����: ��������˿� %s ʱ��������: %s\n', ...
                                get_param(outportCell{i}, 'Name'), ME.message);
                        end
                    end
                end
            catch ME
                error('��������˿�ʱ��������: %s', ME.message);
            end
        end
        
        fprintf('�ź����������\n');
        
    catch ME
        error('�ź������ù����з�������: %s', ME.message);
    end
end