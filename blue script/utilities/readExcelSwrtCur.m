function dataTable = readExcelSwrtCur(excelFileName, sheetName)
%%
% 目的: 读取SwrtCur表格中的数据。
% 输入：
%       excelFileName： 模板 excel 路径
%       sheetName：     表格中的sheet 名字
% 返回：
%       dataTable： 表格数据结构体
% 范例：dataTable = readExcelSwrtCur('SWRT_cur.xlsx', 'Sheet1')
% 说明：
% 作者： Blue.ge
    
    %% Excel文件路径和Sheet名称定义
    % 输入文件
    templateFileName = 'template.xlsx';
    templateSheetName = 'SWRT_last';
    swrtChgFileName = 'SWRT_chg.xlsx';
    swrtChgSheetName = 'SWRT_chg';
    swrtCurFileName = 'SWRT_cur.xlsx';
    swrtCurSheetName = 'SWRT_cur';
    
    % 输出文件
    swrtChgOutputFileName = 'SWRT_chg_new.xlsx';
    swrtChgOutputSheetName = 'SWRT_chg';
    swrtCurOutputFileName = 'SWRT_cur_new.xlsx';
    swrtCurOutputSheetName = 'SWRT_cur';
    
    %% LC 负责人
    responser = {'chenyuanfei','geweidong','wujunjie','luotianhua','liyang','xuqiang','zhushengxin'}

    % 负责人         LC
    chenyuanfei   = {'EcuForClimaModMgt','FrntBlwIf','HfaActrIf','HvacAirTIf','HvacDfrstActrIf','HvacModActrIf','HvacOsaRecActrIf','HvacTempActrIf','InCarTempEstimdMgt'};
    geweidong     = {'AirClngIf','AirPmCtrl','FragAirClngCtrl','FragAirClngIf','HvacAirQlyCtrl','ParkgClimaCtrl'};
    wujunjie      = {'AntiFlshFog','ClimaThm','MixAirCtrl'};
    luotianhua    = {'AirDistCtrl','AirFlowCtrlFrnt'};
    liyang        = {'CoolgReq','EcoClima','HeatgReq','MistRiskMgt','OatEstimdMgt','OsaRecCtrl','SunSnsrMgt'};
    xuqiang       = {'ClimaAssMgt','ClimaIhuIf','CmptmtHumCtrl','EgyMngtCtrlForClima','HeatPumpIf','HvacActrIf','SeatClimaIf'};
    zhushengxin   = {'AirFlowCtrlRe','AutDemstCtrl','ReBlwIf','SwgMotCtrl','SwgMotIf'};

    % 检查每个负责人列表中的内容是否有重合
    all_names = [...
        chenyuanfei, ... 
        geweidong, ...
        wujunjie, ...
        luotianhua, ...
        liyang, ...
        xuqiang, ...
        zhushengxin ...
    ];
    [unique_names, ~, idx] = unique(all_names);
    counts = histcounts(idx, 1:(numel(unique_names)+1));
    duplicated_names = unique_names(counts > 1);

    % 显示有重合的内容
    if ~isempty(duplicated_names)
        disp('以下内容在不同负责人列表中有重合：')
        disp(duplicated_names')
    else
        disp('没有重合的内容。')
    end

    %% 使用 readtable 函数读取 Excel 表格中的数据
    SWRT_last = readtable(templateFileName, 'Sheet', templateSheetName);
    SWRT_chg = readtable(swrtChgFileName, 'Sheet', swrtChgSheetName);
    SWRT_cur = readtable(swrtCurFileName, 'Sheet', swrtCurSheetName);

    %% 为SWRT_chg 表中的person 列添加负责人
    %% 遍历SWRT_chg 表中的 RequirementID 列，再在SWRT_last 中找到对应的LC, 根据LC找到对应的负责人，并填入SWRT_chg 表中的person 列
    
    % 创建LC到负责人的映射字典
    lcToPersonMap = containers.Map('KeyType', 'char', 'ValueType', 'char');
    
    % 将所有负责人的LC列表添加到映射中
    allLcLists = {chenyuanfei, geweidong, wujunjie, luotianhua, liyang, xuqiang, zhushengxin};
    allPersonNames = {'chenyuanfei', 'geweidong', 'wujunjie', 'luotianhua', 'liyang', 'xuqiang', 'zhushengxin'};
    
    for personIdx = 1:length(allLcLists)
        currentLcList = allLcLists{personIdx};
        currentPerson = allPersonNames{personIdx};
        for lcIdx = 1:length(currentLcList)
            lcToPersonMap(currentLcList{lcIdx}) = currentPerson;
        end
    end
    
    % 初始化person列为cell数组
    numRows = height(SWRT_chg);
    if iscell(SWRT_chg.person)
        personCell = SWRT_chg.person;
    else
        personCell = cell(numRows, 1);
    end
    
    % 将SWRT_chg的RequirementID转换为数值数组以便快速查找
    reqID_chg_numeric = zeros(numRows, 1);
    for i = 1:numRows
        reqID_str = SWRT_chg.RequirementID{i};
        if iscell(reqID_str)
            reqID_str = reqID_str{1};
        end
        reqID_chg_numeric(i) = str2double(reqID_str);
    end
    
    % 遍历SWRT_chg表中的每一行
    for i = 1:numRows
        reqID_num = reqID_chg_numeric(i);
        
        % 如果转换失败，跳过该行
        if isnan(reqID_num)
            continue;
        end
        
        % 在SWRT_last中查找匹配的ReqID
        idx = find(SWRT_last.ReqID == reqID_num, 1);
        
        % 如果找到匹配的ReqID
        if ~isempty(idx)
            % 获取对应的LC
            lc = SWRT_last.LC{idx};
            
            % 根据LC查找对应的负责人
            if isKey(lcToPersonMap, lc)
                personCell{i} = lcToPersonMap(lc);
            end
        end
    end
    
    % 将更新后的person列赋值回SWRT_chg表
    SWRT_chg.person = personCell;


    %% 遍历SWRT_chg 表中的 TargetVersionLC 列， 如果person列不为空，则跳过，否则根据LC找到对应的负责人，将对应的负责人添加后缀'_new'，并填入SWRT_chg 表中的person 列
    
    % 遍历SWRT_chg表中的每一行
    for i = 1:numRows
        % 检查person列是否为空（空cell、NaN、空字符串都视为空）
        currentPerson = personCell{i};
        if ~isempty(currentPerson) && ...
           ~(isnumeric(currentPerson) && isnan(currentPerson)) && ...
           ~(ischar(currentPerson) && isempty(strtrim(currentPerson)))
            % 如果person列不为空，跳过该行
            continue;
        end
        
        % 获取TargetVersionLC列的值
        targetLC = SWRT_chg.TargetVersionLC{i};
        
        % 如果TargetVersionLC为空，跳过该行
        if isempty(targetLC) || (iscell(targetLC) && isempty(targetLC{1}))
            continue;
        end
        
        % 确保targetLC是字符串格式
        if iscell(targetLC)
            targetLC = targetLC{1};
        end
        
        % 根据LC查找对应的负责人
        if isKey(lcToPersonMap, targetLC)
            personName = lcToPersonMap(targetLC);
            % 添加'_new'后缀
            personCell{i} = [personName, '_new'];
        end
    end
    
    % 将更新后的person列赋值回SWRT_chg表
    SWRT_chg.person = personCell;

    % 保存SWRT_chg 表到excel
    writetable(SWRT_chg, swrtChgOutputFileName, 'Sheet', swrtChgOutputSheetName);
    disp('SWRT_chg 表保存成功');

    %% 打印SWRT_chg.person 还是空的TargetVersionLC去重后的值
    
    % 收集person列为空的行的TargetVersionLC值
    emptyPersonLCs = cell(numRows, 1);
    lcCount = 0;
    
    % 遍历SWRT_chg表中的每一行
    for i = 1:numRows
        % 检查person列是否为空
        currentPerson = personCell{i};
        isEmptyPerson = isempty(currentPerson) || ...
                       (isnumeric(currentPerson) && isnan(currentPerson)) || ...
                       (ischar(currentPerson) && isempty(strtrim(currentPerson)));
        
        % 如果person列为空
        if isEmptyPerson
            % 获取TargetVersionLC列的值
            targetLC = SWRT_chg.TargetVersionLC{i};
            
            % 如果TargetVersionLC不为空，添加到列表中
            if ~isempty(targetLC) && ~(iscell(targetLC) && isempty(targetLC{1}))
                % 确保targetLC是字符串格式
                if iscell(targetLC)
                    targetLC = targetLC{1};
                end
                % 添加到列表
                lcCount = lcCount + 1;
                emptyPersonLCs{lcCount} = targetLC;
            end
        end
    end
    
    % 去除空元素并去重
    if lcCount > 0
        emptyPersonLCs = emptyPersonLCs(1:lcCount);
        uniqueLCs = unique(emptyPersonLCs);
        
        % 打印结果
        disp('person列为空的TargetVersionLC去重后的值：');
        disp('==========================================');
        for i = 1:length(uniqueLCs)
            fprintf('%d. %s\n', i, uniqueLCs{i});
        end
        fprintf('\n总计：%d 个不同的LC值\n', length(uniqueLCs));
    else
        disp('person列为空的行中没有找到TargetVersionLC值。');
    end

    %% 将之前的SWRT打点结果复制到新的表中
    % 遍历SWRT_last表中的ReqID 列，在SWRT_cur 表中找到对应的行，将对应的行的HB11Aviliavle列赋值为'A'
    
    % 获取SWRT_cur表的行数
    numRowsCur = height(SWRT_cur);
    
    % 初始化HB11Aviliavle列为cell数组
    if iscell(SWRT_cur.HB11Aviliavle)
        hb11Cell = SWRT_cur.HB11Aviliavle;
    else
        % 将非cell类型转换为cell数组
        hb11Cell = cell(numRowsCur, 1);
        if isnumeric(SWRT_cur.HB11Aviliavle)
            % 如果是数值类型，转换为字符串
            for i = 1:numRowsCur
                if ~isnan(SWRT_cur.HB11Aviliavle(i))
                    hb11Cell{i} = num2str(SWRT_cur.HB11Aviliavle(i));
                end
            end
        elseif ischar(SWRT_cur.HB11Aviliavle) || isstring(SWRT_cur.HB11Aviliavle)
            % 如果是字符类型，转换为cell数组
            hb11Cell = cellstr(SWRT_cur.HB11Aviliavle);
        end
    end
    
    % 将SWRT_cur的ReqID转换为数值数组以便快速查找
    reqID_cur_numeric = zeros(numRowsCur, 1);
    for i = 1:numRowsCur
        reqID_str = SWRT_cur.ReqID{i};
        if iscell(reqID_str)
            reqID_str = reqID_str{1};
        end
        reqID_cur_numeric(i) = str2double(reqID_str);
    end
    
    % 遍历SWRT_last表中的每一行
    numRowsLast = height(SWRT_last);
    matchCount = 0;
    
    for i = 1:numRowsLast
        % 获取SWRT_last中的ReqID
        reqID_last = SWRT_last.ReqID(i);
        
        % 在SWRT_cur中查找匹配的ReqID
        idx = find(reqID_cur_numeric == reqID_last, 1);
        
        % 如果找到匹配的行
        if ~isempty(idx)
            % 将HB11Aviliavle列赋值为'A'
            hb11Cell{idx} = 'A';
            matchCount = matchCount + 1;
        end
    end
    
    % 将更新后的HB11Aviliavle列赋值回SWRT_cur表
    SWRT_cur.HB11Aviliavle = hb11Cell;
    
    % 打印匹配结果
    fprintf('成功匹配并更新了 %d 行的HB11Aviliavle列为''A''\n', matchCount);

    %% 保存SWRT_cur 表到excel
    writetable(SWRT_cur, swrtCurOutputFileName, 'Sheet', swrtCurOutputSheetName);
    disp('SWRT_cur 表保存成功');

end


% SWRT_last =
% 
%   268×3 table
% 
%                LC                 ReqID        Rst 
%     ________________________    __________    _____
% 
%     {'CmptmtClngPreStrtReq'}    1.4333e+05    {'A'}
%     {'HvacTempActrIf'      }    7.0624e+05    {'A'}
%     {'ElecDfrstIf'         }    7.0308e+05    {'A'}
%     {'AirDistCtrl'         }    8.5039e+05    {'A'}
%     {'SunSnsrMgt'          }    6.9944e+05    {'A'}
% 
% SWRT_chg =
% 
%   2760×12 table
% 
%     RequirementID                       RequirementName                             Handle_xID_         UpdateType      TargetVersionLC      ComparativeVersionLC    TargetVersionReq    ComparativeVersionReq                                                                                                                                                                                                                                                                                                                                                                                                                                                                    TargetVersionDescription                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ComparativeVersionDescription                                                                                                                                                                                                                                                                                                                                                                                                                                                                  TargetVersionChangeLog    person
%     _____________    ______________________________________________________    _____________________    __________    ___________________    ____________________    ________________    _____________________    _________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________    _________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________    ______________________    ______
% 
%      {'4043'  }      {'AC OFF Maximum Air Flow'                           }    {'x0400000002A9CC06'}    {0×0 char}    {'AirFlowCtrlFrnt'}    {'AirFlowCtrlFrnt'}         {'(4)' }              {'(4)' }           {'At manually selected A/C OFF, there shall be a calibratable restriction of the maximum total air flow at steady state, based on ambient temperature.'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 }    {'At manually selected A/C OFF, there shall be a calibratable restriction of the maximum total air flow at steady state, based on ambient temperature.'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 }          {0×0 char}           NaN  
%      {'4044'  }      {'AC OFF Minimum Air Flow'                           }    {'x0400000002A9CC0D'}    {0×0 char}    {'AirFlowCtrlFrnt'}    {'AirFlowCtrlFrnt'}         {'(7)' }              {'(7)' }           {'At manually selected A/C OFF, there shall be a calibratable lower limit for the total air flow depending on ambient temperature and HMI set temperature. There shall be separate calibrations for dark and sunny conditions (1000 W/m2), with interpolation in between. ↵↵If the HMI set temperature left/right differ, it shall be possible to choose by calibration whether the maximum or mean air flow shall be used ( default: maximum).'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      }    {'At manually selected A/C OFF, there shall be a calibratable lower limit for the total air flow depending on ambient temperature and HMI set temperature. There shall be separate calibrations for dark and sunny conditions (1000 W/m2), with interpolation in between. ↵↵If the HMI set temperature left/right differ, it shall be possible to choose by calibration whether the maximum or mean air flow shall be used ( default: maximum).'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      }           {0×0 char}           NaN  
%      {'4046'  }      {'Air Flow Compensation for 1-2 Zone HVAC'           }    {'x0400000002A9CC14'}    {0×0 char}    {'AirFlowCtrlFrnt'}    {'AirFlowCtrlFrnt'}         {'(11)'}              {'(11)'}           {'It shall be possible to calibrate a first seat row mean mode control temperature dependent adjustment factor for steady state air flow for the first seat row. There shall be separate calibrations for dark and sunny ( 1000 W/m 2) conditions, with interpolation in between. The adjustment factor shall be multiplied with the first seat row steady state base air flow. It shall be possible to calibrate the adjustment factor for the following car configurations: ↵1 and 2 zone HVAC with 5 seats. The same calibration can be used. ↵2 zone HVAC with 7 seats ↵Example of calibration: ↵↵↵First seat row mode control temperature↵↵↵↵↵↵↵-20↵-10↵0↵10↵15↵20↵40↵1,15↵1,1↵1,1↵1↵1↵1,1↵1,15↵  ↵ '                                                                                                                                                                                                                            }    {'It shall be possible to calibrate a first seat row mean mode control temperature dependent adjustment factor for steady state air flow for the first seat row. There shall be separate calibrations for dark and sunny ( 1000 W/m 2) conditions, with interpolation in between. The adjustment factor shall be multiplied with the first seat row steady state base air flow. It shall be possible to calibrate the adjustment factor for the following car configurations: ↵1 and 2 zone HVAC with 5 seats. The same calibration can be used. ↵2 zone HVAC with 7 seats ↵Example of calibration: ↵↵↵First seat row mode control temperature↵↵↵↵↵↵↵-20↵-10↵0↵10↵15↵20↵40↵1,15↵1,1↵1,1↵1↵1↵1,1↵1,15↵  ↵ '                                                                                                                                                                                                                            }           {0×0 char}           NaN  
% 
% 

% SWRT_cur =

%   1568×31 table

%     Num         SubSystem                 LC                                             ReqName                                       x____         ReqID             Version             x_____1        x______     E2_SM_M1         E3          E4_VP         J1_MP           PP            TT        HB11Aviliavle     HB11Comments      x_____       x______1     x____MRD______     x_______     x________     x_______1     x_______2     x_______3     x_______4     x_______5      x_____2       x_____3      IsNeedCheck      Responeser  
%     ____    __________________    ___________________    ________________________________________________________________________    __________    __________    ___________________    ______________    _______    __________    __________    __________    __________    __________    __________    ______________    ____________    __________    __________    ______________    __________    __________    __________    __________    __________    __________    __________    __________    __________    ___________    ______________

%        1    {'ClimateControl'}    {'OsaRecCtrl'     }    {'Saving energy requirement'                                           }    {0×0 char}    {'186356'}    {'(2)'            }    {'CSReleased'}    {'New'}    {'DV'    }    {'DVI'   }    {'PI'    }    {'PR'    }    {'PR'    }    {'PR'    }    {0×0 char    }     {0×0 char}     {0×0 char}    {0×0 char}      {0×0 char}      {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}        NaN        {0×0 char    }
%        2    {'ClimateControl'}    {'AirFlowCtrlFrnt'}    {'Total Air Flow at Different Auto Blower Levels'                      }    {0×0 char}    {'4071'  }    {'(13)'           }    {'CSReleased'}    {'New'}    {'DV'    }    {'DVI'   }    {'PI'    }    {'PR'    }    {'PR'    }    {'PR'    }    {0×0 char    }     {0×0 char}     {0×0 char}    {0×0 char}      {0×0 char}      {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}        NaN        {'luotianhua'}
%        3    {'ClimateControl'}    {'ParkgClimaCtrl' }    {'High voltage energy consumption request'                             }    {0×0 char}    {'75839' }    {'(7)'            }    {'CSReleased'}    {'New'}    {'DV'    }    {'DVI'   }    {'PI'    }    {'PR'    }    {'PR'    }    {'PR'    }    {0×0 char    }     {0×0 char}     {0×0 char}    {0×0 char}      {0×0 char}      {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}        NaN        {0×0 char    }
%        4    {'ClimateControl'}    {'GlbOpenReq'     }    {'Global open exception'                                               }    {0×0 char}    {'196933'}    {'2.0/3.0 23R4(3)'}    {'CSReleased'}    {'New'}    {'DV'    }    {'DVI'   }    {'DI'    }    {'PR'    }    {'PR'    }    {'PI'    }    {0×0 char    }     {0×0 char}     {0×0 char}    {0×0 char}      {0×0 char}      {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}        NaN        {0×0 char    }
%        5    {'ClimateControl'}    {'AirFlowCtrlFrnt'}    {'Speed request at crash'                                              }    {0×0 char}    {'4583'  }    {'(3)'            }    {'CSReleased'}    {'New'}    {'DV'    }    {'DVI'   }    {'PI'    }    {'PR'    }    {'PR'    }    {'PR'    }    {'Applicable'}     {0×0 char}     {0×0 char}    {0×0 char}      {0×0 char}      {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}    {0×0 char}        NaN        {'luotianhua'}
%  