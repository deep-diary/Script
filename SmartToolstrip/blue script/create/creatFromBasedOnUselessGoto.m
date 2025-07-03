function  nums = creatFromBasedOnUselessGoto(varargin)
%%
% 目的: 根据没有匹配的goto模块，创建与之匹配的From模块
% 输入：
%       可选参数：
%       posBase： 横坐标，默认为 [0,0]
%       step： 信号间隔步长， 默认为30
% 返回：已经成功创建的记录数量
% 范例：numCreated = creatFromBasedOnUselessGoto('posBase', [12000,0])
% 说明：1. 打开输入输出子模型，2. 在命令窗口运行此函数
% 作者： Blue.ge
% 修改：ChenYuanfei
%        修改新建模块大小，颜色，显示GotoTag
% 日期： 20231031
%%
    clc
    %% 初始化
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
    % 输入参数处理
    addParameter(p,'posBase',[12000,0]);      % 设置变量名和默认参数 [9000 0]
    addParameter(p,'step',30);      % 设置变量名和默认参数
    addParameter(p,'path',gcs);      % 设置变量名和默认参数
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    stp = p.Results.step;
    posBase = p.Results.posBase;
    path = p.Results.path;
    nums = 0; % 记录已生成的输出端口数量

    % 找到没有用的Goto模块
    uselessGoto = findUselessGoto('path',path);
    for i=1:length(uselessGoto)
        tag = get_param(uselessGoto{i}, 'GotoTag');
        % 1. 初始化位置
        posX = posBase(1);
        posY = posBase(2) + (i-1)*stp;
        posFrom=[posX-15, posY-7.5, posX+15, posY+7.5]; % From 位置
        posX=posX+300;
        posTerm=[posX-10, posY-10, posX+10, posY+10]; % Terminator 位置

        % 2. 创建模块
        bkFrom = add_block('built-in/From', [path '/From'],'MakeNameUnique','on', ...
                              'Position',posFrom,'GotoTag',tag);
        bkTerm = add_block('built-in/Terminator', [path '/Terminator'],...
            'MakeNameUnique','on', 'Position', posTerm);
        set_param(bkFrom,'AttributesFormatString','%<GotoTag>');
        set_param(bkFrom,'BackgroundColor','magenta')
        % 3. add line
%         PortHdFrom = get_param(bkFrom, 'PortHandles');
%         portHdTerm = get_param(bkTerm, 'PortHandles');
%         add_line(path, PortHdFrom.Outport, portHdTerm.Inport, 'autorouting', 'on');
        hArray = [bkFrom, bkTerm];
        createLines(path,hArray)
        nums=nums+1;
    end

    
    
end
