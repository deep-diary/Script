function numCreated = creatIFOut(varargin)
%CREATIFOUT 创建接口输出模型
%   numCreated = creatIFOut() 创建接口输出模型，包括信号创建、解析和端口配置。
%
%   可选参数:
%       'pos' - 模型位置，默认为[12000,0]
%       'template' - Excel模板文件名，默认为'Template.xlsx'
%       'sheetNames' - 工作表名称列表，默认为{'IF_OutportsCommon','IF_OutportsDiag','IF_Outports2F'}
%
%   输出参数:
%       numCreated - 创建的信号总数
%
%   示例:
%       numCreated = creatIFOut()
%       numCreated = creatIFOut('pos', [13000,0], 'template', 'MyTemplate.xlsx')
%       numCreated = creatIFOut('sheetNames', {'IF_OutportsCommon','IF_OutportsDiag'})
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-06-28
%   版本: 1.1

    try
        %% 参数处理
        p = inputParser;
        
        % 添加参数及其验证
        addParameter(p, 'pos', [12000,0], @(x) isnumeric(x) && numel(x) == 2);
        addParameter(p, 'template', 'Template.xlsx', @ischar);
        addParameter(p, 'sheetNames', {'IF_OutportsCommon','IF_OutportsDiag','IF_Outports2F'}, @iscell);
        
        parse(p, varargin{:});
        
        % 获取参数值
        pos = p.Results.pos;
        template = p.Results.template;
        sheetNames = p.Results.sheetNames;
        
        %% 验证Excel文件
        if ~exist(template, 'file')
            error('Excel模板文件不存在: %s', template);
        end
        
        %% 创建模块
        name = 'TmOut';
        root = gcs;
        path = [root '/' name];
        posMd = [pos pos(1)+500 pos(2)+2000];
        
        try
            bk = add_block('built-in/SubSystem', path, ...
                'Name', name, 'Position', posMd);
            open_system(path);
        catch ME
            error('创建子系统时发生错误: %s', ME.message);
        end
        
        %% 循环创建接口信号
        totalCreated = 0;
        for i = 1:length(sheetNames)
            try
                posX = 1500 * (i-1);
                numCreated = creatInterface( ...
                    'template', template, ...
                    'sheetName', sheetNames{i}, ...
                    'posX', posX, ...
                    'mode', 'outport', ...
                    'sigUse', 'in');
                
                totalCreated = totalCreated + numCreated;
                fprintf('基于工作表 %s 创建了 %d 个信号\n', sheetNames{i}, numCreated);
            catch ME
                warning(ME.identifier, '创建工作表 %s 的信号时发生错误: %s', sheetNames{i}, ME.message);
            end
        end
        
        %% 调整模块位置
        try
            changeModPos(path, pos);
        catch ME
            warning(ME.identifier, '调整模块位置时发生错误: %s', ME.message);
        end
        
        %% 信号解析
        try
            createSigOnLine(path, ...
                'isEnableOut', false, ...
                'skipTrig', false, ...
                'resoveValue', true);
        catch ME
            warning(ME.identifier, '信号解析时发生错误: %s', ME.message);
        end
        
        %% 创建端口和Goto模块
        try
            open_system(root);
            createModGoto(path, 'mode', 'inport');
            createModPorts(path, 'mode', 'outport');
        catch ME
            warning(ME.identifier, '创建端口和Goto模块时发生错误: %s', ME.message);
        end
        
        %% 显示完成信息
        fprintf('接口输出模型创建完成，共创建 %d 个信号\n', totalCreated);
        numCreated = totalCreated;
        
    catch ME
        error('创建接口输出模型时发生错误: %s', ME.message);
    end
end
