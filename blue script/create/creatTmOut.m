function nums = creatTmOut(varargin)
%CREATTMOUT 创建内部信号到基础模块的输出信号转换
%   nums = creatTmOut() 将内部信号转换为基础模块的输出信号，包括信号名转换和信号隔离。
%
%   可选参数:
%       'excelFileName' - Excel模板文件名，默认为'Template.xlsx'
%       'sheetNames' - 工作表名称列表，默认为{'IF_OutportsCommon','IF_OutportsDiag','IF_Outports2F'}
%       'posBase' - 基础位置坐标，默认为[0,0]
%       'posMod' - 模块位置坐标，默认为[10500,0,11000,5000]
%       'NAStr' - 无信号标识，默认为'NA'
%       'step' - 信号间隔步长，默认为30
%       'gndBlock' - 接地模块类型，可选'Ground'或'Constant'，默认为'Constant'
%
%   输出参数:
%       nums - 成功创建的信号数量
%
%   示例:
%       nums = creatTmOut()
%       nums = creatTmOut('posBase', [1000,0], 'step', 40)
%       nums = creatTmOut('sheetNames', {'IF_OutportsCommon','IF_OutportsDiag'})
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-06-28
%   版本: 1.1

    try
        %% 参数处理
        p = inputParser;
        
        % 添加参数及其验证
        addParameter(p, 'excelFileName', 'Template.xlsx', @ischar);
        addParameter(p, 'sheetNames', {'IF_OutportsCommon','IF_OutportsDiag','IF_Outports2F'}, @iscell);
        addParameter(p, 'posBase', [0,0], @(x) isnumeric(x) && numel(x) == 2);
        addParameter(p, 'posMod', [10500,0,11000,5000], @(x) isnumeric(x) && numel(x) == 4);
        addParameter(p, 'NAStr', 'NA', @ischar);
        addParameter(p, 'step', 30, @(x) isnumeric(x) && x > 0);
        addParameter(p, 'gndBlock', 'Constant', @(x) any(strcmp(x, {'Ground', 'Constant'})));
        
        parse(p, varargin{:});
        
        % 获取参数值
        excelFileName = p.Results.excelFileName;
        sheetNames = p.Results.sheetNames;
        posBase = p.Results.posBase;
        posMod = p.Results.posMod;
        NAStr = p.Results.NAStr;
        step = p.Results.step;
        gndBlock = p.Results.gndBlock;
        
        %% 验证Excel文件
        if ~exist(excelFileName, 'file')
            error('Excel模板文件不存在: %s', excelFileName);
        end
        
        %% 创建子模型框架
        name = 'TmBase2Out';
        path = [gcs '/' name];
        try
            bk = add_block('built-in/SubSystem', path, ...
                'Name', name, 'Position', posMod);
            open_system(path);
        catch ME
            error('创建子系统时发生错误: %s', ME.message);
        end
        
        %% 处理每个工作表
        nums = 0;
        for i = 1:length(sheetNames)
            try
                % 读取Excel数据
                [data, ~, ~] = readExcelInterface(excelFileName, sheetNames{i});
                if isempty(data)
                    warning('工作表 %s 中没有找到数据', sheetNames{i});
                    continue;
                end
                
                nameMod = data.Model;
                nameOut = data.SigIn;
                
                % 处理有效信号
                validName = nameMod(~strcmp(nameMod, NAStr));
                [~, siginDu, ~, ~] = findProcessedSig(validName, NAStr);
                
                % 处理单输入信号
                nums = processSingleInputSignals(nameMod, nameOut, siginDu, NAStr, posBase, step, gndBlock, nums);
                
                % 处理重复信号
                nums = processDuplicateSignals(siginDu, nameMod, nameOut, NAStr, posBase, step, nums);
                
            catch ME
                warning(ME.identifier, '处理工作表 %s 时发生错误: %s', sheetNames{i}, ME.message);
            end
        end
        
        %% 调整模型位置和信号处理
        try
            changeModPos(path, posMod);
            createSigOnLine(path, 'isEnableIn', false, 'resoveValue', true);
            createModGoto(path, 'mode', 'both');
        catch ME
            warning(ME.identifier, '处理模型时发生错误: %s', ME.message);
        end
        
        fprintf('成功创建 %d 个信号\n', nums);
        
    catch ME
        error('创建输出信号转换时发生错误: %s', ME.message);
    end
end

%% 辅助函数
function nums = processSingleInputSignals(nameMod, nameOut, siginDu, NAStr, posBase, step, gndBlock, nums)
    for j = 1:length(nameOut)
        try
            % 跳过无效信号
            if strcmp(nameOut{j}, NAStr) || ismember(nameMod{j}, siginDu)
                continue;
            end
            
            % 处理无输入信号的情况
            if strcmp(nameMod{j}, NAStr)
                nums = createGroundOutport(nameOut{j}, posBase, step, gndBlock, nums);
            else
                nums = createSignalConversion(nameMod{j}, nameOut{j}, posBase, step, nums);
            end
        catch ME
            warning(ME.identifier, '处理信号 %s 时发生错误: %s', nameOut{j}, ME.message);
        end
    end
end

function nums = createGroundOutport(nameOut, posBase, step, gndBlock, nums)
    % 获取输出类型
    [outType, ~, ~, ~, ~] = findNameType(nameOut);
    
    % 计算位置
    posY = posBase(2) + (nums-1)*step;
    posX = posBase(1);
    
    % 创建接地模块
    posGnd = [posX-10, posY-10, posX+10, posY+10];
    if strcmp(gndBlock, 'Ground')
        bkGround = createBlockWithUniqueName('built-in/Ground', 'Ground', posGnd, '');
    else
        bkGround = createBlockWithUniqueName('built-in/Constant', 'Constant', posGnd, outType);
        set_param(bkGround, 'Value', '0');
    end
    
    % 创建输出端口
    posX = posX + 300;
    posOut = [posX-14, posY-7, posX+14, posY+7];
    try
        bkOut = createBlockWithUniqueName('built-in/Outport', nameOut, posOut, outType);
        creatLines([bkGround bkOut]);
        nums = nums + 1;
    catch
        delete_block(bkGround);
    end
end

function nums = createSignalConversion(nameMod, nameOut, posBase, step, nums)
    % 获取信号类型
    [inType, ~, ~, ~, ~] = findNameType(nameMod);
    [outType, ~, ~, ~, ~] = findNameType(nameOut);
    isDifType = ~strcmp(inType, outType);
    
    % 计算位置
    posY = posBase(2) + (nums-1)*step;
    posXbase = posBase(1);
    
    % 创建输入端口
    posX = posXbase - 300;
    posIn = [posX-14, posY-7, posX+14, posY+7];
    bkIn = createBlockWithUniqueName('built-in/Inport', nameMod, posIn, inType);
    
    % 创建信号转换模块
    posX = posXbase;
    posCov = [posX-14, posY-7, posX+14, posY+7];
    bkCov = createBlockWithUniqueName('built-in/SignalConversion', 'Conversion', posCov, '');
    
    % 创建输出端口
    posX = posXbase + 300;
    posOut = [posX-14, posY-7, posX+14, posY+7];
    try
        bkOut = createBlockWithUniqueName('built-in/Outport', nameOut, posOut, outType);
        
        % 创建类型转换模块（如果需要）
        if isDifType
            posX = posXbase + 150;
            posTypeCov = [posX-25, posY-7, posX+25, posY+7];
            bkTypeCov = createBlockWithUniqueName('built-in/DataTypeConversion', 'TypeConvs', posTypeCov, outType);
            creatLines([bkIn bkCov bkTypeCov bkOut]);
        else
            creatLines([bkIn bkCov bkOut]);
        end
        
        nums = nums + 1;
    catch
        delete_block([bkIn, bkCov]);
    end
end

function nums = processDuplicateSignals(siginDu, nameMod, nameOut, NAStr, posBase, step, nums)
    for j = 1:length(siginDu)
        try
            % 获取输入类型
            [inType, ~, ~, ~, ~] = findNameType(siginDu{j});
            
            % 创建输入端口
            posY = posBase(2) + (nums-1)*step;
            posX = posBase(1) - 300;
            posIn = [posX-14, posY-7, posX+14, posY+7];
            bkIn = createBlockWithUniqueName('built-in/Inport', siginDu{j}, posIn, inType);
            
            % 处理多个输出
            [m, ~] = find(strcmp(nameMod, siginDu{j}));
            for k = 1:length(m)
                try
                    name = nameOut{m(k)};
                    if strcmp(name, NAStr)
                        continue;
                    end
                    
                    nums = createDuplicateOutput(bkIn, name, posBase, step, nums);
                catch ME
                    warning(ME.identifier, '处理重复输出信号 %s 时发生错误: %s', name, ME.message);
                end
            end
        catch ME
            warning(ME.identifier, '处理重复输入信号 %s 时发生错误: %s', siginDu{j}, ME.message);
        end
    end
end

function nums = createDuplicateOutput(bkIn, name, posBase, step, nums)
    % 获取输出类型
    [outType, ~, ~, ~, ~] = findNameType(name);
    inType = get_param(bkIn, 'OutDataTypeStr');
    isDifType = ~strcmp(inType, outType);
    
    % 计算位置
    posY = posBase(2) + (nums-1)*step;
    posXbase = posBase(1);
    
    % 创建信号转换模块
    posX = posXbase;
    posCov = [posX-14, posY-7, posX+14, posY+7];
    bkCov = createBlockWithUniqueName('built-in/SignalConversion', 'Conversion', posCov, '');
    
    % 创建输出端口
    posX = posXbase + 300;
    posOut = [posX-14, posY-7, posX+14, posY+7];
    try
        bkOut = createBlockWithUniqueName('built-in/Outport', name, posOut, outType);
        
        % 创建类型转换模块（如果需要）
        if isDifType
            posX = posXbase + 150;
            posTypeCov = [posX-25, posY-7, posX+25, posY+7];
            bkTypeCov = createBlockWithUniqueName('built-in/DataTypeConversion', 'TypeConvs', posTypeCov, outType);
            creatLines([bkIn bkCov bkTypeCov bkOut]);
        else
            creatLines([bkIn bkCov bkOut]);
        end
        
        nums = nums + 1;
    catch
        delete_block(bkCov);
    end
end

function bk = createBlockWithUniqueName(blockType, name, pos, dataType)
    try
        bk = add_block(blockType, [gcs '/' name], 'Position', pos);
        if ~isempty(dataType)
            set_param(bk, 'OutDataTypeStr', dataType);
        end
    catch
        bk = add_block(blockType, [gcs '/' name], 'MakeNameUnique', 'on', 'Position', pos);
        if ~isempty(dataType)
            set_param(bk, 'OutDataTypeStr', dataType);
        end
        set_param(bk, 'BackgroundColor', 'green');
    end
    if strcmp(dataType, 'Inherit: auto')
        set_param(bk, 'BackgroundColor', 'red');
    end
end
