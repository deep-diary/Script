clear
clc
load('Configuration_VCU.mat');
proj = currentProject;
rootPath = proj.RootFolder;
cd(rootPath);

ExcelName = '15_TmOut-输出信号-cyf.xlsx';
ExcelPath = rootPath+'\Scrpits\'+ExcelName;
sheet=3;
range='C2:D377';
%请输入表格地址（filename），引用工作表序号（sheet），范围（range）
[~,data_list,~] = xlsread(ExcelPath,sheet,range);

ArchName='TmSwArch';
load_system(ArchName);
BusSelector_obj = find_system(ArchName,'SearchDepth',1,'BlockType','BusSelector','Name','TmOut');
Outport_obj = find_system(ArchName,'SearchDepth',1,'BlockType','Outport');
CheckOkCounter=0;
CheckNOkCounter=0;
for i=1:length(Outport_obj)
    Outport_Handle = getSimulinkBlockHandle(Outport_obj(i));
    Outport_Connect_Handle = get_param(Outport_Handle,'PortConnectivity');
    Outport_Connect_SrcBlock_Handle = Outport_Connect_Handle.SrcBlock;
    Outport_Connect_SrcBlock_Type = get_param(Outport_Connect_SrcBlock_Handle,'BlockType');

    if strcmp(Outport_Connect_SrcBlock_Type,'SignalConversion') == 1
        Outport_Connect_SrcBlock_Connect = get_param(Outport_Connect_SrcBlock_Handle,"PortConnectivity");
        Outport_Connect_SrcBlock_Connect_ScrBlock_Handle = Outport_Connect_SrcBlock_Connect.SrcBlock;
        Outport_Connect_SrcBlock_Connect_ScrBlock_Type = get_param(Outport_Connect_SrcBlock_Connect_ScrBlock_Handle,"BlockType");
        
        Outport_Name = get_param(Outport_Handle,"Name");
        if strcmp(Outport_Connect_SrcBlock_Connect_ScrBlock_Type,'BusSelector')
            Outport_Connect_SrcBlock_InputSingnalName = get_param(Outport_Connect_SrcBlock_Handle,"InputSignalNames");
        else
            Outport_Connect_SrcBlock_InputSingnalName = get_param(Outport_Connect_SrcBlock_Connect_ScrBlock_Handle,"InputSignalNames");
        end
    end
    for i_excel = 1:length(data_list)
        if strcmp(data_list{i_excel,2},Outport_Name) ==1
            OutputName_subModel = data_list{i_excel,1};
            
            if  ~strcmp(Outport_Connect_SrcBlock_InputSingnalName{1,1}(2:end-1),OutputName_subModel) ==1
                CheckNOkCounter = CheckNOkCounter + 1;
                warning([Outport_Connect_SrcBlock_InputSingnalName{1,1} ' Mapping ' OutputName_subModel ' Wrong !'])
            else
                CheckOkCounter = CheckOkCounter + 1;
%                 disp([Outport_Connect_SrcBlock_InputSingnalName{1,1} ' mapping ' OutputName_subModel ' Right!']);
            end
        end
    end
end
disp(['-----------Check Finish-----------' newline num2str(CheckOkCounter) ' bus signals mapping Right. ' num2str(CheckNOkCounter) ' bus signals mapping Wrong!']);
