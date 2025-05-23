function saveSlddTable(ModelName, DataPCMU,  varargin)
% 目的: 保存二维表到excel 中
% 输入：
%       ModelName: 模型名称
%       stData:  表格数据
%       DataVCU: VCU sldd数据
% 返回： DataPCMU: null
% 范例： saveSlddTable(ModelName, DataPCMU, 'dataType','1D')
% 作者： Blue.ge
% 日期： 20231010
%%
    %% 参数处理
     clc
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'dataType','1D');  % 1D, 2D
%     addParameter(p,'tarPath',None);  % 1D, 2D
    addParameter(p,'fileNamePCMU','_DD_PCMU.xlsx');  
    addParameter(p,'fileNameVCU','_DD_VCU.xlsx');  
    addParameter(p,'overwrite',true);  
    addParameter(p,'solveTabInputName',false);  
   
    % 输入参数处理   
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    dataType = p.Results.dataType;
    fileNamePCMU = p.Results.fileNamePCMU;
    fileNameVCU = p.Results.fileNameVCU;
    overwrite = p.Results.overwrite;
    solveTabInputName = p.Results.solveTabInputName;

    %% 获取sldd 保存路径
    % 模型名_DD_VCU/PCMU
    %处理ModelName
    if contains(ModelName, "/")
        slashes = strfind(ModelName, "/");
        ModelName = extractAfter(ModelName, slashes(end));
    end

    % 如果是overwrite, 则更新路径, 临时
    if overwrite 
        fNamePCMU =[ModelName fileNamePCMU];
        fNameVCU = [ModelName fileNameVCU] ;
        fPCMU = which(fNamePCMU) ;
        fVCU = which(fNameVCU) ;
        if isempty(fPCMU) || isempty(fVCU)
            fPCMU = fullfile(pwd, [ModelName fileNamePCMU]) ;
            fVCU = fullfile(pwd, [ModelName fileNameVCU]) ;
        end
    else
        fPCMU = fullfile(pwd, [ModelName '_DD_PCMU_EXPORT.xlsx']) ;
        fVCU = fullfile(pwd, [ModelName '_DD_VCU_EXPORT.xlsx']) ;
    end

    sheet = dataType;
     if(strlength(sheet)>=31)
         sheet=sheet(1:30);
     end

    %%
    if strcmp(dataType, '1D')
        %% 保存1维表
        
%         rows1D = startsWith(DataPCMU.Name,'tTm');
%         DataPCMU = DataPCMU(rows1D,:);
        rows = size(DataPCMU,1);
        stData = cell(rows/2*3,10);
        for i=1:2:rows
%             disp(i)
            idy = 4*(i-1)/2+1;
%             idy = idy+1; % 让第一行为空
            data = DataPCMU(i,:);
            X = DataPCMU(i+1,:);
            
            name = data{3};
            nameX = X{3};
            value = data{12};
            valueX = X{12};

            if ischar(value)
                value = str2num(value);
            end
            if ischar(valueX)
                valueX = str2num(valueX);
            end
            widX = length(valueX);

            % 找到输入名字
            if solveTabInputName
                try
                    variables = Simulink.findVars(bdroot, ...
                        'SourceType','base workspace', ...
                        'SearchMethod','cached', ...
                        'Name',name...
                        ); %% 'SourceType','base workspace',     
                catch
                    variables = Simulink.findVars(bdroot, ...
                        'SourceType','base workspace', ...
                        'Name',name...
                        ); %% 'SourceType','base workspace',     'SearchMethod','cached', ...
                end
                path = variables(1).Users{1};  % 对应模块路径
                [X,Y] = findTableInputType(path);
            end


            % 第一行
            stData{idy,1} = data{9};  % description
            stData{idy,2} = widX;  % 宽度

            if solveTabInputName
                stData{idy+1,1} = X.name;
            else
                stData{idy+1,1} = nameX;
            end
            stData(idy+1,2:widX+1) = num2cell(valueX);

            % 第一行
            stData{idy+2,1} = name;
            stData(idy+2,2:widX+1) = num2cell(value);
            
            
        end
    elseif strcmp(dataType, '2D')
        %% 保存2维表
%         rows2D = startsWith(DataPCMU.Name,'mTm');
%         DataPCMU = DataPCMU(rows2D,:);
        rows = size(DataPCMU,1);
        idy = 1; % 从第二行开始
        stData = {};
        for i=1:3:rows
            disp(i)
            data = DataPCMU(i,:);
            X = DataPCMU(i+1,:);
            Y = DataPCMU(i+2,:);
            name = data{3};
            nameX = X{3};
            nameY = Y{3};
            value = data{12};
            valueX = X{12};
            valueY = Y{12}; 
            if ischar(value)
                value = str2num(value);
            end
            if ischar(valueX)
                valueX = str2num(valueX);
            end
            if ischar(valueY)
                valueY = str2num(valueY);
            end
            widX = length(valueX);
            widY = length(valueY);

            % 找到输入名字
            if solveTabInputName
                try
                    variables = Simulink.findVars(bdroot, ...
                        'SourceType','base workspace', ...
                        'SearchMethod','cached', ...
                        'Name',name...
                        ); %% 'SourceType','base workspace',     
                catch
                    variables = Simulink.findVars(bdroot, ...
                        'SourceType','base workspace', ...
                        'Name',name...
                        ); %% 'SourceType','base workspace',     'SearchMethod','cached', ...
                end
                path = variables(1).Users{1};  % 对应模块路径
                [X,Y] = findTableInputType(path);
            end
            % 第一行
            stData{idy,1} = data{9};  % description
            if solveTabInputName
                stData{idy+1,1} = X.name;
            else
                stData{idy+1,1} = nameX;
            end
            stData{idy,3} = widX;  % 宽度
            % 第二行
            if solveTabInputName
                stData{idy+1,1} = Y.name;
            else
                stData{idy+1,1} = nameY;
            end
            stData{idy+1,2} = name;
            stData(idy+1,3:3+widX-1) = num2cell(valueX);
            % 第三行
            stData{idy+2,1} = widY;
            % Y轴区域
            stData(idy+2:idy+2+widY-1,2) = num2cell(valueY);
            % 数据区
            stData(idy+2:idy+2+widY-1,3:3+widX-1) = num2cell(value);
        
            idy = idy + widY + 3;
        end
    else
        error('pls input the right dataType, the chooses are only: 1D, 2D')
    end
    writecell(stData,fPCMU,'Sheet',sheet ,'WriteMode','overwritesheet');
    writecell(stData,fVCU,'Sheet',sheet,'WriteMode','overwritesheet');

end