function maskParams = findMaskParams(blockPath, varargin)
%FINDMASKPARAMS 查找Mask模块中的参数
%   MASKPARAMS = FINDMASKPARAMS(BLOCKPATH) 查找指定Mask模块的参数
%   MASKPARAMS = FINDMASKPARAMS(BLOCKPATH, 'Parameter', Value, ...) 使用指定参数查找
%
%   输入参数:
%      blockPath    - 模块路径或句柄 (字符串或数值)
%
%   可选参数（名值对）:
%      'IncludeValues' - 是否包含参数值中的变量 (逻辑值), 默认值: true
%      'FilterEditable'- 是否只返回可编辑参数 (逻辑值), 默认值: true
%      'FilterTunable' - 是否只返回可调参数 (逻辑值), 默认值: true
%      'FilterEnabled' - 是否只返回启用的参数 (逻辑值), 默认值: true
%      'FilterVisible' - 是否只返回可见参数 (逻辑值), 默认值: true
%      'FilterEvaluate'- 是否只返回可求值参数 (逻辑值), 默认值: true
%
%   输出参数:
%      maskParams  - 找到的Mask参数列表 (元胞数组)
%
%   功能描述:
%      查找Simulink Mask模块中的参数，可以根据参数的属性进行过滤：
%      - 可编辑参数 (Type: 'edit')
%      - 可调参数 (Tunable: 'on')
%      - 启用参数 (Enabled: 'on')
%      - 可见参数 (Visible: 'on')
%      - 可求值参数 (Evaluate: 'on')
%
%   示例:
%      params = findMaskParams(gcb)
%      params = findMaskParams(gcs, 'FilterEditable', false)
%      params = findMaskParams('myModel/MaskSubsystem', 'IncludeValues', false)
%
%   参见: SIMULINK.MASK.GET, GET_PARAM, FINDCALIBPARAMSTRADITIONAL
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 20250312

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
        error('无效的模块路径或句柄');
    end
    
    %% 获取Mask参数
    maskParams = {};
    
    try
        % 检查是否是Mask模块
        if ~strcmp(get_param(blockPath, 'Mask'), 'on')
            warning('指定的模块不是Mask模块: %s', blockPath);
            return;
        end
        
        % 获取Mask对象
        maskObj = Simulink.Mask.get(blockPath);
        if isempty(maskObj)
            warning('无法获取Mask对象: %s', blockPath);
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
                                % 使用addCalibParam函数处理可能包含的变量
                                maskParams = addCalibParam(maskParams, paramValue);
                            end
                        catch
                            % 如果无法获取参数值，继续处理
                        end
                    end
                end
            catch ME
                % 如果处理某个参数失败，记录错误并继续
                warning('处理参数 %s 失败: %s', params(i).Name, ME.message);
                continue;
            end
        end
        
        % 去除重复项
        maskParams = unique(maskParams);
        
    catch ME
        warning('查找Mask参数失败: %s', ME.message);
    end
end

function calibParams = addCalibParam(calibParams, value)
    % 辅助函数：检查并添加标定量
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