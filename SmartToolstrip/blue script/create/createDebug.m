function portsOutNames = createDebug(path, varargin)
%CREATEDEBUG 为输出端口创建debug及对应的输入模块
%   portsOutNames = createDebug(path) 为指定路径下的输出端口创建debug模块和对应的输入模块, 在独立的子模型中执行脚本。
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
%       portsOutNames = createDebug(gcs)
%       portsOutNames = createDebug(gcs, 'NameInType', 'findLoc')
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-04-29
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        addParameter(p, 'step', 30, @(x) isnumeric(x) && x > 0);
        addParameter(p, 'NameInType', 'tailIn', @(x) any(validatestring(x, {'tailIn', 'findLoc'})));
        addParameter(p, 'suffixStr', 'Dbgin', @(x) ischar(x));
        
        % 如果path是模型名称，则转换为模型路径
        parse(p, varargin{:});
        
        step = p.Results.step;
        nameInType = p.Results.NameInType;
        suffixStr = p.Results.suffixStr;
        
        %% 整理端口位置
        changePortPos('stp', step);
        
        %% 获取输出端口
        [modelName, portsIn, portsOut] = findModPorts(path, ...
            'getType', 'Handle', ...
            'FiltUnconnected', true);
        
        cnt = length(portsOut);
        if cnt == 0
            warning('未找到未连接的输出端口');
            return;
        end
        
        %% 创建debug和输入端口
        for i = 1:cnt
            % 获取端口信息
            portHandle = portsOut{i};
            portPos = get_param(portHandle, 'Position');
            portName = get_param(portHandle, 'Name');
            
            % 计算模块位置
            debugPos = portPos + [-300 0 -300 0] + [-100 0 100 0];
            inPortPos = portPos + [-600 0 -600 0];
            
            % 创建debug模块
            debugBlock = add_block('PCMULib/Interface/OutdebugRvs', ...
                [gcs '/OutDebug'], ...
                'MakeNameUnique', 'on', ...
                'Position', debugPos);
            
            % 确定输入端口名称
            if strcmp(nameInType, 'tailIn')
                inPortName = [portName suffixStr];
            else
                inPortName = findNameSigLoc(portName);
            end
            
            % 创建输入端口
            inPortBlock = add_block('built-in/Inport', ...
                [gcs '/' inPortName], ...
                'MakeNameUnique', 'on', ...
                'Position', inPortPos);
            
            % 设置输入端口属性
            [dataType, ~, ~, ~, ~] = findNameType(portName);
            set_param(inPortBlock, ...
                'OutDataTypeStr', dataType, ...
                'BackgroundColor', 'green');
            
            % 创建连线
            creatLines([inPortBlock debugBlock portHandle]);
            
            fprintf('已创建debug模块和输入端口: %s\n', portName);
        end
        
        %% 调整模型大小
        changeModSize(path);
        
        fprintf('共创建了 %d 个debug模块和输入端口\n', cnt);


        createMode(gcs, ...
            'inType','from', ...      % 可选参数 port, ground, from, const, none
            'outType','port', ...       % 可选参数 port, term, goto, disp, none
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