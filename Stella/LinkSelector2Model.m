%根据参考模型生成BusSelector，并且连接BusSelector和参考模型
%使用前，在模型中手动添加一个简单的BusSelector,并和参考模型连接，只连接一根线就行
%返回在参考模型中有，但是在所有信号集合all中没找到信号
%需要提供参考模型的句柄
%只要All的BusSelector的信号分类的结构层次关系有变化，或者增加新的信号都要修改AllSignals的收集代码
%------------------
%该脚本运行和文件夹位置无关
function SisNeedCheck = LinkSelector2Model(TarModelHan)
%TarModel = gcbh;
%TarModelHan= gcbh;
ModelName = get_param(TarModelHan,'ModelName');
disp([ModelName ':']);
disp('Selector和模型连接开始');

%获取参考模型的句柄
ModelHan = get_param(TarModelHan,'Handle');
%加载某参考模型，需保证是顶层,返回值为block_diagram的句柄，非block
Tarsys = load_system(ModelName);
%在某参考模型顶层，找到Inport
TarsysIn = find_system(Tarsys,'SearchDepth','1','BlockType','Inport');
Tem = {};

%获取参考模型Inport信号集合Tem,包括信号名和Port号
for i = 1:length(TarsysIn)
    Tem{i, 1} = get_param(TarsysIn(i),'Name');
    PortStr = get_param(TarsysIn(i),'Port');
    %此处是关键，不然Port是字符的数字，和实际的数字不相等的，要转化为实际数字
    Tem{i, 2} = str2num(PortStr);
end
%关闭加载的参考模型
close_system(ModelName);

%获取参考模型对应的BusSelector句柄
%参考模型是否连接BusSelector标志
ModLin2BusFlag = 0;

%获取和参考模型连接的BusSelector句柄BusSelHan
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
    errordlg('参考模型和BusSelector没有连接，需手动连接1根线','modal');
end

%获取BusSelector中所有信号集合，all第一列最终信号，第二列带路径信号
%这部分的关键是All的BusSelector信号分类的结构层次关系，如何实现信号的搜索和汇总
%只要All的BusSelector的信号分类的结构层次关系有变化，或者增加新的信号都要修改这部分代码
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
        
        %收集SignalsIn_Ip对应BusSeletor的信号
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
        
        %收集Tasks对应BusSeletor的信号
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

%参考模型inport集合Tem在所有信号all中搜索匹配
%如果搜索到，用TemSigInAll返回all中的信号名和带路径的信号名和Tem中参考模型对应的Inport序号，对应TemSigInAll第一列，第二列和第三列
%如果没搜到，输出没搜到的信号并且记录到TemSigOutAll中
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
        %添加未成功匹配信号所在模型名称，方便追溯
        TemSigOutAll{NoFindNum,2} = ModelName;
        
        FindNum = FindNum + 1;
        TemSigInAll{FindNum,1} = Tem{xx,1};
        TemSigInAll{FindNum,2} = Tem{xx,1};
        TemSigInAll{FindNum,3} = Tem{xx,2};               
    end       
end
%返回模型和all中未匹配到的信号
SisNeedCheck = TemSigOutAll;
        
%将参考模型Inport的信号添加到BusSelect中
Add2BusSelectOut = '';
 for yx = 1:length(TemSigInAll(:,2))
     %TemSigInAll拼接成BusSelector输出的格式
     if(yx == 1)
         Add2BusSelectOut = [TemSigInAll{yx,2}];
     else
         Add2BusSelectOut = [Add2BusSelectOut ',' TemSigInAll{yx,2}];
     end
 end
 
 %将拼接后接口信息赋值给BusSelector的输出
  set_param(BusSelHan,'OutputSignals',Add2BusSelectOut);
  
  %删除BusSelect和参考模型之间的已有连线
  BusLine = get_param(BusSelHan,'LineHandles');
  LinToBeDele = BusLine.Outport;
  for ka = 1 :length(LinToBeDele)
      if(LinToBeDele(ka) > 0)
          delete_line(LinToBeDele(ka));
      end
  end
       
  %连接BusSelector Out和参考模型的Inport
  %参考模型Inport从上到下按照Port序号大小的顺序显示在参考模型上
  %BusSelector也是按照参考模型Inport的Port序号大小的顺序显示
  ModelPortHan = get_param(ModelHan,'PortHandles');
  ModelInportHan = ModelPortHan.Inport;
  BusSelPortHan = get_param(BusSelHan,'PortHandles');
  BusSelOutportHan = BusSelPortHan.Outport;
  
  for zx = 1 :length(TemSigInAll(:,3))
      %获取在all中能找到的Port对应的句柄
      InPortHan = ModelInportHan(TemSigInAll{zx, 3});
      SelecOutPortHan = BusSelOutportHan(zx);
      add_line(gcs,SelecOutPortHan,InPortHan);
  end
  
  disp('Selector和模型连接成功');
  disp(' ');
  %如果在函数中保留，会导致返回值没有赋值，而报错
  %clear;
end
 