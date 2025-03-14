function [dataType, nameOutPort] = findNameMdOut(Name, varargin)
%FINDNAMEMDOUT 根据信号名获取信号类型并生成带模型前缀的输出信号名
%   [DATATYPE, NAMEOUTPORT] = FINDNAMEMDOUT(NAME) 使用默认参数处理信号名
%   [DATATYPE, NAMEOUTPORT] = FINDNAMEMDOUT(NAME, 'Parameter', Value, ...) 使用指定参数处理
%
%   输入参数:
%      Name         - 信号名称 (字符串)
%                     标准格式: '<前缀>_<类型>_<信号名>'
%                     示例: 'sTmComprCtrl_D_u32AcOffCode'
%
%   可选参数（名值对）:
%      'mode'       - 信号名称处理模式 (字符串), 默认值: 'keep'
%                     可选值: 
%                     'pre'  - 将前缀替换为当前模型名称
%                     'tail' - 将模型名称添加到后缀
%                     'keep' - 保持原始信号名不变
%
%   输出参数:
%      dataType     - 信号类型 (字符串), 例如: 'D'(数字), 'B'(布尔)等
%      nameOutPort  - 处理后的输出信号名称 (字符串)
%
%   功能描述:
%      根据输入的信号名称，提取信号类型，并根据指定的模式生成带有模型前缀的输出信号名称。
%      当前模型名称会被用于生成新的信号名称（在'pre'或'tail'模式下）。
%
%   示例:
%      % 假设当前模型名称为'CurrrentMode'
%      [type, outName] = findNameMdOut('sTmComprCtrl_D_u32AcOffCode')
%      % 返回: type = 'D', outName = 'sTmComprCtrl_D_u32AcOffCode'
%
%      [type, outName] = findNameMdOut('sTmComprCtrl_D_u32AcOffCode', 'mode', 'pre')
%      % 返回: type = 'D', outName = 'sCurrrentMode_D_u32AcOffCode'
%
%   注意事项:
%      1. 信号名称应遵循标准格式，否则可能无法正确解析
%      2. 'pre'模式会根据信号类型自动选择适当的前缀字母(s/y/r/x)
%
%   参见: FINDNAMETYPE, FINDNAMEMD, SPLIT
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 20231213

    %% 输入参数处理
    p = inputParser;
    addRequired(p, 'Name', @(x)validateattributes(x,{'char','string'},{'nonempty'}));
    addParameter(p, 'mode', 'keep', @(x)ismember(x,{'pre','tail','keep'}));
    
    parse(p, Name, varargin{:});
    
    Name = p.Results.Name;
    mode = p.Results.mode;
    
    %% 获取信号类型和当前模型名称
    [dataType, ~, ~, ~, ~] = findNameType(Name);
    
    % 获取当前模型名称并处理
    currentModelName = get_param(gcs, 'Name');
    modelBaseName = findNameMd(currentModelName);
    modelBaseName(1) = upper(modelBaseName(1)); % 将首字母改成大写
    
    % 分割信号名
    strList = split(Name, '_');
    
    %% 处理信号名称
    % 如果只有1个部分，则不进行解析
    if length(strList) == 1
        nameOutPort = Name;
        return
    end
    
    %% 根据模式处理信号名称
    if strcmp(mode, 'pre') && length(strList) == 3
        % 前缀模式：替换信号前缀为模型名称
        
        % 根据模型层级和信号类型确定前缀字母
        if strcmp(get_param(gcs, 'Name'), bdroot)  % 顶层模型
            if strcmp(strList{2}, 'B')
                prefix = 'y'; % 布尔类型输出信号
            else
                prefix = 's'; % 其他类型输出信号
            end        
        else  % 子模型
            if strcmp(strList{2}, 'B')
                prefix = 'x'; % 布尔类型输出信号
            else
                prefix = 'r'; % 其他类型输出信号
            end
        end
        
        % 构建新的信号名
        strList{1} = [prefix, modelBaseName];
        nameOutPort = join(strList, "_");
        nameOutPort = nameOutPort{1};
        
    elseif strcmp(mode, 'tail')
        % 后缀模式：在信号名后添加模型名称
        if ~strcmp(modelBaseName, bdroot)
            nameOutPort = [Name modelBaseName];
        else
            nameOutPort = Name;
        end
        
    elseif strcmp(mode, 'keep')
        % 保持模式：不修改信号名
        nameOutPort = Name;
        
    else
        % 未知模式：发出警告并保持原名
        nameOutPort = Name;
        warning('模式参数只能是: pre、tail或keep。标准信号格式为ModeName_X_SigName');
    end
end