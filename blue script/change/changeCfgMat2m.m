function changeCfgMat2m(mdName, varargin)
%CHANGECFGMAT2M 将配置文件从MAT格式转换为M格式
%   CHANGECFGMAT2M(MDNAME, Name, Value, ...) 将指定模型的配置从MAT格式转换为M格式
%
%   必需参数:
%      mdName       - 模型名称 (字符串)
%
%   可选参数 (名称-值对):
%      'OutputFile' - 输出M文件名 (字符串, 默认: 基于模型名称自动生成)
%      'CloseModel' - 是否关闭模型 (逻辑值, 默认: false)
%
%   功能描述:
%      1. 获取模型中激活的配置集
%      2. 如果配置集是引用配置，则获取其引用的实际配置集
%      3. 将配置集保存为M格式文件
%      4. 根据参数决定是否关闭模型
%
%   示例:
%      % 基本用法
%      changeCfgMat2m('TmComprCtrl')
%      
%      % 指定输出文件名
%      changeCfgMat2m('TmComprCtrl', 'OutputFile', 'MyConfig.m')
%      
%      % 指定所有参数，转换后关闭模型
%      changeCfgMat2m('TmComprCtrl', 'OutputFile', 'MyConfig.m', 'CloseModel', true)
%
%   注意事项:
%      1. 使用前需要确保模型文件存在
%      2. 如果未指定输出文件名，将基于模型名称自动生成
%      3. 如果配置集是引用配置，将自动获取其引用的实际配置集
%      4. 输出文件将保存为MATLAB脚本格式(.m)
%
%   参见: SIMULINK.CONFIGSET, SIMULINK.CONFIGSETREF, GETACTIVECONFIGSET, INPUTPARSER
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 202501118

    %% 参数解析和验证
    % 验证必需参数
    validateattributes(mdName, {'char', 'string'}, {'scalartext'}, mfilename, 'mdName', 1);
    mdName = char(mdName);
    
    % 创建输入解析器
    p = inputParser;
    p.FunctionName = mfilename;
    
    % 生成默认输出文件名
    defaultOutputFile = [mdName '_Config.m'];
    
    % 添加可选参数
    addParameter(p, 'OutputFile', defaultOutputFile, @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'CloseModel', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    
    % 解析输入参数
    parse(p, varargin{:});
    
    % 提取参数值
    outputFile = char(p.Results.OutputFile);
    CloseModel = p.Results.CloseModel;
    
    % 确保输出文件扩展名为.m
    [~, ~, ext] = fileparts(outputFile);
    if isempty(ext) || ~strcmpi(ext, '.m')
        outputFile = [outputFile '.m'];
    end

    %% 加载模型
    try
        h = load_system(mdName);
    catch ME
        error('MATLAB:changeCfgMat2m:ModelLoadFailed', ...
              '无法加载模型 "%s": %s', mdName, ME.message);
    end

    %% 获取激活的配置集
    try
        cs_ref = getActiveConfigSet(mdName);
        
        % 判断是否是引用配置，如果是，先将其转换成实际的配置
        if isa(cs_ref, 'Simulink.ConfigSetRef')
            actual_cs = getRefConfigSet(cs_ref);
        else
            actual_cs = cs_ref;
        end
    catch ME
        if CloseModel
            close_system(h);
        end
        error('MATLAB:changeCfgMat2m:ConfigSetFailed', ...
              '获取配置集失败: %s', ME.message);
    end

    %% 将配置文件从MAT格式转换为M格式
    try
        % 将实际配置集保存为.m文件
        actual_cs.saveAs(outputFile);
        fprintf('配置已成功保存为: %s\n', outputFile);
    catch ME
        if CloseModel
            close_system(h);
        end
        error('MATLAB:changeCfgMat2m:SaveFailed', ...
              '保存配置文件失败: %s', ME.message);
    end

    %% 关闭模型（如果需要）
    if CloseModel
        try
            close_system(h);
            fprintf('模型 "%s" 已关闭\n', mdName);
        catch ME
            warning('MATLAB:changeCfgMat2m:CloseFailed', ...
                    '关闭模型失败: %s', ME.message);
        end
    end
end