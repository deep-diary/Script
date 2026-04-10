function portsOutNames = createDebugIn(path, varargin)
%createDebugIn 为输出端口创建debug及对应的输入模块
%   portsOutNames = createDebugIn(path) 为指定路径下的输出端口创建debug模块和对应的输入模块, 在独立的子模型中执行脚本。
%
%   输入参数:
%       path - 模型路径，例如 gcs
%
%   可选参数:
%       'step' - 端口间距，默认为30
%       'NameInType' - 输入端口命名方式，可选值为 'tailIn' 或 'findLoc'，默认为 'tailIn'
%
%   输出参数:
%       portsOutNames - 创建的端口名称
%
%   示例:
%       portsOutNames = createDebugIn(gcs)
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2025-07-02
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        addParameter(p, 'step', 30, @(x) isnumeric(x) && x > 0);
        addParameter(p, 'suffixStr', 'DbgOut', @(x) ischar(x));
        
        % 如果path是模型名称，则转换为模型路径
        parse(p, varargin{:});
        
        step = p.Results.step;
        suffixStr = p.Results.suffixStr;
        
        %% 整理端口位置
        changePortPos('stp', step);
        
        %% 获取输出端口
        [modelName, portsIn, portsOut] = findModPorts(path, ...
            'getType', 'Handle', ...
            'FiltUnconnected', true);
        
        cnt = length(portsIn);
        if cnt == 0
            warning('未找到未连接的输出端口');
            return;
        end
        
        %% 创建debug和输出端口
        for i = 1:cnt
            % 获取端口信息
            portHandle = portsIn{i};
            portPos = get_param(portHandle, 'Position');
            portName = get_param(portHandle, 'Name');
            
            % 计算模块位置
            debugPos = portPos + [300 0 300 0] + [-100 0 100 0];
            outPortPos = portPos + [600 0 600 0];
            
            % 创建debug模块
            debugBlock = add_block('PCMULib/Interface/OutdebugRvs', ...
                [gcs '/OutDebug'], ...
                'MakeNameUnique', 'on', ...
                'Position', debugPos);
            
            % 确定输出端口名称
            outPortName = [portName suffixStr];
            
            % 创建输出端口
            outPortBlock = add_block('built-in/Outport', ...
                [gcs '/' outPortName], ...
                'MakeNameUnique', 'on', ...
                'Position', outPortPos);
            
            % 设置输入端口属性
            [dataType, ~, ~, ~, ~] = findNameType(portName);
            set_param(outPortBlock, ...
                'OutDataTypeStr', dataType, ...
                'BackgroundColor', 'orange');
            
            % 创建连线
            creatLines([ portHandle debugBlock outPortBlock])
            
            fprintf('已创建debug模块和输出端口: %s\n', portName);
        end
        
        %% 调整模型大小
        changeModSize(path);
        
        fprintf('共创建了 %d 个debug模块和输入端口\n', cnt);
    %% 当前路径验证

        open_system(get_param(path, 'Parent')) % 需要返回上一层执行


        createMode(path, ...
            'inType','port', ...      % 可选参数 port, ground, from, const, none
            'outType','goto', ...       % 可选参数 port, term, goto, disp, none
            'suffixStr',suffixStr,...
            ...                         % 创建 ports 相关配置
            'add', 'None',...           % 可选参数 blockType, None, etc：SignalConversion DataTypeConversion
            ...                         % 创建 goto from 相关配置
            'bkHalfLength', 125,...
            ...                         % 创建 信号解析 相关配置
            'isEnableIn',false,...
            'isEnableOut',false,...
            'resoveValue',false,...
            'logValue',false,...
            'testValue',false,...
            'dispName', false...
            )

        %% 获取输出端口
        [~, ~, portsOutNames] = findModPorts(path, ...
            'getType', 'Name', ...
            'FiltUnconnected', false);
        
    catch ME
        error('创建debug模块时发生错误: %s', ME.message);
    end
end