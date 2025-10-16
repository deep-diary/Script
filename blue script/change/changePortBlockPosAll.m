function changePortBlockPosAll(path,varargin)
%CHANGEPORTBLOCKPOSALL 重新整理当前模型所有的输入输出端口及其对应连线block的位置
%   CHANGEPORTBLOCKPOSALL(PATH) 使用默认参数重新整理指定路径下模型的端口位置
%   CHANGEPORTBLOCKPOSALL(PATH, 'Parameter', Value, ...) 使用指定参数重新整理端口位置
%
%   输入参数:
%      path         - 目标系统路径 (字符串), 默认值: gcs (当前系统)
%
%   可选参数（名值对）:
%      'newPosin'   - 新输入端口位置 [x y], 默认值: [] (自动确定)
%      'newPosout'  - 新输出端口位置 [x y], 默认值: [] (自动确定)
%      'portSize'   - 端口模块尺寸 [width height], 默认值: [30 14]
%      'blockSize'  - 连接模块尺寸 [width height], 默认值: [150 14]
%      'posInBase'  - 输入端口基准编号，默认值: 0 (使用第一个端口位置)
%                    当newPosin为空且posInBase不为0时，使用指定编号端口的位置作为基准
%      'posOutBase' - 输出端口基准编号，默认值: 0 (使用第一个端口位置)
%                    当newPosout为空且posOutBase不为0时，使用指定编号端口的位置作为基准
%      'portDistance' - 端口与连接模块的距离，默认值: 400 (像素)
%                      输入端口向右偏移，输出端口向左偏移
%
%   功能描述:
%      1. 查找系统中的所有输入输出端口
%      2. 根据指定的新位置重新排列端口
%      3. 保持端口之间的间距为固定值
%      4. 自动调整端口对应的连线block位置
%      5. 可选择性地修改端口和连接模块的尺寸
%      6. 支持基于指定端口编号的位置基准
%      7. 智能步进：只有成功改变位置的端口才会增加Y坐标步进
%      8. 可自定义端口与连接模块的距离
%
%   示例:
%      % 基本用法
%      changePortBlockPosAll(gcs)
%
%      % 使用端口编号2作为输入端口基准
%      changePortBlockPosAll(gcs, 'posInBase', 2)
%
%      % 使用端口编号3作为输出端口基准
%      changePortBlockPosAll(gcs, 'posOutBase', 3)
%
%      % 同时指定输入和输出端口基准
%      changePortBlockPosAll(gcs, 'posInBase', 2, 'posOutBase', 3)
%
%      % 指定位置和尺寸
%      changePortBlockPosAll('myModel/subsystem1', ...
%          'newPosin', [-730 3600], ...
%          'newPosout', [0 3600], ...
%          'portSize', [30 14], ...
%          'blockSize', [30 14])
%
%      % 指定端口与连接模块的距离
%      changePortBlockPosAll(gcs, 'portDistance', 600)
%
%   注意事项:
%      1. 使用前需要打开目标Simulink模型
%      2. 端口间距固定为30像素
%      3. 位置确定优先级：newPosin/newPosout > posInBase/posOutBase > 第一个端口位置
%      4. 端口和模块的尺寸可以统一设置
%      5. 如果指定的端口编号不存在，将回退到使用第一个端口位置
%      6. 智能步进：只有成功改变位置的端口才会增加Y坐标，避免位置重叠
%      7. 端口与连接模块的距离可以通过portDistance参数自定义
%
%   参见: CHANGEPORTBLOCKPOS, FINDMODPORTS
%
%   作者: Blue.ge
%   版本: 1.1
%   日期: 20231020
    %%
    clc
    p = inputParser;
    p.FunctionName = mfilename;
    
    addParameter(p, 'newPosin',  [], @(x) isempty(x) || (isnumeric(x) && length(x) == 2)); 
    addParameter(p, 'newPosout', [], @(x) isempty(x) || (isnumeric(x) && length(x) == 2)); 
    addParameter(p, 'portSize', [30 14], @(x) isnumeric(x) && length(x) == 2);
    addParameter(p, 'blockSize', [30 14], @(x) isnumeric(x) && length(x) == 2);
    addParameter(p, 'posInBase', 0, @(x) isnumeric(x) && isscalar(x) && x >= 0);
    addParameter(p, 'posOutBase', 0, @(x) isnumeric(x) && isscalar(x) && x >= 0);
    addParameter(p, 'portDistance', 400, @(x) isnumeric(x) && isscalar(x) && x > 0);
    
    parse(p, varargin{:});
    
    newPosin = p.Results.newPosin;
    newPosout = p.Results.newPosout;
    portSize = p.Results.portSize;
    blockSize = p.Results.blockSize;
    posInBase = p.Results.posInBase;
    posOutBase = p.Results.posOutBase;
    portDistance = p.Results.portDistance;
    
    [~,PortsIn,PortsOut] = findModPorts(path);
    stp=30;
    %% 处理输入端口
    if ~isempty(PortsIn)
        if isempty(newPosin)
            % 确定输入端口基准位置
            if posInBase > 0 && posInBase <= length(PortsIn)
                % 使用指定编号的端口位置作为基准
                newPosin = get_param(PortsIn{posInBase}, 'Position');
            else
                % 使用第一个端口位置作为基准
                PosinFirst = find_system(path, 'SearchDepth', 1, 'BlockType', 'Inport', 'Port', '1');
                if ~isempty(PosinFirst)
                    newPosin = get_param(PosinFirst{1}, 'Position');
                else
                    % 如果找不到第一个端口，使用第一个可用端口
                    newPosin = get_param(PortsIn{1}, 'Position');
                end
            end
        end
        
        posX = newPosin(1);
        posY = newPosin(2);
        for i=1:length(PortsIn)
            [success, ~, ~, ~] = changePortBlockPos(PortsIn{i}, [posX posY], ...
                'portSize', portSize, ...
                'blockSize', blockSize, ...
                'portDistance', portDistance);
            
            % 只有成功时才增加Y坐标步进
            if success
                posY = posY + stp;
            end
        end
    end

    %% 处理输出端口
    if ~isempty(PortsOut)
        if isempty(newPosout)
            % 确定输出端口基准位置
            if posOutBase > 0 && posOutBase <= length(PortsOut)
                % 使用指定编号的端口位置作为基准
                newPosout = get_param(PortsOut{posOutBase}, 'Position');
            else
                % 使用第一个端口位置作为基准
                PosoutFirst = find_system(path, 'SearchDepth', 1, 'BlockType', 'Outport', 'Port', '1');
                if ~isempty(PosoutFirst)
                    newPosout = get_param(PosoutFirst{1}, 'Position');
                else
                    % 如果找不到第一个端口，使用第一个可用端口
                    newPosout = get_param(PortsOut{1}, 'Position');
                end
            end
        end
        
        posX = newPosout(1);
        posY = newPosout(2);
        for i=1:length(PortsOut)
            [success, ~, ~, ~] = changePortBlockPos(PortsOut{i}, [posX posY], ...
                'portSize', portSize, ...
                'blockSize', blockSize, ...
                'portDistance', portDistance);
            
            % 只有成功时才增加Y坐标步进
            if success
                posY = posY + stp;
            end
        end
    end
    
end