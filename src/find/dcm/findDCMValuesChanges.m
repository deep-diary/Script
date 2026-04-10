function changes = findDCMValuesChanges(filepath1, filepath2, varargin)
%FINDDCMVALUESCHANGES 比较两个DCM文件中参数值的差异
%   CHANGES = FINDDCMVALUESCHANGES(FILEPATH1, FILEPATH2) 比较两个DCM文件中
%   标定量的具体值，找出发生变化的参数及其变化情况
%
%   CHANGES = FINDDCMVALUESCHANGES(FILEPATH1, FILEPATH2, 'Parameter', Value, ...)
%   使用指定的参数比较DCM文件
%
%   输入参数:
%      filepath1    - 基准DCM文件的完整路径
%      filepath2    - 比较DCM文件的完整路径
%
%   可选参数（名值对）:
%      'Tolerance'     - 浮点数比较容差 (数值), 默认值: 1e-6
%      'ShowDetails'   - 是否显示详细变化信息 (逻辑值), 默认值: true
%      'OnlyCommon'    - 是否只比较共有参数 (逻辑值), 默认值: true
%      'IgnoreType'    - 要忽略的参数类型 (元胞数组), 默认值: {}
%                        可能的值: {'FESTWERT', 'STUETZSTELLENVERTEILUNG', 
%                                   'FESTWERTEBLOCK', 'GRUPPENKENNLINIE', 'GRUPPENKENNFELD'}
%
%   输出参数:
%      changes      - 包含参数值变化的结构体数组，每个结构体包含以下字段:
%                     .name      - 参数名称
%                     .type      - 参数类型
%                     .oldValue  - 旧值
%                     .newValue  - 新值
%                     .diff      - 差值或差异描述
%
%   示例:
%      diff = findDCMValuesChanges('HY11_PCMU_Tm_OTA3_V6050327_All.DCM', 'HY11_PCMU_Tm_OTA3_V6060416_All.DCM');
%      diff = findDCMValuesChanges('HY11_VCU_Tm_OTA2_V4100303_All_V2.DCM', 'HY11_PCMU_Tm_OTA3_V6040303_All.DCM')
%      diff = findDCMValuesChanges('HY11_PCMU_Tm_OTA3_V6030217_All.DCM', 'HY11_PCMU_Tm_OTA3_V6040303_All.DCM', 'Tolerance', 1e-4, 'ShowDetails', false);
%
%   参见: FINDDCMNAMES, FINDDCMPARAM, FINDDCMNAMESCHANGES
%
%   作者: Blue.ge
%   版本: 1.2
%   日期: 20250330

    %% 输入参数处理
    p = inputParser;
    addRequired(p, 'filepath1', @ischar);
    addRequired(p, 'filepath2', @ischar);
    addParameter(p, 'Tolerance', 1e-6, @isnumeric);
    addParameter(p, 'ShowDetails', true, @islogical);
    addParameter(p, 'OnlyCommon', true, @islogical);
    addParameter(p, 'IgnoreType', {}, @iscell);
    
    % 解析输入参数
    parse(p, filepath1, filepath2, varargin{:});
    
    filepath1 = p.Results.filepath1;
    filepath2 = p.Results.filepath2;
    tolerance = p.Results.Tolerance;
    showDetails = p.Results.ShowDetails;
    onlyCommon = p.Results.OnlyCommon;
    ignoreType = p.Results.IgnoreType;
    
    % 参数类型名称映射
    typeNames = {'常量', '轴定义', '值块', '一维表', '二维表'};
    typeKeys = {'FESTWERT', 'STUETZSTELLENVERTEILUNG', 'FESTWERTEBLOCK', 'GRUPPENKENNLINIE', 'GRUPPENKENNFELD'};
    
    %% 检查文件是否存在
    if ~exist(filepath1, 'file')
        error('基准文件不存在: %s', filepath1);
    end
    if ~exist(filepath2, 'file')
        error('比较文件不存在: %s', filepath2);
    end
    
    %% 解析两个DCM文件
    try
        fprintf('正在解析基准文件 %s...\n', filepath1);
        params1 = findDCMParam(filepath1);
        fprintf('正在解析比较文件 %s...\n', filepath2);
        params2 = findDCMParam(filepath2);
    catch ME
        error('解析DCM文件时出错: %s', ME.message);
    end
    
    %% 获取并组织文件中的参数信息
    paramMap1 = containers.Map(); % 使用Map存储参数信息，便于快速查找
    paramMap2 = containers.Map();
    
    % 遍历所有参数类型
    for typeIdx = 1:length(params1)
        if ismember(typeKeys{typeIdx}, ignoreType)
            continue; % 跳过被忽略的类型
        end
        
        % 处理文件1中的参数
        for i = 1:length(params1{typeIdx})
            param = params1{typeIdx}(i);
            if ~isKey(paramMap1, param.name)
                paramMap1(param.name) = struct('type', typeIdx, 'data', param);
            end
        end
    end
    
    % 遍历所有参数类型
    for typeIdx = 1:length(params2)
        if ismember(typeKeys{typeIdx}, ignoreType)
            continue; % 跳过被忽略的类型
        end
        
        % 处理文件2中的参数
        for i = 1:length(params2{typeIdx})
            param = params2{typeIdx}(i);
            if ~isKey(paramMap2, param.name)
                paramMap2(param.name) = struct('type', typeIdx, 'data', param);
            end
        end
    end
    
    %% 准备比较参数
    changes = struct('name', {}, 'type', {}, 'oldValue', {}, 'newValue', {}, 'diff', {});
    
    % 获取两个文件的参数名称
    names1 = keys(paramMap1);
    names2 = keys(paramMap2);
    
    % 确定要比较的参数
    if onlyCommon
        % 只比较共有参数
        commonNames = intersect(names1, names2);
        paramNames = commonNames;
    else
        % 比较所有参数
        paramNames = union(names1, names2);
    end
    
    fprintf('开始比较参数值...\n');
    
    %% 比较参数值
    for i = 1:length(paramNames)
        paramName = paramNames{i};
        
        % 检查参数是否在两个文件中都存在
        if ~isKey(paramMap1, paramName) || ~isKey(paramMap2, paramName)
            continue;
        end
        
        % 获取参数信息
        paramInfo1 = paramMap1(paramName);
        paramInfo2 = paramMap2(paramName);
        
        % 检查参数类型是否相同
        if paramInfo1.type ~= paramInfo2.type
            continue;
        end
        
        typeIdx = paramInfo1.type;
        param1 = paramInfo1.data;
        param2 = paramInfo2.data;
        
        % 根据参数类型进行比较
        switch typeIdx
            case 1 % 常量 FESTWERT
                % 检查值
                if ~isfield(param1, 'wert') || ~isfield(param2, 'wert')
                    continue;
                end
                
                % 获取值
                oldVal = param1.wert;
                newVal = param2.wert;
                
                % 比较值
                if abs(oldVal - newVal) > tolerance
                    % 计算差值
                    diff = newVal - oldVal;
                    
                    % 记录变化
                    changes(end+1) = struct('name', paramName, ...
                                           'type', typeIdx, ...
                                           'oldValue', oldVal, ...
                                           'newValue', newVal, ...
                                           'diff', diff);
                end
                
            case 2 % 轴定义 STUETZSTELLENVERTEILUNG
                % 检查x轴
                if ~isfield(param1, 'x') || ~isfield(param2, 'x')
                    continue;
                end
                
                % 比较x轴
                if ~isequal(size(param1.x), size(param2.x))
                    changes(end+1) = struct('name', paramName, ...
                                           'type', typeIdx, ...
                                           'oldValue', {param1.x}, ...
                                           'newValue', {param2.x}, ...
                                           'diff', '轴大小变化');
                elseif any(abs(param1.x - param2.x) > tolerance)
                    changes(end+1) = struct('name', paramName, ...
                                           'type', typeIdx, ...
                                           'oldValue', {param1.x}, ...
                                           'newValue', {param2.x}, ...
                                           'diff', '轴值变化');
                end
                
            case 3 % 值块 FESTWERTEBLOCK
                % 检查值
                if ~isfield(param1, 'wert') || ~isfield(param2, 'wert')
                    continue;
                end
                
                % 比较值
                if ~isequal(size(param1.wert), size(param2.wert))
                    changes(end+1) = struct('name', paramName, ...
                                          'type', typeIdx, ...
                                          'oldValue', {param1.wert}, ...
                                          'newValue', {param2.wert}, ...
                                          'diff', '值块大小变化');
                elseif any(abs(param1.wert - param2.wert) > tolerance)
                    changes(end+1) = struct('name', paramName, ...
                                          'type', typeIdx, ...
                                          'oldValue', {param1.wert}, ...
                                          'newValue', {param2.wert}, ...
                                          'diff', '值块内容变化');
                end
                
            case 4 % 一维表 GRUPPENKENNLINIE
                % 检查x轴和值
                if ~isfield(param1, 'x') || ~isfield(param2, 'x') || ...
                   ~isfield(param1, 'wert') || ~isfield(param2, 'wert')
                    continue;
                end
                
                % 比较x轴
                xDiff = false;
                if ~isequal(size(param1.x), size(param2.x))
                    xDiff = true;
                    changes(end+1) = struct('name', [paramName '_X'], ...
                                          'type', typeIdx, ...
                                          'oldValue', {param1.x}, ...
                                          'newValue', {param2.x}, ...
                                          'diff', 'X轴大小变化');
                elseif any(abs(param1.x - param2.x) > tolerance)
                    xDiff = true;
                    changes(end+1) = struct('name', [paramName '_X'], ...
                                          'type', typeIdx, ...
                                          'oldValue', {param1.x}, ...
                                          'newValue', {param2.x}, ...
                                          'diff', 'X轴值变化');
                end
                
                % 比较值
                if ~isequal(size(param1.wert), size(param2.wert))
                    changes(end+1) = struct('name', [paramName '_Val'], ...
                                          'type', typeIdx, ...
                                          'oldValue', {param1.wert}, ...
                                          'newValue', {param2.wert}, ...
                                          'diff', '值大小变化');
                elseif any(abs(param1.wert - param2.wert) > tolerance)
                    changes(end+1) = struct('name', [paramName '_Val'], ...
                                          'type', typeIdx, ...
                                          'oldValue', {param1.wert}, ...
                                          'newValue', {param2.wert}, ...
                                          'diff', '值内容变化');
                end
                
            case 5 % 二维表 GRUPPENKENNFELD
                % 检查x轴、y轴和值
                if ~isfield(param1, 'x') || ~isfield(param2, 'x') || ...
                   ~isfield(param1, 'y') || ~isfield(param2, 'y') || ...
                   ~isfield(param1, 'wert') || ~isfield(param2, 'wert')
                    continue;
                end
                
                % 比较x轴
                if ~isequal(size(param1.x), size(param2.x))
                    changes(end+1) = struct('name', [paramName '_X'], ...
                                          'type', typeIdx, ...
                                          'oldValue', {param1.x}, ...
                                          'newValue', {param2.x}, ...
                                          'diff', 'X轴大小变化');
                elseif any(abs(param1.x - param2.x) > tolerance)
                    changes(end+1) = struct('name', [paramName '_X'], ...
                                          'type', typeIdx, ...
                                          'oldValue', {param1.x}, ...
                                          'newValue', {param2.x}, ...
                                          'diff', 'X轴值变化');
                end
                
                % 比较y轴
                if ~isequal(size(param1.y), size(param2.y))
                    changes(end+1) = struct('name', [paramName '_Y'], ...
                                          'type', typeIdx, ...
                                          'oldValue', {param1.y}, ...
                                          'newValue', {param2.y}, ...
                                          'diff', 'Y轴大小变化');
                elseif any(abs(param1.y - param2.y) > tolerance)
                    changes(end+1) = struct('name', [paramName '_Y'], ...
                                          'type', typeIdx, ...
                                          'oldValue', {param1.y}, ...
                                          'newValue', {param2.y}, ...
                                          'diff', 'Y轴值变化');
                end
                
                % 比较值矩阵
                if ~isequal(size(param1.wert), size(param2.wert))
                    changes(end+1) = struct('name', [paramName '_Val'], ...
                                          'type', typeIdx, ...
                                          'oldValue', {param1.wert}, ...
                                          'newValue', {param2.wert}, ...
                                          'diff', '值矩阵大小变化');
                else
                    % 如果大小相同，逐元素比较
                    diffMatrix = abs(param1.wert - param2.wert) > tolerance;
                    if any(diffMatrix(:))
                        changes(end+1) = struct('name', [paramName '_Val'], ...
                                              'type', typeIdx, ...
                                              'oldValue', {param1.wert}, ...
                                              'newValue', {param2.wert}, ...
                                              'diff', '值矩阵内容变化');
                    end
                end
        end
    end
    
    %% 显示比较结果
    if isempty(changes)
        fprintf('未发现参数值的变化。\n');
    else
        fprintf('发现 %d 个参数值有变化:\n', length(changes));
        
        if showDetails
            fprintf('--------------------------------------------------------------\n');
            fprintf('%-30s %-15s %-30s\n', '参数名称', '类型', '变化描述');
            fprintf('--------------------------------------------------------------\n');
            
            for i = 1:length(changes)
                change = changes(i);
                typeName = typeNames{change.type};
                
                % 根据参数类型格式化变化描述
                switch change.type
                    case 1 % 常量
                        if ischar(change.diff)
                            diffDesc = change.diff;
                        else
                            diffDesc = sprintf('%.6g -> %.6g (变化: %.6g)', ...
                                        change.oldValue, change.newValue, change.diff);
                        end
                        
                    case {2, 3, 4, 5} % 轴定义、值块、一维表或二维表
                        diffDesc = change.diff;
                end
                
                fprintf('%-30s %-15s %-30s\n', change.name, typeName, diffDesc);
            end
            fprintf('--------------------------------------------------------------\n');
        end
    end
    
    % 如果没有输出参数，则不需要返回结果
    if nargout == 0
        clear changes;
    end
end 