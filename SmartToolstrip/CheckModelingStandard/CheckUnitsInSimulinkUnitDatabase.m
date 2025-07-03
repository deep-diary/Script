% 功能：检查数据字典中单位是否可以被simulink识别
% 输入：数据字典Execl
% 版本：V2.0
% 作者：陈远飞（yuanfei.chen)
% 日期：2025-7-2

function CheckUnitsInSimulinkUnitDatabase
    % 获取当前活跃的Simulink模型名称
    modelName = bdroot;
    uiwait(msgbox('请选择要检查的数据字典xls文件'));
    
    try


        % 获取模型文件的完整路径
        modelPath = get_param(modelName, 'FileName');

        % 提取目录路径
        [modelDir, ~, ~] = fileparts(modelPath);
        [DDName,DDPath] = uigetfile({'*.xlsx;*.xls'},'Select a file',modelDir);
    catch
        warning('Please select right "*.xlsx" or "*.xls" file !')
        return;
    end
    fileAllName = [DDPath,DDName];
    sheet = {'Signals','Parameters'};
    cnt = 0;
    for j = 1:length(sheet)
        range = 'A1:Z1';
        [headers,data] = xlsread(fileAllName,sheet{j},range);
        title = strcmp(data,'Unit');
        posn = find(title);
        collom = char(posn+uint8('A')-1);
        range = [collom,':',collom];
        [headers,data] = xlsread(fileAllName,sheet{j},range);

        %     opts = detectImportOptions(fileAllName,'Sheet',sheet,'Range',[collom,':',collom]);
        %     opts.VariableNamingRule = 'Modify';
        %     opts.MissingRule = 'fill';
        %     opts.ImportErrorRule ='error';
        %     opts.VariableNames = 'Unit';
        %     T = readtable(fileAllName,opts);
        try
            Units = data;
        catch
            warning('Error:Data Dictionery have no Unit title !')
            return;
        end
        ComUseUnits = {'degC','rpm','sec','W','kW','kgps','kgpss','kg/s','kPa','kg/h','kgph','%','kW/s','kWps','l/min','bar','km/h','kmph',''};
       
        for i = 2:length(Units)
            if ~nnz(strcmp(Units{i},ComUseUnits))
                warning(['单位在 Simulink Unit Database 中无法识别,请修改单位 : "',Units{i},'"']);
                cnt = cnt + 1;
                
            end
        end
        
    end
    if isempty(Units)==0 && cnt == 0
        fprintf("恭喜：单位都正确！\n");
    end
end
