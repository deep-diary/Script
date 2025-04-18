function [hPort, hLine, hBlock] = changePortBlockPos(portPath, newPos, varargin)
%CHANGEPORTBLOCKPOS 改变输入输出端口及其对应连线block的位置
%   [HPORT, HLINE, HBLOCK] = CHANGEPORTBLOCKPOS(PORTPATH, NEWPOS) 使用默认参数改变端口位置
%   [HPORT, HLINE, HBLOCK] = CHANGEPORTBLOCKPOS(PORTPATH, NEWPOS, 'Parameter', Value, ...) 使用指定参数
%
%   输入参数:
%      portPath     - 端口路径 (字符串)
%      newPos       - 新位置的起始坐标 [x y]
%
%   可选参数（名值对）:
%      'portSize'   - 端口模块尺寸 [width height], 默认值: [] (保持原尺寸)
%      'blockSize'  - 连接模块尺寸 [width height], 默认值: [] (保持原尺寸)
%
%   输出参数:
%      hPort        - 端口句柄
%      hLine        - 对应线的句柄
%      hBlock       - 连接的模块句柄
%
%   功能描述:
%      1. 根据端口路径查找对应的端口、连线和模块
%      2. 将端口移动到指定位置
%      3. 根据端口类型（输入/输出）调整连接模块的位置
%      4. 可选择性地修改端口和连接模块的尺寸
%
%   示例:
%      % 基本用法
%      [hPort, hLine, hBlock] = changePortBlockPos(gcb, [-2825 200])
%
%      % 指定模块尺寸
%      [hPort, hLine, hBlock] = changePortBlockPos(gcb, [-2825 200], 
%          'portSize', [30 14], 'blockSize', [150 14])
%
%   注意事项:
%      1. 使用前需要打开目标Simulink模型
%      2. 输入端口对应的模块会向右偏移200像素
%      3. 输出端口对应的模块会向左偏移200像素
%
%   参见: CHANGEPORTBLOCKPOSALL, FINDPORTLINEBLOCK
%
%   作者: Blue.ge
%   版本: 1.1
%   日期: 20231020

    %% 参数解析
    p = inputParser;
    addParameter(p, 'portSize', []);
    addParameter(p, 'blockSize', []);
    parse(p, varargin{:});
    
    portSize = p.Results.portSize;
    blockSize = p.Results.blockSize;

    %% 获取端口、连线和模块句柄
    [hPort, hLine, hBlock] = findPortLineBlock(portPath);
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
    set_param(hPort,'Position', posPortNew)

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
        posBlockNew = posBlockNew + [200 0 200 0];
    end
    if strcmp(posType, 'Outport')
        posBlockNew = posBlockNew + [-200 0 -200 0];
    end
    set_param(hBlock,'Position', posBlockNew)
end