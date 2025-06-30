function CheckUnitsInSimulinkUnitDatabase
    uiwait(msgbox('请选择要检查的数据字典xls文件'));
    try
        [DDName,DDPath] = uigetfile({'*.xlsx;*.xls'});
    catch
        warning('Please select right "*.xlsx" or "*.xls" file !')
        return;
    end
    fileAllName = [DDPath,DDName];
    sheet = 'Signals';
    range = 'A1:Z1';
    [headers,data] = xlsread(fileAllName,sheet,range);
    title = strcmp(data,'Unit');
    posn = find(title);
    collom = char(posn+uint8('A')-1);
    range = [collom,':',collom];
    [headers,data] = xlsread(fileAllName,sheet,range);

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
            warning(['Unit is not in Simulink Unit Database,Please Modify Unit : "',Units{i},'"']);
        end
    end

end
