function bk = createPortsBySheet(path, pos, data, varargin)
%CREATEPORTSBYSHEET 从一行元组包中提取属性并创建端口
%   BK = CREATEPORTSBYSHEET(PATH, POS, DATA) 根据输入参数创建端口
%   BK = CREATEPORTSBYSHEET(PATH, POS, DATA, Name, Value) 使用名称-值对参数创建端口
%
%   输入参数:
%       PATH    - 端口所在的路径，字符串
%       POS     - 端口在模型中的位置，[x y width height]格式的数组
%       DATA    - 包含端口属性的表格或结构体，必须包含以下字段：
%                 Name: 端口名称
%                 Details: 端口描述
%                 Min: 最小值
%                 Max: 最大值
%                 Unit: 单位
%                 DataType: 数据类型
%
%   名称-值对参数:
%       'type'  - 端口类型，可选值为 'Inport' 或 'Outport'，默认为 'Inport'
%
%   输出参数:
%       BK      - 创建的端口句柄
%
%   示例:
%       % 创建输入端口
%       result = createPortsBySheet('model/Subsystem', [100 100 30 30], dataTable)
%
%       % 创建输出端口
%       result = createPortsBySheet('model/Subsystem', [200 100 30 30], dataTable, 'type', 'Outport')
%
%   另请参阅: add_block, set_param
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2025-06-04
%   版本: 1.0


    %% 输入参数处理
    p = inputParser;
    
    % 添加参数及其验证
    addParameter(p, 'type', 'Inport', @ischar); % Inport Outport
    
    parse(p, varargin{:});
    
    % 获取参数值
    type = p.Results.type;
    %% 获取属性
    bk = '';
    try
        Name = data.Name{1};
        Details = data.Details{1};
        Min = data.Min(1);
        Max = data.Max(1);
        Unit = data.Unit{1};
        bkPath = [path '/' Name];
        bkType = ['built-in/' type];
        DataType = data.DataType{1};
        if isempty(DataType)
            [DataType, ~, ~, ~, ~] = findNameType(Name);
        end

        if strcmp(type,'Inport')
            BackgroundColor = "green";
        elseif strcmp(type,'Outport')
            BackgroundColor = "orange";
        else
            BackgroundColor = "white";
        end

    catch ME
        fprintf('警告: 属性数据不完整: %s\n',  ME.message);
    end

    %% 创建端口
    try
        bk = add_block(bkType, bkPath, ...
            'MakeNameUnique','on',...
            'Position', pos, ...
            "BackgroundColor", BackgroundColor, ...
            'OutDataTypeStr', DataType, ...
            "Description", Details ...
            );

        if ~isnan(Min)
            set_param(bk, "OutMin", num2str(Min));
        end
        if ~isnan(Max)
            set_param(bk, "OutMax", num2str(Max));
        end
        if ~isempty(Unit)
            set_param(bk, "Unit", Unit);
        end

    catch ME
        fprintf('警告: 端口创建失败: %s\n',  ME.message);
    end
end