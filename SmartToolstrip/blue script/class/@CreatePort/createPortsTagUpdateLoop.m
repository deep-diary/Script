function [inList, outList] = createPortsTagUpdateLoop(varargin)
%%
% 目的: 当系统使用From 方式新增信号后，这些From没有对应的goto, 因此，需要循环创建对应的Inport 及Goto 知道根路径
% 输入：
%       inList: 限制创建的输入信号
%       outList：限制创建的输出信号
%       inputStep：输入端口步长
%       outputStep：输出端口步长
% 返回：成功创建好的信号
% 范例： createPortsTagpdateLoop(),
% 作者： Blue.ge
% 日期： 20231114
%%
    clc
    %% 初始化
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
    % 输入参数处理
    addParameter(p,'path',gcs);      % 设置变量名和默认参数 [0 0]

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    path = p.Results.path;

    
    %% 找到当前路径的父路径

    %% 循环判断父路径是不是bdroot
    while ~strcmp(path, bdroot)
        open_system(path)
        [inList, outList] = createPortsTagUpdate('path',path);
        parent = get_param(path, 'Parent');
        if strcmp(parent, bdroot)
            createModPorts(path,'mode','both');
            createSigOnLine(bdroot)
        else
            createModGoto(path,'mode','both');
        end
        path = get_param(path, 'Parent');
    end
    
end

