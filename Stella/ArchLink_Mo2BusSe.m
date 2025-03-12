function ArchLink_Mo2BusSe

disp(' ');
disp('ArchLink_Mo2BusSe开始运行--------------------------------------------------------------------------------------------------------------------');

%该脚本运行和文件夹位置无关
%Simulink打开且进入架构模型，如HX11SwArch
%根据参考模型生成BusSelector，并且连接BusSelector和参考模型
%使用前，在模型中手动添加一个简单的BusSelector,并和参考模型连接，只连接一根线就行
%只要All的BusSelector的信号分类的结构层次关系有变化，或者增加新的信号都要修改LinkSelectorModel.m文件中AllSignals的收集代码
%bdroot with no arguments returns the name of the current top-level system.
%bdroot

%根据参考模型，在架构模型中建立BusCreator
BusCreator();

%returns the numeric handle of the top-level system that contains the current block.返回值为block_diagram的句柄，非block
ArchHan = bdroot(gcbh);
%收集在参考模型和信号汇总集合all之间没有匹配成功的信号，需自行检查原因
SignalsNeedCheck = {};
t = 0;
%收集处理过的模型
ModelReport = {};
k = 0;
%获取所有参考模型的句柄
%ModelHans = find_system(ArchHan,'SearchDepth','1','BlockType','ModelReference');
ModelHans = find_system(ArchHan,'BlockType','ModelReference');

for i = 1 :length(ModelHans)
    ModelHan = get_param(ModelHans(i),'Handle');
    k = k + 1;
    ModelReport{k,1} = get_param(ModelHans(i),'ModelName');
    %根据参考模型生成BusSelector，并且连接BusSelector和参考模型，且返回MissMatch的信号
    TemSignals = LinkSelector2Model(ModelHan);
    %将没匹配成功的信号添加到SignalsNeedCheck
    if(length(TemSignals) ~= 0)
        for j = 1 : length(TemSignals(:,1))
            t = t + 1;
            SignalsNeedCheck{t,1} = TemSignals{j,1};
            SignalsNeedCheck{t,2} = TemSignals{j,2};
        end
    end
end

%报告处理过的模型
disp('本次处理的模型如下：');
for r = 1 :length(ModelReport(:,1))
    disp(['          ' num2str(r) '.' ModelReport{r}]);
end

if(~isempty(SignalsNeedCheck))
    xlswrite('MissMatchSignals.xlsx',SignalsNeedCheck);
    %生成MissMatch报告
    disp('需修复MissMatch:');
    disp('          未匹配成功信号见文件：MissMatchSignals.xlsx');
end

if(isempty(SignalsNeedCheck))
    disp('所有信号全部匹配成功！！！');
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

disp(['Package2Release位置：' which('Package2Release')]);
disp(['LinkSelector2Model位置：' which('LinkSelector2Model')]);

disp('ArchLink_Mo2BusSe结束运行--------------------------------------------------------------------------------------------------------------------');

end




    
    

