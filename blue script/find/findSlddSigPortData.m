function [DataPCMU, DataVCU] = findSlddSigPortData(ModelName, portsPath)
% 目的: 构建Signal表格，便于保存到excel
% 输入：
%       ModelName： 模型名称
%       portsPath: 模型中所有的port 路径
% 返回： DataPCMU: 满足sldd格式的DataPCMU矩阵,DataVCU: 满足sldd格式的DataVCU矩阵
% 范例： [DataPCMU, DataVCU] = findSlddSigPortData(ModelName, portsPath)
% 作者： Blue.ge
% 日期： 20231027
%%
    if isempty(portsPath)
        warning('the ports path is unaviliable, pls input the right portsPath')
    end
    len = length(portsPath);
    % 这里的17表示数据有17列
    % pcmu DATA
    DataPCMU=cell(len,17);
    % vcu DATA
    DataVCU=cell(len,17);
    for i=1:len
        h=get_param(portsPath{i}, 'Handle');
        ins = get(h);
        if strcmp(ins.BlockType,'Inport')
            PortType = 'Input';
            IniValue = '';
            CustomStorageClass = 'Global1';
        end
        if strcmp(ins.BlockType,'Outport')
            PortType = 'Output';
            IniValue = '';
            CustomStorageClass = 'Global1';
        end
        
        DataPCMU{i,1} = ModelName;  % ModelName
        DataPCMU{i,2} = PortType;  % PortType
        DataPCMU{i,3} = ins.Name;  % Name
        DataPCMU{i,4} = ins.OutDataTypeStr;  % DataPCMUType
        DataPCMU{i,5} = CustomStorageClass;  % CustomStorageClass
        DataPCMU{i,6} = [ModelName '.c'];  % DefinitionFile
        DataPCMU{i,7} = '';  % RTE_Interface
        DataPCMU{i,8} = ins.PortDimensions;  % Dimensions
        DataPCMU{i,9} = '';  % Details
        DataPCMU{i,10} = '';  % ValueTable
        DataPCMU{i,11} = ins.Unit;  % Unit
        DataPCMU{i,12} = IniValue;  % IniValue
        DataPCMU{i,13} = ins.OutMin;  % Min
        DataPCMU{i,14} = ins.OutMax;  % Max
        DataPCMU{i,15} = '';  % DataPCMUTypeSelect
        DataPCMU{i,16} = '';  % CustomStorageClassSelect
        DataPCMU{i,17} = '';  % DefinitionFile

        [~, ~, ~, sigVCU, ~] = findNameType(ins.Name);
        DataVCU(i,:) = DataPCMU(i,:);
        if strcmp(PortType, 'Input')
            sigVCU = strrep(sigVCU, 'APP', 'IMP');
        end
        DataVCU{i,5} = sigVCU;

    end

end
