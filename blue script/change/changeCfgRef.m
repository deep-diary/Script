function changeCfgRef(mdName, varargin)
%CHANGECFGREF 更改模型的配置引用设置
%   CHANGECFGREF(MDNAME, Name, Value, ...) 为指定模型设置配置引用
%
%   必需参数:
%      mdName       - 模型名称 (字符串)
%
%   可选参数 (名称-值对):
%      'ConfigFile' - 配置文件名称 (字符串, 默认: 'Config_Climate')
%      'RefName'    - 配置引用名称 (字符串, 默认: 'Reference')
%      'CloseModel'  - 是否保存模型 (逻辑值, 默认: true)
%
%   功能描述:
%      1. 加载指定的配置文件
%      2. 为模型创建或更新配置引用
%      3. 激活新的配置引用
%      4. 根据参数决定是否保存并关闭模型
%
%   示例:
%      % 基本用法
%      changeCfgRef('TmComprCtrl')
%      
%      % 指定配置文件
%      changeCfgRef('TmComprCtrl', 'ConfigFile', 'TmVcThermal_Configuration_sub')
%      
%      % 指定配置文件和引用名称
%      changeCfgRef('TmComprCtrl', 'ConfigFile', 'MyConfig', 'RefName', 'MyRef')
%      
%      % 指定所有参数，不保存模型
%      changeCfgRef('TmComprCtrl', 'ConfigFile', 'MyConfig', 'RefName', 'MyRef', 'CloseModel', false)
%
%   注意事项:
%      1. 使用前需要确保配置文件存在
%      2. 配置文件应为.mat格式
%      3. 如果CloseModel为true，函数会自动保存并关闭模型
%      4. 如果配置引用已存在，将更新其源文件
%
%   参见: SIMULINK.CONFIGSETREF, SETACTIVECONFIGSET, INPUTPARSER
%
%   作者: Blue.ge
%   版本: 3.0
%   日期: 20250911

    %% 参数解析和验证
    % 验证必需参数
    validateattributes(mdName, {'char', 'string'}, {'scalartext'}, mfilename, 'mdName', 1);
    mdName = char(mdName);
    
    % 创建输入解析器
    p = inputParser;
    p.FunctionName = mfilename;
    
    % 添加可选参数
    addParameter(p, 'ConfigFile', 'Config_Climate', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'RefName', 'Reference', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'CloseModel', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    
    % 解析输入参数
    parse(p, varargin{:});
    
    % 提取参数值
    cfg = char(p.Results.ConfigFile);
    refName = char(p.Results.RefName);
    CloseModel = p.Results.CloseModel;

    %% 加载配置文件
    try
        load(cfg); %#ok<LOAD>
    catch ME
        warning('MATLAB:changeCfgRef:ConfigFileNotFound', ...
                '配置文件 "%s" 未找到: %s', cfg, ME.message);
    end

    %% 加载模型
    try
        h = load_system(mdName);
    catch ME
        error('MATLAB:changeCfgRef:ModelLoadFailed', ...
              '无法加载模型 "%s": %s', mdName, ME.message);
    end

    %% 配置模型引用
    try
        existingConfigSet = getConfigSet(mdName, refName);
        
        if isempty(existingConfigSet)
            % 创建新的配置引用
            configRef = Simulink.ConfigSetRef;
            set_param(configRef, 'Name', refName);
            set_param(configRef, 'SourceName', cfg);
            attachConfigSet(mdName, configRef);
        else
            % 更新现有配置引用
            set_param(existingConfigSet, 'SourceName', cfg);
        end
        
        % 激活配置引用
        setActiveConfigSet(mdName, refName);
        
    catch ME
        close_system(h);
        error('MATLAB:changeCfgRef:ConfigSetFailed', ...
              '配置引用设置失败: %s', ME.message);
    end

    %% 保存并关闭模型
    try
        save_system(h, 'SaveDirtyReferencedModels', 'on');
        fprintf('模型 "%s" 配置引用设置完成并已保存\n', mdName);
    catch ME
        warning('MATLAB:changeCfgRef:SaveFailed', ...
                '保存模型失败: %s', ME.message);
    end
    if CloseModel
        close_system(h);
    end
end

