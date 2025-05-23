function [fPCMU, fVCU] = saveSldd(ModelName, DataPCMU, DataVCU, varargin)
% 目的: 将端口的Signal信号，保存到excel中
% 输入：
%       ModelName: 模型名称
%       DataPCMU:  PCMU sldd数据
%       DataVCU: VCU sldd数据
% 返回： DataPCMU: [fPCMU, fVCU]
% 范例： saveSldd(DataPCMU, DataVCU)
% 作者： Blue.ge
% 日期： 20231010
%%
    %% 参数处理
     clc
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'dataType','Signals');  % Signals, Parameters
    addParameter(p,'fileNamePCMU','_DD_PCMU.xlsx');  
    addParameter(p,'fileNameVCU','_DD_VCU.xlsx');  
    addParameter(p,'overwrite',true);  
   
    % 输入参数处理   
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    dataType = p.Results.dataType;
    fileNamePCMU = p.Results.fileNamePCMU;
    fileNameVCU = p.Results.fileNameVCU;
    overwrite = p.Results.overwrite;

    %% 处理保存路径
    %处理ModelName
    if contains(ModelName, "/")
        slashes = strfind(ModelName, "/");
        ModelName = extractAfter(ModelName, slashes(end));
    end

    modPath = which(ModelName);
    modFold = fileparts(modPath);
    % 如果是overwrite, 则更新路径, 临时
    if overwrite 
        fPCMU = fullfile(modFold, [ModelName fileNamePCMU]) ;
        fVCU = fullfile(modFold, [ModelName fileNameVCU]) ;

    else
        fPCMU = fullfile(modFold, [ModelName '_DD_PCMU_EXPORT.xlsx']) ;
        fVCU = fullfile(modFold, [ModelName '_DD_VCU_EXPORT.xlsx']) ;
    end



    if ~strcmp(dataType, 'Signals') && ~strcmp(dataType, 'Parameters')
        error('pls input the right dataType, the chooses are only: Signals, Parameters')
    end
    sheet = dataType;
     if(strlength(sheet)>=31)
         sheet=sheet(1:30);
     end


    %% 合并标题
    dataTitle={'ModelName', 'PortType','Name','DataType','CustomStorageClass','DefinitionFile','RTE_Interface','Dimensions','Details', 'ValueTable', 'Unit','IniValue','Min','Max','DataTypeSelect','CustomStorageClassSelect','DefinitionFile'};
    DataPCMUT = [dataTitle; DataPCMU];
    DataVCUT = [dataTitle; DataVCU];

    %%
%     xlswrite(fPCMU,DataPCMUT,sheet,xlRange);
%     xlswrite(fVCU,DataVCUT,sheet,xlRange);
    writecell(DataPCMUT,fPCMU,'Sheet',sheet ,'WriteMode','overwritesheet');
    writecell(DataVCUT,fVCU,'Sheet',sheet,'WriteMode','overwritesheet');
end