%% 创建CCM autosar 软件架构

% [x] 获取SWC清单及周期属性并创建架构SWC
% [x] 将Autosar的模型端口，转换成bus
% [] 对Autosar SWC进行链接到模型
% [] 对非Autosar SWC 创建新模型
% [] 创建输入输出端口
% [x] 自动连线
% [] 根据模型，创建架构Interface Dictionary，为每个端口，配置Bus 数据类型
% [] 更改arxml 配置
% [] 生成架构代码及arxml

ArchName = 'CcmArch';
templateFile = 'CCMtaskmappingV2.0.xlsx';
%% 1. 获取SWC清单及周期属性
[Tb_autosarSWC, Tb_ertSWC, ArchModel] = createArchSWC(templateFile, ArchName);
autosarSwcs = ArchModel.Components;

%% 2. 将Autosar的模型端口，转换成bus
for i = 1:length(autosarSwcs)
    try
        changeAutosarPortToBus(autosarSwcs(i).Name);
    catch ME
        warning('MATLAB:appCreateCcmArch:ChangeAutosarPortToBusFailed', ...
            '将Autosar的模型%s的端口转换成bus失败: %s', autosarSwcs(i).Name, ME.message);
    end
end

%% 3. 对Autosar SWC进行链接到模型

for i = 1:length(autosarSwcs)
    try
        % Link to Simulink implementation model and inherit its interface
        linkToModel(autosarSwcs(i),autosarSwcs(i).Name);
    catch ME
        warning('MATLAB:appCreateCcmArch:LinkToModelFailed', ...
            '对Autosar的模型%s进行链接到模型失败: %s', autosarSwcs(i).Name, ME.message);
    end
end

%% 4. 对非Autosar SWC 创建新模型

%% 5. 创建输入输出端口
swcRxName = 'SdbRxSigProc';
swcTxName = 'SdbTxSigProc';
swcRx = find(ArchModel,'Component', 'Name', swcRxName);
swcTx = find(ArchModel,'Component', 'Name', swcTxName);
% 处理swcRx的输入输口
[ModelName, PortsIn, PortsOut, PortsSpecial] = findModPorts(swcRx.SimulinkHandle,'skipTrig', true,'getType','Handle');
if ~isempty(PortsIn)
    for i = 1:length(PortsIn)
        portHandle = PortsIn{i};
        IsBusElementPort = get_param(portHandle, 'IsBusElementPort');
        if strcmp(IsBusElementPort, 'off') % 不是BusElementPort，则跳过,比如Updated端口
            continue;
        end
        PortName = get_param(portHandle, 'PortName');
        BlockType = get_param(portHandle, 'BlockType');
        OutDataTypeStr = get_param(portHandle, 'OutDataTypeStr');
        Description = get_param(portHandle, 'Description');
        port = addPort(ArchModel,'Receiver',PortName);
        set_param(port.SimulinkHandle,'OutDataTypeStr',OutDataTypeStr);
        set_param(port.SimulinkHandle,'Description',Description);  
    end
end

% 处理swcTx的输出输口
[ModelName, PortsIn, PortsOut, PortsSpecial] = findModPorts(swcTx.SimulinkHandle,'getType','Handle');
if ~isempty(PortsOut)
    for i = 1:length(PortsOut)
        portHandle = PortsOut{i};
        PortName = get_param(portHandle, 'PortName');
        BlockType = get_param(portHandle, 'BlockType');
        OutDataTypeStr = get_param(portHandle, 'OutDataTypeStr');
        Description = get_param(portHandle, 'Description');
        port = addPort(ArchModel,'Sender',PortName);
        set_param(port.SimulinkHandle,'OutDataTypeStr',OutDataTypeStr);
        set_param(port.SimulinkHandle,'Description',Description);  
    end
end

%% 6. 自动连线
createArchLines(ArchModel);

%% 7. 根据模型，创建架构Interface Dictionary，为每个端口，配置Bus 数据类型

interfaceDict = Simulink.interface.dictionary.open('ccmArxml.sldd')
ifTest = getInterface(interfaceDict, 'IF_ToSWC')

port = find(ArchModel,'Port','Name','ActvnOfWshrFrntSafe')
setInterface(port,ifTest)

% 
% 
% % 步骤1: 加载架构模型（如果未加载）
% archModel = autosar.arch.loadModel('myArchModel');
% 
% % 步骤2: 获取端口对象（假设端口已存在）
% ports = find(archModel, 'Port');  % 查找所有端口
% port = ports(strcmp(get(ports, 'Name'), 'ActvnOfWshrFrntSafe666'));  % 根据名称过滤，替换为你的端口名
% 
% % 如果端口路径已知，直接获取：
% % port = autosar.arch.ArchPort('myArchModel/Path/To/Port');
% 
% % 步骤3: 获取接口字典和接口对象（如果未有 ifTest）
% dictObj = Simulink.data.dictionary.open('myInterfaces.sldd');  % 替换为你的 .sldd 文件
% archDataObj = getSection(dictObj, 'ArchitecturalData');  % 获取 ArchitecturalData 部分
% ifTest = getInterface(archDataObj, 'AqsPwrSplySta');  % 获取目标接口对象
% 
% % 步骤4: 设置接口
% setInterface(port, ifTest);
% 
% % 步骤5: 验证
% disp(port.Interface.Name);  % 应输出 'AqsPwrSplySta'
% 
% % 保存模型
% save_system('myArchModel');
% close_system('myArchModel');  % 可选，关闭模型
% 
% autosar.dictionary.UI.utils.linkDictToModel('myArchModel', 'myInterfaces.sldd')

%% 8. 生成架构代码及arxml

