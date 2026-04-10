function maskParams = findParamMask(blockPath, varargin)
%FINDPARAMMASK 从 Mask 子系统中提取可能参与标定/变量的标识符列表
%
% 语法:
%   maskParams = findParamMask(blockPath)
%   maskParams = findParamMask(blockPath, 'Name', Value, ...)
%
% 功能描述:
%   对指定 Simulink 模块调用 Simulink.Mask.get，遍历 Mask.Parameters，按各 Filter*
%   开关过滤；仅当参数名为合法 MATLAB 标识符且以字母开头时才继续处理（否则跳过）。
%   当前实现不把 Mask 参数名本身写入结果（历史上曾注释掉直接收集参数名）；若
%   IncludeValues 为 true，则 get_param 读取该参数的取值字符串，用正则拆出疑似
%   变量名并合并去重。IncludeValues 为 false 时通常得到空元胞（无解析来源）。
%   用于从 Mask 对话框表达式中粗提与标定相关的符号（非完整语义解析）。
%
% 输入参数:
%   blockPath - 模块全路径 (char)、模块句柄 (numeric) 或图形句柄 (handle)
%
% 可选参数（Name-Value）:
%   'IncludeValues'   - 为 true 时解析各参数取值字符串中的标识符并加入结果；
%                       为 false 时通常无输出（本函数不向结果写入参数名本身）(logical)
%                       默认: true
%   'FilterEditable'  - 为 true 时仅保留 Type 为 'edit' 的参数 (logical)
%                       默认: false（不过滤类型，保留非 edit 等类型）
%   'FilterTunable'   - 为 true 时仅保留 Tunable 为 'on' 的参数 (logical)
%                       默认: true
%   'FilterEnabled'   - 为 true 时仅保留 Enabled 为 'on' 的参数 (logical)
%                       默认: true
%   'FilterVisible'   - 为 true 时仅保留 Visible 为 'on' 的参数 (logical)
%                       默认: true
%   'FilterEvaluate'  - 为 true 时仅保留 Evaluate 为 'on' 的参数 (logical)
%                       默认: true
%   各 Filter* 为 false 时表示不对该项施加过滤。某属性在 Mask API 中不可读时，按
%   'on' 处理（与实现中 try/catch 默认一致）。
%
% 输出参数:
%   maskParams - 去重后的标识符元胞数组 (cellstr)，每项为 char；无匹配或异常时
%                可能为空元胞数组 {}
%
% 异常与边界行为:
%   - blockPath 无法解析为合法模块路径时 error（含本函数名）。
%   - 模块未开启 Mask 或无法取得 Mask 对象时 warning 并返回空或已有部分结果。
%   - 单个参数处理失败时 warning 并跳过该参数。
%   - 外层 try 失败时 warning，不保证结果完整。
%
% 示例:
%   % 示例1：当前模块，默认过滤并从 Mask 参数取值中解析标识符
%   p = findParamMask(gcb);
%
%   % 示例2：仅针对 Type 为 edit 且满足默认 Tunable 等条件的参数解析取值
%   p = findParamMask(gcb, 'FilterEditable', true);
%
% 参见: SIMULINK.MASK.GET, GET_PARAM, FINDCALIBPARAMSTRADITIONAL
%
% 作者: blue.ge(葛维冬@Smart)
% 版本: 1.1
% 日期: 2026-04-10
% 变更记录:
%   2026-04-10 v1.1 按项目规则重写帮助文档；修正 FilterEditable 默认值与代码一致；
%                  说明 IncludeValues/输出与实现一致；warning/error 带函数名；本地子函数更名为 i_addCalibParam。
%   2025-03-12 v1.0 初版。

    %% 输入参数处理
    p = inputParser;
    addRequired(p, 'blockPath', @(x)ischar(x) || isnumeric(x) || ishandle(x));
    addParameter(p, 'IncludeValues', true, @islogical);
    addParameter(p, 'FilterEditable', false, @islogical);
    addParameter(p, 'FilterTunable', true, @islogical);
    addParameter(p, 'FilterEnabled', true, @islogical);
    addParameter(p, 'FilterVisible', true, @islogical);
    addParameter(p, 'FilterEvaluate', true, @islogical);
    
    parse(p, blockPath, varargin{:});
    
    includeValues = p.Results.IncludeValues;
    filterEditable = p.Results.FilterEditable;
    filterTunable = p.Results.FilterTunable;
    filterEnabled = p.Results.FilterEnabled;
    filterVisible = p.Results.FilterVisible;
    filterEvaluate = p.Results.FilterEvaluate;
    
    % 验证路径
    try
        if ~ischar(blockPath)
            blockPath = getfullname(blockPath);
        end
    catch
        error('%s: 无效的模块路径或句柄。', mfilename);
    end
    
    %% 获取Mask参数
    maskParams = {};
    
    try
        % 检查是否是Mask模块
        if ~strcmp(get_param(blockPath, 'Mask'), 'on')
            warning('%s: 指定的模块不是 Mask 模块: %s', mfilename, blockPath);
            return;
        end
        
        % 获取Mask对象
        maskObj = Simulink.Mask.get(blockPath);
        if isempty(maskObj)
            warning('%s: 无法获取 Mask 对象: %s', mfilename, blockPath);
            return;
        end
        
        % 获取参数列表
        params = maskObj.Parameters;
        
        for i = 1:length(params)
            try
                % 获取参数属性
                paramName = params(i).Name;
                paramType = params(i).Type;
                
                % 获取参数特性（如果属性不存在则默认为'on'）
                try
                    paramTunable = params(i).Tunable;
                catch
                    paramTunable = 'on';
                end
                
                try
                    paramEnabled = params(i).Enabled;
                catch
                    paramEnabled = 'on';
                end
                
                try
                    paramVisible = params(i).Visible;
                catch
                    paramVisible = 'on';
                end
                
                try
                    paramEvaluate = params(i).Evaluate;
                catch
                    paramEvaluate = 'on';
                end
                
                % 根据过滤条件检查参数
                isEditable = ~filterEditable || strcmp(paramType, 'edit');
                isTunable = ~filterTunable || strcmp(paramTunable, 'on');
                isEnabled = ~filterEnabled || strcmp(paramEnabled, 'on');
                isVisible = ~filterVisible || strcmp(paramVisible, 'on');
                isEvaluate = ~filterEvaluate || strcmp(paramEvaluate, 'on');
                
                % 如果满足所有条件，添加到结果列表
                if isEditable && isTunable && isEnabled && isVisible && isEvaluate
                    % 检查是否是合法的变量名
                    if isvarname(paramName) && ~isempty(regexp(paramName, '^[A-Za-z]', 'once'))
%                         maskParams{end+1} = paramName;  % 变量名并不是标定量
                    else
                        continue
                    end
                    
                    % 如果需要包含参数值中的变量
                    if includeValues
                        try
                            % 获取参数值
                            paramValue = get_param(blockPath, paramName);
                            if ischar(paramValue)
                                % 使用 i_addCalibParam 处理取值中可能包含的变量名
                                maskParams = i_addCalibParam(maskParams, paramValue);
                            end
                        catch
                            % 如果无法获取参数值，继续处理
                        end
                    end
                end
            catch ME
                % 如果处理某个参数失败，记录错误并继续
                warning('%s: 处理参数 %s 失败: %s', mfilename, params(i).Name, ME.message);
                continue;
            end
        end
        
        % 去除重复项
        maskParams = unique(maskParams);
        
    catch ME
        warning('%s: 查找 Mask 参数失败: %s', mfilename, ME.message);
    end
end

function calibParams = i_addCalibParam(calibParams, value)
    % 从参数字符串中提取疑似变量名并追加到元胞列表（本地子函数）
    if ischar(value) && ~isempty(regexp(value, '^[A-Za-z]', 'once')) && ...
       ~any(strcmp(value, {'pi', 'inf', 'nan', 'eps', 'realmax', 'realmin'}))
        
        % 处理可能包含多个变量的表达式
        % 例如 "a*b + c" 应该提取 a, b, c
        tokens = regexp(value, '[A-Za-z][A-Za-z0-9_]*', 'match');
        
        for i = 1:length(tokens)
            token = tokens{i};
            
            % 排除MATLAB内置函数和运算符
            if ~any(strcmp(token, {'sin', 'cos', 'tan', 'exp', 'log', 'sqrt', 'abs', ...
                    'min', 'max', 'round', 'floor', 'ceil', 'mod', 'rem', ...
                    'and', 'or', 'not', 'xor', 'if', 'else', 'elseif', 'end', ...
                    'for', 'while', 'switch', 'case', 'otherwise', 'break', 'continue'}))
                
                % 检查是否已存在于列表中
                if ~any(strcmp(calibParams, token))
                    calibParams{end+1} = token;
                end
            end
        end
    end
end 