function [numInputPorts, numOutputPorts] = createPortsGoto(varargin)
%CREATEPORTSGOTO 创建输入输出端口及其相连接的Goto/From模块
%   [numInputPorts, numOutputPorts] = createPortsGoto() 根据指定的信号列表或模板文件
%   创建输入输出端口，并自动添加对应的Goto/From模块和连线。
%
%   可选参数:
%       'posIn' - 输入端口起始位置，默认为[-500 0]
%       'posOut' - 输出端口起始位置，默认为[500 0]
%       'step' - 端口间距，默认为30
%       'gotoLength' - Goto/From模块宽度，默认为180
%       'inList' - 输入信号列表，默认为{}
%       'outList' - 输出信号列表，默认为{}
%       'NAStr' - 忽略的字段标识，默认为'NA'
%       'mode' - 命名模式，可选'pre'、'tail'、'keep'，默认为'keep'
%       'fromTemplate' - 是否使用模板文件，默认为false
%       'template' - 模板文件名，默认为'Template'
%       'sheet' - 模板工作表名，默认为'Signals'
%       'inRecognName' - 输入信号识别字段，默认为'Input'
%       'outRecognName' - 输出信号识别字段，默认为'Output'
%
%   输出参数:
%       numInputPorts - 创建的输入端口数量
%       numOutputPorts - 创建的输出端口数量
%
%   示例:
%       [in, out] = createPortsGoto('fromTemplate', true)
%       [in, out] = createPortsGoto('inList', {'a','b'}, 'outList', {'c','d'})
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2023-09-28
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        
        % 添加参数及其验证
        addParameter(p, 'posIn', [-500 0], @(x) isnumeric(x) && length(x) == 2);
        addParameter(p, 'posOut', [500 0], @(x) isnumeric(x) && length(x) == 2);
        addParameter(p, 'step', 30, @(x) isnumeric(x) && x > 0);
        addParameter(p, 'gotoLength', 180, @(x) isnumeric(x) && x > 0);
        addParameter(p, 'inList', {}, @iscell);
        addParameter(p, 'outList', {}, @iscell);
        addParameter(p, 'NAStr', 'NA', @ischar);
        addParameter(p, 'mode', 'keep', @(x) any(strcmp(x, {'pre', 'tail', 'keep'})));
        addParameter(p, 'fromTemplate', false, @islogical);
        addParameter(p, 'template', 'Template', @ischar);
        addParameter(p, 'sheet', 'Signals', @ischar);
        addParameter(p, 'inRecognName', 'Input', @ischar);
        addParameter(p, 'outRecognName', 'Output', @ischar);
        
        parse(p, varargin{:});
        
        % 获取参数值
        NAStr = p.Results.NAStr;
        inList = p.Results.inList;
        outList = p.Results.outList;
        inputStep = p.Results.step;
        outputStep = p.Results.step;
        gotoLength = p.Results.gotoLength;
        posIn = p.Results.posIn;
        posOut = p.Results.posOut;
        mode = p.Results.mode;
        inRecognName = p.Results.inRecognName;
        outRecognName = p.Results.outRecognName;
        sheet = p.Results.sheet;
        template = p.Results.template;
        fromTemplate = p.Results.fromTemplate;
        
        %% 自动调整端口位置
        if posIn(1) == -500 && posOut(1) == 500
            pos = findGcsPos();
            if pos(1) ~= Inf
                posIn = [pos(1) - 500, pos(2)];
                posOut = [pos(3) + 500, pos(2)];
            end
        end
        
        %% 获取信号列表
        if ~isempty(inList) || ~isempty(outList)
            fprintf('使用指定的信号列表\n');
            inList = inList(~strcmp(inList, NAStr));
            outList = outList(~strcmp(outList, NAStr));
        elseif fromTemplate
            fprintf('使用模板文件中的信号\n');
            try
                dataTable = readtable(template, 'Sheet', sheet);
                inportTab = dataTable(strcmp(dataTable.PortType, inRecognName), :);
                outportTab = dataTable(strcmp(dataTable.PortType, outRecognName), :);
                inList = inportTab.Name;
                outList = outportTab.Name;
            catch ME
                error('读取模板文件失败: %s', ME.message);
            end
        else
            error('未指定有效的输入信号。请至少指定以下参数之一：inList、outList或fromTemplate');
        end
        
        %% 创建输入端口和Goto模块
        numInputPorts = 0;
        for i = 1:length(inList)
            try
                Name = inList{i};
                if strcmp(Name, NAStr)
                    continue;
                end
                
                % 创建输入端口
                pos = [posIn(1), posIn(2) + numInputPorts * inputStep, ...
                       posIn(1) + 30, posIn(2) + 14 + numInputPorts * inputStep];
                bkIn = add_block('built-in/Inport', [gcs '/' Name], 'Position', pos);
                
                % 设置数据类型
                [dataType, ~, ~, ~, ~] = findNameType(Name);
                set_param(bkIn, 'OutDataTypeStr', dataType);
                set_param(bkIn, "BackgroundColor", "green");
                
                % 创建Goto模块
                gotoPos = pos + [300 - gotoLength/2, 0, 300 + gotoLength/2, 0];
                bkGoto = add_block('built-in/Goto', [gcs '/Goto'], ...
                                  'MakeNameUnique', 'on', 'Position', gotoPos);
                set_param(bkGoto, 'GotoTag', Name);
                
                % 连线
                creatLines([bkIn, bkGoto]);
                
                numInputPorts = numInputPorts + 1;
            catch ME
                fprintf('警告: 创建输入端口 %s 失败: %s\n', Name, ME.message);
            end
        end
        
        %% 创建输出端口和From模块
        numOutputPorts = 0;
        for i = 1:length(outList)
            try
                Name = outList{i};
                if strcmp(Name, NAStr)
                    continue;
                end
                
                % 获取输出端口名称和数据类型
                [dataType, nameOutPort] = findNameMdOut(Name, 'mode', mode);
                
                % 创建输出端口
                pos = [posOut(1), posOut(2) + numOutputPorts * outputStep, ...
                       posOut(1) + 30, posOut(2) + 14 + numOutputPorts * outputStep];
                bkOut = add_block('built-in/Outport', [gcs '/' nameOutPort], ...
                                 'MakeNameUnique', 'on', 'Position', pos);
                set_param(bkOut, 'OutDataTypeStr', dataType);
                set_param(bkOut, "BackgroundColor", "orange");
                
                % 创建From模块
                fromPos = pos + [-300 - gotoLength/2, 0, -300 + gotoLength/2, 0];
                bkFrom = add_block('built-in/From', [gcs '/From'], ...
                                  'MakeNameUnique', 'on', 'Position', fromPos);
                set_param(bkFrom, 'GotoTag', Name);
                
                % 连线
                creatLines([bkFrom, bkOut]);
                
                numOutputPorts = numOutputPorts + 1;
            catch ME
                fprintf('警告: 创建输出端口 %s 失败: %s\n', Name, ME.message);
            end
        end
        
        fprintf('端口创建完成:\n');
        fprintf('  创建输入端口: %d\n', numInputPorts);
        fprintf('  创建输出端口: %d\n', numOutputPorts);
        
    catch ME
        error('端口创建过程中发生错误: %s', ME.message);
    end
end

