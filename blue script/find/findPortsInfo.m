function Data = findPortsInfo(pathMd)
    [ModelName,PortsIn,PortsOut] = findModPorts(pathMd);

    %     process the input port
    dataInports = findPortsInfoData(ModelName, PortsIn);
    %     process the out port
    dataOutports = findPortsInfoData(ModelName, PortsOut);
    %     combine all the info together
    Data = vertcat(dataInports, dataOutports);

    savePortsInfo(ModelName, Data)
end