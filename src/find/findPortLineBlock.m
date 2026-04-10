function [hPort, hLine, hBlock] = findPortLineBlock(portPath, varargin)
%FINDPORTLINEBLOCK 找到与端口相连的句柄，包括端口本身、连接线和对应模块的句柄
%   [HPORT, HLINE, HBLOCK] = FINDPORTLINEBLOCK(PORTPATH) 使用默认参数查找端口连接
%   [HPORT, HLINE, HBLOCK] = FINDPORTLINEBLOCK(PORTPATH, 'Parameter', Value, ...) 使用指定参数查找
%
%   输入参数:
%      portPath    - 端口路径 (字符向量或字符串标量)
%
%   可选参数（名值对）:
%      'FilterSingle' - 是否过滤单个连接模块，可选值: true, false (默认值: false)
%                      当为true时，对于Inport类型，只返回输入端口数为1且无输出端口的模块
%                      用于找到零散连接到端口的模块，便于整理
%
%   输出参数:
%      hPort   - 端口句柄
%      hLine   - 对应连接线的句柄
%      hBlock  - 连接的模块句柄（如果FilterSingle为true且不满足条件，返回-1）
%
%   功能描述:
%      找到与指定端口相连的句柄信息，包括端口本身、连接线和对应的模块。
%      支持过滤功能，可以只返回连接到单个端口的模块，便于识别零散模块。
%
%   示例:
%      [hPort, hLine, hBlock] = findPortLineBlock(gcb);
%      [hPort, hLine, hBlock] = findPortLineBlock(gcb, 'FilterSingle', true);
%      [hPort, hLine, hBlock] = findPortLineBlock('MyModel/SubSystem/In1');
%
%   应用场景:
%      - 批量改变模块位置
%      - 批量删除模块
%      - 识别零散连接到端口的模块进行整理
%
%   作者: Blue.ge
%   日期: 2025-01-27
%   版本: 2.0

    %% 输入参数验证
    narginchk(1, inf);
    validateattributes(portPath, {'char', 'string'}, {'scalartext'}, mfilename, 'portPath', 1);
    
    % 确保输入为字符向量
    portPath = char(portPath);

    %% 参数解析
    p = inputParser;
    p.FunctionName = mfilename;
    
    addRequired(p, 'portPath', @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'FilterSingle', true, @islogical);
    
    parse(p, portPath, varargin{:});
    
    filterSingle = p.Results.FilterSingle;

    %% 获取端口信息
    bkType = get_param(portPath, 'BlockType');
    
    hPort = get_param(portPath, 'Handle');
    hPortCon = get_param(hPort, 'PortHandles');
    
    if strcmp(bkType, 'Inport')
        hLine = get_param(hPortCon.Outport, 'Line');
        if hLine == -1
            hBlock = -1;
            return
        end
        
        hBlock = get_param(hLine, 'DstBlockHandle');
        
        % 如果启用FilterSingle，检查连接的模块是否满足条件
        if filterSingle
            if ~isSingleConnectionBlock(hBlock)
                hBlock = -1;
                return
            end
        end
        
    elseif strcmp(bkType, 'Outport')
        hLine = get_param(hPortCon.Inport, 'Line');
        if hLine == -1
            hBlock = -1;
            return
        end
        
        hBlock = get_param(hLine, 'SrcBlockHandle');
        
        % 如果启用FilterSingle，检查连接的模块是否满足条件
        if filterSingle
            if ~isSingleConnectionBlock(hBlock)
                hBlock = -1;
                return
            end
        end
        
    else
        % 不支持的块类型
        hLine = -1;
        hBlock = -1;
    end
end

%% 辅助函数：检查模块是否为单个连接模块
function isSingle = isSingleConnectionBlock(blockHandle)
    % 检查模块是否满足单个连接的条件
    % 输入: blockHandle - 模块句柄
    % 输出: isSingle - 是否为单个连接模块（逻辑值）
    
    isSingle = false;
    
    try
        % 获取模块的端口信息
        blockPorts = get_param(blockHandle, 'Ports');
        
        % 检查输入端口数量
        numInports = blockPorts(1);
        % 检查输出端口数量
        numOutports = blockPorts(2);
        
        % 条件：输入端口数为1且无输出端口或者输出端口数为1且无输入端口
        if (numInports == 1 && numOutports == 0) || (numOutports == 1 && numInports == 0)
            isSingle = true;
        end
        
    catch
        % 如果获取端口信息失败，返回false
        isSingle = false;
    end
end