function [DataPCMU, DataVCU] = findSlddSigLocData(ModelName, hSig)
% 目的: 构建Signal表格，便于保存到excel
% 输入：
%       ModelName： 模型名称
%       hSig:  信号线句柄
% 返回： DataPCMU: 满足sldd格式的DataPCMU矩阵,DataVCU: 满足sldd格式的DataVCU矩阵
% 范例： [DataPCMU, DataVCU] = getPortsSlddDataPCMU(ModelName, portsPath)
% 作者： Blue.ge
% 日期： 20240202
%%
    if isempty(hSig)
%         error('the signal handle is unaviliable, pls input the right portsPath')
        DataPCMU = {};
        DataVCU = {};
        return
    end
    len = length(hSig);
    % 这里的17表示数据有17列
    % pcmu DATA
    DataPCMU=cell(len,17);
    % vcu DATA
    DataVCU=cell(len,17);
    for i=1:len
        h=hSig(i);
        ins = get(h);
        [dataType, ~, ~, sigVCU, ~] = findNameType(ins.Name);

        DataPCMU{i,1} = ModelName;  % ModelName
        DataPCMU{i,2} = 'Local';  % PortType
        DataPCMU{i,3} = ins.Name;  % Name
        DataPCMU{i,4} = dataType;  % DataPCMUType
        DataPCMU{i,5} = 'Global1';  % CustomStorageClass
        DataPCMU{i,6} = [ModelName '.c'];  % DefinitionFile
        DataPCMU{i,7} = '';  % RTE_Interface
        DataPCMU{i,8} = '-1';  % Dimensions
        DataPCMU{i,9} = '';  % Details
        DataPCMU{i,10} = '';  % ValueTable
        DataPCMU{i,11} = 'inherit';  % Unit
        DataPCMU{i,12} = '';  % IniValue
        DataPCMU{i,13} = '[]';  % Min
        DataPCMU{i,14} = '[]';  % Max
        DataPCMU{i,15} = '';  % DataPCMUTypeSelect
        DataPCMU{i,16} = '';  % CustomStorageClassSelect
        DataPCMU{i,17} = '';  % DefinitionFile

        
        DataVCU(i,:) = DataPCMU(i,:);
        DataVCU{i,5} = sigVCU;

    end

end
