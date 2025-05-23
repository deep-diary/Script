function [modNums] = createSubMod(varargin)
%CREATESUBMOD 批量创建Simulink子模型
%   MODNUMS = CREATESUBMOD() 使用默认参数创建子模型
%   MODNUMS = CREATESUBMOD('Parameter', Value, ...) 使用指定参数创建子模型
%
%   输入参数（名值对）:
%      'template'     - Excel文件名 (字符串), 默认值: 'Template.xlsx'
%      'sheet'        - Excel工作表名 (字符串), 默认值: 'ModelName'
%      'FunPrefix'    - 功能ID前缀 (字符串), 默认值: 'Fun'
%      'ReqPrefix'    - 需求ID前缀 (字符串), 默认值: 'Req'
%      'rows'         - 布局行数 (正整数), 默认值: 1
%      'blockWidth'   - 模块宽度 (正整数), 默认值: 150
%      'blockHeight'  - 模块高度 (正整数), 默认值: 100
%      'hSpacing'     - 水平间距 (正整数), 默认值: 300
%      'vSpacing'     - 垂直间距 (正整数), 默认值: 50
%
%   输出参数:
%      modNums       - 创建的子模型数量 (正整数)
%
%   示例:
%      modNums = createSubMod('rows', 3)
%      modNums = createSubMod('template', 'myTemplate.xlsx', 'rows', 2)
%
%   注意事项:
%      1. 使用前需要打开目标Simulink模型
%      2. Excel模板需包含FunctionID、RequirementID和ModelName三列
%      3. 子模型命名格式为: FunXXXXXX_ReqYYYYYY_ModelName
%
%   参见: ADD_BLOCK, SET_PARAM, GCS
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 20250312

    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'template','Template.xlsx');         % 路径下的excel
    addParameter(p,'sheet','ModelName');                % 模板中的sheet名
    addParameter(p,'FunPrefix','');                  % 功能ID前缀
    addParameter(p,'ReqPrefix','');                  % 需求ID前缀
    addParameter(p,'rows',1);                           % 需要创建的行数
    addParameter(p,'blockWidth',150);                   % 模块宽度
    addParameter(p,'blockHeight',100);                  % 模块高度
    addParameter(p,'hSpacing',300);                      % 水平间距
    addParameter(p,'vSpacing',50);                      % 垂直间距

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    template = p.Results.template;
    sheet = p.Results.sheet;
    FunPrefix = p.Results.FunPrefix;
    ReqPrefix = p.Results.ReqPrefix;
    rows = p.Results.rows;
    blockWidth = p.Results.blockWidth;
    blockHeight = p.Results.blockHeight;
    hSpacing = p.Results.hSpacing;
    vSpacing = p.Results.vSpacing;

    %% 读取excel模板内容
    dataTable = readtable(template, 'Sheet', sheet);
    
    %% 获取FunctionID，RequirementID，ModelName
    FunctionIDs = dataTable.FunctionID;
    RequirementIDs = dataTable.RequirementID;
    ModelNames = dataTable.ModelName;

    %% 创建子模型
    modNums = 0;
    
    % 计算布局参数
    totalModels = length(FunctionIDs);
    cols = ceil(totalModels / rows);    % 计算每行需要的列数
    
    for i = 1:length(FunctionIDs)
        % 计算当前模块的行列位置
        currentRow = ceil(i / cols);
        currentCol = mod(i - 1, cols) + 1;
        
        % 计算模块的位置坐标
        xPos = (currentCol - 1) * (blockWidth + hSpacing);
        yPos = (currentRow - 1) * (blockHeight + vSpacing);
        
        FunctionID = FunctionIDs{i};
        RequirementID = RequirementIDs{i};
        ModelName = ModelNames{i};
        % 获取子模型名称
        if strcmp(FunctionID, 'None')
            subModName = [ReqPrefix, RequirementID, '_', ModelName];
        else
            subModName = [FunPrefix, FunctionID, '_', ReqPrefix, RequirementID, '_', ModelName];
        end
        
        % 创建子模型并设置位置
        newBlock = add_block('built-in/SubSystem', [gcs, '/', subModName]);
        set_param(newBlock, 'Position', [xPos, yPos, xPos+blockWidth, yPos+blockHeight]);
        modNums = modNums + 1;
    end


