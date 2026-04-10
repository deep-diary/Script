function changeModSize(pathMd, varargin)
%CHANGEMODSIZE 根据端口数量调整Simulink模型的大小
%   CHANGEMODSIZE(PATHMD) 使用默认宽度调整指定模型的大小
%   CHANGEMODSIZE(PATHMD, 'Parameter', Value, ...) 使用指定参数调整模型大小
%
%   输入参数:
%      pathMd       - 模型路径或句柄 (字符串或数值)
%
%   可选参数（名值对）:
%      'wid'        - 模型最小宽度 (正整数), 默认值: 400
%      'minHeight'  - 模型最小高度 (正整数), 默认值: 60
%      'portStep'   - 端口间距 (正整数), 默认值: 30
%
%   功能描述:
%      根据模型的输入输出端口数量，自动调整模型的大小。
%      模型宽度至少为指定的'wid'值，高度根据端口数量自动计算。
%      调整后会自动整理模型内部的连线。
%
%   示例:
%      changeModSize(gcb)
%      changeModSize('myModel/subsystem1')
%      changeModSize(gcb, 'wid', 600, 'minHeight', 100)
%
%   注意事项:
%      1. 函数会自动跳过MATLAB内置的模块（如Compare To Constant等）
%      2. 对于没有端口的模型，会使用最小尺寸
%
%   参见: GET_PARAM, SET_PARAM, FINDMODPORTS, CHANGELINEARRANGE
%
%   作者: Blue.ge
%   版本: 1.1
%   日期: 20231020

    %% 输入参数处理
    p = inputParser;
    addRequired(p, 'pathMd', @(x)validateattributes(x,{'char','string','double'},{'nonempty'}));
    addParameter(p, 'wid', 400, @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
    addParameter(p, 'minHeight', 60, @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
    addParameter(p, 'portStep', 30, @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
    
    parse(p, pathMd, varargin{:});
    
    pathMd = p.Results.pathMd;
    wid = p.Results.wid;
    minHeight = p.Results.minHeight;
    portStep = p.Results.portStep;

    %% 检查模型类型，跳过内置模块
    try
        % 获取模型类型
        blockType = get_param(pathMd, 'BlockType');
        
        % 获取模型源
        blockSource = get_param(pathMd, 'MaskType');
        if ~isempty(blockSource)
            % 检查是否为内置模块
            if ~strcmp(blockType, 'SubSystem') || ...
               ~isempty(regexp(blockSource, '^(Compare|Logical|Math|Bitwise)', 'once'))
                disp(['跳过内置模块: ' get_param(pathMd, 'Name')]);
                return;
            end
        end
        
        % 检查是否为内置子系统
        if strcmp(blockType, 'SubSystem')
            % 获取子系统的标签
            tags = get_param(pathMd, 'Tag');
            if ~isempty(tags) && any(strcmp(tags, {'MATLAB Function', 'Stateflow'}))
                disp(['跳过内置子系统: ' get_param(pathMd, 'Name')]);
                return;
            end
        end
    catch ME
        warning('无法确定模块类型，将尝试调整大小: %s', ME.message);
    end
    
    %% 获取模型信息并计算新尺寸
    try
        % 获取模型句柄
        h = get_param(pathMd, 'Handle');
        
        % 获取模型端口信息
        [~, PortsIn, PortsOut, PortsSpecial] = findModPorts(pathMd);
        
        % 计算端口总数
        portNum = max(length(PortsIn), length(PortsOut));
        
        % 计算目标尺寸
        targetWid = max(wid, 300);
        targetHeight = max(portNum * portStep, minHeight);
        
        % 获取当前位置并计算新位置
        pos = get_param(h, 'Position');
        posNew = [pos(1:2), pos(1) + targetWid, pos(2) + targetHeight];
        
        % 设置新位置
        set_param(h, 'Position', posNew);
        
        % 整理连线
        changeLineArrange('path', pathMd);
        
        disp(['已调整模型大小: ' get_param(pathMd, 'Name')]);
    catch ME
        warning('调整模型大小失败: %s', ME.message);
    end
end