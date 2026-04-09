inport=find_system('VcThermal_old/VcThermal_50ms_sys','BlockType','Outport');
for i=1:length(inport)
    portName=get_param(inport{i},'Name');
    xhx=strfind(portName,'_');
    if mod(length(xhx),2)==0
        portNameNew=portName(1:xhx(length(xhx)/2)-1);
    elseif mod(length(xhx),2)==1
        idx=length(xhx)-1;
        portNameNew=portName(1:xhx(idx/2)-1);
    end
    set_param(inport{i},'Name',portNameNew);
end