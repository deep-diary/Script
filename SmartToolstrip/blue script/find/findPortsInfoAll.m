function Data = findPortsInfoAll()
%   导出2层内所有子模型或者引用模型的端口
    clc
    Data={};
    hMd=gcbh;
    mdBlock = get(hMd);
    mdType=mdBlock.BlockType;
    if ~strcmp(mdType, 'ModelReference')
        error('this function only used for subsystem, pls click ModelReference block ')
    end
%     ModelName = '';

    % 根据顶层模型得到所有的次层引用模型信息
    ModelName = mdBlock.ModelName;
    load_system(ModelName);
    ModelReference = find_system(ModelName,'SearchDepth',1,'BlockType','ModelReference');

    % 获取顶层模型的端口信息
    PortsData = getPortsInfo(gcb, mdType);
    Data = vertcat(Data, PortsData);
    
    % 获取次层模型的端口信息
    for i=1:length(ModelReference)
        PortsData = findPortsInfo(ModelReference{i}, mdType);
        Data = vertcat(Data, PortsData);
    end
   
    savePortsInfo(ModelName, Data)
end