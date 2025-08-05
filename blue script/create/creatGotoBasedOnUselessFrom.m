function  nums = creatGotoBasedOnUselessFrom(varargin)
%%
% 目的: 根据没有匹配的from模块，创建与之匹配的Goto模块
% 输入：
%       可选参数：
%       posBase： 横坐标，默认为 [0,0]
%       step： 信号间隔步长， 默认为30
% 返回：已经成功创建的记录数量
% 范例：numCreated = creatGotoBasedOnUselessFrom('posBase', [12500,0])
% 说明：1. 打开输入输出子模型，2. 在命令窗口运行此函数
% 作者： Blue.ge
% 日期： 20231031
%%
    clc
    %% 初始化
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
    % 输入参数处理
    addParameter(p,'posBase',[13500,0]);      % 设置变量名和默认参数 [9000 0]
    addParameter(p,'step',30);      % 设置变量名和默认参数
    addParameter(p,'path',gcs);      % 设置变量名和默认参数
    addParameter(p,'type','ground');      % 设置变量名和默认参数 constant, ground
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    stp = p.Results.step;
    posBase = p.Results.posBase;
    path = p.Results.path;
    nums = 0; % 记录已生成的输出端口数量

    % 找到没有用的Goto模块
    uselessFrom = findUselessFrom('path',path);
    for i=1:length(uselessFrom)
        tag = get_param(uselessFrom{i}, 'GotoTag');
        [dataType, ~, ~, ~, ~] = findNameType(tag);

        % 1. 初始化位置
        posX = posBase(1);
        posY = posBase(2) + (i-1)*stp;
        posGnd=[posX-10, posY-10, posX+10, posY+10]; % Ground 位置
        posX=posX+300;
        posGoto=[posX-150, posY-10, posX+150, posY+10]; % Goto 位置

        % 2. 创建模块
        if strcmp(p.Results.type, 'constant')
            block = add_block('built-in/Constant', [path '/Constant'],...
                'MakeNameUnique','on', ...
                'Position', posGnd, ...
                'Value','0');
            if ~strcmp(dataType, 'Inherit: auto')
                set_param(block,'OutDataTypeStr',dataType)
            end
        else
            block = add_block('built-in/Ground', [path '/Ground'],...
                'MakeNameUnique','on', ...
                'Position', posGnd);
        end
        
        bkGoto = add_block('built-in/Goto', [path '/Goto'],'MakeNameUnique','on', ...
                              'Position',posGoto,'GotoTag',tag);

        
        % 3. add line
%         PortHdFrom = get_param(block, 'PortHandles');
%         portHdTerm = get_param(bkGoto, 'PortHandles');
%         add_line(path, PortHdFrom.Outport, portHdTerm.Inport, 'autorouting', 'on');
        
        hArray = [block, bkGoto];
        createLines(path,hArray)

        nums=nums+1;
    end

    
    
end
