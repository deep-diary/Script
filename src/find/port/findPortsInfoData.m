function Data = findPortsInfoData(ModelName, portsPath)
    if isempty(portsPath)
        disp('the ports path is unaviliable, pls input the right portsPath')
        Data = {};
        return
    end
    len = length(portsPath);
    Data=cell(len,9);
    for i=1:len
        h=get_param(portsPath{i}, 'Handle');
        ins = get(h);
        Data{i,1} = ModelName;
        Data{i,2} = ins.BlockType;
        Data{i,3} = ins.Port;
        Data{i,4} = ins.Name;
        Data{i,5} = ins.OutDataTypeStr;
    end
end