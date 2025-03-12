function [DataPCMU, DataVCU] = findSlddSig(pathMd,  varargin)
%%
    % 目的: 获取模型的Signals, 保存到excel中，用于生成sldd
    % 输入：
    %       pathMd： 模型路径
    % 返回： type: 信号类型及PCMU, VCU的storage class
    % 范例： [DataPCMU, DataVCU] = findSlddSig('TmComprCtrlDev')
    % 作者： Blue.ge
    % 日期： 20240202
%%
    %% 参数处理
     clc
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'override',false);  
   
    % 输入参数处理   
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    override = p.Results.override;

    %% 获取端口sldd signal
    [ModelName,PortsIn,PortsOut] = findModPorts(pathMd);
    [DataPCMUPort, DataVCUPort] = findSlddSigPortData(ModelName, [PortsIn;PortsOut]);
    
    %% 获取端口sldd 内部信号线
    % 这里假定根目录下只有一个SubSystem
    subSysPath = find_system(pathMd, 'SearchDepth',1, 'BlockType', 'SubSystem');
    signalHandles = []
    for i=1:length(subSysPath)
        Handles = findResolvedSignals(subSysPath{i});
        signalHandles = [signalHandles Handles];
    end
    [DataPCMULoc, DataVCULoc] = findSlddSigLocData(ModelName, signalHandles);

    %% 合并并保存
    DataPCMU = [DataPCMUPort;DataPCMULoc];
    DataVCU = [DataVCUPort;DataVCULoc];
    saveSldd(ModelName, DataPCMU, DataVCU, 'dataType','Signals','override',override);
end