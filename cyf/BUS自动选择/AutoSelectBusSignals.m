%%AutoSelectBusSignals
clear
BusSelector_obj=find_system('TMSwArch/TmDiag','SearchDepth',1,'Name','Bus Selector6');
BusSelector_Handle=getSimulinkBlockHandle(BusSelector_obj);
get(BusSelector_Handle);
%获取所需信号
Inports_obj=find_system('TmDiag','SearchDepth',1,'BlockType','Inport');
%信号名拼接赋值给BusSelect输出信号
busSignals=get_param(Inports_obj{1},'Name');
%busSignals=busSignals(1:length(busSignals)-2);
for i=1:528
    Outport_Name=get_param(Inports_obj{2},'Name');
    busSignals=[busSignals ',' Outport_Name];
end
set_param(BusSelector_Handle,"OutputSignals",string(busSignals));

%(1:length(Outport_Name)-2)