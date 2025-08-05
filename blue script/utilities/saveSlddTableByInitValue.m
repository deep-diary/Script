function saveSlddTableByInitValue(path, DataPCMU,  varargin)
%% 待优化
% 目的: 将sldd的表格初始值导出表格形式
% 输入：
%       ModelName: 模型名称
%       stData:  表格数据
%       DataVCU: VCU sldd数据
% 返回： DataPCMU: null
% 范例： saveSlddTableByInitValue('TmComprCtrl_DD_PCMU.xlsx', 'HY11_PCMU_Tm_OTA3_V6060416_All.DCM', 'dataType','2D')
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
    stData = {};
    if strcmp(dataType, '1D')
        %% 保存1维表
        
        rows1D = startsWith(DataPCMU.Name,'tTm'); % startsWith,contains
        DataPCMU = DataPCMU(rows1D,:);
        rows = size(DataPCMU,1);% 数据加X轴总个数
%         stData = cell(rows/2*3,10);

%         for i=1:rows
%             name = strtrim(DataPCMU.Name{i});
%             is_X(i) = endsWith(name,'_x') | endsWith(name,'_X');
%             is_data(i)  = ~is_X(i);
%         end

        is_X = endsWith(DataPCMU.Name,'_x') | endsWith(DataPCMU.Name,'_X');
        is_data  = ~is_X;


        X_t=DataPCMU(is_X,:);
        data_t = DataPCMU(is_data,:);
        rows = size(data_t,1); % 数据个数

        for i=1:rows
%             disp(i)
            idy = 4*(i-1)+1;

            data = data_t(i,:);
            name = strtrim(data.Name{1});
            X = X_t(contains(X_t.Name,name),:);

            if isempty(X) 
                warning('The X axis of %s is not existed',name)
                continue
            end

            nameX = strtrim(X.Name{1});

            % 去掉字符串前面的空格或者空行
            value = data.IniValue{1};
            valueX = X.IniValue{1};
            
            % 字符串转数字
            value = str2num(value);
            valueX = str2num(valueX);

            % 如果是浮点数则保留4位小数
            if any(mod(value,1)~=0)
                value = round(value,4);
            end
            if any(mod(valueX,1)~=0)
                valueX = round(valueX,4);
            end

            % 数字转元组
            value = num2cell(value);
            valueX = num2cell(valueX);

            widX = length(valueX);

            % 第一行
            stData{idy,1} = data.Details{1};  % description
            stData{idy,2} = widX;  % 宽度

            stData{idy+1,1} = nameX;
            stData(idy+1,2:widX+1) = valueX;

            % 第一行
            stData{idy+2,1} = name;
            stData(idy+2,2:widX+1) = value;

        end



    elseif strcmp(dataType, '2D')
        %% 保存2维表
        rows2D = startsWith(DataPCMU.Name,'mTm');
        DataPCMU = DataPCMU(rows2D,:);
        rows = size(DataPCMU,1);
        idy = 1; % 从第二行开始
        stData = {};

%         for i=1:rows
%             name = strtrim(DataPCMU.Name{i});
%             is_X(i) = endsWith(name,'_x') | endsWith(name,'_X');
%             is_Y(i)  = endsWith(name,'_y') | endsWith(name,'_Y');
%             is_data(i)  = ~(is_X(i) | is_Y(i));
%         end

        is_X = endsWith(DataPCMU.Name,'_x') | endsWith(DataPCMU.Name,'_X');
        is_Y  = endsWith(DataPCMU.Name,'_y') | endsWith(DataPCMU.Name,'_Y');
        is_data  = ~(is_X | is_Y);

        X_t=DataPCMU(is_X,:);
        Y_t=DataPCMU(is_Y,:);
        data_t = DataPCMU(is_data,:);
        rows = size(data_t,1);
        for i=1:rows
%             disp(i)
            data = data_t(i,:);
            name = strtrim(data.Name{1});
            X = X_t(contains(X_t.Name,name),:);
            Y = Y_t(contains(Y_t.Name,name),:);
            if isempty(X) || isempty(Y)
                warning('The X or Y axis of %s is not existed',name)
                continue
            end

            nameX = strtrim(X.Name{1});
            nameY = strtrim(Y.Name{1});

            % 去掉字符串前面的空格或者空行
            value = data.IniValue{1};
            valueX = X.IniValue{1};
            valueY = Y.IniValue{1};
            
            % 字符串转数字
            value = str2num(value);
            valueX = str2num(valueX);
            valueY = str2num(valueY);

            % 如果是浮点数则保留4位小数
            if any(mod(value,1)~=0)
                value = round(value,4);
            end
            if any(mod(valueX,1)~=0)
                valueX = round(valueX,4);
            end
            if any(mod(valueY,1)~=0)
                valueY = round(valueY,4);
            end
            
            % 数字转元组
            value = num2cell(value);
            valueX = num2cell(valueX);
            valueY = num2cell(valueY);

            widX = length(valueX);
            widY = length(valueY);

            % 第一行
            stData{idy,2} = nameX;

            stData{idy,3} = widX;  % 宽度
            % 第二行
            stData{idy+1,1} = nameY;
            stData{idy+1,2} = name;
            stData(idy+1,3:3+widX-1) = valueX;
            % 第三行
            stData{idy+2,1} = widY;
            % Y轴区域
            stData(idy+2:idy+2+widY-1,2) = valueY;
            % 数据区
            stData(idy+2:idy+2+widY-1,3:3+widX-1) = value;
        
            idy = idy + widY + 3;
        end

    else
        error('pls input the right dataType, the chooses are only: 1D, 2D')
    end
    writecell(stData,fPath,'Sheet',sheet ,'WriteMode','overwritesheet');

end