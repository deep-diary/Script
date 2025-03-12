function saveSlddTableByInitValue(path, DataPCMU,  varargin)
% 目的: 将sldd的表格初始值导出表格形式
% 输入：
%       ModelName: 模型名称
%       stData:  表格数据
%       DataVCU: VCU sldd数据
% 返回： DataPCMU: null
% 范例： saveSlddTableByInitValue(ModelName, DataPCMU, 'dataType','1D')
% 作者： Blue.ge
% 日期： 20240805
%%
    %% 参数处理
%      clc
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'dataType','1D');  % 1D, 2D
    addParameter(p,'override',true);  
   
    % 输入参数处理   
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    dataType = p.Results.dataType;
    override = p.Results.override;

    %% 获取sldd 保存路径
    % 模型名_DD_VCU/PCMU
    %处理ModelName
%     if contains(ModelName, "/")
%         slashes = strfind(ModelName, "/");
%         ModelName = extractAfter(ModelName, slashes(end));
%     end
% 
%     % 如果是override, 则更新路径, 临时
%     if override 
%         fNamePCMU =[ModelName fileNamePCMU];
%         fNameVCU = [ModelName fileNameVCU] ;
%         fPCMU = which(fNamePCMU) ;
%         fVCU = which(fNameVCU) ;
%         if isempty(fPCMU) || isempty(fVCU)
%             fPCMU = fullfile(pwd, [ModelName fileNamePCMU]) ;
%             fVCU = fullfile(pwd, [ModelName fileNameVCU]) ;
%         end
%     else
%         fPCMU = fullfile(pwd, [ModelName fileNamePCMU]) ;
%         fVCU = fullfile(pwd, [ModelName fileNameVCU]) ;
%     end

    if override 
        fPath = which(path);
    else
        fPath = fullfile(pwd, path);
    end

    sheet = dataType;
     if(strlength(sheet)>=31)
         sheet=sheet(1:30);
     end

    %%
    if strcmp(dataType, '1D')
        %% 保存1维表
        
        rows1D = startsWith(DataPCMU.Name,'tTm');
        DataPCMU = DataPCMU(rows1D,:);
        rows = size(DataPCMU,1);
        stData = cell(rows/2*3,10);
        for i=1:2:rows
%             disp(i)
            idy = 4*(i-1)/2+1;
%             idy = idy+1; % 让第一行为空

            % confirm the rows
            row1 = DataPCMU(i,:);
            row2 = DataPCMU(i+1,:);
            
            nameR1 = row1.Name{1};
            nameR2 = row2.Name{1};

            EndXR1 = endsWith(nameR1,'_x') || endsWith(nameR1,'_X');
            EndXR2 = endsWith(nameR2,'_x') || endsWith(nameR2,'_X');

            if EndXR1 && ~EndXR2
                data = row2;
                X = row1;
            elseif EndXR2 && ~EndXR1
                data = row1;
                X = row2;
            else
                error('pls check the data. the Axis value should end with _X or _x ')
            end


            value = data.IniValue{1};
            valueX = X.IniValue{1};

            value = str2num(value);
            valueX = str2num(valueX);
            widX = length(valueX);


            % 第一行
            stData{idy,1} = data.Details{1};  % description
            stData{idy,2} = widX;  % 宽度

            stData{idy+1,1} = X.Name{1};
            stData(idy+1,2:widX+1) = num2cell(valueX);

            % 第一行
            stData{idy+2,1} = data.Name{1};
            stData(idy+2,2:widX+1) = num2cell(value);
            
            
        end
    elseif strcmp(dataType, '2D')
        %% 保存2维表
        rows2D = startsWith(DataPCMU.Name,'mTm');
        DataPCMU = DataPCMU(rows2D,:);
        rows = size(DataPCMU,1);
        idy = 1; % 从第二行开始
        stData = {};

        % 初始化标志列
        is_X = false([1 3]);
        is_Y = false([1 3]);
        is_data = false([1 3]);
        for i=1:3:rows
%             disp(i)
            table = DataPCMU(i:i+2,:);

            % solution 1
            is_X = endsWith(table.Name,'_x') | endsWith(table.Name,'_X');
            is_Y = endsWith(table.Name,'_y') | endsWith(table.Name,'_Y');
            is_data = ~(is_X | is_Y);

            % solution 2 遍历每行数据并进行判断
%             for j = 1:3
%                 if endsWith(v.Name{j},'_x') || endsWith(table.Name{j},'_X')
%                     is_X(j) = true;
%                 elseif endsWith(table.Name{j},'_y') || endsWith(table.Name{j},'_Y')
%                     is_Y(j) = true;
%                 else
%                     is_data(j) = true;
%                 end
%             end

            data = table(is_data,:);
            X = table(is_X,:);
            Y = table(is_Y,:);
            name = data.Name{1};
            nameX = X.Name{1};
            nameY = Y.Name{1};
            value = data.IniValue{1};
            valueX = X.IniValue{1};
            valueY = Y.IniValue{1};
            value = str2num(value);
            valueX = str2num(valueX);
            valueY = str2num(valueY);
            widX = length(valueX);
            widY = length(valueY);


            % 第一行
            stData{idy,2} = nameX;

            stData{idy,3} = widX;  % 宽度
            % 第二行
            stData{idy+1,1} = nameY;
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
    writecell(stData,fPath,'Sheet',sheet ,'WriteMode','overwritesheet');

end