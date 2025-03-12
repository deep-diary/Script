function [inList, outList] = createPortsGotoUpdate(varargin)
%%
% 目的: 当系统使用From 方式新增信号后，这些From没有对应的goto, 因此，需要创建对应的Inport 及Goto
% 输入：
%       inList: 限制创建的输入信号
%       outList：限制创建的输出信号
%       inputStep：输入端口步长
%       outputStep：输出端口步长
% 返回：成功创建好的信号
% 范例： createPortsGotoUpdate(),
% 作者： Blue.ge
% 日期： 20231114
%%
    clc
    %% 初始化
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
    % 输入参数处理
    addParameter(p,'path',gcs);         % 设置变量名和默认参数 [0 0]
    addParameter(p,'wid',500);          % 设置变量名和默认参数
    addParameter(p,'mode','keep');      % mode: pre, tail, keep

    parse(p,varargin{:}); 

    path = p.Results.path;
    wid = p.Results.wid;
    mode = p.Results.mode;

    %% 为没有连线的子模型创建goto from
    createModGotoAll();

    %% 找到当前模型中无效的From
    uselessFrom = findUselessFrom('path',path);

    %% 找到输入端口的位置
    [maxInPos, maxOutPos] = findPortPos('path',path);
    %% 根据无效的From 创建 Inport Goto
    inList = {};
    for i=1:length(uselessFrom)
        name = get_param(uselessFrom{i}, 'GotoTag');
        inList = [inList name];
    end
    
    inList = unique(inList);
%     createPortsGoto('inList', inList, 'posIn',maxInPos(1:2) + [0 30])
    


    %% 找到当前模型中无效的 Goto
    uselessGoto = findUselessGoto();
    
    %% 根据无效的From 创建 Inport Goto
    outList = {};
    for i=1:length(uselessGoto)
        name = get_param(uselessGoto{i}, 'GotoTag');
        outList = [outList name];
    end
    
    %% 创建goto and ports
    createPortsGoto( ...
        'inList', inList, ...
        'outList', outList, ...
        'posOut',maxOutPos(1:2) + [0 30], ...
        'mode',mode)
    %% 改变模型大小
    changeModSize(gcs, 'wid', wid)
    
    createModGoto(path,'mode','both');
end

