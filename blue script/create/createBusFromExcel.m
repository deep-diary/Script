function createdBuses = createBusFromExcel(varargin)
% createBusFromExcel  从Excel模板批量创建Simulink.Bus对象
%
%   createBusFromExcel('template', 'Template.xlsx', 'sheet', 'BusDefinition')
%
%   参数:
%       'template'  - Excel文件名（默认 'Template'）
%       'sheet'     - 工作表名（默认 'BusDefinition'）
%
%   范例: 
%       createdBuses = createBusFromExcel()
%       createdBuses = createBusFromExcel('template', 'TemplateCCMSensor.xlsx')
%   Excel模板需包含列：BusName, ElementName, DataType, Dimensions, Unit, Description, Min, Max

    %% 输入参数解析
    p = inputParser;
    addParameter(p, 'template', 'Template', @ischar);
    addParameter(p, 'sheet', 'BusDefinition', @ischar);
    parse(p, varargin{:});
    template = p.Results.template;
    sheet = p.Results.sheet;

    %% 读取Excel数据
    data = readtable(template, 'Sheet', sheet, 'TextType', 'string');

    %% 获取所有唯一Bus名称
    busNames = unique(data.BusName);

    %% 批量创建Bus对象
    createdBuses = {};
    for i = 1:numel(busNames)
        busNameStr = busNames{i};
        elements = data(strcmp(data.BusName, busNameStr), :);

        % 预分配BusElement数组
        ele(numel(elements.ElementName), 1) = Simulink.BusElement;

        for j = 1:height(elements)
            busElement = Simulink.BusElement;
            busElement.Name        = elements.ElementName(j);
            busElement.Complexity  = 'real';
            busElement.Dimensions  = elements.Dimensions(j);
            busElement.DataType    = elements.DataType(j);
            if isfinite(elements.Min(j))
                busElement.Min = elements.Min(j);
            end
            if isfinite(elements.Max(j))
                busElement.Max = elements.Max(j);
            end
            busElement.DimensionsMode = 'Fixed';
            busElement.SamplingMode   = 'Sample based';
            busElement.SampleTime     = -1;
            if ~isnan(elements.Unit(j))
                busElement.DocUnits = elements.Unit(j);
            end
            busElement.Description    = elements.Description(j);
            ele(j) = busElement;
        end

        % 创建Bus对象并赋名到base workspace
        busObj = Simulink.Bus;
        busObj.Description = '';
        busObj.DataScope   = 'Auto';
        busObj.HeaderFile  = 'Rte_Type.h';
        busObj.Alignment   = -1;
        busObj.Elements    = ele;

        assignin('base', busNameStr, busObj);
        createdBuses{end+1} = busNameStr; %#ok<AGROW>

        clear ele % 清理变量，避免下次循环污染
    end
end
