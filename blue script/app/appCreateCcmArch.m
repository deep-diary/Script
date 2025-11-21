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
ertComposition = find(ArchModel,'Composition', 'Name', 'ERT');

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
        swcComponent = autosarSwcs(i);
        % Link to Simulink implementation model and inherit its interface
        if isempty(autosarSwcs(i).ReferenceName)
            linkToModel(swcComponent,swcComponent.Name);
        else
            fprintf('Autosar的模型%s有引用模型%s\n', swcComponent.Name, swcComponent.ReferenceName);
        end
    catch ME
        warning('MATLAB:appCreateCcmArch:LinkToModelFailed', ...
            '对Autosar的模型%s进行链接到模型失败: %s', autosarSwcs(i).Name, ME.message);
    end
end
layout(ArchModel)
save(ArchModel)
% unlinkFromModel(component) % backup code

%% 4. 对非Autosar SWC 创建新模型
% 找到ERT组合，创建新模型

if isempty(ertComposition)
    error('未找到ERT组合');
end
for i = 1:height(Tb_ertSWC)
    SWCName = Tb_ertSWC(i,:).SWCName{1}; 
    Periodic = Tb_ertSWC(i,:).Periodic;

    % 判断是否有对应的component
    component = find(ertComposition,'Component', 'Name', SWCName);
    if isempty(component)
        error('未找到对应的组件%s', SWCName);
    end
    % 及工作空间中是否存在对应的模型
    if isempty(which(SWCName))
        fprintf('-------------------创建ERT组件模型: %s\n, %d / %d-------------\n', SWCName, i, height(Tb_ertSWC));
        createModExportFun(SWCName, 'Periodic', Periodic, 'TargetFolder', 'ModelErt', 'ModelType', 'autosar')
        changeAutosarRunnable(SWCName, 'AutoBuild', false,'RunnablePeriod',Periodic)
    end

    % 链接模型
    if isempty(component.ReferenceName)
        linkToModel(component,which(SWCName));
    else
        fprintf('ERT组件模型%s有引用模型%s\n', SWCName, component.ReferenceName);
    end
end
save(ArchModel)

%% 5. 创建输入输出端口
createArchPort(ArchModel, 'RxComponentName', 'SdbRxSigProc', 'TxComponentName', 'SdbTxSigProc');


%% 6. 自动连线
createArchLines(ArchModel);

%% 7. 根据模型，创建架构Interface Dictionary，为每个端口，配置Bus 数据类型
linkDictionary(ArchModel, 'CcmArch.sldd')
save(ArchModel)
% unlinkDictionary(ArchModel)

% interfaceDict = Simulink.interface.dictionary.open('ccmArxml.sldd')
% ifTest = getInterface(interfaceDict, 'IF_ToSWC')

% port = find(ArchModel,'Port','Name','ActvnOfWshrFrntSafe')
% setInterface(port,ifTest)

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

