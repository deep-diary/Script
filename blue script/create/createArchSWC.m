function [autosarSWC, ertSWC, ArchModel] = createArchSWC(templateFile, ArchName, varargin)
%CREATEARCHSWC 从Excel表格中读取SWC信息，并创建对应的SWC组件
%   [AUTOSARSWC, ERTSWC, ARCHMODEL] = CREATEARCHSWC(TEMPLATEFILE, ARCHNAME, Name, Value, ...)
%   从Excel表格读取SWC信息并在架构模型中创建对应的SWC组件
%
%   必需参数:
%      templateFile  - Excel模板文件路径 (字符串)
%      ArchName      - 架构模型名称 (字符串)
%
%   可选参数 (名称-值对):
%      'Sheet'       - Excel工作表名称 (字符串, 默认: 'SWC')
%      'AutoLayout'  - 是否自动整理布局 (逻辑值, 默认: true)
%      'ERTCompositionName' - ERT组合名称 (字符串, 默认: 'ERT')
%
%   输出参数:
%      autosarSWC    - AUTOSAR组件信息表 (表格)
%      ertSWC        - ERT组件信息表 (表格)
%      ArchModel     - 架构模型句柄 (对象)
%
%   Excel表格格式要求:
%      Sheet名称: 默认为'SWC'，可通过'Sheet'参数指定
%      必需列:
%        - SWCName:   SWC名称 (字符串)
%        - Periodic:  周期 (数值)
%        - isAutosar: 是否为AUTOSAR组件 (0或1)
%                     1: AUTOSAR组件，直接添加到架构模型
%                     0: ERT组件，添加到ERT组合中（无输入输出端口）
%
%   功能描述:
%      1. 读取Excel表格中的SWC信息
%      2. 根据isAutosar属性分类SWC组件
%      3. 创建或加载架构模型
%      4. 创建ERT组合并添加ERT组件
%      5. 在架构模型中添加AUTOSAR组件
%      6. 根据参数决定是否自动整理布局
%
%   示例:
%      % 基本用法
%      [autosarSWC, ertSWC, archModel] = createArchSWC('Template.xlsx', 'CcmArch')
%      
%      % 指定工作表名称
%      [autosarSWC, ertSWC, archModel] = createArchSWC('Template.xlsx', 'CcmArch', 'Sheet', 'MySWC')
%      
%      % 指定所有参数
%      [autosarSWC, ertSWC, archModel] = createArchSWC('Template.xlsx', 'CcmArch', ...
%                                                        'Sheet', 'SWC', 'AutoLayout', true, ...
%                                                        'ERTCompositionName', 'ERT_Components')
%
%   注意事项:
%      1. Excel文件必须包含SWCName、Periodic和isAutosar三列
%      2. 如果架构模型已存在，将加载现有模型；否则创建新模型
%      3. ERT组件将全部放在指定的组合中，且无输入输出端口
%      4. AUTOSAR组件直接添加到架构模型顶层
%      5. 如果AutoLayout为true，函数会自动整理模型布局
%
%   参见: READTABLE, AUTOSAR.ARCH.CREATEMODEL, AUTOSAR.ARCH.LOADMODEL, 
%         AUTOSAR.ARCH.ADDCOMPOSITION, AUTOSAR.ARCH.ADDCOMPONENT, AUTOSAR.ARCH.LAYOUT
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 20251118

    %% 参数解析和验证
    % 验证必需参数
    validateattributes(templateFile, {'char', 'string'}, {'scalartext'}, mfilename, 'templateFile', 1);
    validateattributes(ArchName, {'char', 'string'}, {'scalartext'}, mfilename, 'ArchName', 2);
    templateFile = char(templateFile);
    ArchName = char(ArchName);
    
    % 验证Excel文件是否存在
    if ~exist(templateFile, 'file')
        error('MATLAB:createArchSWC:FileNotFound', ...
              'Excel文件 "%s" 不存在', templateFile);
    end
    
    % 创建输入解析器
    p = inputParser;
    p.FunctionName = mfilename;
    
    % 添加可选参数
    addParameter(p, 'Sheet', 'SWC', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'AutoLayout', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    addParameter(p, 'ERTCompositionName', 'ERT', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    
    % 解析输入参数
    parse(p, varargin{:});
    
    % 提取参数值
    sheetName = char(p.Results.Sheet);
    AutoLayout = p.Results.AutoLayout;
    ertCompositionName = char(p.Results.ERTCompositionName);

    %% 读取Excel表格数据
    try
        % 使用更简单的方式读取Excel文件，保留原始列名
        dataTable = readtable(templateFile, 'Sheet', sheetName, ...
                              'ReadVariableNames', true, ...
                              'VariableNamingRule', 'preserve');
        fprintf('成功读取Excel文件 "%s" (工作表: %s)，共 %d 行 %d 列\n', ...
                templateFile, sheetName, height(dataTable), width(dataTable));
    catch ME
        error('MATLAB:createArchSWC:ReadExcelFailed', ...
              '读取Excel文件失败: %s', ME.message);
    end
    
    % 验证必需的列是否存在
    requiredColumns = {'SWCName', 'Periodic', 'isAutosar'};
    missingColumns = setdiff(requiredColumns, dataTable.Properties.VariableNames);
    if ~isempty(missingColumns)
        error('MATLAB:createArchSWC:MissingColumns', ...
              'Excel表格缺少必需的列: %s', strjoin(missingColumns, ', '));
    end
    
    % 验证isAutosar列的值
    if ~all(ismember(dataTable.isAutosar, [0, 1]))
        warning('MATLAB:createArchSWC:InvalidIsAutosar', ...
                'isAutosar列包含非0/1值，将自动过滤');
        dataTable = dataTable(ismember(dataTable.isAutosar, [0, 1]), :);
    end

    %% 根据isAutosar属性，过滤出哪些SWC是ERT组件，哪些是AUTOSAR组件
    try
        ertSWC = dataTable(dataTable.isAutosar == 0, :);
        autosarSWC = dataTable(dataTable.isAutosar == 1, :);
        
        fprintf('分类完成: AUTOSAR组件 %d 个, ERT组件 %d 个\n', ...
                height(autosarSWC), height(ertSWC));
    catch ME
        error('MATLAB:createArchSWC:FilterFailed', ...
              'SWC分类失败: %s', ME.message);
    end

    %% 创建或加载架构模型
    try
        % 检查模型文件是否存在
        modelFile = which(ArchName);
        if isempty(modelFile) || ~exist(modelFile, 'file')
            archModel = autosar.arch.createModel(ArchName);
            fprintf('已创建新的架构模型: %s\n', ArchName);
        else
            archModel = autosar.arch.loadModel(ArchName);
            fprintf('已加载现有架构模型: %s\n', ArchName);
            ArchModel = archModel;
            return;
        end
    catch ME
        error('MATLAB:createArchSWC:ModelOperationFailed', ...
              '架构模型操作失败: %s', ME.message);
    end

    %% 创建ERT组合，并在其中创建ERT组件
    if height(ertSWC) > 0
        try
            ertComposition = addComposition(archModel, ertCompositionName);
            fprintf('已创建ERT组合: %s\n', ertCompositionName);
            
            for i = 1:height(ertSWC)
                addComponent(ertComposition, ertSWC.SWCName{i}, ...
                            'Kind', 'Application');
            end
            fprintf('已在ERT组合中添加 %d 个ERT组件\n', height(ertSWC));
            layout(ertComposition);
        catch ME
            warning('MATLAB:createArchSWC:ERTComponentFailed', ...
                    '创建ERT组件失败: %s', ME.message);
        end
    else
        fprintf('未找到ERT组件，跳过ERT组合创建\n');
    end

    %% 创建AUTOSAR组件
    if height(autosarSWC) > 0
        try
            for i = 1:height(autosarSWC)
                addComponent(archModel, autosarSWC.SWCName{i}, ...
                            'Kind', 'Application');
            end
            fprintf('已在架构模型中添加 %d 个AUTOSAR组件\n', height(autosarSWC));
        catch ME
            warning('MATLAB:createArchSWC:AutosarComponentFailed', ...
                    '创建AUTOSAR组件失败: %s', ME.message);
        end
    else
        fprintf('未找到AUTOSAR组件，跳过AUTOSAR组件创建\n');
    end

    %% 自动排列布局（如果需要）
    if AutoLayout
        try
            layout(archModel);
            fprintf('已完成布局整理\n');
        catch ME
            warning('MATLAB:createArchSWC:LayoutFailed', ...
                    '布局整理失败: %s', ME.message);
        end
    end
    
    fprintf('架构模型 "%s" SWC组件创建完成\n', ArchName);
    
    % 返回架构模型句柄
    ArchModel = archModel;
    save(ArchModel);
end
