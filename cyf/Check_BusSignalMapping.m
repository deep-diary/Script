%% 验证端口是否正确匹配
clear
clc
proj = currentProject;
rootPath = proj.RootFolder;
cd(rootPath);
load('Configuration_VCU.mat');
ArchName='TmSwArch';
load_system([ArchName '.slx']);
BusSelector_obj=find_system(ArchName,'SearchDepth',1,'BlockType','BusSelector');
% ExcelName='C:\Users\yuanfei.chen\Desktop\BusSignalCheck.xlsx';

for j=1:length(BusSelector_obj)
    BusSelector_name=get_param(BusSelector_obj{j},"Name");
    BusSelector_Handle=getSimulinkBlockHandle(BusSelector_obj{j});
    if ~strcmp(BusSelector_name,'TmOut')
    SubModel_name=BusSelector_name;
    load_system(SubModel_name);

    Inports_obj=find_system(SubModel_name,'SearchDepth',1,'BlockType','Inport');

    get(BusSelector_Handle);
    BusOutputSignalsName=get_param(BusSelector_Handle,"OutputSignalNames");
    n_BusOutputSignals=length(BusOutputSignalsName);
    for i2=1:n_BusOutputSignals
        BusOutputSignalsList{i2,1}=BusOutputSignalsName{1,i2};
        BusOutputSignalsList{i2,1}=BusOutputSignalsList{i2,1}(2:length(BusOutputSignalsList{i2,1})-1);
    end

    for i3=1:length(Inports_obj)
        InportName=get_param(Inports_obj,'Name');
    end

    for i2=1:n_BusOutputSignals
        if ~isequal(BusOutputSignalsList(i2),InportName(i2))
            warning(['<',BusOutputSignalsList{i2,1},'> is not mapping with <',InportName{i2,1},'>']);
        end
    end
    %BusOutputSignalsList_str=string(BusOutputSignalsList);
    disp(['BusSelector ',SubModel_name,' mapping check is finished!'])
    end
end
