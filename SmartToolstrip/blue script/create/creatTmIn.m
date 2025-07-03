function  nums = creatTmIn(varargin)
%%
% 目的: 将外部信号转换为base模块的输入信号，1. 信号名的转变； 2. 增加data storage 模块，用于信号隔离
% 输入：
%       可选参数：
%       posBase： 横坐标，默认为 [0,0]
%       NAStr： 无信号标识， 默认为'NA'
%       step： 信号间隔步长， 默认为30
% 返回：已经成功创建的记录数量
% 范例：numCreated = creatTmIn('sheetNames',{'IF_InportsCommon','IF_InportsDiag','IF_Inports2F'})
% 说明：1. 打开输入输出子模型，2. 在命令窗口运行此函数
% 作者： Blue.ge
% 日期： 20231030
%%
    clc
    %% 初始化
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
    posBase = [0,0];     % 输出端口起始位置
    % 输入参数处理
    addParameter(p,'excelFileName','Template.xlsx'); 
    addParameter(p,'sheetNames',{'Inports Common','Inports Diag','Inports 2F'}); 
    addParameter(p,'posBase',posBase);      % 设置变量名和默认参数 [9000 0]
    addParameter(p,'NAStr','NA');      % 设置变量名和默认参数
    addParameter(p,'step',30);      % 设置变量名和默认参数
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    NAStr = p.Results.NAStr;
    stp = p.Results.step;
    posBase = p.Results.posBase;
    excelFileName = p.Results.excelFileName;
    sheetNames = p.Results.sheetNames;


    %% 读取excel 数据
    nums = 0; % 记录已生成的输出端口数量

    for i=1:length(sheetNames)
        [data,~,~] = readExcelInterface(excelFileName, sheetNames{i});
        nameList = data.SigOut;

        % 查找输入重复的信号

        validName = nameList(~strcmp(nameList, NAStr));
%         uniName = unique(validName);

        siginDu = {};
        siginMono = {};
        for k=1:length(validName)

            if ~ismember(validName{k},siginMono)
                siginMono = [siginMono,validName{k}];
            else
                siginDu = [siginDu, validName{k}];
            end
        end
        siginDu=unique(siginDu,'stable');  % 去重并保持排序

        nameOut = validName;
        % 添加后缀 '_in'
        nameMod = cellfun(@(x) [x, '_in'], nameOut, 'UniformOutput', false);
        %% 遍历所有单输入的信号
        for j=1: length(validName)
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
                % 1. 初始化位置
                posX = posBase(1);
                posY = posBase(2) + (nums-1)*stp;
                posGnd=[posX-10, posY-10, posX+10, posY+10]; % Ground 位置
                posX = posX + 600; % 向右偏移600
                posOut=[posX-14, posY-7, posX+14, posY+7]; % Outport 位置

                % 2. 创建模块
                bkGround = add_block('built-in/Ground', [gcs '/Ground'], 'MakeNameUnique','on',...
                       'Position', posGnd);
                try
                    bkOut = add_block('built-in/Outport', [gcs '/' nameOut{j}], ...
                           'Position', posOut);
                catch
                    bkOut = add_block('built-in/Outport', [gcs '/' nameOut{j}], 'MakeNameUnique','on',...
                       'Position', posOut);
                    set_param(bkOut, "BackgroundColor","green")
%                     delete_block(bkGround)
%                     nums = nums+1;
%                     continue
                end

                % 3. add line
                PortHdGround = get_param(bkGround, 'PortHandles');
                portHdOut = get_param(bkOut, 'PortHandles');
                add_line(gcs, PortHdGround.Outport, portHdOut.Inport, 'autorouting', 'on');
            else
            % 如果模型nameMod{j} 不是NA，则创建gotoTag 为nameMod{j}的From + Signal Conversion + 名为nameOut{j} 的Outport 
                % 1. 初始化位置
                posX = posBase(1);
                posY = posBase(2) + (nums-1)*stp;
                posIn=[posX-14, posY-7, posX+14, posY+7]; % Ground 位置
                posX = posX + 300; % 向右偏移600
                posCov=[posX-14, posY-7, posX+14, posY+7];  % Signal Conversion  位置
                posX = posX + 300; % 向右偏移600
                posOut=[posX-14, posY-7, posX+14, posY+7]; % Outport 位置

                % 2. 创建模块
                bkIn = add_block('built-in/Inport', [gcs '/' nameMod{j}], ...
                       'Position', posIn);

                bkCov = add_block('built-in/SignalConversion', [gcs '/Conversion'], 'MakeNameUnique','on', ...
                  'Position', posCov);

                try
                    bkOut = add_block('built-in/Outport', [gcs '/' nameOut{j}], ...
                           'Position', posOut);
                catch
                    bkOut = add_block('built-in/Outport', [gcs '/' nameOut{j}], 'MakeNameUnique','on',...
                       'Position', posOut);
                    set_param(bkOut, "BackgroundColor","green")
%                     delete_block([bkIn,bkCov])
%                     nums = nums+1;
%                     continue
                end

                % 3. add line
                PortHdIn = get_param(bkIn, 'PortHandles');
                PortHdCov = get_param(bkCov, 'PortHandles');
                portHdOut = get_param(bkOut, 'PortHandles');
                add_line(gcs, PortHdIn.Outport, PortHdCov.Inport, 'autorouting', 'on');
                add_line(gcs, PortHdCov.Outport, portHdOut.Inport, 'autorouting', 'on');
            end   
            nums = nums+1;
        end
%         nums=170; % for debug only
        %% 处理相同的信号
        for j=1:length(siginDu)
            % 创建inport 模块
            posX = posBase(1);
            posY = posBase(2) + (nums-1)*stp;
            posIn=[posX-14, posY-7, posX+14, posY+7]; % Ground 位置
            bkIn = add_block('built-in/Inport', [gcs '/' siginDu{j}], ...
            'Position', posIn);

            % 创建cov 和outport 模块
            % 得到输出索引
            [m,n] = find(strcmp(nameMod,siginDu{j}));
            for k=1:length(m)
                % 1. 确定位置
                posX = posBase(1) + 300;
                posY = posBase(2) + (nums-1)*stp;

                posCov=[posX-14, posY-7, posX+14, posY+7];  % Signal Conversion  位置
                posX = posX + 300; % 向右偏移600
                posOut=[posX-14, posY-7, posX+14, posY+7]; % Outport 位置

                % 2. 创建模块
                bkCov = add_block('built-in/SignalConversion', [gcs '/Conversion'], 'MakeNameUnique','on', ...
                  'Position', posCov);
                
                try % 输入输出都有重复
                    bkOut = add_block('built-in/Outport', [gcs '/' nameOut{m(k)}], ...
                           'Position', posOut);
                catch
                    bkOut = add_block('built-in/Outport', [gcs '/' nameOut{m(k)}], 'MakeNameUnique','on',...
                       'Position', posOut);
                    set_param(bkOut, "BackgroundColor","green")
%                     delete_block(bkCov)
%                     nums = nums+1;
%                     continue
                end

                % 3. add line
                PortHdIn = get_param(bkIn, 'PortHandles');
                PortHdCov = get_param(bkCov, 'PortHandles');
                portHdOut = get_param(bkOut, 'PortHandles');
                add_line(gcs, PortHdIn.Outport, PortHdCov.Inport, 'autorouting', 'on');
                add_line(gcs, PortHdCov.Outport, portHdOut.Inport, 'autorouting', 'on');

                nums = nums+1;
            end
        end      
    end
    changeModSize(gcs)
end
