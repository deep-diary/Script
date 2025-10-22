function changeNameAutosar(model, varargin)
%CHANGENAMEAUTOSAR 更改AUTOSAR模型端口名称
%   CHANGENAMEAUTOSAR(MODEL) 更改指定模型的所有端口名称
%   CHANGENAMEAUTOSAR(MODEL, 'Mode', MODE) 使用指定模式更改端口名称
%
%   输入参数:
%      model - 模型名称 (字符串)
%
%   可选参数（名值对）:
%      'Mode' - 名称更改模式 (字符串)
%               可选值: 'prefixHalf', 'deleteTail', 'halfTail', 'justHalf', 'modelHalf'
%               默认值: 'justHalf'
%
%   功能描述:
%      根据指定模式更改AUTOSAR模型的所有输入输出端口名称
%
%   示例:
%      changeNameAutosar('MyModel')
%      changeNameAutosar('MyModel', 'Mode', 'prefixHalf')
%
%   作者: Blue.ge
%   日期: 20240912
%   版本: 2.0

    %% 输入参数验证
    narginchk(1, inf);
    validateattributes(model, {'char', 'string'}, {'scalartext'}, mfilename, 'model', 1);
    
    % 确保输入为字符向量
    model = char(model);
    
    % 验证模型是否存在
    if ~bdIsLoaded(model)
        error('changeNameAutosar:modelNotLoaded', '模型 "%s" 未加载', model);
    end
    
    %% 输入参数处理
    p = inputParser;
    p.FunctionName = mfilename;
    
    validModes = {'prefixHalf', 'deleteTail', 'halfTail', 'justHalf', 'modelHalf'};
    addParameter(p, 'Mode', 'justHalf', @(x) any(validatestring(x, validModes)));
    
    parse(p, varargin{:});
    mode = p.Results.Mode;
    
    try
        %% 找到模型根路径下的输入输出端口
        inports = find_system(model, 'SearchDepth', 1, 'BlockType', 'Inport');
        outports = find_system(model, 'SearchDepth', 1, 'BlockType', 'Outport');
        
        %% 处理输入端口
        for i = 1:length(inports)
            try
                inportName = get_param(inports{i}, 'Name');
                newInportName = findNameAutosar(inportName, 'mode', mode, 'type', 'Inport');
                set_param(inports{i}, 'Name', newInportName);
                fprintf('输入端口 "%s" 已重命名为 "%s"\n', inportName, newInportName);
            catch ME
                warning('changeNameAutosar:inportError', '处理输入端口 "%s" 时发生错误: %s', inports{i}, ME.message);
            end
        end
        
        %% 处理输出端口
        for i = 1:length(outports)
            try
                outportName = get_param(outports{i}, 'Name');
                newOutportName = findNameAutosar(outportName, 'mode', mode, 'type', 'Outport');
                set_param(outports{i}, 'Name', newOutportName);
                fprintf('输出端口 "%s" 已重命名为 "%s"\n', outportName, newOutportName);
            catch ME
                warning('changeNameAutosar:outportError', '处理输出端口 "%s" 时发生错误: %s', outports{i}, ME.message);
            end
        end
        
        %% 显示处理结果
        fprintf('模型 "%s" 端口重命名完成。处理了 %d 个输入端口和 %d 个输出端口。\n', ...
                model, length(inports), length(outports));
        
    catch ME
        error('changeNameAutosar:processingError', '处理模型端口时发生错误: %s', ME.message);
    end
end
