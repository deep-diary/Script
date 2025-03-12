function paramsArr = findDCMParam(filepath)
%%
    % 目的: 解析DCM文件
    % 输入：
    %       filepath： DCM 文件路径
    % 返回： DCM 各种数据类型结构体
    % 范例： paramsArr = findDCMParam('HY11_PCMU_Tm_OTA2_V5010208_Change.DCM')
    % 作者： Blue.ge
    % 日期： 20240123
%%
    clc
    %% 初始化变量
    % 初始化变量为空的结构体数组
    constArr = struct('name', {}, 'langname', {}, 'einheitW', {}, 'wert', {});  % 'fuction', {}, 
    axisArr = struct('name', {}, 'langname', {}, 'einheitX', {}, 'x', {});
    wertArr = struct('name', {}, 'langname', {},'einheitW', {}, 'wert', {});
    tabArr = struct('name', {}, 'nameX', {}, 'langname', {}, 'einheitX', {}, 'einheitW', {}, 'x', {}, 'wert', {});
    mapArr = struct('name', {}, 'nameX', {}, 'nameY', {}, 'langname', {}, 'einheitX', {}, 'einheitY', {}, 'einheitW', {}, 'x', {}, 'y', {}, 'wert', {});
%     mapArr = struct('name', {}, 'nameX', {}, 'nameY', {}, 'langname', {}, 'fuction', {}, 'einheitX', {}, 'einheitY', {}, 'einheitW', {}, 'x', {}, 'y', {}, 'wert', {});
    %% 打开文件并逐行读取
    fid = fopen(filepath, 'r');
    if fid == -1
        error('无法打开文件：%s', filepath);
    end
    cnt = 1;
    currentType = '';
    tempData = struct();
%     tempData = struct('name', '', 'langname', '', 'fuction', '', 'einheitX', '', 'einheitY', '', 'einheitW', '', 'x', [], 'y', [], 'wert', {});
    currentX = [];
    currentY = [];
    currentWert = [];
    isInMultiLine = false;

    try
        while ~feof(fid)
            cnt = cnt+1;
            line = fgetl(fid);
            line = strtrim(line);

            % 检查行类型
            if startsWith(line, 'FESTWERT ')
                currentType = 'FESTWERT';
                tempData.name = strtrim(extractAfter(line, 'FESTWERT '));
            elseif startsWith(line, 'STUETZSTELLENVERTEILUNG ')
                currentType = 'STUETZSTELLENVERTEILUNG';
%                 tempData.name = strtrim(extractAfter(line, 'STUETZSTELLENVERTEILUNG '));

                nameParts = regexp(line, 'STUETZSTELLENVERTEILUNG\s+(\S+)', 'tokens');
                if ~isempty(nameParts)
                    tempData.name = nameParts{1}{1};
                end
            elseif startsWith(line, 'FESTWERTEBLOCK ')
                currentType = 'FESTWERTEBLOCK';
%                 tempData.name = strtrim(extractAfter(line, 'FESTWERTEBLOCK '));

                nameParts = regexp(line, 'FESTWERTEBLOCK\s+(\S+)', 'tokens');
                if ~isempty(nameParts)
                    tempData.name = nameParts{1}{1};
                end
            elseif startsWith(line, 'GRUPPENKENNLINIE ')
                currentType = 'GRUPPENKENNLINIE';
%                 tempData.name = strtrim(extractAfter(line, 'GRUPPENKENNLINIE '));

                nameParts = regexp(line, 'GRUPPENKENNLINIE\s+(\S+)', 'tokens');
                if ~isempty(nameParts)
                    tempData.name = nameParts{1}{1};
                end
                currentX = [];
                currentWert = [];
            elseif startsWith(line, 'GRUPPENKENNFELD ')
                currentType = 'GRUPPENKENNFELD';
%                 tempData.name = strtrim(extractAfter(line, 'GRUPPENKENNFELD '));

                nameParts = regexp(line, 'GRUPPENKENNFELD\s+(\S+)', 'tokens');
                if ~isempty(nameParts)
                    tempData.name = nameParts{1}{1};
                end
                
                tempData.nameX = '';
                tempData.nameY = '';
                currentX = [];
                currentY = [];
                currentWert = [];
                isInMultiLine = false;

            % 解析行内容
            elseif startsWith(line, 'LANGNAME')
                langname = extractBetween(line, '"', '"');
                tempData.langname = langname{1};
%                 if ~isempty(langname)
%                     tempData.langname = langname{1};
%                 else
%                     tempData.langname='';
%                 end
            elseif startsWith(line, 'FUNKTION')
                tempData.fuction = strtrim(extractAfter(line, 'FUNKTION '));
            elseif startsWith(line, 'EINHEIT_W')
                tempData.einheitW = strtrim(extractAfter(line, 'EINHEIT_W '));
            elseif startsWith(line, 'EINHEIT_X')
                tempData.einheitX = strtrim(extractAfter(line, 'EINHEIT_X '));
            elseif startsWith(line, 'EINHEIT_Y')
                tempData.einheitY = strtrim(extractAfter(line, 'EINHEIT_Y '));
            elseif startsWith(line, '*SSTX')
                tempData.nameX = strtrim(extractAfter(line, '*SSTX'));
            elseif startsWith(line, '*SSTY')
                tempData.nameY = strtrim(extractAfter(line, '*SSTY'));
            elseif startsWith(line, 'ST/X')
                xValues = str2num(extractAfter(line, 'ST/X'));
                currentX = [currentX, xValues];  % 累积 X 值
                tempData.x = currentX;

            elseif startsWith(line, 'ST/Y')
                yValue = str2num(extractAfter(line, 'ST/Y'));
                if isInMultiLine
                    % Finish the previous Y-Wert pair and start a new one
                    if ~isfield(tempData, 'y')
                        tempData.y = currentY;
                    else
                        % 如果 y 字段已存在，则追加值
                        tempData.y(end+1) = currentY;
                    end

                    if ~isfield(tempData, 'wert')
                        tempData.wert = currentWert;
                    else
                        % 如果 wert 字段已存在，则追加值
%                         tempData.wert{end+1} = currentWert;
                        tempData.wert = [tempData.wert; currentWert];
                    end
                end
                currentY = yValue;
                currentWert = [];
                isInMultiLine = true;
            elseif startsWith(line, 'WERT')
                wertValues = str2num(extractAfter(line, 'WERT'));
                currentWert = [currentWert, wertValues];  % 累积 Wert 值

            % 当到达每个变量的结尾时
            elseif strcmp(line, 'END')
%                 disp(currentType)
                switch currentType
                    case 'FESTWERT'
                        tempData.wert = currentWert;  
                        constArr(end+1) = tempData;
                    case 'STUETZSTELLENVERTEILUNG'
                        tempData.x = currentX;
                        axisArr(end+1) = tempData;
                    case 'FESTWERTEBLOCK'
                        tempData.wert = currentWert;
                        wertArr(end+1) = tempData;
                    case 'GRUPPENKENNLINIE'
                        tempData.x = currentX;
                        tempData.wert = currentWert;
                        tabArr(end+1) = tempData;
                    case 'GRUPPENKENNFELD'
                        if isInMultiLine
                            tempData.y(end+1) = currentY;
                            tempData.wert = [tempData.wert; currentWert];
                        end
                        % 将 tempData.wert 中的单元数组转换为矩阵
%                         if isfield(tempData, 'wert') && iscell(tempData.wert)
%                             tempData.wert = vertcat(tempData.wert{:});
%                         end
                        mapArr(end+1) = tempData;
                end
                % 重置临时数据结构
                tempData = struct();
                currentX = [];
                currentY = [];
                currentWert = [];
                currentType = '';
                isInMultiLine = false;
            end
        end
    catch
        fclose(fid);
        rethrow(lasterror);
    end

    fclose(fid);


    paramsArr = {constArr,axisArr,wertArr,tabArr,mapArr};
end





