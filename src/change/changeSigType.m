function changeSigType(sigName, varargin)
%CHANGESIGTYPE 更改指定信号的端口数据类型
%   CHANGESIGTYPE(SIGNAME, TYPE) 使用默认参数更改信号的数据类型
%   CHANGESIGTYPE(SIGNAME, TYPE, 'Parameter', Value, ...) 使用指定参数更改
%
%   输入参数:
%      sigName      - 信号名称 (字符串)
%      type         - 目标数据类型 (字符串)
%
%   可选参数（名值对）:
%      'allLev'     - 是否在全局范围内搜索, 默认值: true
%      'fromSigName'- 是否根据信号名称自动判断类型, 默认值: true
%
%   功能描述:
%      1. 根据参数设置搜索指定信号的所有端口
%      2. 根据信号名称或指定类型更新端口数据类型
%      3. 支持输入端口和输出端口的处理
%      4. 可选择在全局或当前系统范围内搜索
%
%   示例:
%      % 基本用法
%      changeSigType('rTmComprCtrl_n_s32CompRpmReqModeOut')
%      changeSigType('rTmComprCtrl_n_s32CompRpmReqModeOut', 'type', 'uint16')
%
%      % 根据信号名
%      changeSigType('rTmComprCtrl_n_s32CompRpmReqModeOut', 'fromSigName', true)
%
%      % 在当前系统范围内搜索并更新
%      changeSigType('rTmComprCtrl_n_s32CompRpmReqModeOut', 'single', 'allLev', true)
%
%   注意事项:
%      1. 使用前需要确保模型已打开
%      2. 数据类型更改会立即生效
%      3. 如果fromSigName为true，将忽略type参数
%      4. 支持的数据类型包括: single, uint8, int32等
%
%   参见: FINDNAMETYPE
%
%   作者: Blue.ge
%   版本: 1.1
%   日期: 20240109

    %% 参数解析
    p = inputParser;
    addParameter(p, 'type', 'Inherit: auto');
    addParameter(p, 'allLev', true);
    addParameter(p, 'fromSigName', true);
    
    parse(p, varargin{:});
    
    allLev = p.Results.allLev;
    fromSigName = p.Results.fromSigName;
    type = p.Results.type;

    %% 确定搜索范围
    if allLev
        searchRoot = bdroot;
    else
        searchRoot = gcs;
    end

    %% 查找输入和输出端口
    inPorts = find_system(searchRoot, 'BlockType', 'Inport', 'Name', sigName);
    outPorts = find_system(searchRoot, 'BlockType', 'Outport', 'Name', sigName);
    ports = [inPorts; outPorts];

    %% 确定数据类型
    if fromSigName
        [typeNew, ~, ~, ~, ~] = findNameType(sigName);
    end
    if ~strcmp(type, 'Inherit: auto')
        typeNew = type;
    end

    %% 更新端口数据类型
    for i = 1:length(ports)
        set_param(ports{i}, 'OutDataTypeStr', typeNew);
    end
end