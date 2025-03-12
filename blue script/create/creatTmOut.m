function  nums = creatTmOut(varargin)
%%
% 目的: 将内部信号转换为base模块的输出信号，1. 信号名的转变； 2. 增加data storage 模块，用于信号隔离
% 输入：
%       可选参数：
%       posBase： 横坐标，默认为 [0,0]
%       NAStr： 无信号标识， 默认为'NA'
%       step： 信号间隔步长， 默认为30
% 返回：已经成功创建的记录数量
% 范例：numCreated = creatTmOut('sheetNames',{'IF_OutportsCommon','IF_OutportsDiag','IF_Outports2F'})
% 说明：1. 打开输入输出子模型，2. 在命令窗口运行此函数
% 作者： Blue.ge
% 日期： 20231030
%%
    clc
    
    %% 初始化
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
%     posBase = [0,0];     % 输出端口起始位置
    % 输入参数处理
    addParameter(p,'excelFileName','Template.xlsx'); 
    addParameter(p,'sheetNames',{'IF_OutportsCommon','IF_OutportsDiag','IF_Outports2F'}); 
    addParameter(p,'posBase',[0,0]);      % 设置变量名和默认参数 [9000 0]
    addParameter(p,'posMod',[10500,0,11000,5000]);      % 设置变量名和默认参数 [9000 0]
    addParameter(p,'NAStr','NA');      % 设置变量名和默认参数
    addParameter(p,'step',30);      % 设置变量名和默认参数
    addParameter(p,'gndBlock','Constant');      % 设置接地模式， 'Ground', Constant

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    excelFileName = p.Results.excelFileName;
    sheetNames = p.Results.sheetNames;
    NAStr = p.Results.NAStr;
    posMod = p.Results.posMod;
    posBase = p.Results.posBase;
    stp = p.Results.step;
    gndBlock = p.Results.gndBlock;
    
    %% 创建子模型框架
    name = 'TmBase2Out';
    path = [gcs '/' name];
    bk = add_block('built-in/SubSystem', path, ...
             'Name', name, 'Position', posMod);  
    open_system(path)

    %% 读取excel 数据
    nums = 0; % 记录已生成的输出端口数量
    for i=1:length(sheetNames)
        [data,~,~] = readExcelInterface(excelFileName, sheetNames{i});
        nameMod = data.Model;
        nameOut = data.SigIn;
        % 查找输入重复的信号

        validName = nameMod(~strcmp(nameMod, NAStr));
%         uniName = unique(validName);

        [~, siginDu, ~, ~] = findProcessedSig(validName, NAStr);


        %% 遍历所有单输入的信号
        for j=1: length(nameOut)
%         for j=1: 54
            % 如果输出信号为NAStr，则跳过             
            if strcmp(nameOut{j}, NAStr)
                continue
            end
            % 如果输入信号为重复信号，则跳过
            if ismember(nameMod{j}, siginDu)
                disp('-------------duplicate signal')
                continue
            end
            
            % 如果模型nameMod{j} 是NA，则创建Ground +  名为nameOut{j} 的Outport
            if strcmp(nameMod{j}, NAStr)
                % 0. 获取输出类型
                [outType,~,~,~,~] = findNameType(nameOut{j});



                % 1. 初始化位置
                posXbase = posBase(1);
                posY = posBase(2) + (nums-1)*stp;

                posX = posXbase;
                posGnd=[posX-10, posY-10, posX+10, posY+10]; % Ground 位置
                posX = posX + 300; % 向右偏移600
                posOut=[posX-14, posY-7, posX+14, posY+7]; % Outport 位置

                % 2. 创建接地模块
                if strcmp(gndBlock, 'Ground')
                    bkGround = add_block('built-in/Ground', [gcs '/Ground'], 'MakeNameUnique','on',...
                           'Position', posGnd);
                elseif strcmp(gndBlock, 'Constant')
                    bkGround = add_block('built-in/Constant', [gcs '/Constant'], 'MakeNameUnique','on',...
                           'Position', posGnd, 'Value', '0');
                    if strcmp(outType, 'Inherit: auto')
                        set_param(bkGround, "OutDataTypeStr",'Inherit: Inherit via back propagation')
                    else
                        set_param(bkGround, "OutDataTypeStr",outType)
                    end
                    
                else
                    error('pls input the right gndBlock. the valiable choose is Constant, Ground')
                end



                try
                    bkOut = add_block('built-in/Outport', [gcs '/' nameOut{j}], ...
                           'Position', posOut, 'OutDataTypeStr', outType);
                    if strcmp(outType, 'Inherit: auto')
                        set_param(bkOut, "BackgroundColor","red")
                    end
                catch
%                     bkOut = add_block('built-in/Outport', [gcs '/' nameOut{j}], 'MakeNameUnique','on',...
%                        'Position', posOut);
%                     set_param(bkOut, "BackgroundColor","green")

                    delete_block(bkGround)
                    nums = nums+1;
                    continue
                end

                % 3. add line
                creatLines([bkGround bkOut])

            else
                % 0. 获取输入输出信号
                [inType,~,~,~,~] = findNameType(nameMod{j});
                [outType,~,~,~,~] = findNameType(nameOut{j});
                if strcmp(inType, outType)
                    isDifType = false;
                else
                    isDifType = true;
                end

            % 如果模型nameMod{j} 不是NA，则创建gotoTag 为nameMod{j}的From + Signal Conversion + 名为nameOut{j} 的Outport 
                % 1. 初始化位置
                posXbase = posBase(1);
                posY = posBase(2) + (nums-1)*stp;
                
                posX = posXbase-300;
                posIn=[posX-14, posY-7, posX+14, posY+7]; % In 位置
                posX = posXbase; % 向左偏移300
                posCov=[posX-14, posY-7, posX+14, posY+7];  % Signal Conversion  位置
                posX = posXbase + 300; % 向右偏移300
                posOut=[posX-14, posY-7, posX+14, posY+7]; % Outport 位置

                posX = posXbase + 150; % 向右偏移450
                posTypeCov=[posX-25, posY-7, posX+25, posY+7]; % Outport 位置

                % 2. 创建模块
                bkIn = add_block('built-in/Inport', [gcs '/' nameMod{j}], ...
                       'Position', posIn, 'OutDataTypeStr', inType);
                if strcmp(inType, 'Inherit: auto')
                    set_param(bkIn, "BackgroundColor","red")
                end
                bkCov = add_block('built-in/SignalConversion', [gcs '/Conversion'], 'MakeNameUnique','on', ...
                  'Position', posCov);

                try
                    bkOut = add_block('built-in/Outport', [gcs '/' nameOut{j}], ...
                           'Position', posOut, 'OutDataTypeStr', outType);
                    if strcmp(outType, 'Inherit: auto')
                        set_param(bkOut, "BackgroundColor","red")
                    end
                catch
%                     bkOut = add_block('built-in/Outport', [gcs '/' nameOut{j}], 'MakeNameUnique','on',...
%                        'Position', posOut);
%                     set_param(bkOut, "BackgroundColor","green")

                    delete_block([bkIn,bkCov])
                    nums = nums+1;
                    continue
                end
                % 判断是否需要数据类型转换
                if isDifType
                    bkTypeCov  = add_block('built-in/DataTypeConversion', [gcs '/TypeConvs'], ...
                    'MakeNameUnique','on','Position', posTypeCov);
                    if ~strcmp(outType, 'Inherit: auto')
                        set_param(bkTypeCov,'OutDataTypeStr', outType)
                    end
                end


                % 3. add line
                if isDifType
                    creatLines([bkIn bkCov bkTypeCov bkOut])
                else
                    creatLines([bkIn bkCov bkOut])
                end
                
            end   
            nums = nums+1;
        end
%         nums=170; % for debug only
        %% 处理相同的信号
        for j=1:length(siginDu)
            % 0. 确认输入信号的数据类型
            [inType,~,~,~,~] = findNameType(siginDu{j});

            % 创建inport 模块
            posXbase = posBase(1);
            posY = posBase(2) + (nums-1)*stp;

            posX = posXbase-300;
            posIn=[posX-14, posY-7, posX+14, posY+7]; % Ground 位置
            bkIn = add_block('built-in/Inport', [gcs '/' siginDu{j}], ...
            'Position', posIn, 'OutDataTypeStr', inType);
            if strcmp(inType, 'Inherit: auto')
                set_param(bkIn, "BackgroundColor","red")
            end



            % 创建cov 和outport 模块
            % 得到输出索引
            [m,n] = find(strcmp(nameMod,siginDu{j}));
            for k=1:length(m)
                %  如果信号名字为NA，则直接返回
                name = nameOut{m(k)};
                if strcmp(name, NAStr)
                    continue
                end
                % 0. 确认输出信号的数据类型
                [outType,~,~,~,~] = findNameType(name);
                if strcmp(inType, outType)
                    isDifType = false;
                else
                    isDifType = true;
                end

                % 1. 确定位置
                posXbase = posBase(1);
                posY = posBase(2) + (nums-1)*stp;

                posX = posXbase;   
                posCov=[posX-14, posY-7, posX+14, posY+7];  % Signal Conversion  位置
                posX = posXbase + 300; % 向右偏移300
                posOut=[posX-14, posY-7, posX+14, posY+7]; % Outport 位置

                posX = posXbase + 150; % 向右偏移150
                posTypeCov=[posX-25, posY-7, posX+25, posY+7]; % Outport 位置

                % 2. 创建模块
                bkCov = add_block('built-in/SignalConversion', [gcs '/Conversion'], 'MakeNameUnique','on', ...
                  'Position', posCov);
                
                try % 输入输出都有重复
                    bkOut = add_block('built-in/Outport', [gcs '/' nameOut{m(k)}], ...
                           'Position', posOut, 'OutDataTypeStr', outType);
                    if strcmp(outType, 'Inherit: auto')
                        set_param(bkOut, "BackgroundColor","red")
                    end
                catch
%                     bkOut = add_block('built-in/Outport', [gcs '/' nameOut{m(k)}], 'MakeNameUnique','on',...
%                        'Position', posOut);
%                     set_param(bkOut, "BackgroundColor","green")

                    delete_block(bkCov)
                    nums = nums+1;
                    continue
                end

                % 判断是否需要数据类型转换
                if isDifType
                    bkTypeCov  = add_block('built-in/DataTypeConversion', [gcs '/TypeConvs'], ...
                    'MakeNameUnique','on','Position', posTypeCov);
                    if ~strcmp(outType, 'Inherit: auto')
                        set_param(bkTypeCov,'OutDataTypeStr', outType)
                    end
                end


                % 3. add line
                if isDifType
                    creatLines([bkIn bkCov bkTypeCov bkOut])
                else
                    creatLines([bkIn bkCov bkOut])
                end


                nums = nums+1;
            end
        end      
    end
    %% 改变模型大小
    changeModPos(path, posMod)
    %% 解析输出信号
    createSigOnLine(path, 'isEnableIn',false, 'resoveValue',true)
    %% 创建输入输出goto from
    createModGoto(path, 'mode','both');  % 创建输入输出端口
    
end
