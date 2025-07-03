function creatTmBase(varargin)
%CREATTMBASE 创建基础模块的输入信号转换
%   creatTmBase() 将外部信号转换为基础模块的输入信号，包括信号名转换和信号隔离。
%
%   可选参数:
%       'stpX' - X轴步长，默认为1500
%       'stpY' - Y轴步长，默认为4000
%       'posOrg' - 原始位置坐标，默认为[0 0 500 5000]
%
%   示例:
%       creatTmBase()
%       creatTmBase('stpX', 2000, 'stpY', 5000)
%       creatTmBase('posOrg', [100 100 600 5100])
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-06-28
%   版本: 1.1

    try
        %% 参数处理
        p = inputParser;
        
        % 添加参数及其验证
        addParameter(p, 'stpX', 1500, @(x) isnumeric(x) && x > 0);
        addParameter(p, 'stpY', 4000, @(x) isnumeric(x) && x > 0);
        addParameter(p, 'posOrg', [0 0 500 5000], @(x) isnumeric(x) && numel(x) == 4);
        
        parse(p, varargin{:});
        
        % 获取参数值
        stpX = p.Results.stpX;
        stpY = p.Results.stpY;
        posOrg = p.Results.posOrg;
        
        %% 定义子模块列表
        subMods = {
            'TmRefriModeMgr', 'TmColtModeMgr', 'TmHvchCtrl', ...   % 远飞
            'TmComprCtrl', 'TmRefriVlvCtrl', 'TmSovCtrl', ...      % Blue
            'TmSigProces', 'TmPumpCtrl', 'TmColtVlvCtrl', 'TmEnergyMgr', ...  % 江敏
            'TmDiag', 'TmAfCtrl'                                 % 冬清
        };
        
        %% 计算布局参数
        row = 2;
        col = length(subMods) / row;
        root = gcs;
        
        %% 计算子模块位置
        subPos = cell(1, length(subMods));
        for i = 1:row
            for j = 1:col
                idx = col * (i-1) + j;
                pos = posOrg + [stpX * (j), stpY * (i-1), stpX * (j), stpY * (i-1)];
                subPos{idx} = pos;
            end
        end
        
        %% 创建子模块
        for i = 1:length(subMods)
            try
                name = subMods{i};
                path = [root '/' name];
                pos = subPos{i};
                
                % 创建模型引用
                bk = add_block('built-in/ModelReference', path, ...
                    'ModelName', name, 'Position', pos);
                
                % 调整模型大小
                changeModSize(path);
                
                % 创建输入输出端口
                createModGoto(path, 'mode', 'both');
                
                fprintf('成功创建子模块: %s\n', name);
            catch ME
                warning(ME.identifier, '创建子模块 %s 时发生错误: %s', name, ME.message);
            end
        end
        
        fprintf('所有子模块创建完成\n');
        
    catch ME
        error('创建基础模块时发生错误: %s', ME.message);
    end
end
