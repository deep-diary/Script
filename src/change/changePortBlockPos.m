function [success, hPort, hLine, hBlock] = changePortBlockPos(portPath, newPos, varargin)
%CHANGEPORTBLOCKPOS 改变输入输出端口及其对应连线block的位置
%   [SUCCESS, HPORT, HLINE, HBLOCK] = CHANGEPORTBLOCKPOS(PORTPATH, NEWPOS) 使用默认参数改变端口位置
%   [SUCCESS, HPORT, HLINE, HBLOCK] = CHANGEPORTBLOCKPOS(PORTPATH, NEWPOS, 'Parameter', Value, ...) 使用指定参数
%
%   输入参数:
%      portPath     - 端口路径 (字符串)
%      newPos       - 新位置的起始坐标 [x y]
%
%   可选参数（名值对）:
%      'portSize'   - 端口模块尺寸 [width height], 默认值: [] (保持原尺寸)
%      'blockSize'  - 连接模块尺寸 [width height], 默认值: [] (保持原尺寸)
%      'FilterSingle' - 是否过滤单个连接模块，可选值: true, false (默认值: true)
%                      当为true时，只处理满足条件的单个连接模块
%      'portDistance' - 端口与连接模块的距离，默认值: 400 (像素)
%                      输入端口向右偏移，输出端口向左偏移
%
%   输出参数:
%      success      - 操作是否成功 (逻辑值)
%      hPort        - 端口句柄
%      hLine        - 对应线的句柄
%      hBlock       - 连接的模块句柄
%
%   功能描述:
%      1. 根据端口路径查找对应的端口、连线和模块
%      2. 检查是否找到有效的连接模块（非-1值）
%      3. 将端口移动到指定位置
%      4. 根据端口类型（输入/输出）和指定距离调整连接模块的位置
%      5. 可选择性地修改端口和连接模块的尺寸
%      6. 返回操作成功/失败状态
%
%   示例:
%      % 基本用法
%      [success, hPort, hLine, hBlock] = changePortBlockPos(gcb, [-2825 200])
%
%      % 指定模块尺寸
%      [success, hPort, hLine, hBlock] = changePortBlockPos(gcb, [-2825 200], 
%          'portSize', [30 14], 'blockSize', [150 14])
%
%      % 指定端口与连接模块的距离
%      [success, hPort, hLine, hBlock] = changePortBlockPos(gcb, [-2825 200], 
%          'portDistance', 600)
%
%      % 不过滤单个连接模块
%      [success, hPort, hLine, hBlock] = changePortBlockPos(gcb, [-2825 200], 
%          'FilterSingle', false)
%
%   注意事项:
%      1. 使用前需要打开目标Simulink模型
%      2. 输入端口对应的模块会向右偏移指定距离（默认400像素）
%      3. 输出端口对应的模块会向左偏移指定距离（默认400像素）
%      4. 如果找不到有效的连接模块，操作将失败并返回false
%      5. 端口距离可以通过portDistance参数自定义
%
%   参见: CHANGEPORTBLOCKPOSALL, FINDPORTLINEBLOCK
%
%   作者: Blue.ge
%   版本: 2.0
%   日期: 2025-01-27

    %% 参数解析
    p = inputParser;
    p.FunctionName = mfilename;
    
    addParameter(p, 'portSize', [], @(x) isempty(x) || (isnumeric(x) && length(x) == 2));
    addParameter(p, 'blockSize', [], @(x) isempty(x) || (isnumeric(x) && length(x) == 2));
    addParameter(p, 'FilterSingle', true, @islogical);
    addParameter(p, 'portDistance', 400, @(x) isnumeric(x) && isscalar(x) && x > 0);
    
    parse(p, varargin{:});
    
    portSize = p.Results.portSize;
    blockSize = p.Results.blockSize;
    filterSingle = p.Results.FilterSingle;
    portDistance = p.Results.portDistance;

    %% 获取端口、连线和模块句柄
    [hPort, hLine, hBlock] = findPortLineBlock(portPath, 'FilterSingle', filterSingle);
    
    %% 检查是否找到有效的连接模块
    if hBlock == -1
        success = false;
        return;
    end
    
    %% 检查其他句柄是否有效
    if hPort == -1 || hLine == -1
        success = false;
        return;
    end
    
    try
        %% 获取端口信息
        bk = get(hPort);
        posType = bk.BlockType;

        %% 移动端口
        posPort = bk.Position;
        if isempty(portSize)
            wid = posPort(3)-posPort(1);
            height = posPort(4)-posPort(2);
        else
            wid = portSize(1);
            height = portSize(2);
        end
        posPortNew = [newPos(1)-wid/2, newPos(2)-height/2, newPos(1)+wid/2, newPos(2)+height/2];
        set_param(hPort, 'Position', posPortNew);

        %% 移动对应的Block
        posBlock = get(hBlock).Position;
        if isempty(blockSize)
            wid = posBlock(3)-posBlock(1);
            height = posBlock(4)-posBlock(2);
        else
            wid = blockSize(1);
            height = blockSize(2);
        end
        posBlockNew = [newPos(1)-wid/2, newPos(2)-height/2, newPos(1)+wid/2, newPos(2)+height/2];
        
        % 根据端口类型调整位置
        if strcmp(posType, 'Inport')
            posBlockNew = posBlockNew + [portDistance 0 portDistance 0];
        elseif strcmp(posType, 'Outport')
            posBlockNew = posBlockNew + [-portDistance 0 -portDistance 0];
        end
        set_param(hBlock, 'Position', posBlockNew);
        
        success = true;
        
    catch ME
        % 如果操作过程中出现错误，返回失败状态
        success = false;
        warning('changePortBlockPos:operationError', '改变端口位置时发生错误: %s', ME.message);
    end
end