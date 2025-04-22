function cnt = createStoreMem(path, template, varargin)
%CREATESTOREMEM 根据Excel模板批量创建Data Store Memory
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
%       cnt = createStoreMem(gcs, 'Template.xlsx')
%       cnt = createStoreMem(gcs, 'Template.xlsx', 'step', 30, 'posIn', [100, 100])
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-04-29
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        
        % 添加参数及其验证
        addParameter(p, 'step', 40, @isnumeric);
        addParameter(p, 'posIn', [0, 0], @(x) isnumeric(x) && numel(x) == 2);
        addParameter(p, 'sheet', 'Parameters', @ischar);
        addParameter(p, 'halfLen', 50, @isnumeric);
        
        parse(p, varargin{:});
        
        % 获取参数值
        step = p.Results.step;
        posIn = p.Results.posIn;
        sheet = p.Results.sheet;
        halfLen = p.Results.halfLen;
        
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
                
                % 计算位置
                posCent = [posIn(1), posIn(2) + cnt*step, posIn(1), posIn(2) + cnt*step];
                Pos = posCent + [-halfLen -15 halfLen 15];
                PosWrite = Pos + [-150 0 -150 0];
                PosDisplay = PosWrite + [-150 0 -150 0];
                PosRead = Pos + [150 0 150 0];
                posTerm = posCent + [-10 -10 10 10] + [250 0 250 0];
                
                % 获取模块参数
                Name = data.Name{1};
                DataType = data.DataType{1};
                IniValue = data.IniValue{1};
                
                %% 创建DataStoreMemory
                bkPath = [path '/DataStoreMemory'];
                hMem = add_block('built-in/DataStoreMemory', bkPath, ...
                    'MakeNameUnique', 'on', ...
                    'Position', Pos, ...
                    'DataStoreName', Name, ...
                    'OutDataTypeStr', DataType, ...
                    'InitialValue', IniValue);
                
                %% 创建DataStoreWrite
                bkPath = [path '/DataStoreWrite'];
                hWrite = add_block('built-in/DataStoreWrite', bkPath, ...
                    'MakeNameUnique', 'on', ...
                    'Position', PosWrite, ...
                    'DataStoreName', Name);
                
                %% 创建DataStoreRead
                bkRead = [path '/Read' Name];
                hRead = add_block('built-in/DataStoreRead', bkRead, ...
                    'MakeNameUnique', 'on', ...
                    'Position', PosRead, ...
                    'DataStoreName', Name);
                
                % 存储Read模块句柄
                hReadArr(i) = get(hRead).PortHandles.Outport;
                
                %% 创建Display模块
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
                
                cnt = cnt + 1;
                fprintf('已创建模块: %s\n', Name);
                
            catch ME
                warning('创建模块 %s 时发生错误: %s', data.Name{1}, ME.message);
            end
        end
        
        %% 创建MultiPortSwitch
        try
            length = ((cnt + 1) * step + 8)/2;
            posMult = [posIn(1), posIn(2), posIn(1), posIn(2)] + ...
                     [-10 -length 10 length] + [300 0 300 0];
            
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
        
        %% 创建按类型分组的DataStoreMemory
        try
            types = unique(dataTable.DataType, 'stable');
            
            for i = 1:length(types)
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
        
        fprintf('完成创建，共创建 %d 个模块\n', cnt);
        
    catch ME
        error('创建Data Store Memory过程中发生错误: %s', ME.message);
    end
end
