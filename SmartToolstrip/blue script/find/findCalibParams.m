function calibParams = findCalibParams(path, varargin)
%FINDCALIBPARAMS 查找模型中的标定量
%   CALIBPARAMS = FINDCALIBPARAMS(PATH) 在指定路径查找标定量
%   CALIBPARAMS = FINDCALIBPARAMS(PATH, 'Parameter', Value, ...) 使用指定参数查找标定量
%
%   输入参数:
%      path         - 模型路径或句柄 (字符串或数值)
%
%   可选参数（名值对）:
%      'SearchDepth'   - 搜索深度 (正整数或'all'), 默认值: 1
%                      1表示仅当前层，'all'表示所有层级
%      'SkipMask'      - 是否跳过Mask子系统内部 (逻辑值), 默认值: true
%      'SkipLib'       - 是否跳过库链接 (逻辑值), 默认值: true
%
%   输出参数:
%      calibParams  - 找到的标定量列表 (元胞数组)
%
%   功能描述:
%      查找Simulink模型中的标定量，首先尝试使用Simulink.findVars（R2016b或更高版本），
%      如果失败则使用传统方法。支持多种标定量来源：
%      - 模型工作区变量
%      - Mask参数值
%      - 模块参数
%      - 常量块
%      - 查找表
%      - 增益块
%      - 等等
%
%   示例:
%      params = findCalibParams(gcs)
%      params = findCalibParams(gcs, 'SearchDepth', 'all')
%
%   参见: FINDCALIBPARAMSTRADITIONAL, FINDMASKPARAMS, SIMULINK.FINDVARS
%
%   作者: Blue.ge
%   版本: 1.2
%   日期: 20250312

    %% 输入参数处理
    p = inputParser;
    addRequired(p, 'path', @(x)ischar(x) || isnumeric(x) || ishandle(x));
    addParameter(p, 'SearchDepth', 1, @(x)isnumeric(x) || (ischar(x) && strcmp(x, 'all')));
    addParameter(p, 'SkipMask', true, @islogical);
    addParameter(p, 'SkipLib', true, @islogical);
    
    % 解析输入参数
    parse(p, path, varargin{:});
    
    % 获取参数值
    path = p.Results.path;
    searchDepth = p.Results.SearchDepth;
    skipMask = p.Results.SkipMask;
    skipLib = p.Results.SkipLib;
    
    % 验证路径
    try
        if ~ischar(path)
            path = getfullname(path);
        end
    catch
        error('无效的模型路径或句柄');
    end
    
    %% 查找标定量
    calibParams = {};
    
    try
        % 检查MATLAB版本，R2016b(9.1)或更高版本支持Simulink.findVars
        if ~verLessThan('matlab', '9.1') && strcmp(searchDepth,'all')

            vars = Simulink.findVars(path,'SourceType','base workspace');

            
            % 处理找到的变量
            if ~isempty(vars)
                for i = 1:length(vars)
                    try
                        varName = vars(i).Name;
                        
                        % 排除内置常量和特殊变量
                        if ~any(strcmp(varName, {'pi', 'inf', 'nan', 'eps', 'realmax', 'realmin', 'const'})) && ...
                            isvarname(varName) && ~isempty(regexp(varName, '^[A-Za-z]', 'once'))
                            calibParams{end+1} = varName;
                        end
                    catch
                        % 如果无法处理某个变量，继续下一个
                        continue;
                    end
                end
            end
            
            % 如果找到了变量，不再使用传统方法
            if ~isempty(calibParams)
                calibParams = unique(calibParams);
                return;
            end
        end
        
        % 如果上面的方法未找到变量或者MATLAB版本较低，使用传统方法
        traditional_params = findCalibParamsTraditional(path, ...
                                'SearchDepth', searchDepth, ...
                                'SkipMask', skipMask, ...
                                'SkipLib', skipLib);
        
        % 合并结果
        calibParams = [calibParams, traditional_params];
        calibParams = unique(calibParams);
        
    catch ME
        warning('查找标定量失败: %s\n使用传统方法继续...', ME.message);
        % 出错时仍然尝试使用传统方法
        calibParams = findCalibParamsTraditional(path, ...
                        'SearchDepth', searchDepth, ...
                        'SkipMask', skipMask, ...
                        'SkipLib', skipLib);
    end
end