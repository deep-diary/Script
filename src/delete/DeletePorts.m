function [inCnt, outCnt] = DeletePorts(template, model,varargin)
%%
% 目的: 从excel 模板中提取信息并创建输入输出端口
% 输入：
%       template: 路径下的excel 文件名
% 可选： step: 30

% 返回： inCnt, outCnt：输入输出端口数量
% 范例： [inCnt, outCnt] = DeletePorts('Template_PortsCreate', 'new_model')
% 作者： Blue.ge
% 日期： 20240426

    %% 清空命令区
    clc    
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器

    addParameter(p,'inRecognName','Inport');      % 设置变量名和默认参数
    addParameter(p,'outRecognName','Outport');      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    inRecognName = p.Results.inRecognName;
    outRecognName = p.Results.outRecognName;
    
    %% 读取excel 数据

    dataTable = readtable(template, 'Sheet', 'Signals');
    inportTab = dataTable(strcmp(dataTable.PortType, inRecognName),:);
    outportTab = dataTable(strcmp(dataTable.PortType, outRecognName),:);
    
    %% 检查创建模型是否已经打开，如果没有则新建并打开
    if ~bdIsLoaded(model)
        open_system(model); % 打开该模型
    end
    
    %% 删除输入端口
    inCnt = 0; % 记录已生成的输入端口数量
    sz = size(inportTab);
    for i=1:sz(1)
        data = inportTab(i,:);
        % 找到对应的端口
        h = find_system(bdroot,'Name',data.Name{1});
        if ~isempty(h)
            delete_block(h);
            inCnt = inCnt + 1;
        end
    end

    %% 删除输出端口
    outCnt = 0; % 记录已生成的输入端口数量
    sz = size(inportTab);
    for i=1:sz(1)
        data = outportTab(i,:);
        % 找到对应的端口
        h = find_system(bdroot,'Name',data.Name{1});
        if ~isempty(h)
            delete_block(h);
            outCnt = outCnt + 1;
        end
    end

end