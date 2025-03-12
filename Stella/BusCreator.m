function BusCreator()

%���ݲο�ģ�ͣ��ڼܹ�ģ���н���BusCreator
Model = find_system(bdroot,'BlockType','ModelReference');
for i = 1 : length(Model)
    TemHan = get_param(Model{i,1},'Handle');
    TemPc = get_param(Model{i,1},'PortConnectivity');
    
    %�ҵ��ο�ģ�����ӵ�BusCreator�ľ��
    DesBlk = 0;
    for j = 1 : length(TemPc)
        if(~isempty(TemPc(j).DstBlock))
            DesBlk = TemPc(j).DstBlock;
        end
    end
    
    %�����ǰ�ο�ģ�ͺ�BusCreator֮�����������
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
    
    
    %���ݲο�ģ�͵�����źţ�ȷ��BusCreator���ź���Ŀ������ʵ�ֲο�ģ�ͺ�BusCreator������
    ModelPh = get(TemHan,'PortHandles');
    BusCreatorPh = get(DesBlk,'PortHandles');
    for m = 1 : length(ModelPh.Outport)
        set(DesBlk,'Inputs',num2str(length(ModelPh.Outport)));
        add_line(gcs,ModelPh.Outport(m),BusCreatorPh.Inport(m));
    end
end
end