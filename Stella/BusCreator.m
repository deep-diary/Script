function BusCreator()

%根据参考模型，在架构模型中建立BusCreator
Model = find_system(bdroot,'BlockType','ModelReference');
for i = 1 : length(Model)
    TemHan = get_param(Model{i,1},'Handle');
    TemPc = get_param(Model{i,1},'PortConnectivity');
    
    %找到参考模型连接的BusCreator的句柄
    DesBlk = 0;
    for j = 1 : length(TemPc)
        if(~isempty(TemPc(j).DstBlock))
            DesBlk = TemPc(j).DstBlock;
        end
    end
    
    %清除当前参考模型和BusCreator之间的已有连线
    modelLh = get(TemHan,'LineHandles');
    for k = 1 : length(modelLh.Outport)
        if(modelLh.Outport(k)>0)
            delete_line(modelLh.Outport(k));
        end
    end
    DesBlkLh = get(DesBlk,'LineHandles');
    for k = 1 : length(DesBlkLh.Inport)
        if(DesBlkLh.Inport(k)>0)
            delete_line(DesBlkLh.Inport(k));
        end
    end
    
    
    %根据参考模型的输出信号，确定BusCreator的信号数目，并且实现参考模型和BusCreator的连线
    ModelPh = get(TemHan,'PortHandles');
    BusCreatorPh = get(DesBlk,'PortHandles');
    for m = 1 : length(ModelPh.Outport)
        set(DesBlk,'Inputs',num2str(length(ModelPh.Outport)));
        add_line(gcs,ModelPh.Outport(m),BusCreatorPh.Inport(m));
    end
end
end