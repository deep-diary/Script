%% Add new blocks
% Inp1_obj=Simulink.findBlocks('TMSwArch','Name','In1');
% Inp1_Handle=Inp1_obj;
% Inp1_posn=get_param(Inp1_Handle,'Position');
% 
% for i=1:2
%     add_block('simulink/Commonly Used Blocks/In1','TMSwArch/Inport',...
%         'position',[Inp1_posn(1) 40*i+Inp1_posn(2) Inp1_posn(3) 40*i+Inp1_posn(4)],'MakeNameUnique','On');
% end

%%Add blocks from Excel
clear
[File_name,Path_name]=uigetfile({'*.xlsx;*.xls'});
Excel_name=[Path_name File_name];
Excel_sheet='Sheet1';
Excel_Range='B1:B590';
[~,~,cells]=xlsread(Excel_name,Excel_sheet,Excel_Range);
a=cells{1};
Model_target='SigIn_Tot';
Model_target1='SigIn_Tot/';
Outp1_obj=Simulink.findBlocks(Model_target,'Name','From');
get(Outp1_obj);
Outp1_posn=get_param(Outp1_obj,'Position');
set_param(Outp1_obj,"GotoTag",a);
% add_block('simulink/Signal Routing/From',[Model_target1,'From2'] ,'GotoTag',a,...
%         'position',[Outp1_posn(1) 40+Outp1_posn(2) Outp1_posn(3) 40+Outp1_posn(4)]);
% b=[Model_target1,'From',num2str(idx+1)];
for idx=1:length(cells)-1
    add_block('simulink/Signal Routing/From',[Model_target1,'From',num2str(idx)],'GotoTag',cells{idx+1},...
        'position',[Outp1_posn(1) 40*idx+Outp1_posn(2) Outp1_posn(3) 40*idx+Outp1_posn(4)]);
end
OurportCell = find_system(bdroot,'SearchDepth',1,'BlockType','From');  %
for i = 1:length(OurportCell)  
    set_param(OurportCell{i},'AttributesFormatString','%<GotoTag>')  %
end
%%Copy blocks
% baseBlock_Obj=Simulink.findBlocks('SigIn_Tot','Name','Signal_In340');
% baseBlock_posn=get_param(baseBlock_Obj,'Position');
% for idx=1:591
%     add_block('SigIn_Tot/Signal_In340','SigIn_Tot/Signal_In','position',...
%         [baseBlock_posn(1) 40*idx+baseBlock_posn(2),baseBlock_posn(3) 40*idx+baseBlock_posn(4)],'MakeNameUnique','On');
% end


%%Add Line
% outBlock_Name='Signal_In';
% for idx=341:591
%     outBlock_fullName=outBlock_Name+string(idx);
%     outBlock_Obj=Simulink.findBlocks('SigIn_Tot','Name',outBlock_fullName);
%     outBlock_Handle=get_param(outBlock_Obj,"PortHandles");
%     inBlock_Obj=Simulink.findBlocks('SigIn_Tot','Port',string(idx+1));
%     inBlock_Handle=get_param(inBlock_Obj,"PortHandles");
%     add_line('SigIn_Tot',outBlock_Handle.Outport,inBlock_Handle.Inport);
% end

%% Delete Line
% outBlock_Name='Signal_In';
% for idx=341:591
%     outBlock_fullName=outBlock_Name+string(idx);
%     outBlock_Obj=Simulink.findBlocks('SigIn_Tot','Name',outBlock_fullName);
%     outBlock_Handle=get_param(outBlock_Obj,"PortHandles");
%     inBlock_Obj=Simulink.findBlocks('SigIn_Tot','Port',string(idx+2));
%     inBlock_Handle=get_param(inBlock_Obj,"PortHandles");
%     delete_line('SigIn_Tot',outBlock_Handle.Outport,inBlock_Handle.Inport);
% end