%���ݲο�ģ������BusSelector����������BusSelector�Ͳο�ģ��
%ʹ��ǰ����ģ�����ֶ����һ���򵥵�BusSelector,���Ͳο�ģ�����ӣ�ֻ����һ���߾���
%�����ڲο�ģ�����У������������źż���all��û�ҵ��ź�
%��Ҫ�ṩ�ο�ģ�͵ľ��
%ֻҪAll��BusSelector���źŷ���Ľṹ��ι�ϵ�б仯�����������µ��źŶ�Ҫ�޸�AllSignals���ռ�����
%------------------
%�ýű����к��ļ���λ���޹�
function SisNeedCheck = LinkSelector2Model(TarModelHan)
%TarModel = gcbh;
%TarModelHan= gcbh;
ModelName = get_param(TarModelHan,'ModelName');
disp([ModelName ':']);
disp('Selector��ģ�����ӿ�ʼ');

%��ȡ�ο�ģ�͵ľ��
ModelHan = get_param(TarModelHan,'Handle');
%����ĳ�ο�ģ�ͣ��豣֤�Ƕ���,����ֵΪblock_diagram�ľ������block
Tarsys = load_system(ModelName);
%��ĳ�ο�ģ�Ͷ��㣬�ҵ�Inport
TarsysIn = find_system(Tarsys,'SearchDepth','1','BlockType','Inport');
Tem = {};

%��ȡ�ο�ģ��Inport�źż���Tem,�����ź�����Port��
for i = 1:length(TarsysIn)
    Tem{i, 1} = get_param(TarsysIn(i),'Name');
    PortStr = get_param(TarsysIn(i),'Port');
    %�˴��ǹؼ�����ȻPort���ַ������֣���ʵ�ʵ����ֲ���ȵģ�Ҫת��Ϊʵ������
    Tem{i, 2} = str2num(PortStr);
end
%�رռ��صĲο�ģ��
close_system(ModelName);

%��ȡ�ο�ģ�Ͷ�Ӧ��BusSelector���
%�ο�ģ���Ƿ�����BusSelector��־
ModLin2BusFlag = 0;

%��ȡ�Ͳο�ģ�����ӵ�BusSelector���BusSelHan
BusSelHan = 0;
LinHan = get_param(TarModelHan,'LineHandles');
InLin = LinHan.Inport;
for j = 1 :length(InLin)
    if(LinHan.Inport(j) ~= -1)
        ModLin2BusFlag = ModLin2BusFlag + 1;
        BusSelPortHan = LinHan.Inport(j);
        BusSelHan = get_param(BusSelPortHan,'SrcBlockHandle');
        break;
    end
end

if(ModLin2BusFlag == 0)
    errordlg('�ο�ģ�ͺ�BusSelectorû�����ӣ����ֶ�����1����','modal');
end

%��ȡBusSelector�������źż��ϣ�all��һ�������źţ��ڶ��д�·���ź�
%�ⲿ�ֵĹؼ���All��BusSelector�źŷ���Ľṹ��ι�ϵ�����ʵ���źŵ������ͻ���
%ֻҪAll��BusSelector���źŷ���Ľṹ��ι�ϵ�б仯�����������µ��źŶ�Ҫ�޸��ⲿ�ִ���
t = 1;
all = {};
if(ModLin2BusFlag ~= 0)
    AllSignals = get_param(BusSelHan,'InputSignals');
    for m = 1 :length(AllSignals)
        %if(~isequal(AllSignals{m,1}{1,1},'SignalsIn_Ip'))
        if((~isequal(AllSignals{m,1}{1,1},'SignalsIn_Ip')) && (~isequal(AllSignals{m,1}{1,1},'Tasks')))
            for n = 1 : length(AllSignals{m,1}{1,2})
                %all{t} = AllSignals{m,1}{1,2}{n,1};
                all{t,1} = AllSignals{m,1}{1,2}{n,1};
                %all{t} = [AllSignals{m,1}{1,1} '.' AllSignals{m,1}{1,2}{n,1}];
                all{t,2} = [AllSignals{m,1}{1,1} '.' AllSignals{m,1}{1,2}{n,1}];
                t = t + 1;
            end
        end
        
        %�ռ�SignalsIn_Ip��ӦBusSeletor���ź�
        if(isequal(AllSignals{m,1}{1,1},'SignalsIn_Ip'))
            for r = 1 :length(AllSignals{m,1}{1,2})
                for p =1 :length(AllSignals{m,1}{1,2}{r,1} {1,2})
                    for q = 1 :length(AllSignals{m,1}{1,2}{r,1} {1,2}{p,1}{1,2})
                        %all{t} = AllSignals{m,1}{1,2}{r,1}{1,2}{p,1}{1,2}{q,1};
                        all{t,1} = AllSignals{m,1}{1,2}{r,1}{1,2}{p,1}{1,2}{q,1};
                        %all{t} = [AllSignals{m,1}{1,1} '.' AllSignals{m,1}{1,2}{r,1}{1,1} '.' AllSignals{m,1}{1,2}{r,1}{1,2}{p,1}{1,1} '.' AllSignals{m,1}{1,2}{r,1}{1,2}{p,1}{1,2}{q,1}];
                        all{t,2} = [AllSignals{m,1}{1,1} '.' AllSignals{m,1}{1,2}{r,1}{1,1} '.' AllSignals{m,1}{1,2}{r,1}{1,2}{p,1}{1,1} '.' AllSignals{m,1}{1,2}{r,1}{1,2}{p,1}{1,2}{q,1}];
                        t = t + 1;
                        %disp([num2str(m) num2str(p) num2str(q)]);
                        %disp(AllSignals{m,1}{1,2}{r,1}{1,1});
                    end
                end
            end
        end
        
        %�ռ�Tasks��ӦBusSeletor���ź�
        if(isequal(AllSignals{m,1}{1,1},'Tasks'))
            for tx = 1 : length(AllSignals{m,1}{1,2})
                for ty = 1 : length(AllSignals{m,1}{1,2}{tx,1}{1,2})
                    all{t,1} = AllSignals{m,1}{1,2}{tx,1}{1,2}{ty,1};
                    all{t,2} = [AllSignals{m,1}{1,1} '.' AllSignals{m,1}{1,2}{tx,1}{1,1} '.' AllSignals{m,1}{1,2}{tx,1}{1,2}{ty,1}];
                    t = t + 1;
                end
            end
        end
                
    end
end

%�ο�ģ��inport����Tem�������ź�all������ƥ��
%�������������TemSigInAll����all�е��ź����ʹ�·�����ź�����Tem�вο�ģ�Ͷ�Ӧ��Inport��ţ���ӦTemSigInAll��һ�У��ڶ��к͵�����
%���û�ѵ������û�ѵ����źŲ��Ҽ�¼��TemSigOutAll��
TemSigInAll = {};
TemSigOutAll = {};
FindNum =  0;
NoFindNum = 0;
for xx = 1 :length(Tem(:,1))
    FindFlag = 0;
    for xy = 1 : length(all(:,1))
        if(isequal(Tem{xx,1}, all{xy ,1}))
            FindNum = FindNum + 1;
            FindFlag = FindFlag + 1;
            TemSigInAll{FindNum,1} = all{xy,1};
            TemSigInAll{FindNum,2} = all{xy,2};
            TemSigInAll{FindNum,3} = Tem{xx,2};
        end        
    end
    if(FindFlag == 0)
        disp( ['          ' 'Miss Match:' Tem{xx,1}]);
        NoFindNum = NoFindNum + 1;
        TemSigOutAll{NoFindNum,1} = Tem{xx,1};
        %���δ�ɹ�ƥ���ź�����ģ�����ƣ�����׷��
        TemSigOutAll{NoFindNum,2} = ModelName;
        
        FindNum = FindNum + 1;
        TemSigInAll{FindNum,1} = Tem{xx,1};
        TemSigInAll{FindNum,2} = Tem{xx,1};
        TemSigInAll{FindNum,3} = Tem{xx,2};               
    end       
end
%����ģ�ͺ�all��δƥ�䵽���ź�
SisNeedCheck = TemSigOutAll;
        
%���ο�ģ��Inport���ź���ӵ�BusSelect��
Add2BusSelectOut = '';
 for yx = 1:length(TemSigInAll(:,2))
     %TemSigInAllƴ�ӳ�BusSelector����ĸ�ʽ
     if(yx == 1)
         Add2BusSelectOut = [TemSigInAll{yx,2}];
     else
         Add2BusSelectOut = [Add2BusSelectOut ',' TemSigInAll{yx,2}];
     end
 end
 
 %��ƴ�Ӻ�ӿ���Ϣ��ֵ��BusSelector�����
  set_param(BusSelHan,'OutputSignals',Add2BusSelectOut);
  
  %ɾ��BusSelect�Ͳο�ģ��֮�����������
  BusLine = get_param(BusSelHan,'LineHandles');
  LinToBeDele = BusLine.Outport;
  for ka = 1 :length(LinToBeDele)
      if(LinToBeDele(ka) > 0)
          delete_line(LinToBeDele(ka));
      end
  end
       
  %����BusSelector Out�Ͳο�ģ�͵�Inport
  %�ο�ģ��Inport���ϵ��°���Port��Ŵ�С��˳����ʾ�ڲο�ģ����
  %BusSelectorҲ�ǰ��ղο�ģ��Inport��Port��Ŵ�С��˳����ʾ
  ModelPortHan = get_param(ModelHan,'PortHandles');
  ModelInportHan = ModelPortHan.Inport;
  BusSelPortHan = get_param(BusSelHan,'PortHandles');
  BusSelOutportHan = BusSelPortHan.Outport;
  
  for zx = 1 :length(TemSigInAll(:,3))
      %��ȡ��all�����ҵ���Port��Ӧ�ľ��
      InPortHan = ModelInportHan(TemSigInAll{zx, 3});
      SelecOutPortHan = BusSelOutportHan(zx);
      add_line(gcs,SelecOutPortHan,InPortHan);
  end
  
  disp('Selector��ģ�����ӳɹ�');
  disp(' ');
  %����ں����б������ᵼ�·���ֵû�и�ֵ��������
  %clear;
end
 