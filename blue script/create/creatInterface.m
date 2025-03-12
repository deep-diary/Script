function  numCreated = creatInterface(varargin)
%%
% 目的: 为输入输出interface创建调试接口。
% 输入：
%       excelFileName： 模板 excel 路径
%       sheetName：     表格中的sheet 名字
%       可选参数：posX： 横坐标，默认为100
% 返回：已经成功创建的记录数量
% 范例：numCreated = creatInterface(),
% 说明：1. 打开输入输出子模型，2. 在命令窗口运行此函数, 此函数支持4种模式
%       mode=0: 有正常的输入输出，则创建Inport Debug Outport
%       mode=1: 有输入，没有对应输出，则创建Inport and Terminator
%       mode=2: 有输出，没有对应输入，则创建Ground and Outport
%       mode=3: 一个输入，对应多个输出，则分别创建并自动连线
% 作者： Blue.ge
% 日期： 20230928
%%
    clc
%% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'excelFileName','Template_Interface.xlsx'); 
    addParameter(p,'sheetName','Inports Common'); 
    addParameter(p,'mode','inport');      % 设置变量名和默认参数 可选 in, out
    addParameter(p,'sigUse','in');      % 设置变量名和默认参数 可选 in, out
    addParameter(p,'posX',0);      % 设置变量名和默认参数
    addParameter(p,'posY',0);      % 设置变量名和默认参数
    addParameter(p,'gndBlock','Constant');      % 设置接地模式， 'Ground', Constant
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    excelFileName = p.Results.excelFileName;
    sheetName = p.Results.sheetName;
    mode = p.Results.mode;
    sigUse = p.Results.sigUse;
    posX = p.Results.posX;
    posY = p.Results.posY;
    gndBlock = p.Results.gndBlock;

%%
    NAStr = 'NA';
    [dataTable,sigin,sigout] = readExcelInterface(excelFileName, sheetName);
    posInit = [posX, posY]; % 输入端口起始位置

    
    numCreated = 0; % 记录已生成的记录数量
    isDifType = false;

    %% 查找输入重复的信号
    [~, siginDu, ~, ~] = findProcessedSig(sigin, NAStr);
    %% 输入输出一对一
    for i=1:length(sigin)
        if ismember(sigin{i}, siginDu)
            disp('-------------duplicate signal')
            type = 3; % 一个输入对应多个输出
            continue
        end
        if strcmp(sigin{i},NAStr) && strcmp(sigout{i},NAStr)
            continue
        
        elseif strcmp(sigout{i},NAStr)
            type = 1;  % 创建Inport and Terminator
        elseif strcmp(sigin{i},NAStr)
            type = 2;  % 创建Ground and Outport
        else
            type = 0;  % 正常模式，创建Inport Debug Outport
        end

        %% 获取输入输出类型

        if strcmp(mode, 'inport')
            IFType = findNameIFType(sigin{i});
            [TmInType,~,~,~,~] = findNameType(sigout{i});

            inType = IFType;
            outType = TmInType;
        elseif strcmp(mode, 'outport')
            [TmOutType,~,~,~,~] = findNameType(sigin{i});
            IFType = findNameIFType(sigout{i});

            inType = TmOutType;
            outType = IFType;
        else
            error('pls input the right mode, valide name is: inport, outport')
        end
        
        % 判断输入输出类型是否一致，不一致，isDifType = true
        if type == 0 && ~strcmp(inType, outType)
            isDifType = true;
        else
            isDifType = false;
        end


        % create block
        posXbase = posInit(1);
        posY = posInit(2) + 30*numCreated;

        %% type = 0 正常模式，创建Inport Debug Outport
        if type == 0
            %% 1. 创建inport 模块
            posX = posXbase -300;
            posIn = [posX-15 posY-7 posX+15 posY+7];
            % 尝试创建模块 built-in/Goto，built-in/Inport, built-in/From
            try
                bkIn = add_block('built-in/Inport', [gcs '/' sigin{i}], ...
                           'Position', posIn, 'OutDataTypeStr', inType);
            catch
                bkIn = add_block('built-in/Inport', [gcs '/' sigin{i}], 'MakeNameUnique','on',...
                           'Position', posIn, 'OutDataTypeStr', inType);
                set_param(bkIn, "BackgroundColor","green")
            end
            if strcmp(inType, 'Inherit: auto')
                set_param(bkIn, "BackgroundColor","red")
            end
    
            %% 2. 创建debug 模块
            posX = posXbase;
            posDb = [posX - 100 posY-10 posX+100 posY+10];
    %         if strcmp(sheetName, 'Inports')
            if strcmp(mode, 'inport')
                if strcmp(sigUse, 'out')
                    bkDb  = add_block('PCMULib/Interface/Indebug', [gcs '/InDebug'], ...
                        'MakeNameUnique','on','Position', posDb);
                else
                    bkDb  = add_block('PCMULib/Interface/IndebugRvs', [gcs '/InDebugRvs'], ...
                        'MakeNameUnique','on','Position', posDb);
                end
            elseif strcmp(mode, 'outport')  %strcmp(sheetName, 'Outports')
                if strcmp(sigUse, 'in')
                    bkDb  = add_block('PCMULib/Interface/Outdebug', [gcs '/OutDebug'], ...
                        'MakeNameUnique','on','Position', posDb);
                else
                    bkDb  = add_block('PCMULib/Interface/OutdebugRvs', [gcs '/OutDebugRvs'], ...
                        'MakeNameUnique','on','Position', posDb);
                end
            else
                error('pls input the right mode, valide name is: inport, outport')
            end
    
            %% 3. 创建outport 模块  
            posX = posXbase + 300;
            posOut = [posX-15 posY-7 posX+15 posY+7];
            % 这里增加'MakeNameUnique','on',是因为有些信号，有输出，但interface没有输出 'MakeNameUnique','on',
            bkOut = add_block('built-in/Outport', [gcs '/' sigout{i}], ...
                   'Position', posOut, 'OutDataTypeStr', outType);
            if strcmp(outType, 'Inherit: auto')
                set_param(bkOut, "BackgroundColor","red")
            end

            %% 4. 创建 DataTypeConversion
            if isDifType && strcmp(mode, 'outport')
                posX = posXbase + 180;
                posCov = [posX-25 posY-7 posX+25 posY+7];
                bkCov  = add_block('built-in/DataTypeConversion', [gcs '/TypeConvs'], ...
                'MakeNameUnique','on','Position', posCov);
                if ~strcmp(outType, 'Inherit: auto')
                    set_param(bkCov,'OutDataTypeStr', outType)
                end
            elseif isDifType && strcmp(mode, 'inport')
                posX = posXbase - 180;
                posCov = [posX-25 posY-7 posX+25 posY+7];
                bkCov  = add_block('built-in/DataTypeConversion', [gcs '/TypeConvs'], ...
                'MakeNameUnique','on','Position', posCov);
                if ~strcmp(inType, 'Inherit: auto')
                    set_param(bkCov,'OutDataTypeStr', outType)
                end
            else

            end

            %% 5. add line
            if isDifType && strcmp(mode, 'outport')
                creatLines([bkIn bkDb bkCov bkOut])
            elseif isDifType && strcmp(mode, 'inport')
                creatLines([bkIn bkCov bkDb bkOut])
            else
                creatLines([bkIn bkDb bkOut])
            end


        %% type = 1 创建Inport and Terminator
        elseif type == 1
            %% 1. 创建inport 模块
            posX = posXbase -300;
            posIn = [posX-15 posY-7 posX+15 posY+7];
            % 尝试创建模块 built-in/Goto，built-in/Inport, built-in/From
            try
                bkIn = add_block('built-in/Inport', [gcs '/' sigin{i}], ...
                           'Position', posIn, 'OutDataTypeStr', inType);
            catch
                bkIn = add_block('built-in/Inport', [gcs '/' sigin{i}], 'MakeNameUnique','on',...
                           'Position', posIn, 'OutDataTypeStr', inType);
                set_param(bkIn, "BackgroundColor","green")
            end
            if strcmp(inType, 'Inherit: auto')
                set_param(bkIn, "BackgroundColor","red")
            end
            %% 2. 创建Terminator
            posX = posX + 300;
            posTerm = [posX-10 posY-10 posX+10 posY+10];
            % 这里增加'MakeNameUnique','on',是因为有些信号，有输出，但interface没有输出 'MakeNameUnique','on',
            bkTerm = add_block('built-in/Terminator', [gcs '/Terminator'], 'MakeNameUnique','on',...
                   'Position', posTerm);
                    % add line
    
    
            %% 3. 连线
            creatLines([bkIn bkTerm])

        %% mode = 2 创建Ground and Outport
        %% 1. 创建Ground
        elseif type==2
            posX = posXbase;
            posGround = [posX-10 posY-10 posX+10 posY+10];
            % 这里增加'MakeNameUnique','on',是因为有些信号，有输出，但interface没有输出 'MakeNameUnique','on',
            if strcmp(gndBlock, 'Ground')
                bkGround = add_block('built-in/Ground', [gcs '/Ground'], 'MakeNameUnique','on',...
                       'Position', posGround);
            elseif strcmp(gndBlock, 'Constant')
                bkGround = add_block('built-in/Constant', [gcs '/Constant'], 'MakeNameUnique','on',...
                       'Position', posGround, 'Value', '0');
                if strcmp(outType, 'Inherit: auto')
                    set_param(bkGround, "OutDataTypeStr",'Inherit: Inherit via back propagation')
                else
                    set_param(bkGround, "OutDataTypeStr",outType)
                end
                
            else
                error('pls input the right gndBlock. the valiable choose is Constant, Ground')
            end
    
            %% 2. 创建outport 模块  
            posX = posXbase + 300;
            posOut = [posX-15 posY-7 posX+15 posY+7];
            % 这里增加'MakeNameUnique','on',是因为有些信号，有输出，但interface没有输出 'MakeNameUnique','on',
            bkOut = add_block('built-in/Outport', [gcs '/' sigout{i}], ...
                   'Position', posOut, 'OutDataTypeStr', outType);
            if strcmp(outType, 'Inherit: auto')
                set_param(bkOut, "BackgroundColor","red")
            end
            %% 3. add line
            creatLines([bkGround bkOut])
        end
        
        numCreated = numCreated + 1;
    end



    %% 输入输出一对二
    for i=1:length(siginDu)

        %% 获取输入输出类型

        if strcmp(mode, 'inport')
            IFType = findNameIFType(siginDu{i});
            inType = IFType;
            
        elseif strcmp(mode, 'outport')
            [TmOutType,~,~,~,~] = findNameType(siginDu{i});
            inType = TmOutType;
            
        else
            error('pls input the right mode, valide name is: inport, outport')
        end

        %% create block
        posXbase = posInit(1);
        posY = posInit(2) + 30*numCreated;
        
        %% 创建inport 模块
        posX = posXbase -300;
        posIn = [posX-15 posY-7 posX+15 posY+7];
        % 尝试创建模块 built-in/Goto，built-in/Inport, built-in/From
        try
            bkIn = add_block('built-in/Inport', [gcs '/' siginDu{i}], ...
                       'Position', posIn, 'OutDataTypeStr', inType);
        catch
            bkIn = add_block('built-in/Inport', [gcs '/' siginDu{i}], 'MakeNameUnique','on',...
                       'Position', posIn, 'OutDataTypeStr', inType);
            set_param(bkIn, "BackgroundColor","green")
        end
        if strcmp(inType, 'Inherit: auto')
            set_param(bkIn, "BackgroundColor","red")
        end

        %% 得到输出索引
        [m,n] = find(strcmp(sigin,siginDu{i}));

%         %% 创建debug 模块
%         posX = posXbase;
%         posDb = [posX - 100 posY-10 posX+100 posY+10];
%         if strcmp(mode, 'inport')
%             if strcmp(sigUse, 'out')
%                 bkDb  = add_block('PCMULib/Interface/Indebug', [gcs '/InDebug'], ...
%                     'MakeNameUnique','on','Position', posDb);
%             else
%                 bkDb  = add_block('PCMULib/Interface/IndebugRvs', [gcs '/InDebugRvs'], ...
%                     'MakeNameUnique','on','Position', posDb);
%             end
%         elseif strcmp(mode, 'outport')  %strcmp(sheetName, 'Outports')
%             if strcmp(sigUse, 'in')
%                 bkDb  = add_block('PCMULib/Interface/Outdebug', [gcs '/OutDebug'], ...
%                     'MakeNameUnique','on','Position', posDb);
%             else
%                 bkDb  = add_block('PCMULib/Interface/OutdebugRvs', [gcs '/OutDebugRvs'], ...
%                     'MakeNameUnique','on','Position', posDb);
%             end
%         else
%             error('pls input the right mode, valide name is: inport, outport')
%         end
        %% 遍历输出信号
        for j=1:length(m)
         % 获取输入输出类型
        
            if strcmp(mode, 'inport')
                [TmInType,~,~,~,~] = findNameType(sigout{m(j)});
                outType = TmInType;
                
            elseif strcmp(mode, 'outport')
                IFType = findNameIFType(sigout{m(j)});
                 outType = IFType;
                
            else
                error('pls input the right mode, valide name is: inport, outport')
            end
            
            % 判断输入输出类型是否一致，不一致，isDifType = true
            if ~strcmp(inType, outType)
                isDifType = true;
            else
                isDifType = false;
            end


%             posXbase = posInit(1);
            posY = posInit(2) + 30*numCreated;
            %% 判断base输出信号，是否有对应的interface 信号
            if strcmp(sigout{m(j)}, NAStr)  % '#N/A' 这个会被解析成空
%             if  isempty(sigout{m(j)})
                % 创建输入，在接Terminator，直接返回
                posX = posXbase;
                posOut = [posX-10 posY-10 posX+10 posY+10];
                % 这里增加'MakeNameUnique','on',是因为有些信号，有输出，但interface没有输出 'MakeNameUnique','on',
                bkTerm = add_block('built-in/Terminator', [gcs '/Terminator'], 'MakeNameUnique','on',...
                       'Position', posOut);
                % add line
                creatLines([bkIn bkTerm])

                numCreated = numCreated + 1;
                continue
            end
             %% 创建debug 模块
            posX = posXbase;
            posDb = [posX - 100 posY-10 posX+100 posY+10];
            if strcmp(mode, 'inport')
                if strcmp(sigUse, 'out')
                    bkDb  = add_block('PCMULib/Interface/Indebug', [gcs '/InDebug'], ...
                        'MakeNameUnique','on','Position', posDb);
                else
                    bkDb  = add_block('PCMULib/Interface/IndebugRvs', [gcs '/InDebugRvs'], ...
                        'MakeNameUnique','on','Position', posDb);
                end
            elseif strcmp(mode, 'outport')  %strcmp(sheetName, 'Outports')
                if strcmp(sigUse, 'in')
                    bkDb  = add_block('PCMULib/Interface/Outdebug', [gcs '/OutDebug'], ...
                        'MakeNameUnique','on','Position', posDb);
                else
                    bkDb  = add_block('PCMULib/Interface/OutdebugRvs', [gcs '/OutDebugRvs'], ...
                        'MakeNameUnique','on','Position', posDb);
                end
            else
                error('pls input the right mode, valide name is: inport, outport')
            end
        
    
            %% 创建outport 模块  
            posX = posXbase + 300;
            posOut = [posX-15 posY-7 posX+15 posY+7];
            % 这里增加'MakeNameUnique','on',是因为有些信号，有输出，但interface没有输出 'MakeNameUnique','on',
            bkOut = add_block('built-in/Outport', [gcs '/' sigout{m(j)}], ...
                   'Position', posOut, 'OutDataTypeStr', outType);
            if strcmp(outType, 'Inherit: auto')
                set_param(bkOut, "BackgroundColor","red")
            end

            %% 4. 创建 DataTypeConversion
            if isDifType && strcmp(mode, 'outport')
                posX = posXbase + 180;
                posCov = [posX-25 posY-7 posX+25 posY+7];
                bkCov  = add_block('built-in/DataTypeConversion', [gcs '/TypeConvs'], ...
                'MakeNameUnique','on','Position', posCov);
                if ~strcmp(outType, 'Inherit: auto')
                    set_param(bkCov,'OutDataTypeStr', outType)
                end
            elseif isDifType && strcmp(mode, 'inport')
                posX = posXbase - 180;
                posCov = [posX-25 posY-7 posX+25 posY+7];
                bkCov  = add_block('built-in/DataTypeConversion', [gcs '/TypeConvs'], ...
                'MakeNameUnique','on','Position', posCov);
                if ~strcmp(inType, 'Inherit: auto')
                    set_param(bkCov,'OutDataTypeStr', outType)
                end
            else

            end

            %% add line
%             creatLines([bkIn bkDb bkOut])
            if isDifType && strcmp(mode, 'outport')
                creatLines([bkIn bkDb bkCov bkOut])
            elseif isDifType && strcmp(mode, 'inport')
                creatLines([bkIn bkCov bkDb bkOut])
            else
                creatLines([bkIn bkDb bkOut])
            end

            numCreated = numCreated + 1;
    
        end
       
    end

end
