function annotationBlocks = findAnnotation(varargin)
%FINDANNOTATION 查找模型中的注释模块
%   ANNOTATIONBLOCKS = FINDANNOTATION() 在当前系统中查找所有注释模块
%   ANNOTATIONBLOCKS = FINDANNOTATION('Parameter', Value, ...) 使用指定参数查找注释模块
%
%   输入参数（名值对）:
%      'path'            - 目标系统路径 (字符串), 默认值: gcs (当前系统)
%      'ForegroundColor' - 前景颜色 (字符串), 默认值: [] (任意颜色)
%      'BackgroundColor' - 背景颜色 (字符串或数组), 默认值: [] (任意颜色)
%      'UserData'        - 用户数据 (任意类型), 默认值: [] (任意用户数据)
%      'Text'            - 注释文本内容 (字符串), 默认值: [] (任意文本)
%      'Name'            - 注释名称 (字符串), 默认值: [] (任意名称)
%      'ShowInfo'        - 是否显示注释信息 (逻辑值), 默认值: false
%
%   输出参数:
%      annotationBlocks  - 找到的注释模块句柄列表 (数组)
%
%   功能描述:
%      查找指定模型中符合条件的注释模块，可以按颜色、文本内容、名称等条件过滤。
%      可以选择是否显示找到的注释模块的详细信息。
%
%   示例:
%      blocks = findAnnotation()
%      blocks = findAnnotation('path', 'myModel/subsystem1')
%      blocks = findAnnotation('ForegroundColor', 'blue', 'ShowInfo', true)
%      blocks = findAnnotation('Text', '模型信息', 'Name', 'SubmodInfo')
%
%   参见: FIND_SYSTEM, GET_PARAM, GCS
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 20250312

    %% 输入参数处理
    p = inputParser;
    addParameter(p, 'path', gcs, @ischar);
    addParameter(p, 'ForegroundColor', 'blue', @(x)isempty(x) || ischar(x) || isnumeric(x));
    addParameter(p, 'BackgroundColor', [], @(x)isempty(x) || ischar(x) || isnumeric(x));
    addParameter(p, 'UserData', [], @(x)true); % 允许任何类型
    addParameter(p, 'Text', [], @(x)isempty(x) || ischar(x) || isstring(x));
    addParameter(p, 'Name', [], @(x)isempty(x) || ischar(x) || isstring(x));
    addParameter(p, 'ShowInfo', true, @islogical);
    
    parse(p, varargin{:});
    
    path = p.Results.path;
    ForegroundColor = p.Results.ForegroundColor;
    BackgroundColor = p.Results.BackgroundColor;
    UserData = p.Results.UserData;
    Text = p.Results.Text;
    Name = p.Results.Name;
    ShowInfo = p.Results.ShowInfo;
    
    %% 构建查找参数
    findParams = {'FindAll', 'on', 'Type', 'annotation'};
    
    % 添加可选过滤条件
    if ~isempty(ForegroundColor)
        findParams = [findParams, 'ForegroundColor', ForegroundColor];
    end
    
    if ~isempty(BackgroundColor)
        findParams = [findParams, 'BackgroundColor', BackgroundColor];
    end
    
    if ~isempty(UserData)
        findParams = [findParams, 'UserData', UserData];
    end
    
    if ~isempty(Name)
        findParams = [findParams, 'Name', Name];
    end
    
    %% 查找注释模块
    try
        % 查找符合条件的注释模块
        annotationBlocks = find_system(path, findParams{:});
        
        % 如果指定了文本内容，进行额外过滤
        if ~isempty(Text)
            filteredBlocks = [];
            for i = 1:length(annotationBlocks)
                try
                    blockText = get_param(annotationBlocks(i), 'Text');
                    if contains(blockText, Text)
                        filteredBlocks = [filteredBlocks; annotationBlocks(i)];
                    end
                catch
                    % 跳过无法获取文本的块
                    continue;
                end
            end
            annotationBlocks = filteredBlocks;
        end
        
        % 显示注释信息
        if ShowInfo && ~isempty(annotationBlocks)
            displayAnnotationInfo(annotationBlocks)
        end
        
        % 如果没有找到注释模块，显示提示
        if isempty(annotationBlocks) && ShowInfo
            disp('未找到符合条件的注释模块。');
        end
    catch ME
        warning('查找注释模块失败: %s', ME.message);
        annotationBlocks = [];
    end
end

function displayAnnotationInfo(annotationBlocks)
    % 显示注释模块的详细信息
    fprintf('\n找到 %d 个注释模块:\n', length(annotationBlocks));
    fprintf('----------------------------------------\n');
    
    for idx = 1:length(annotationBlocks)
        try
            % 获取注释属性
            name = get_param(annotationBlocks(idx), 'Name');
            text = get_param(annotationBlocks(idx), 'Text');
            position = get_param(annotationBlocks(idx), 'Position');
            fgColor = get_param(annotationBlocks(idx), 'ForegroundColor');
            bgColor = get_param(annotationBlocks(idx), 'BackgroundColor');
            
            % 截断过长的文本
            if length(text) > 50
                displayText = [text(1:47), '...'];
            else
                displayText = text;
            end
            
            % 显示信息
            fprintf('注释 %d: %s\n', idx, name);
            fprintf('  位置: [%d, %d, %d, %d]\n', position(1), position(2), position(3), position(4));
            fprintf('  前景色: %s\n', mat2str(fgColor));
            fprintf('  背景色: %s\n', mat2str(bgColor));
            fprintf('  文本: %s\n', displayText);
            fprintf('----------------------------------------\n');
        catch
            fprintf('注释 %d: 无法获取完整信息\n', idx);
            fprintf('----------------------------------------\n');
        end
    end
end