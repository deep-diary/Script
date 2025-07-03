function numCreated = creatInterface(varargin)
%CREATINTERFACE 创建接口调试模块
%   numCreated = creatInterface() 为输入输出接口创建调试模块，支持多种模式。
%
%   可选参数:
%       'template' - Excel模板文件名，默认为'Template.xlsx'
%       'sheetName' - 工作表名称，默认为'IF_InportsCommon'
%       'mode' - 模式选择，可选'inport'或'outport'，默认为'inport'
%       'sigUse' - 信号使用方式，可选'in'或'out'，默认为'in'
%       'posX' - 横坐标位置，默认为0
%       'posY' - 纵坐标位置，默认为0
%       'gndBlock' - 接地模块类型，可选'Ground'或'Constant'，默认为'Constant'
%
%   输出参数:
%       numCreated - 成功创建的信号数量
%
%   模式说明:
%       mode=0: 正常输入输出，创建Inport Debug Outport
%       mode=1: 有输入无输出，创建Inport和Terminator
%       mode=2: 有输出无输入，创建Ground和Outport
%       mode=3: 一个输入对应多个输出，分别创建并自动连线
%
%   示例:
%       numCreated = creatInterface()
%       numCreated = creatInterface('mode', 'outport', 'sheetName', 'IF_OutportsCommon')
%       numCreated = creatInterface('gndBlock', 'Ground', 'posX', 100)
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-06-28
%   版本: 1.1

    try
        %% 参数处理
        p = inputParser;
        
        % 添加参数及其验证
        addParameter(p, 'template', 'Template.xlsx', @ischar);
        addParameter(p, 'sheetName', 'IF_InportsCommon', @ischar);
        addParameter(p, 'mode', 'inport', @(x) any(strcmp(x, {'inport', 'outport'})));
        addParameter(p, 'sigUse', 'in', @(x) any(strcmp(x, {'in', 'out'})));
        addParameter(p, 'posX', 0, @isnumeric);
        addParameter(p, 'posY', 0, @isnumeric);
        addParameter(p, 'gndBlock', 'Constant', @(x) any(strcmp(x, {'Ground', 'Constant'})));
        
        parse(p, varargin{:});
        
        % 获取参数值
        template = p.Results.template;
        sheetName = p.Results.sheetName;
        mode = p.Results.mode;
        sigUse = p.Results.sigUse;
        posX = p.Results.posX;
        posY = p.Results.posY;
        gndBlock = p.Results.gndBlock;
        
        %% 验证Excel文件
        if ~exist(template, 'file')
            error('Excel模板文件不存在: %s', template);
        end
        
        %% 读取Excel数据
        NAStr = 'NA';
        [dataTable, sigin, sigout] = readExcelInterface(template, sheetName);
        if isempty(sigin) || isempty(sigout)
            error('Excel文件中没有找到有效的信号数据');
        end
        
        posInit = [posX, posY];
        numCreated = 0;
        
        %% 处理重复信号
        [~, siginDu, ~, ~] = findProcessedSig(sigin, NAStr);
        
        %% 处理一对一信号
        for i = 1:length(sigin)
            try
                % 跳过无效信号
                if strcmp(sigin{i}, NAStr) && strcmp(sigout{i}, NAStr)
                    continue;
                end
                
                % 确定信号类型
                if ismember(sigin{i}, siginDu)
                    type = 3; % 一个输入对应多个输出
                    continue;
                elseif strcmp(sigout{i}, NAStr)
                    type = 1; % 创建Inport和Terminator
                elseif strcmp(sigin{i}, NAStr)
                    type = 2; % 创建Ground和Outport
                else
                    type = 0; % 正常模式
                end
                
                % 获取信号类型
                [inType, outType, isDifType] = getSignalTypes(sigin{i}, sigout{i}, mode);
                
                % 创建模块
                posY = posInit(2) + 30 * numCreated;
                createSignalBlocks(type, sigin{i}, sigout{i}, inType, outType, isDifType, ...
                    posInit(1), posY, mode, sigUse, gndBlock);
                
                numCreated = numCreated + 1;
            catch ME
                warning(ME.identifier, '处理信号 %s 时发生错误: %s', sigin{i}, ME.message);
            end
        end
        
        %% 处理一对多信号
        for i = 1:length(siginDu)
            try
                % 获取输入类型
                if strcmp(mode, 'inport')
                    inType = findNameIFType(siginDu{i});
                else
                    [inType, ~, ~, ~, ~] = findNameType(siginDu{i});
                end
                
                % 创建输入模块
                posY = posInit(2) + 30 * numCreated;
                createInputBlock(siginDu{i}, inType, posInit(1), posY);
                
                % 处理多个输出
                [m, ~] = find(strcmp(sigin, siginDu{i}));
                for j = 1:length(m)
                    try
                        % 获取输出类型
                        if strcmp(mode, 'inport')
                            [outType, ~, ~, ~, ~] = findNameType(sigout{m(j)});
                        else
                            outType = findNameIFType(sigout{m(j)});
                        end
                        
                        % 创建输出模块
                        if ~strcmp(sigout{m(j)}, NAStr)
                            createOutputBlocks(siginDu{i}, sigout{m(j)}, inType, outType, ...
                                posInit(1), posY, mode, sigUse);
                            numCreated = numCreated + 1;
                        end
                    catch ME
                        warning(ME.identifier, '处理输出信号 %s 时发生错误: %s', sigout{m(j)}, ME.message);
                    end
                end
            catch ME
                warning(ME.identifier, '处理重复信号 %s 时发生错误: %s', siginDu{i}, ME.message);
            end
        end
        
        fprintf('成功创建 %d 个信号\n', numCreated);
        
    catch ME
        error('创建接口调试模块时发生错误: %s', ME.message);
    end
end

%% 辅助函数
function [inType, outType, isDifType] = getSignalTypes(sigin, sigout, mode)
    if strcmp(mode, 'inport')
        inType = findNameIFType(sigin);
        [outType, ~, ~, ~, ~] = findNameType(sigout);
    else
        [inType, ~, ~, ~, ~] = findNameType(sigin);
        outType = findNameIFType(sigout);
    end
    
    isDifType = ~strcmp(inType, outType);
end

function createSignalBlocks(type, sigin, sigout, inType, outType, isDifType, posXbase, posY, mode, sigUse, gndBlock)
    switch type
        case 0 % 正常模式
            createNormalBlocks(sigin, sigout, inType, outType, isDifType, posXbase, posY, mode, sigUse);
        case 1 % Inport和Terminator
            createInportTerminator(sigin, inType, posXbase, posY);
        case 2 % Ground和Outport
            createGroundOutport(sigout, outType, posXbase, posY, gndBlock);
    end
end

function createNormalBlocks(sigin, sigout, inType, outType, isDifType, posXbase, posY, mode, sigUse)
    % 创建输入端口
    posX = posXbase - 300;
    posIn = [posX-15 posY-7 posX+15 posY+7];
    bkIn = createBlockWithUniqueName('built-in/Inport', sigin, posIn, inType);
    
    % 创建调试模块
    posX = posXbase;
    posDb = [posX-100 posY-10 posX+100 posY+10];
    bkDb = createDebugBlock(mode, sigUse, posDb);
    
    % 创建输出端口
    posX = posXbase + 300;
    posOut = [posX-15 posY-7 posX+15 posY+7];
    bkOut = createBlockWithUniqueName('built-in/Outport', sigout, posOut, outType);
    
    % 创建类型转换模块（如果需要）
    if isDifType
        if strcmp(mode, 'outport')
            posX = posXbase + 180;
            posCov = [posX-25 posY-7 posX+25 posY+7];
            bkCov = createTypeConversionBlock(outType, posCov);
            creatLines([bkIn bkDb bkCov bkOut]);
        else
            posX = posXbase - 180;
            posCov = [posX-25 posY-7 posX+25 posY+7];
            bkCov = createTypeConversionBlock(outType, posCov);
            creatLines([bkIn bkCov bkDb bkOut]);
        end
    else
        creatLines([bkIn bkDb bkOut]);
    end
end

function createInportTerminator(sigin, inType, posXbase, posY)
    % 创建输入端口
    posX = posXbase - 300;
    posIn = [posX-15 posY-7 posX+15 posY+7];
    bkIn = createBlockWithUniqueName('built-in/Inport', sigin, posIn, inType);
    
    % 创建Terminator
    posX = posX + 300;
    posTerm = [posX-10 posY-10 posX+10 posY+10];
    bkTerm = createBlockWithUniqueName('built-in/Terminator', 'Terminator', posTerm, '');
    
    creatLines([bkIn bkTerm]);
end

function createGroundOutport(sigout, outType, posXbase, posY, gndBlock)
    % 创建Ground或Constant
    posX = posXbase;
    posGround = [posX-10 posY-10 posX+10 posY+10];
    if strcmp(gndBlock, 'Ground')
        bkGround = createBlockWithUniqueName('built-in/Ground', 'Ground', posGround, '');
    else
        bkGround = createBlockWithUniqueName('built-in/Constant', 'Constant', posGround, outType);
        set_param(bkGround, 'Value', '0');
    end
    
    % 创建输出端口
    posX = posXbase + 300;
    posOut = [posX-15 posY-7 posX+15 posY+7];
    bkOut = createBlockWithUniqueName('built-in/Outport', sigout, posOut, outType);
    
    creatLines([bkGround bkOut]);
end

function createInputBlock(sigin, inType, posXbase, posY)
    posX = posXbase - 300;
    posIn = [posX-15 posY-7 posX+15 posY+7];
    createBlockWithUniqueName('built-in/Inport', sigin, posIn, inType);
end

function createOutputBlocks(sigin, sigout, inType, outType, posXbase, posY, mode, sigUse)
    % 创建调试模块
    posX = posXbase;
    posDb = [posX-100 posY-10 posX+100 posY+10];
    bkDb = createDebugBlock(mode, sigUse, posDb);
    
    % 创建输出端口
    posX = posXbase + 300;
    posOut = [posX-15 posY-7 posX+15 posY+7];
    bkOut = createBlockWithUniqueName('built-in/Outport', sigout, posOut, outType);
    
    % 创建类型转换模块（如果需要）
    isDifType = ~strcmp(inType, outType);
    if isDifType
        if strcmp(mode, 'outport')
            posX = posXbase + 180;
            posCov = [posX-25 posY-7 posX+25 posY+7];
            bkCov = createTypeConversionBlock(outType, posCov);
            creatLines([bkDb bkCov bkOut]);
        else
            posX = posXbase - 180;
            posCov = [posX-25 posY-7 posX+25 posY+7];
            bkCov = createTypeConversionBlock(outType, posCov);
            creatLines([bkCov bkDb bkOut]);
        end
    else
        creatLines([bkDb bkOut]);
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

function bk = createDebugBlock(mode, sigUse, pos)
    if strcmp(mode, 'inport')
        if strcmp(sigUse, 'out')
            bk = add_block('PCMULib/Interface/Indebug', [gcs '/InDebug'], ...
                'MakeNameUnique', 'on', 'Position', pos);
        else
            bk = add_block('PCMULib/Interface/IndebugRvs', [gcs '/InDebugRvs'], ...
                'MakeNameUnique', 'on', 'Position', pos);
        end
    else
        if strcmp(sigUse, 'in')
            bk = add_block('PCMULib/Interface/Outdebug', [gcs '/OutDebug'], ...
                'MakeNameUnique', 'on', 'Position', pos);
        else
            bk = add_block('PCMULib/Interface/OutdebugRvs', [gcs '/OutDebugRvs'], ...
                'MakeNameUnique', 'on', 'Position', pos);
        end
    end
end

function bk = createTypeConversionBlock(outType, pos)
    bk = add_block('built-in/DataTypeConversion', [gcs '/TypeConvs'], ...
        'MakeNameUnique', 'on', 'Position', pos);
    if ~strcmp(outType, 'Inherit: auto')
        set_param(bk, 'OutDataTypeStr', outType);
    end
end
