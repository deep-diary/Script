function changePortBlockPosAll(path,varargin)
%CHANGEPORTBLOCKPOSALL 重新整理当前模型所有的输入输出端口及其对应连线block的位置
%   CHANGEPORTBLOCKPOSALL(PATH) 使用默认参数重新整理指定路径下模型的端口位置
%   CHANGEPORTBLOCKPOSALL(PATH, 'Parameter', Value, ...) 使用指定参数重新整理端口位置
%
%   输入参数:
%      path         - 目标系统路径 (字符串), 默认值: gcs (当前系统)
%
%   可选参数（名值对）:
%      'newPosin'   - 新输入端口位置 [x y], 默认值: [0 0]
%      'newPosout'  - 新输出端口位置 [x y], 默认值: [1000 0]
%      'portSize'   - 端口模块尺寸 [width height], 默认值: [30 14]
%      'blockSize'  - 连接模块尺寸 [width height], 默认值: [150 14]
%
%   功能描述:
%      1. 查找系统中的所有输入输出端口
%      2. 根据指定的新位置重新排列端口
%      3. 保持端口之间的间距为固定值
%      4. 自动调整端口对应的连线block位置
%      5. 可选择性地修改端口和连接模块的尺寸
%
%   示例:
%      % 基本用法
%      changePortBlockPosAll(gcs)
%
%      % 默认端口尺寸和模块尺寸
%      changePortBlockPosAll(gcs, 'portSize', [30 14], 'blockSize', [30 14])
%
%      % 指定位置和尺寸
%      changePortBlockPosAll('myModel/subsystem1', ...
%          'newPosin', [-730 3600], ...
%          'newPosout', [0 3600], ...
%          'portSize', [30 14], ...
%          'blockSize', [30 14])
%
%   注意事项:
%      1. 使用前需要打开目标Simulink模型
%      2. 端口间距固定为30像素
%      3. 如果不指定新位置，将使用第一个端口的位置作为基准
%      4. 端口和模块的尺寸可以统一设置
%
%   参见: CHANGEPORTBLOCKPOS, FINDMODPORTS
%
%   作者: Blue.ge
%   版本: 1.1
%   日期: 20231020
    %%
    clc
    p = inputParser;
    addParameter(p, 'newPosin',  []); 
    addParameter(p, 'newPosout', []); 
    addParameter(p, 'portSize', [30 14]);
    addParameter(p, 'blockSize', [30 14]);
    
    parse(p, varargin{:});
    
    newPosin = p.Results.newPosin;
    newPosout = p.Results.newPosout;
    portSize = p.Results.portSize;
    blockSize = p.Results.blockSize;
    
    [ModelName,PortsIn,PortsOut] = findModPorts(path);
    stp=30;
    %% 处理输入
    if ~isempty(PortsIn)
        if isempty(newPosin)
            PosinFirst = find_system(path, 'SearchDepth', 1, 'BlockType', 'Inport', 'Port', '1');
            newPosin = get_param(PosinFirst{1}, 'Position');
        end
        posX = newPosin(1);
        for i=1:length(PortsIn)
            posY = newPosin(2) + stp * i;
            changePortBlockPos(PortsIn{i}, [posX posY], ...
                'portSize', portSize, ...
                'blockSize', blockSize)
        end
    end

    %% 处理输出
    if ~isempty(PortsOut)
        if isempty(newPosout)
        PosoutFirst = find_system(path, 'SearchDepth', 1, 'BlockType', 'Outport', 'Port', '1');
        newPosout = get_param(PosoutFirst{1}, 'Position');
        end
        posX = newPosout(1);
        for i=1:length(PortsOut)
        posY = newPosout(2) + stp * i;
            changePortBlockPos(PortsOut{i}, [posX posY], ...
                'portSize', portSize, ...
                'blockSize', blockSize)
        end
    end
    
end