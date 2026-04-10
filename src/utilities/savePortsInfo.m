function savePortsInfo(modelName, Data)

    fullpath =pwd;%mfilename('fullpath');将软件运行目录改为matlab当前工作目录
    filename = [fullpath,'\','PortsInfo','.xlsx'];
    fprintf(filename)
    xlRange = 'A1';
    sheet = modelName;
     if(strlength(sheet)>=31)
         sheet=sheet(1:30);
     end
    fprintf('%s\n',filename);


    %% 增加序号列
    % 获取二维 cell 数组的行数
    numRows = size(Data, 1);

    % 创建递增序列作为新的一列，从 1 开始到总行数减一
    incrementalColumn = num2cell(1:numRows)';
    

    dataTitle={'Num', 'ModelName','BlockType','PortNum','PortName','DateType','From','To','Label', 'Remark'};
    Data = [incrementalColumn, Data];
    Data = [dataTitle; Data];

    %%
    xlswrite(filename,Data,sheet,xlRange);

end