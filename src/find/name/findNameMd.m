function [ModelName, FunctionID, RequirementID] = findNameMd(Name, varargin)
%FINDNAMEMD 从模型名称中解析出模型名、功能ID和需求ID
%   [MODELNAME, FUNCTIONID, REQUIREMENTID] = FINDNAMEMD(NAME) 解析模型名称
%   [MODELNAME, FUNCTIONID, REQUIREMENTID] = FINDNAMEMD(NAME, 'Parameter', Value, ...)
%
%   输入参数:
%      Name         - 模型完整名称 (字符串)
%                     标准格式: 'Fun<数字>_Req<数字>_<模型名>'
%                     也支持: 'ID<数字>_<模型名>' 或 '<任意前缀>_<模型名>'
%                     示例: 'Fun666666_Req26245_DemoSub1' 或 'ID26245_DemoSub1'
%
%   可选参数（名值对）:
%      'FunPrefix'  - 功能ID前缀 (字符串), 默认值: 'Fun'
%      'ReqPrefix'  - 需求ID前缀 (字符串), 默认值: 'Req'
%      'IDPrefix'   - 单ID前缀 (字符串), 默认值: 'ID'
%
%   输出参数:
%      ModelName    - 模型名称 (字符串), 例如: 'DemoSub1'
%      FunctionID   - 功能ID (数值), 如果不存在则为NaN
%      RequirementID- 需求ID (数值), 如果不存在则为NaN
%
%   示例:
%      % 标准格式
%      [modelName, funID, reqID] = findNameMd('Fun666666_Req26245_DemoSub1')
%
%      % 简化格式（只有一个ID）
%      [modelName, funID, reqID] = findNameMd('ID26245_DemoSub1')
%      % 返回: modelName = 'DemoSub1', funID = NaN, reqID = 26245
%
%      % 自定义前缀
%      [modelName, funID, reqID] = findNameMd('Function666666_Request26245_DemoSub1', ...
%                                            'FunPrefix', 'Function', ...
%                                            'ReqPrefix', 'Request')
%
%   注意事项:
%      1. 函数会尝试解析不同格式的模型名称
%      2. 对于不符合标准格式的名称，会发出警告但仍会尝试提取可用信息
%      3. 无法提取的ID将返回NaN
%
%   参见: SPLIT, STR2DOUBLE, WARNING
%
%   作者: Blue.ge
%   版本: 1.2
%   日期: 20240409

    % 输入参数处理
    p = inputParser;
    addRequired(p, 'Name', @(x)validateattributes(x,{'char','string'},{'nonempty'}));
    addParameter(p, 'FunPrefix', 'Fun', @(x)validateattributes(x,{'char','string'},{'nonempty'}));
    addParameter(p, 'ReqPrefix', 'Req', @(x)validateattributes(x,{'char','string'},{'nonempty'}));
    addParameter(p, 'IDPrefix', 'ID', @(x)validateattributes(x,{'char','string'},{'nonempty'}));
    
    parse(p, Name, varargin{:});
    
    Name = p.Results.Name;
    FunPrefix = p.Results.FunPrefix;
    ReqPrefix = p.Results.ReqPrefix;
    IDPrefix = p.Results.IDPrefix;
    
    % 初始化返回值
    FunctionID = NaN;
    RequirementID = NaN;
    ModelName = '';
    
    % 按下划线分割字符串
    strList = split(Name, '_');
    numParts = length(strList);
    
    % 根据分割后的部分数量处理不同情况
    if numParts == 1
        % 只有一个部分，直接作为模型名
        ModelName = strList{1};
        warning('模型名称格式不标准: 未找到下划线分隔符。标准格式应为: "%s<数字>_%s<数字>_<模型名>"', FunPrefix, ReqPrefix);
        return;
    elseif numParts == 2
        % 两个部分，尝试解析为ID_模型名格式
        firstPart = strList{1};
        ModelName = strList{2};
        
        % 尝试提取ID
        if startsWith(firstPart, IDPrefix)
            idStr = firstPart(length(IDPrefix)+1:end);
            id = str2double(idStr);
            if ~isnan(id)
                RequirementID = id;
            end
        else
            % 尝试从任意前缀中提取数字
            idStr = regexp(firstPart, '\d+', 'match');
            if ~isempty(idStr)
                id = str2double(idStr{1});
                if ~isnan(id)
                    RequirementID = id;
                end
            end
        end
        
        warning('模型名称格式简化: 只包含一个ID。标准格式应为: "%s<数字>_%s<数字>_<模型名>"', FunPrefix, ReqPrefix);
    elseif numParts >= 3
        % 三个或更多部分，尝试标准解析
        ModelName = strList{end};
        
        % 提取功能ID
        funStr = strList{1};
        if startsWith(funStr, FunPrefix)
            FunctionID = str2double(funStr(length(FunPrefix)+1:end));
        else
            % 尝试从任意前缀中提取数字
            idStr = regexp(funStr, '\d+', 'match');
            if ~isempty(idStr)
                FunctionID = str2double(idStr{1});
            end
            warning('功能ID格式不标准: 应以"%s"开头。', FunPrefix);
        end
        
        % 提取需求ID
        reqStr = strList{2};
        if startsWith(reqStr, ReqPrefix)
            RequirementID = str2double(reqStr(length(ReqPrefix)+1:end));
        else
            % 尝试从任意前缀中提取数字
            idStr = regexp(reqStr, '\d+', 'match');
            if ~isempty(idStr)
                RequirementID = str2double(idStr{1});
            end
            warning('需求ID格式不标准: 应以"%s"开头。', ReqPrefix);
        end
        
        % 验证转换结果
        if isnan(FunctionID) && isnan(RequirementID)
            warning('无法提取有效ID: 功能ID和需求ID均不是有效的数字。标准格式应为: "%s<数字>_%s<数字>_<模型名>"', FunPrefix, ReqPrefix);
        end
    end
end