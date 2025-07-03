function paramsArr = findDCMParam(filepath)
%FINDDCMPARAM 解析DCM文件并提取参数
%   PARAMSARR = FINDDCMPARAM(FILEPATH) 解析指定的DCM文件，提取所有参数
%
%   输入参数:
%      filepath     - DCM文件的完整路径
%
%   输出参数:
%      paramsArr    - 包含5种参数类型的元胞数组:
%                     {1} - 常量 (FESTWERT)
%                     {2} - 轴定义 (STUETZSTELLENVERTEILUNG)
%                     {3} - 值块 (FESTWERTEBLOCK)
%                     {4} - 一维表 (GRUPPENKENNLINIE)
%                     {5} - 二维表 (GRUPPENKENNFELD)
%
%   示例:
%      params = findDCMParam('HY11_PCMU_Tm_OTA3_V6030303_Change.DCM');
%      constValues = params{1};  % 获取所有常量
%      maps = params{5};         % 获取所有二维表
%
%   参见: FINDDCMNAMES, FINDDCMNAMESCHANGES
%
%   作者: Blue.ge
%   版本: 2.0
%   日期: 20250320

    %% 初始化变量
    % 初始化5种参数类型的结构体数组
    constArr = struct('name', {}, 'langname', {}, 'einheitW', {}, 'wert', {});
    axisArr = struct('name', {}, 'langname', {}, 'einheitX', {}, 'x', {});
    wertArr = struct('name', {}, 'langname', {}, 'einheitW', {}, 'wert', {});
    tabArr = struct('name', {}, 'nameX', {}, 'langname', {}, 'einheitX', {}, 'einheitW', {}, 'x', {}, 'wert', {});
    mapArr = struct('name', {}, 'nameX', {}, 'nameY', {}, 'langname', {}, 'einheitX', {}, 'einheitY', {}, 'einheitW', {}, 'x', {}, 'y', {}, 'wert', {});
    
    %% 检查文件路径
    if ~exist(filepath, 'file')
        error('文件不存在: %s', filepath);
    end
    
    %% 打开文件并逐行读取
    fid = fopen(filepath, 'r');
    if fid == -1
        error('无法打开文件: %s', filepath);
    end
    
    % 初始化解析变量
    currentType = '';
    tempData = struct();
    currentX = [];
    currentY = [];
    currentWert = [];
    isInMultiLine = false;

    try
        while ~feof(fid)
            line = fgetl(fid);
            if isempty(line)
                continue;
            end
            
            line = strtrim(line);

            % 检查数据类型开始标记
            if startsWith(line, 'FESTWERT ')
                currentType = 'FESTWERT';
                tempData.name = strtrim(extractAfter(line, 'FESTWERT '));
                
            elseif startsWith(line, 'STUETZSTELLENVERTEILUNG ')
                currentType = 'STUETZSTELLENVERTEILUNG';
                nameParts = regexp(line, 'STUETZSTELLENVERTEILUNG\s+(\S+)', 'tokens');
                if ~isempty(nameParts)
                    tempData.name = nameParts{1}{1};
                end
                
            elseif startsWith(line, 'FESTWERTEBLOCK ')
                currentType = 'FESTWERTEBLOCK';
                nameParts = regexp(line, 'FESTWERTEBLOCK\s+(\S+)', 'tokens');
                if ~isempty(nameParts)
                    tempData.name = nameParts{1}{1};
                end
                
            elseif startsWith(line, 'GRUPPENKENNLINIE ')
                currentType = 'GRUPPENKENNLINIE';
                nameParts = regexp(line, 'GRUPPENKENNLINIE\s+(\S+)', 'tokens');
                if ~isempty(nameParts)
                    tempData.name = nameParts{1}{1};
                end
                currentX = [];
                currentWert = [];
                
            elseif startsWith(line, 'GRUPPENKENNFELD ')
                currentType = 'GRUPPENKENNFELD';
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

            % 解析属性值
            elseif startsWith(line, 'LANGNAME')
                langname = extractBetween(line, '"', '"');
                if ~isempty(langname)
                    tempData.langname = langname{1};
                else
                    tempData.langname = '';
                end
                
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
                xValues = str2num(extractAfter(line, 'ST/X')); %#ok<ST2NM>
                currentX = [currentX, xValues];  % 累积X值
                tempData.x = currentX;

            elseif startsWith(line, 'ST/Y')
                yValue = str2num(extractAfter(line, 'ST/Y')); %#ok<ST2NM>
                if isInMultiLine
                    % 结束前一个Y-Wert对并开始新的一个
                    if ~isfield(tempData, 'y')
                        tempData.y = currentY;
                    else
                        tempData.y(end+1) = currentY;
                    end

                    if ~isfield(tempData, 'wert')
                        tempData.wert = currentWert;
                    else
                        tempData.wert = [tempData.wert; currentWert];
                    end
                end
                currentY = yValue;
                currentWert = [];
                isInMultiLine = true;
                
            elseif startsWith(line, 'WERT')
                wertValues = str2num(extractAfter(line, 'WERT')); %#ok<ST2NM>
                currentWert = [currentWert, wertValues];  % 累积Wert值

            % 当达到每个参数的结束标记时
            elseif strcmp(line, 'END')
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
                        mapArr(end+1) = tempData;
                end
                
                % 重置临时数据
                tempData = struct();
                currentX = [];
                currentY = [];
                currentWert = [];
                currentType = '';
                isInMultiLine = false;
            end
        end
    catch ME
        fclose(fid);
        error('解析DCM文件时出错: %s\n行: %s', ME.message, line);
    end

    fclose(fid);

    % 返回包含所有参数类型的元胞数组
    paramsArr = {constArr, axisArr, wertArr, tabArr, mapArr};
end





