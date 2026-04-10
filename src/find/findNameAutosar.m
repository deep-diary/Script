function NameSigOut = findNameAutosar(Name, varargin)
%FINDNAMEAUTOSAR 根据AUTOSAR信号名获取对应的解析信号名
%   NAMESIGOUT = FINDNAMEAUTOSAR(NAME) 根据AUTOSAR信号名解析出对应的信号名
%   NAMESIGOUT = FINDNAMEAUTOSAR(NAME, 'Parameter', Value, ...) 使用指定参数解析信号名
%
%   输入参数:
%      Name        - AUTOSAR信号名称 (字符串)
%
%   可选参数（名值对）:
%      'nameMd'    - 模型名称 (字符串)
%                   默认值: bdroot
%      'type'      - 端口类型，'Inport' 或 'Outport' (字符串)
%                   默认值: 'Inport'
%      'mode'      - 解析模式，可选值: 'deleteTail', 'halfTail', 'justHalf', 'modelHalf', 'prefixHalf'
%                   默认值: 'deleteTail'
%      'prefixName' - 前缀名称，用于 'prefixHalf' 模式
%                   默认值: 'CcmIF'
%
%   输出参数:
%      NameSigOut  - 解析后的信号名称 (字符串)
%
%   功能描述:
%      根据AUTOSAR信号名称解析出对应的信号名。支持多种解析模式：
%      - deleteTail: 删除后缀（_read 或 _write）
%      - halfTail: 保留一半名称并添加相应后缀
%      - justHalf: 只保留一半名称
%      - modelHalf: 模型名_一半名称
%      - prefixHalf: 前缀名_一半名称
%
%   示例:
%      NameSigOut = findNameAutosar('AmbTFildForClima_AmbTFildForClima_read')
%      NameSigOut = findNameAutosar('AmbTFildForClima_AmbTFildForClima_read', 'nameMd', 'PrkgClimaEgyMgr', 'type', 'Inport')
%      NameSigOut = findNameAutosar('AmbTFildForClima_AmbTFildForClima_write', 'type', 'Outport', 'mode', 'modelHalf')
%      NameSigOut = findNameAutosar('AmbTFildForClima_AmbTFildForClima_read', 'mode', 'prefixHalf')
%      NameSigOut = findNameAutosar('AmbTFildForClima_AmbTFildForClima_read', 'mode', 'prefixHalf', 'prefixName', 'CustomPrefix')
%
%   作者: Blue.ge
%   日期: 20240912
%   版本: 2.0
    %% 输入参数验证
    narginchk(1, inf);
    validateattributes(Name, {'char', 'string'}, {'scalartext'}, mfilename, 'Name', 1);
    
    % 确保输入为字符向量
    Name = char(Name);
    
    %% 输入参数处理
    p = inputParser;
    p.FunctionName = mfilename;
    
    % 添加可选参数
    addParameter(p, 'nameMd', bdroot, @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'type', 'Inport', @(x) any(validatestring(x, {'Inport', 'Outport'})));
    validModes = {'deleteTail', 'halfTail', 'justHalf', 'modelHalf', 'prefixHalf'};
    addParameter(p, 'mode', 'prefixHalf', @(x) any(validatestring(x, validModes)));
    addParameter(p, 'prefixName', 'CcmIF', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    
    parse(p, varargin{:});
    nameMd = char(p.Results.nameMd);
    type = char(p.Results.type);
    mode = p.Results.mode;
    prefixName = char(p.Results.prefixName);
    
    try
        %% 确定信号前缀
        if endsWith(Name, '_read')
            nameWithoutTail = Name(1:end-5);
        elseif endsWith(Name, '_write')
            nameWithoutTail = Name(1:end-6);
        else
            % 如果没有标准后缀，使用原名称
            nameWithoutTail = Name;
        end
        
        %% 验证名称格式
        if isempty(nameWithoutTail)
            error('findNameAutosar:invalidName', '无效的信号名称: %s', Name);
        end
        
        %% 计算一半名称（处理重复名称的情况）
        if contains(nameWithoutTail, '_') && length(nameWithoutTail) > 1
            % 查找下划线位置
            underscorePos = strfind(nameWithoutTail, '_');
            if ~isempty(underscorePos)
                % 特殊处理包含_IsUpdated的信号名
                if strcmp(mode, 'prefixHalf') && contains(nameWithoutTail, '_IsUpdated_')
                    % 对于prefixHalf模式，如果包含_IsUpdated_，则取_IsUpdated_之后的部分
                    isUpdatedPos = strfind(nameWithoutTail, '_IsUpdated_');
                    if ~isempty(isUpdatedPos)
                        nameHalf = nameWithoutTail(isUpdatedPos(1) + length('_IsUpdated_'):end);
                    else
                        % 如果没有找到_IsUpdated_，使用原来的逻辑
                        nameHalf = nameWithoutTail(underscorePos(1)+1:end);
                    end
                else
                    % 取第一个下划线之后的部分作为一半名称
                    nameHalf = nameWithoutTail(underscorePos(1)+1:end);
                end
            else
                nameHalf = nameWithoutTail;
            end
        else
            nameHalf = nameWithoutTail;
        end
        
        %% 根据模式生成输出名称
        switch mode
            case 'deleteTail'
                NameSigOutReq = nameWithoutTail;
                
            case 'halfTail'
                if strcmp(type, 'Inport')
                    NameSigOutReq = [nameHalf '_read'];
                elseif strcmp(type, 'Outport')
                    NameSigOutReq = [nameHalf '_write'];
                else
                    error('findNameAutosar:invalidType', '无效的端口类型: %s。此模式需要指定type参数: Inport, Outport', type);
                end
                
            case 'justHalf'
                NameSigOutReq = nameHalf;
                
            case 'modelHalf'
                NameSigOutReq = [nameMd '_' nameHalf];
                
            case 'prefixHalf'
                NameSigOutReq = [prefixName '_' nameHalf];
                
            otherwise
                error('findNameAutosar:invalidMode', '无效的解析模式: %s', mode);
        end
        
        %% 验证输出结果
        if isempty(NameSigOutReq)
            error('findNameAutosar:emptyResult', '解析结果为空');
        end

        %% 验证长度
        if length(NameSigOutReq) > 63
            NameSigOut = NameSigOutReq(1:63);
            warning('findNameAutosar:truncatedLength', '信号名称长度超过63个字符，%s ----截取----> %s', NameSigOutReq, NameSigOut);
        else
            NameSigOut = NameSigOutReq;
        end

    catch ME
        error('findNameAutosar:processingError', '处理信号名称时发生错误: %s', ME.message);
    end

end