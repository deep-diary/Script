[num,txt,~] =xlsread("Template_SigEdit.xlsx","ExvSim");%读取表格数据
Sig_name=txt;
Sig_data=num;
% Sig_name=cell(2,1);
Sig_length=size(Sig_data,1);%1——返回数据的行数（按照采样时间的数据点）
Sig_Num=size(Sig_data,2);%2——返回数据的列数（信号数）
test_time=Sig_data(:,1);%赋值时间数据
DataInput = Simulink.SimulationData.Dataset;%新建数据类
for i=2:Sig_Num
    sig_Tmp=Sig_data(:,i);
    element_Tmp = Simulink.SimulationData.Signal;
    element_Tmp.Name = Sig_name{i};
    element_Tmp.Values=timeseries(sig_Tmp,test_time);
    DataInput = DataInput.addElement(element_Tmp);%向数据类中添加数据
end


