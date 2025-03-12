function ArchLink_Mo2BusSe

disp(' ');
disp('ArchLink_Mo2BusSe��ʼ����--------------------------------------------------------------------------------------------------------------------');

%�ýű����к��ļ���λ���޹�
%Simulink���ҽ���ܹ�ģ�ͣ���HX11SwArch
%���ݲο�ģ������BusSelector����������BusSelector�Ͳο�ģ��
%ʹ��ǰ����ģ�����ֶ����һ���򵥵�BusSelector,���Ͳο�ģ�����ӣ�ֻ����һ���߾���
%ֻҪAll��BusSelector���źŷ���Ľṹ��ι�ϵ�б仯�����������µ��źŶ�Ҫ�޸�LinkSelectorModel.m�ļ���AllSignals���ռ�����
%bdroot with no arguments returns the name of the current top-level system.
%bdroot

%���ݲο�ģ�ͣ��ڼܹ�ģ���н���BusCreator
BusCreator();

%returns the numeric handle of the top-level system that contains the current block.����ֵΪblock_diagram�ľ������block
ArchHan = bdroot(gcbh);
%�ռ��ڲο�ģ�ͺ��źŻ��ܼ���all֮��û��ƥ��ɹ����źţ������м��ԭ��
SignalsNeedCheck = {};
t = 0;
%�ռ��������ģ��
ModelReport = {};
k = 0;
%��ȡ���вο�ģ�͵ľ��
%ModelHans = find_system(ArchHan,'SearchDepth','1','BlockType','ModelReference');
ModelHans = find_system(ArchHan,'BlockType','ModelReference');

for i = 1 :length(ModelHans)
    ModelHan = get_param(ModelHans(i),'Handle');
    k = k + 1;
    ModelReport{k,1} = get_param(ModelHans(i),'ModelName');
    %���ݲο�ģ������BusSelector����������BusSelector�Ͳο�ģ�ͣ��ҷ���MissMatch���ź�
    TemSignals = LinkSelector2Model(ModelHan);
    %��ûƥ��ɹ����ź���ӵ�SignalsNeedCheck
    if(length(TemSignals) ~= 0)
        for j = 1 : length(TemSignals(:,1))
            t = t + 1;
            SignalsNeedCheck{t,1} = TemSignals{j,1};
            SignalsNeedCheck{t,2} = TemSignals{j,2};
        end
    end
end

%���洦�����ģ��
disp('���δ����ģ�����£�');
for r = 1 :length(ModelReport(:,1))
    disp(['          ' num2str(r) '.' ModelReport{r}]);
end

if(~isempty(SignalsNeedCheck))
    xlswrite('MissMatchSignals.xlsx',SignalsNeedCheck);
    %����MissMatch����
    disp('���޸�MissMatch:');
    disp('          δƥ��ɹ��źż��ļ���MissMatchSignals.xlsx');
end

if(isempty(SignalsNeedCheck))
    disp('�����ź�ȫ��ƥ��ɹ�������');
end

disp('     ');
disp('     ');
disp('BUS Size AutoFit Start:');
RefMod = find_system(bdroot,'SearchDepth','1','BlockType','ModelReference');
for i = 1 : length(RefMod)
    PosRefMod = get_param(RefMod{i},'Position');
    LenRefMode = PosRefMod(3) - PosRefMod(1);
    TemCnn = get_param(RefMod{i},'PortConnectivity');
    TemCnnSrc = TemCnn(1,1).SrcBlock;
    TemCnnDes = TemCnn(end,1).DstBlock;
    if(isequal(get(TemCnnSrc,'BlockType'),'BusSelector'))
       set_param(TemCnnSrc,'Position',PosRefMod-[180+30,0,LenRefMode+180,0]);  
       %disp('BusSelector Done---------------------------------------------------------');
    end
    if(isequal(get(TemCnnDes,'BlockType'),'BusCreator'))
        set_param(TemCnnDes,'Position',PosRefMod+[LenRefMode+180,0,180+30,0]); 
        %disp('BusCreator Done---------------------------------------------------------');
    end  
    disp(['          ' num2str(i) '.' get_param(RefMod{i},'name') ': Done']);
end
disp('BUS Size AutoFit Finish!');

disp(['Package2Releaseλ�ã�' which('Package2Release')]);
disp(['LinkSelector2Modelλ�ã�' which('LinkSelector2Model')]);

disp('ArchLink_Mo2BusSe��������--------------------------------------------------------------------------------------------------------------------');

end




    
    

