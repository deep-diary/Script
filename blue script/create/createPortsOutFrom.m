function [outCnt] = createPortsOutFrom(path, nameMd, varargin)
%% 貌似没找到对应的应用场景，后续可能会删除
% 目的: 通过当前路径的无用的From，这些from是模型的内部信号，通过这些信号，创建外部信号对用的输出端口
% 输入：
%       path: 当前路径
% 可选： step: 30

% 返回： outCnt：输出端口数量
% 范例： outCnt = createPortsOutFrom(gcs, 'TmRefriVlvCtrl')
% 作者： Blue.ge
% 日期： 20240320

    %% 清空命令区
    clc    
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'step',30);      % 设置变量名和默认参数
    addParameter(p,'posOut',[1000, 0]);      % 设置变量名和默认参数


    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    step = p.Results.step;
    posOut = p.Results.posOut;

    
    %% 找到无匹配的from
    uselessFrom = findUselessFrom('path',path);

    %% 遍历from
    outCnt = 0; % 记录已生成的输入端口数量
    for i=1:length(uselessFrom)
        % 确认输入端口位置
        posCent = [posOut(1), posOut(2) + outCnt*step, posOut(1), posOut(2) + outCnt*step];
        Pos = posCent + [-15 -7 15 7];
        % 获取输出端口名
        from = uselessFrom{i};
        sigNmLoc = get_param(from,'GotoTag');
        sigNmOut = findNameSigOut(sigNmLoc, nameMd);
        % 获取输出端口路径
        bkPath = [path '/' sigNmOut];
        % 生成输出端口
        h = add_block('built-in/Outport', bkPath, ...
          'MakeNameUnique','on', ...
          'Position', Pos);
        [dataType, ~, ~, ~, ~] = findNameType(sigNmOut);
        set_param(h, 'OutDataTypeStr', dataType);
        set_param(h,"BackgroundColor","orange");
        % 计数
        outCnt = outCnt + 1;
    end
end