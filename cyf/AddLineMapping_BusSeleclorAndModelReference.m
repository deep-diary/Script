% clear
clc
proj = currentProject;
rootPath = proj.RootFolder;
cd(rootPath);
load('TmVcThermal_Configuration_sub.mat');
ArchName='TmSwArch';
load_system([ArchName '.slx']);
BusSelector_obj=find_system(ArchName,'SearchDepth',1,'BlockType','BusSelector');
% ExcelName='C:\Users\yuanfei.chen\Desktop\BusSignalCheck.xlsx';
ModelReference_obj=find_system(ArchName,'SearchDepth',1,'BlockType','ModelReference');
ModelReference_name=get_param(ModelReference_obj,'Name');
for j=1:length(BusSelector_obj)
    BusSelector_name=get_param(BusSelector_obj{j},"Name");
    BusSelector_Handle=getSimulinkBlockHandle(BusSelector_obj{j});
    if ~strcmp(BusSelector_name,'TmOut')
    SubModel_name=BusSelector_name;
%     try
        load_system(SubModel_name);
        %获取所需信号
        Inports_obj=find_system(SubModel_name,'SearchDepth',1,'BlockType','Inport');
        BusIpSigs_cells=get_param(BusSelector_Handle,"InputSignals");

        %信号名拼接赋值给BusSelect输出信号
        Outport_Name0=get_param(Inports_obj{1},'Name');
        busOutSignal_list=['Tasks.Task_100ms_TmSw.' Outport_Name0];
        % busOutSignal_list=['sTmSigProces_Op.' Outport_Name0];
        for i=2:length(Inports_obj)
            Outport_Name=get_param(Inports_obj{i},'Name');
            for n_cell=2:length(BusIpSigs_cells)
                K=matches(BusIpSigs_cells{n_cell,1}{1,2},Outport_Name);
                a=find(K);
                if ~isempty(a)
                    busOutSignal_frontName=BusIpSigs_cells{n_cell,1}{1,1};
                    busOutSignal_fullName=[busOutSignal_frontName '.' Outport_Name];
                end
            end
            busOutSignal=[',' busOutSignal_fullName];
            busOutSignal_list=[busOutSignal_list busOutSignal];
%             Excel_cell{j}{i,2}=string(Outport_Name);%将Inport名写如Excel单元
        end

        set_param(BusSelector_Handle,"OutputSignals",string(busOutSignal_list));
        %% BusSelector与ModelReference连线
        busSeletcor_portHandles=get_param(BusSelector_Handle,'PortHandles');
        
        modelReference_Obj = find_system(ArchName,'SearchDepth',1,'BlockType','ModelReference','ModelName',SubModel_name);
        modelReference_Handle = getSimulinkBlockHandle(modelReference_Obj);
        modelReference_portHandles=get_param(modelReference_Handle,'PortHandles');
%         PortHandles=busSeletcor_portHandles.Inport;
%         a=get(PortHandles);
      
        for s=1:length(busSeletcor_portHandles.Outport)
            LineHandle=get(busSeletcor_portHandles.Outport(s),"Line");
            if isequal(LineHandle,-1)
            add_line(ArchName,busSeletcor_portHandles.Outport(s),modelReference_portHandles.Inport(s))
            end
        end
        %% Bus mapping 结果提示
        disp([SubModel_name,' Bus match is finished!'])
        
        %% 验证端口是否正确匹配
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
