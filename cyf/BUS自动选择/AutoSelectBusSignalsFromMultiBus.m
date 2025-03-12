%%AutoSelectBusSignalsFromMutiBus
% clear
BusSelector_obj=find_system(gcs,'SearchDepth',1,'Name','BusHp');
BusSelector_Handle=getSimulinkBlockHandle(BusSelector_obj);
get(BusSelector_Handle);
%获取所需信号 GlTmSigOut

Inports_obj=find_system('HP_MODEL','SearchDepth',1,'BlockType','Inport');
BusIpSigs_cells=get_param(BusSelector_Handle,"InputSignals");

%信号名拼接赋值给BusSelect输出信号
Outport_Name0=get_param(Inports_obj{1},'Name');
busOutSignal_list=['Tasks.' Outport_Name0];

suffix='in';
for i=2:length(Inports_obj)
    Outport_Name=get_param(Inports_obj{i},'Name');
    if endsWith(Outport_Name,suffix)
        Outport_Name=extractBefore(Outport_Name,length(Outport_Name)-length(suffix)+1)
    end
    busOutSignal_fullName = ['----',Outport_Name, '----------'];
    for n_cell=2:length(BusIpSigs_cells)
        K=matches(BusIpSigs_cells{n_cell,1}{1,2},Outport_Name);
        a=find(K);
        if ~isempty(a)
            busOutSignal_frontName=BusIpSigs_cells{n_cell,1}{1,1};
            busOutSignal_fullName=[busOutSignal_frontName '.' Outport_Name];
            break
        end
    end
    busOutSignal=[',' busOutSignal_fullName];
    busOutSignal_list=[busOutSignal_list busOutSignal];
end

set_param(BusSelector_Handle,"OutputSignals",string(busOutSignal_list));