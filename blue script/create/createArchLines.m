function createArchLines(ArchModel, varargin)
%CREATEARCHLINES 让架构模型根据端口名称自动连线
%   CREATEARCHLINES(ARCHMODEL, Name, Value, ...) 根据端口名称自动连接架构模型中的组件
%
%   必需参数:
%      ArchModel    - 架构模型名称 (字符串) 或已加载的架构模型对象
%                     如果为字符串，将使用 autosar.arch.loadModel 加载模型
%                     如果为对象，将直接使用该对象
%
%   可选参数 (名称-值对):
%      'AutoLayout' - 是否自动整理布局 (逻辑值, 默认: true)
%
%   功能描述:
%      1. 加载或使用指定的AUTOSAR架构模型
%      2. 自动连接顶层输入端口到内部组件
%      3. 自动连接内部SWC组件之间的端口
%      4. 自动连接内部组件到顶层输出端口
%      5. 根据参数决定是否自动整理布局
%
%   示例:
%      % 基本用法 - 使用字符串
%      createArchLines('CcmArch')
%      
%      % 使用已加载的架构模型对象
%      archModel = autosar.arch.loadModel('CcmArch');
%      createArchLines(archModel)
%      
%      % 不自动整理布局
%      createArchLines('CcmArch', 'AutoLayout', false)
%
%   注意事项:
%      1. 如果输入为字符串，使用前需要确保架构模型文件存在
%      2. 如果输入为对象，确保该对象是有效的架构模型对象
%      3. 连线基于端口名称自动匹配
%      4. 如果AutoLayout为true，函数会自动整理模型布局
%      5. 函数会连接所有匹配的端口，包括：
%         - 顶层输入到内部组件
%         - 内部SWC组件之间
%         - 内部组件到顶层输出
%
%   参见: AUTOSAR.ARCH.LOADMODEL, AUTOSAR.ARCH.CONNECT, AUTOSAR.ARCH.LAYOUT
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 20251118

    %% 参数解析和验证
    % 创建输入解析器
    p = inputParser;
    p.FunctionName = mfilename;
    
    % 添加可选参数
    addParameter(p, 'AutoLayout', true, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    
    % 解析输入参数
    parse(p, varargin{:});
    
    % 提取参数值
    AutoLayout = p.Results.AutoLayout;

    %% 加载或使用架构模型
    % 判断输入是字符串还是已加载的模型对象
    if ischar(ArchModel) || isstring(ArchModel)
        % 输入是字符串，需要加载模型
        archModelName = char(ArchModel);
        try
            archModel = autosar.arch.loadModel(archModelName);
            fprintf('已加载架构模型: %s\n', archModelName);
        catch ME
            error('MATLAB:createArchLines:ModelLoadFailed', ...
                  '无法加载架构模型 "%s": %s', archModelName, ME.message);
        end
        modelNameForDisplay = archModelName;
    else
        % 输入是对象，直接使用
        archModel = ArchModel;
        try
            % 尝试获取模型名称，如果无法获取则使用默认名称
            if isprop(archModel, 'Name')
                modelNameForDisplay = archModel.Name;
            else
                modelNameForDisplay = '架构模型';
            end
        catch
            modelNameForDisplay = '架构模型';
        end
        fprintf('使用已加载的架构模型对象\n');
    end

    %% 获取组件列表
    try
        Components = archModel.Components;
        totalComponents = length(Components);
        
        if totalComponents == 0
            warning('MATLAB:createArchLines:NoComponents', ...
                    '架构模型 "%s" 中没有找到组件', modelNameForDisplay);
            return;
        end
    catch ME
        error('MATLAB:createArchLines:GetComponentsFailed', ...
              '获取组件列表失败: %s', ME.message);
    end

    %% 顶层输入到内部组件连线
    try
        for i = 1:totalComponents
            component = Components(i);
            connect(archModel, [], component);
        end
        fprintf('已完成顶层输入到内部组件连线 (%d 个组件)\n', totalComponents);
    catch ME
        warning('MATLAB:createArchLines:TopToInternalFailed', ...
                '顶层输入到内部组件连线失败: %s', ME.message);
    end

    %% 内部SWC组件之间连线
    try
        connectionCount = 0;
        for i = 1:totalComponents
            outComponent = Components(i);
            inComponents = Components;
            inComponents(i) = [];
            
            for j = 1:length(inComponents)
                inComponent = inComponents(j);
                connect(archModel, outComponent, inComponent);
                connectionCount = connectionCount + 1;
            end
        end
        fprintf('已完成内部SWC组件之间连线 (%d 个连接)\n', connectionCount);
    catch ME
        warning('MATLAB:createArchLines:InternalConnectionFailed', ...
                '内部SWC组件之间连线失败: %s', ME.message);
    end

    %% 内部组件到顶层输出连线
    try
        for i = 1:totalComponents
            component = Components(i);
            connect(archModel, component, []);
        end
        fprintf('已完成内部组件到顶层输出连线 (%d 个组件)\n', totalComponents);
    catch ME
        warning('MATLAB:createArchLines:InternalToTopFailed', ...
                '内部组件到顶层输出连线失败: %s', ME.message);
    end

    %% 整理布局（如果需要）
    if AutoLayout
        try
            layout(archModel);
            fprintf('已完成布局整理\n');
        catch ME
            warning('MATLAB:createArchLines:LayoutFailed', ...
                    '布局整理失败: %s', ME.message);
        end
    end
    
    fprintf('架构模型 "%s" 自动连线完成\n', modelNameForDisplay);
    save(archModel)
end