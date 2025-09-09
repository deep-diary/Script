function [ModelName, validPath] = findValidPath(path)
%%
% 目的: 根据输入路径类型，返回有效的路径，便于find_system 函数使用
% 输入：
%       path - 模型或子系统的路径
% 返回： 
%       ModelName - 模型名称
%       validPath - 可以用于find_system的有效路径
% 范例： [ModelName, validPath] = findValidPath(path)
% 作者： Blue.ge
% 日期： 20231114
% 版本： 2.0
%%
    % 验证输入参数
    if nargin < 1 || isempty(path)
        error('必须提供有效的路径参数');
    end
    
    try
        % 使用get_param获取块类型，更安全可靠
        mdType = get_param(path, 'BlockType');
        
        if strcmp(mdType, 'SubSystem')
            ModelName = get_param(path, 'Name');
            validPath = path;
            
        elseif strcmp(mdType, 'ModelReference')
            ModelName = get_param(path, 'ModelName');
            % 确保模型已加载
            if ~bdIsLoaded(ModelName)
                load_system(ModelName);
            end
            validPath = ModelName;
            
        else
            error('不支持的块类型: %s。只支持SubSystem或ModelReference类型', mdType);
        end
        
    catch ME
        % 如果获取BlockType失败，尝试其他方法
        try
            % 检查是否是模型根
            if strcmp(path, bdroot(path))
                ModelName = path;
                validPath = path;
            else
                % 默认当作SubSystem处理
                ModelName = get_param(path, 'Name');
                validPath = path;
            end
        catch
            error('无法解析路径 "%s": %s', path, ME.message);
        end
    end
end
