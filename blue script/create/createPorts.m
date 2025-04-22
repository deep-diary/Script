function [inCnt, outCnt, inCntDel, outCntDel] = createPorts(template, portPath, varargin)
%CREATEPORTS 从Excel模板中提取信息并创建输入输出端口
%   [inCnt, outCnt, inCntDel, outCntDel] = createPorts(template, portPath) 
%   根据Excel模板中的信息在指定路径下创建输入输出端口。
%   其中有一列是Action，如果这列对应的数据是0，则表示删除该端口，反之则新建
%
%   输入参数:
%       template - Excel模板文件路径
%       portPath - 端口创建路径
%
%   可选参数:
%       'step' - 端口间距，默认为30
%       'posIn' - 输入端口起始位置，默认为[0, 0]
%       'posOut' - 输出端口起始位置，默认为[1000, 0]
%       'inRecognName' - 输入端口识别名称，默认为'Input'
%       'outRecognName' - 输出端口识别名称，默认为'Output'
%       'sheet' - Excel工作表名称，默认为'Signals'
%
%   输出参数:
%       inCnt - 创建的输入端口数量
%       outCnt - 创建的输出端口数量
%       inCntDel - 删除的输入端口数量
%       outCntDel - 删除的输出端口数量
%
%   示例:
%       [inCnt, outCnt, inCntDel, outCntDel] = createPorts('Template.xlsx', gcs)
%       [inCnt, outCnt, inCntDel, outCntDel] = createPorts('Template.xlsx', gcs, 'step', 40)
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-03-20
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        
        % 添加参数及其验证
        addParameter(p, 'step', 30, @(x) isnumeric(x) && x > 0);
        addParameter(p, 'posIn', [0, 0], @(x) isnumeric(x) && length(x) == 2);
        addParameter(p, 'posOut', [1000, 0], @(x) isnumeric(x) && length(x) == 2);
        addParameter(p, 'inRecognName', 'Input', @ischar);
        addParameter(p, 'outRecognName', 'Output', @ischar);
        addParameter(p, 'sheet', 'Signals', @ischar);
        
        parse(p, varargin{:});
        
        % 获取参数值
        step = p.Results.step;
        posIn = p.Results.posIn;
        posOut = p.Results.posOut;
        inRecognName = p.Results.inRecognName;
        outRecognName = p.Results.outRecognName;
        sheet = p.Results.sheet;
        
        %% 读取Excel数据
        try
            dataTable = readtable(template, 'Sheet', sheet);
        catch ME
            error('读取Excel文件失败: %s', ME.message);
        end
        
        % 分离输入输出端口数据
        inportTab = dataTable(strcmp(dataTable.PortType, inRecognName), :);
        outportTab = dataTable(strcmp(dataTable.PortType, outRecognName), :);
        
        % 分离需要删除和新建的端口
        inportTabDel = inportTab(inportTab.Action == 0, :);
        inportTabNew = inportTab(inportTab.Action ~= 0, :);
        outportTabDel = outportTab(outportTab.Action == 0, :);
        outportTabNew = outportTab(outportTab.Action ~= 0, :);
        
        %% 创建输入端口
        inCnt = 0;
        for i = 1:height(inportTabNew)
            data = inportTabNew(i, :);
            posCent = [posIn(1), posIn(2) + inCnt * step, posIn(1), posIn(2) + inCnt * step];
            inPos = posCent + [-15 -7 15 7];
            
            name = data.Name{1};
            path = [portPath '/' name];
            
            try
                h = add_block('built-in/Inport', path, 'Position', inPos);
                [dataType, ~, ~, ~, ~] = findNameType(name);
                set_param(h, 'OutDataTypeStr', dataType);
                set_param(h, "BackgroundColor", "green");
                inCnt = inCnt + 1;
            catch ME
                fprintf('警告: 端口 %s 已存在或创建失败: %s\n', name, ME.message);
            end
        end
        
        %% 创建输出端口
        outCnt = 0;
        for i = 1:height(outportTabNew)
            data = outportTabNew(i, :);
            posCent = [posOut(1), posOut(2) + outCnt * step, posOut(1), posOut(2) + outCnt * step];
            inPos = posCent + [-15 -7 15 7];
            
            name = data.Name{1};
            path = [portPath '/' name];
            
            try
                h = add_block('built-in/Outport', path, 'Position', inPos);
                [dataType, ~, ~, ~, ~] = findNameType(name);
                set_param(h, 'OutDataTypeStr', dataType);
                set_param(h, "BackgroundColor", "orange");
                outCnt = outCnt + 1;
            catch ME
                fprintf('警告: 端口 %s 已存在或创建失败: %s\n', name, ME.message);
            end
        end
        
        %% 删除输入端口
        inCntDel = 0;
        for i = 1:height(inportTabDel)
            data = inportTabDel(i, :);
            h = find_system(bdroot, 'Name', data.Name{1});
            if ~isempty(h)
                try
                    delete_block(h);
                    inCntDel = inCntDel + 1;
                catch ME
                    fprintf('警告: 删除端口 %s 失败: %s\n', data.Name{1}, ME.message);
                end
            end
        end
        
        %% 删除输出端口
        outCntDel = 0;
        for i = 1:height(outportTabDel)
            data = outportTabDel(i, :);
            h = find_system(bdroot, 'Name', data.Name{1});
            if ~isempty(h)
                try
                    delete_block(h);
                    outCntDel = outCntDel + 1;
                catch ME
                    fprintf('警告: 删除端口 %s 失败: %s\n', data.Name{1}, ME.message);
                end
            end
        end
        
        fprintf('端口操作完成:\n');
        fprintf('  创建输入端口: %d\n', inCnt);
        fprintf('  创建输出端口: %d\n', outCnt);
        fprintf('  删除输入端口: %d\n', inCntDel);
        fprintf('  删除输出端口: %d\n', outCntDel);
        
    catch ME
        error('端口操作时发生错误: %s', ME.message);
    end
end