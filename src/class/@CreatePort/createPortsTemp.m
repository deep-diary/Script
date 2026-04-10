function [inCnt, outCnt,inCntDel, outCntDel] = createPortsTemp(template, portPath, varargin)
%%
% 目的: 从excel 模板中提取信息并创建输入输出端口
% 输入：
%       template: 路径下的excel 文件名
% 可选： step: 30

% 返回： inCnt, outCnt：输入输出端口数量
% 范例： [inCnt, outCnt,inCntDel, outCntDel] = createPortsTemp('Template_PortsCreate', gcs, 'sheet','TmComprCtrl')
% 作者： Blue.ge
% 日期： 20240320

    %% 清空命令区
    clc    
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'step',30);      % 设置变量名和默认参数
    addParameter(p,'posIn',[0, 0]);      % 设置变量名和默认参数
    addParameter(p,'posOut',[1000, 0]);      % 设置变量名和默认参数
    addParameter(p,'inRecognName','Input');      % 设置变量名和默认参数
    addParameter(p,'outRecognName','Output');      % 设置变量名和默认参数
    addParameter(p,'sheet','Signals');      % 设置变量名和默认参数

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    step = p.Results.step;
    posIn = p.Results.posIn;
    posOut = p.Results.posOut;
    inRecognName = p.Results.inRecognName;
    outRecognName = p.Results.outRecognName;
    sheet = p.Results.sheet;
    
    %% 读取excel 数据

    dataTable = readtable(template, 'Sheet', sheet);
    inportTab = dataTable(strcmp(dataTable.PortType, inRecognName),:);
    outportTab = dataTable(strcmp(dataTable.PortType, outRecognName),:);

    inportTabDel = inportTab(inportTab.Action==0,:);
    inportTabNew = inportTab(inportTab.Action~=0,:);

    outportTabDel = outportTab(outportTab.Action==0,:);
    outportTabNew = outportTab(outportTab.Action~=0,:);
    

    
    %% 检查创建模型是否已经打开，如果没有则新建并打开
%     model_name = 'new_model';
%     if ~bdIsLoaded(model_name)
%         new_system(model_name); % 新建一个 Simulink 空白模型
%         open_system(model_name); % 打开该模型
%     end
    
    %% 生成输入端口
    inCnt = 0; % 记录已生成的输入端口数量
    sz = size(inportTabNew);
    for i=1:sz(1)
        data = inportTabNew(i,:);
        % 确认输入端口位置
        posCent = [posIn(1), posIn(2) + inCnt*step, posIn(1), posIn(2) + inCnt*step];
        inPos = posCent + [-15 -7 15 7];
        % 生成输入端口
        name = data.Name{1};
        path = [portPath '/' name];
        try
            h = add_block('built-in/Inport', path, ...
                      'Position', inPos);
%             set_param(h, 'OutDataTypeStr', data.DataType{1});
            [dataType, ~, ~, ~, ~] = findNameType(name);
            set_param(h, 'OutDataTypeStr', dataType);
            set_param(h,"BackgroundColor","green");
        catch
            disp([data.Name{1} ' already existed'])
        end
        
%         'MakeNameUnique','on',...
%             'OutMin',num2str(data.Min),...
%             'OutMax',num2str(data.Max));

        inCnt = inCnt + 1;
    end

    %% 生成输出端口
    outCnt = 0; % 记录已生成的输入端口数量
    sz = size(outportTabNew);
    for i=1:sz(1)
        data = outportTabNew(i,:);
        % 确认输入端口位置
        posCent = [posOut(1), posOut(2) + outCnt*step, posOut(1), posOut(2) + outCnt*step];
        inPos = posCent + [-15 -7 15 7];
        % 生成输入端口
        name = data.Name{1};
        path = [portPath '/' name];
        try
            h = add_block('built-in/Outport', path, ...
                      'Position', inPos);
%             set_param(h, 'OutDataTypeStr', data.DataType{1});
            [dataType, ~, ~, ~, ~] = findNameType(name);
            set_param(h, 'OutDataTypeStr', dataType);
            set_param(h,"BackgroundColor","orange");
        catch
            disp([data.Name{1} ' already existed'])
        end

%         'MakeNameUnique','on',...
%             'OutMin',num2str(data.Min),...
%             'OutMax',num2str(data.Max)

        outCnt = outCnt + 1;
    end

    %% 删除输入端口
    inCntDel = 0; % 记录已生成的输入端口数量
    sz = size(inportTabDel);
    for i=1:sz(1)
        data = inportTabDel(i,:);
        % 找到对应的端口
        h = find_system(bdroot,'Name',data.Name{1});
        if ~isempty(h)
            delete_block(h);
            inCntDel = inCntDel + 1;
        end
    end

    %% 删除输出端口
    outCntDel = 0; % 记录已生成的输入端口数量
    sz = size(outportTabDel);
    for i=1:sz(1)
        data = outportTabDel(i,:);
        % 找到对应的端口
        h = find_system(bdroot,'Name',data.Name{1});
        if ~isempty(h)
            delete_block(h);
            outCntDel = outCntDel + 1;
        end
    end


end