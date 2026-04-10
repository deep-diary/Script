TelmDefrostReqdataForStorgfunction creatBusSig(mdPath, varargin)
%%
% 目的: 为模型创建对应的输入bus, 
% 输入：
%       模型路径
% 返回：None
% 范例：creatBusSig(gcb)
% 说明：1. 鼠标点击在子模型上，2. 在命令窗口运行此函数
% 作者： Blue.ge
% 日期： 20231201
%%
    %% 参数处理
     clc
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'prefix','in');  
    addParameter(p,'isEnPrefix',false);  
   
    % 输入参数处理   
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    prefix = p.Results.prefix;
    isEnPrefix = p.Results.isEnPrefix;
    %%
    try
        ModelName = get_param(mdPath,'ModelName'); % 适合引用模型
    catch
        ModelName = get_param(mdPath,'Name'); % 适合子模型模型
    end
    ModelPath = get_param(mdPath,'Parent');
    load_system(ModelName);
    busName = ModelName;
    busPath = [ModelPath,'/',busName];
    BusSelector_Handle=get_param(busPath,'Handle');
    get(BusSelector_Handle);
    %获取所需信号 GlTmSigOut
    
    Inports_obj=find_system(ModelName,'SearchDepth',1,'BlockType','Inport');
    BusIpSigs_cells=get_param(BusSelector_Handle,"InputSignals");
    
    %信号名拼接赋值给BusSelect输出信号
    Outport_Name0=get_param(Inports_obj{1},'Name');
    busOutSignal_list=['Tasks.HX11_TM_Task100ms.' Outport_Name0];
    
    
    for i=2:length(Inports_obj)
        Outport_Name=get_param(Inports_obj{i},'Name');
        if isEnPrefix && endsWith(Outport_Name,prefix)
            Outport_Name=extractBefore(Outport_Name,length(Outport_Name)-length(prefix)+1);
        end
        busOutSignal_fullName = ['----', Outport_Name, '----'];
        for n_cell=2:length(BusIpSigs_cells)
            K=matches(BusIpSigs_cells{n_cell,1}{1,2},Outport_Name);
            a=find(K);
            if ~isempty(a)
                busOutSignal_frontName=BusIpSigs_cells{n_cell,1}{1,1};
                busOutSignal_fullName=[busOutSignal_frontName '.' Outport_Name];
                break
            end
        end
        busOutSignal=[',' busOutSignal_fullName];
        busOutSignal_list=[busOutSignal_list busOutSignal];
    end
    
    set_param(BusSelector_Handle,"OutputSignals",string(busOutSignal_list));

end