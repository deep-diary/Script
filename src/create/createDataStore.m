function cnt = createDataStore(varargin)
%CREATEDATASTORE 根据Excel模板批量创建Data Store Memory
%   cnt = createStoreMem(path, template) 根据指定的Excel模板在模型中批量创建
%   Data Store Memory、Data Store Write和Data Store Read模块。
%
%   输入参数:
%       path - 模型路径
%       template - Excel模板文件名
%
%   可选参数:
%       'step' - 模块之间的垂直间距，默认为40
%       'posIn' - 起始位置坐标，默认为[0, 0]
%       'sheet' - Excel工作表名称，默认为'Parameters'
%       'halfLen' - 模块宽度的一半，默认为50
%
%   输出参数:
%       cnt - 创建的模块数量
%
%   示例:
%       cnt = createDataStore('template', 'TemplateCDD.xlsx','createType', {'Memory'})
%       cnt = createDataStore('template', 'Template.xlsx', 'createType', {'Memory', 'Write', 'Read', 'Display', 'MultiPortSwitch'})
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2025-07-04
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        
        % 添加参数及其验证
        addParameter(p, 'step', 40, @isnumeric);
        addParameter(p, 'posIn', [0, 0], @(x) isnumeric(x) && numel(x) == 2);
        addParameter(p, 'path', gcs, @ischar);
        addParameter(p, 'template', 'Template.xlsx', @ischar);
        addParameter(p, 'sheet', 'DataStore', @ischar);
        addParameter(p, 'createType', {'Memory'}, @iscell); % 创建的类型，Memory、Write、Read、Display、MultiPortSwitch
        addParameter(p, 'createEnum', true, @islogical);
        addParameter(p, 'gap', 300, @isnumeric);
        addParameter(p, 'EnableIndexing', 'on', @ischar);
        addParameter(p, 'IndexMode', 'Zero-based', @ischar);
        
        parse(p, varargin{:});
        
        % 获取参数值
        step = p.Results.step;
        posIn = p.Results.posIn;
        path = p.Results.path;
        template = p.Results.template;
        sheet = p.Results.sheet;
        gap = p.Results.gap;
        createType = p.Results.createType;
        createEnum = p.Results.createEnum;
        EnableIndexing = p.Results.EnableIndexing;
        IndexMode = p.Results.IndexMode;

        
        %% 验证输入参数
        if ~exist(template, 'file')
            error('模板文件不存在: %s', template);
        end
        
        if ~bdIsLoaded(bdroot(path))
            error('模型未加载: %s', bdroot(path));
        end
        
        %% 读取Excel模板内容
        try
            dataTable = readSldd(template, 'sheet', sheet);
            if isempty(dataTable)
                error('Excel模板为空或格式不正确');
            end
            fprintf('成功读取Excel模板，共 %d 条记录\n', height(dataTable));
        catch ME
            error('读取Excel模板时发生错误: %s', ME.message);
        end
        
        %% 创建Data Store Memory模块
        cnt = 0; % 记录已生成的模块数量
        hReadArr = zeros(1, height(dataTable)); % 存储Read模块的句柄
        
        for i = 1:height(dataTable)
            try
                data = dataTable(i,:);

                % 获取模块参数
                Name = data.Name{1};
                halfLen = 3.5 * strlength(Name) ;
                DataType = data.DataType{1};
                IniValue = data.IniValue{1};
                Dimensions = data.Dimensions{1};
                
                % 计算位置

                posCent = [posIn(1), posIn(2) + cnt*step, posIn(1), posIn(2) + cnt*step];
                Pos = posCent + [-halfLen -15 halfLen 15];
                PosWrite = Pos + [-gap 0 -gap 0];
                PosDisplay = PosWrite + [-gap 0 -gap 0];
                PosRead = Pos + [gap 0 gap 0];
                posTerm = posCent + [-10 -10 10 10] + [gap 0 gap 0];
                

                
                %% 创建DataStoreMemory
                if any(strcmp(createType, 'Memory'))
                    bkPath = [path '/DataStoreMemory'];
                    hMem = add_block('built-in/DataStoreMemory', bkPath, ...
                        'MakeNameUnique', 'on', ...
                        'Position', Pos, ...
                        'DataStoreName', Name, ...
                        'OutDataTypeStr', DataType, ...
                        'InitialValue', IniValue, ...
                        'Dimensions', Dimensions, ...
                        'SignalType','Real');
                end

                %% 创建DataStoreWrite
                if any(strcmp(createType, 'Write'))
                    bkPath = [path '/DataStoreWrite'];
                    hWrite = add_block('built-in/DataStoreWrite', bkPath, ...
                        'MakeNameUnique', 'on', ...
                        'Position', PosWrite, ...
                        'DataStoreName', Name, ...
                        'EnableIndexing', EnableIndexing, ...
                        'IndexOptionArray',{'Index vector (port)'}, ...
                        'IndexMode',IndexMode);
                end
                
                %% 创建DataStoreRead
                if any(strcmp(createType, 'Read'))
                    bkRead = [path '/Read' Name];
                    hRead = add_block('built-in/DataStoreRead', bkRead, ...
                        'MakeNameUnique', 'on', ...
                        'Position', PosRead, ...
                        'DataStoreName', Name, ...
                        'EnableIndexing', EnableIndexing, ...
                        'IndexOptionArray',{'Index vector (port)'}, ...
                        'IndexMode',IndexMode);
                % 存储Read模块句柄
                hReadArr(i) = get(hRead).PortHandles.Outport; 
                end

                
                %% 创建Display模块
                if any(strcmp(createType, 'Display'))
                    bkPath = [path '/' Name];
                    hDisplay = add_block('built-in/DisplayBlock', bkPath, ...
                        'MakeNameUnique', 'on', ...
                        'Position', PosDisplay);
       
                    % 配置Display模块
                    sig = Simulink.HMI.SignalSpecification;
                    sig.BlockPath = bkRead;
                    set_param(hDisplay, 'Binding', sig);
                    set_param(hDisplay, 'LabelPosition', 'Hide');
                    set_param(hDisplay, 'BackgroundColor', '[0.6, 0.6, 0.6]');

                end
                
                cnt = cnt + 1;
                fprintf('已创建模块: %s\n', Name);
                
            catch ME
                warning('创建模块 %s 时发生错误: %s', data.Name{1}, ME.message);
            end
        end
        
        %% 创建MultiPortSwitch
        if any(strcmp(createType, 'MultiPortSwitch'))
            try
                length = ((cnt + 1) * step + 8)/2;
                posMult = [posIn(1), posIn(2), posIn(1), posIn(2)] + ...
                        [-10 -1.5*step 10 2 * length-1.5*step] + [gap*2 0 gap*2 0];
                
                bkPath = [path '/MultiPortSwitch'];
                hMultSw = add_block('built-in/MultiPortSwitch', bkPath, ...
                    'MakeNameUnique', 'on', ...
                    'Position', posMult);
                
                set_param(hMultSw, 'Inputs', num2str(cnt));
                add_line(gcs, hReadArr, get(hMultSw).PortHandles.Inport(2:end), ...
                        'autorouting', 'on');
                
                fprintf('已创建MultiPortSwitch模块\n');
            catch ME
                warning('创建MultiPortSwitch模块时发生错误: %s', ME.message);
            end
        end
        
        %% 创建按类型分组的DataStoreMemory
        try
            types = unique(dataTable.DataType, 'stable');
            
            for i = 1:strlength(types)
                type = types{i};
                posCent = [posIn(1), posIn(2) + i*step, posIn(1), posIn(2) + i*step];
                posMemAll = posCent + [-halfLen -15 halfLen 15] + [500 0 500 0];
                
                idx = strcmp(dataTable.DataType, type);
                data = dataTable(idx,:);
                Name = strcat(sheet, upper(type));
                
                % 转换初始值为数组格式
                numericArray = str2double(data.IniValue);
                IniValue = ['[', num2str(numericArray', '%d '), ']'];
                
                bkPath = [path '/DataStoreMemory'];
                hMem = add_block('built-in/DataStoreMemory', bkPath, ...
                    'MakeNameUnique', 'on', ...
                    'Position', posMemAll, ...
                    'DataStoreName', Name, ...
                    'OutDataTypeStr', type, ...
                    'InitialValue', IniValue);
                
                fprintf('已创建分组模块: %s\n', Name);
            end
        catch ME
            warning('创建分组模块时发生错误: %s', ME.message);
        end
        
        %% 创建枚举类型
        if createEnum
            try
                Simulink.defineIntEnumType('ParametersUINT16', ...
                    cellstr(dataTable.Name), ...
                    1:height(dataTable), ...
                    'Description', 'ParametersUINT16', ...
                    'DefaultValue', dataTable.Name{1}, ...
                    'HeaderFile', 'Type.h', ...
                    'DataScope', 'Exported', ...
                    'AddClassNameToEnumNames', true, ...
                    'StorageType', 'int8');
                
                fprintf('已创建枚举类型: ParametersUINT16\n');
            catch ME
                warning('创建枚举类型时发生错误: %s', ME.message);
            end
        end
        fprintf('完成创建，共创建 %d 个模块\n', cnt);
        
        
    catch ME
        error('创建Data Store Memory过程中发生错误: %s', ME.message);
    end
end

