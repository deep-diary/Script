function cnt = createStoreMem(path, template, varargin)
%%
% 目的:  根据excel模板，批量创建Data Store Memory
% 输入：
% path:     模型路径     
% template: 路径下的excel 文件名
% 可选： step: 30

% 返回： cnt：创建的端口数量
% 范例： [cnt] = createStoreMem(gcs,'Template_Sldd.xlsx')
% 作者： Blue.ge
% 日期： 20240429

    %% 清空命令区
    clc    
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'step',40);      % 设置变量名和默认参数
    addParameter(p,'posIn',[0, 0]);      % 设置变量名和默认参数
    addParameter(p,'sheet','Parameters');      % 设置变量名和默认参数
    addParameter(p,'halfLen',50);      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    step = p.Results.step;
    sheet = p.Results.sheet;
    posIn = p.Results.posIn;
    halfLen = p.Results.halfLen;

    %% 读取excel 模板内容

    dataTable = readSldd(template, 'sheet',sheet)


    %% 创建 Data Store Memory 并设置参数
    cnt = 0; % 记录已生成的输入端口数量
    sz = size(dataTable);
    hReadArr = zeros(1,sz(1))
    for i=1:sz(1)
        data = dataTable(i,:);
        % 确认输入端口位置
        posCent = [posIn(1), posIn(2) + cnt*step, posIn(1), posIn(2) + cnt*step];
        Pos = posCent + [-halfLen -15 halfLen 15];
        PosWrite = Pos+ [-150 0 -150 0];
        PosDisplay = PosWrite+ [-150 0 -150 0];
        PosRead = Pos+ [150 0 150 0];
        posTerm = posCent + [-10 -10 10 10] + [250 0 250 0];
        posMemAll = posCent + [-150 0 -150 0] + [500 0 500 0];
        
        % 生成输入端口
        Name = data.Name{1};
        DataType = data.DataType{1};
%         IniValue = num2str(data.IniValue)
        IniValue = data.IniValue{1};

        %% 创建DataStoreMemory
        bkPath = [path '/DataStoreMemory' ];
        hMem = add_block('built-in/DataStoreMemory', bkPath, ...
            'MakeNameUnique','on',...
            'Position', Pos, ...
            'DataStoreName',Name, ...
            'OutDataTypeStr', DataType, ...
            'InitialValue',IniValue);
        %% 创建 DataStoreWrite
        bkPath = [path '/DataStoreWrite'];
        hWrite = add_block('built-in/DataStoreWrite', bkPath, ...
            'MakeNameUnique','on',...
            'Position', PosWrite, ...
            'DataStoreName',Name);
        
        %% 创建 DataStoreRead
        bkRead = [path '/Read' Name];
        hRead = add_block('built-in/DataStoreRead', bkRead, ...
            'MakeNameUnique','on',...
            'Position', PosRead, ...
            'DataStoreName',Name);
        
        bkPath = [path '/Terminator' ];
%         hTerm = add_block('built-in/Terminator', bkPath,'MakeNameUnique','on', ...
%                           'Position', posTerm);
      
%         creatLines([hRead,hTerm])
        hReadArr(i) = get(hRead).PortHandles.Outport

        %% 创建 DisplayBloc
        bkPath = [path '/' Name];
        hDisplay = add_block('built-in/DisplayBlock', bkPath,'MakeNameUnique','on', ...
            'Position', PosDisplay);
        sig = Simulink.HMI.SignalSpecification;
        sig.BlockPath = bkRead;
        set_param(hDisplay,'Binding',sig)
        set_param(hDisplay,'LabelPosition','Hide')
        set_param(hDisplay,'BackgroundColor','[0.6, 0.6, 0.6]')


        %% 计数
        cnt = cnt + 1;
    end

    %% 创建 multiswitch
    length = ((cnt + 1 ) * step + 8)/2
    posMult = [posIn(1), posIn(2),posIn(1), posIn(2)] + [-10 -length 10 length] + [300 0 300 0];
    bkPath = [path '/MultiPortSwitch' ];
    hMultSw = add_block('built-in/MultiPortSwitch', bkPath,'MakeNameUnique','on', ...
        'Position', posMult);
    set_param(hMultSw,'Inputs',num2str(cnt))
    
    add_line(gcs,hReadArr,get(hMultSw).PortHandles.Inport(2:end),'autorouting', 'on')

    %% 创建 dataStoreMem All
    types = unique(dataTable.DataType,'stable');

    for i=1:size(types,1)
        %% 创建DataStoreMemory
        posCent = [posIn(1), posIn(2) + i*step, posIn(1), posIn(2) + i*step];
        posMemAll = posCent + [-halfLen -15 halfLen 15] + [500 0 500 0]
        type = types(i)
        bkPath = [path '/DataStoreMemory' ];
        idx = dataTable.DataType==type;
        data = dataTable(idx,:);
        Name = strcat(sheet,upper(type))

        numericArray = str2double(data.IniValue);
        IniValue = ['[', num2str(numericArray', '%d '), ']'];

        
        hMem = add_block('built-in/DataStoreMemory', bkPath, ...
            'MakeNameUnique','on',...
            'Position', posMemAll, ...
            'DataStoreName',Name, ...
            'OutDataTypeStr', type, ...
            'InitialValue',IniValue);
    end

    %% 创建 枚举变量
    Simulink.defineIntEnumType('ParametersUINT16', ...
    cellstr(data.Name), ...
    1:size(data.Name,1), ... 
    'Description', 'ParametersUINT16', ...
    'DefaultValue', 'cTmRefriVlvCtrl_n_u16BexvLmtCompSpdOffset', ...
    'HeaderFile', 'Type.h', ...
    'DataScope', 'Exported', ...
    'AddClassNameToEnumNames', true, ...
    'StorageType', 'int8');

    enumeration('ParametersUINT16')
    Parameters = ParametersUINT16.cTmRefriVlvCtrl_n_u16BexvLmtCompSpdOffset
    
end
