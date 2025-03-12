filename='ChangeName.xlsx';
sheet=1;
range='A1:B29';
%请输入表格地址（filename），引用工作表序号（sheet），范围（range）
[~,data_list,~]=xlsread(filename,sheet,range);
modelname='TmComprCtrl';%模型名
%% 替换Port
for i=1:length(data_list)
    PortExist=find_system(modelname,'Name',data_list{i,1});
    if isempty(PortExist)
        %do nothing;
    else
        for j=1:length(PortExist)
            set_param(PortExist{j},'Name',data_list{i,2});
        end
    end
end
%% 替换goto
for i=1:length(data_list)
    gotoExist=find_system(modelname,'BlockType','Goto', 'GotoTag',data_list{i,1});

    if isempty(gotoExist)
        %do nothing;
    else
        for j=1:length(gotoExist)
            set_param(gotoExist{j},'GotoTag',data_list{i,2});
        end
    end
end

%% 替换From
for i=1:length(data_list)
    fromExist=find_system(modelname,'BlockType','From', 'GotoTag',data_list{i,1});

    if isempty(fromExist)
        %do nothing;
    else
        for j=1:length(fromExist)
            set_param(fromExist{j},'GotoTag',data_list{i,2});
        end
    end
end
