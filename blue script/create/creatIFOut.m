function  creatIFOut(varargin)
%%
% 目的: 创建接口输入模型
% 输入：
%       可选参数：
%       pos： 横坐标，默认为 [12000,0]
% 返回：已经成功创建的记录数量
% 范例：creatIFOut('sheetNames',{'IF_OutportsCommon','IF_OutportsDiag','IF_Outports2F'})
% 说明：1. 打开输入输出子模型，2. 在命令窗口运行此函数
% 作者： Blue.ge
% 日期： 20231030
%%
    clc
    %% 参数处理
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
    % 输入参数处理
    addParameter(p,'pos',[12000,0]);      % 设置变量名和默认参数 [9000 0]
    addParameter(p,'excelFileName','Template.xlsx');                      % Interface 模板路径
    addParameter(p,'sheetNames',{'IF_OutportsCommon','IF_OutportsDiag','IF_Outports2F'});    % 输入表清单

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    pos = p.Results.pos;
    excelFileName = p.Results.excelFileName;
    sheetNames = p.Results.sheetNames;

    %% 创建模块
    name = 'TmOut';
    root = gcs;
    path = [root '/' name];
    posMd = [pos pos(1)+500 pos(2)+2000];
    bk = add_block('built-in/SubSystem', path, ...
             'Name', name, 'Position', posMd);  
%             set_param(bk, 'Position', pos)
    open_system(path)

    for i=1:length(sheetNames)
        posX = 1500 * (i-1);
        numCreated = creatInterface( ...
            'excelFileName',excelFileName,...
            'sheetName', sheetNames{i}, ...
            'posX', posX, ...
            'mode','outport', ...
            'sigUse','in');
        disp([num2str(numCreated),' signals have been created based on: ', sheetNames{1}, '/r/n' ])
    end
%     numCreated = creatInterface('sheetName', 'Outports Common','posX', 0, 'mode','outport', 'sigUse','in');
%     numCreated = creatInterface('sheetName', 'Outports Diag','posX', 1500, 'mode','outport', 'sigUse','in');
%     numCreated = creatInterface('sheetName', 'Outports 2F','posX', 3000, 'mode','outport', 'sigUse','in');
    changeModPos(path, pos)
    %% 信号解析
    createSigOnLine(path, ...
    'isEnableOut',false, ...
    'skipTrig',false, ...
    'resoveValue',true)

    %% 创建输入端口和输出Goto
    open_system(root)
    createModGoto(path,'mode','inport');
    createModPorts(path,'mode','outport');
%     createMode(gcb, ...
%         'inType','from', ...      % 可选参数 port, ground, from, const, none
%         'outType','port', ...       % 可选参数 port, term, goto, disp, none
%         'wid', 500,...              % 模块宽度
%         ...                         % 创建 ports 相关配置
%         'findType','interface',...       % 可选参数 base, interface, None
%         'add', 'None',...           % 可选参数 blockType, None, etc：SignalConversion
%         'isDelSuffix',false,...
%         'suffixStr','_in', ...
%         'enFirstTrig',false, ...
%         ...                         % 创建 goto from 相关配置
%         'inList', [], ...
%         'outList', [],...
%         'bkHalfLength', 100,...
%         ...                         % 创建 信号解析 相关配置
%         'skipTrig',false,...
%         'isEnableIn',false,...
%         'isEnableOut',false,...
%         'resoveValue',false,...
%         'logValue',false,...
%         'testValue',false,...
%         'dispName', false...
%         )
end
