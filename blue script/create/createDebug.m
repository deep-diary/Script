function cnt = createDebug(path, varargin)
%%
% 目的:  为输出端口创建debug 及对应的输入模块
% 输入：
%       template: 路径下的excel 文件名
% 可选： step: 30

% 返回： cnt：创建的端口数量
% 范例： [cnt] = createDebug(gcs)
% 作者： Blue.ge
% 日期： 20240429

    %% 清空命令区
    clc    
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'step',30);      % 设置变量名和默认参数
    addParameter(p,'NameInType','tailIn');      % tailIn, findLoc

    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    step = p.Results.step;
    NameInType = p.Results.NameInType;

    %% 整理端口位置
    changePortPos('stp',step);

    %% 找到输出端口
    [ModelName,PortsIn,PortsOut] = findModPorts(path, 'getType', 'Handle', 'FiltUnconnected',true) ;

    cnt = length(PortsOut);
    
    %% 创建debug
    
    
    %% 创建输入端口
    for i=1:cnt
        pos = get_param(PortsOut{i}, 'Position');
        posDb = pos + [-300 0 -300 0] + [-100 0 100 0];
        PosIn = pos + [-600 0 -600 0];
        Name = get_param(PortsOut{i}, 'Name');

        % 创建debug
        
        bkDb  = add_block('PCMULib/Interface/OutdebugRvs', [gcs '/OutDebug'], ...
                        'MakeNameUnique','on','Position', posDb);

        % 创建输入端口
        if strcmp(NameInType,'tailIn')
            NameIn = [Name 'In'];
        end
        if strcmp(NameInType,'findLoc')
            NameIn = findNameSigLoc(Name);
        end
        

        bkIn = add_block('built-in/Inport', [gcs '/' NameIn], ...
            'MakeNameUnique','on',...
          'Position', PosIn);
        [dataType, ~, ~, ~, ~] = findNameType(Name);
        set_param(bkIn,'OutDataTypeStr',dataType);
        set_param(bkIn,"BackgroundColor","green");
        % 创建连线
        creatLines([bkIn bkDb PortsOut{i}])

    end
    
    %% 改变模型大小
    changeModSize(path)
    
end