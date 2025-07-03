% 功能：取消所选子系统输入输出端口信号线的Signal类型对象及信号名
% 示例:
%      params = DeleteSignalResolveAndName('port','Inport','DeleteName',true)
%      params = DeleteSignalResolveAndName('port','both','DeleteName',false)
% 版本：V2.0
% 作者：Chen Yuanfei
% 日期：2025-6-26
% 创建输入解析器

function DeleteSignalResolveAndName(varargin)
p = inputParser;
expectedShapes = {'Inport','Outport','both'};
addParameter(p, 'port', 'both',@(x) any(validatestring(x,expectedShapes)));
addParameter(p, 'DeleteName', true, @islogical);

% 解析输入参数
parse(p, varargin{:});

% 获取参数值
port = p.Results.port;
DeleteName = p.Results.DeleteName;

switch port

    case 'Inport'

        InportCell = find_system(gcs,'SearchDepth',1,'BlockType','Inport');  %获取顶层Inport模块路径
        for i = 1:length(InportCell)
            InportHandle = get_param(InportCell{i},'Handle');  %信号线句柄
            LineHandleStruct = get(InportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Outport;
            set(LineHandle,'MustResolveToSignalObject',0)

            if DeleteName == true
                set(LineHandle,'Name','')  %清除信号线名称
            end
        end

    case 'Outport'

        OurportCell = find_system(gcs,'SearchDepth',1,'BlockType','Outport');  %获取顶层Outport模块路径
        for i = 1:length(OurportCell)
            OutportHandle = get_param(OurportCell{i},'Handle');  %信号线句柄
            LineHandleStruct = get(OutportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Inport;
            set(LineHandle,'MustResolveToSignalObject',0)

            if DeleteName == true
                set(LineHandle,'Name','')  %清除信号线名称
            end
        end

    otherwise
        InportCell = find_system(gcs,'SearchDepth',1,'BlockType','Inport');  %获取顶层Inport模块路径
        for i = 1:length(InportCell)
            InportHandle = get_param(InportCell{i},'Handle');  %信号线句柄
            LineHandleStruct = get(InportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Outport;
            set(LineHandle,'MustResolveToSignalObject',0)

            if DeleteName == true
                set(LineHandle,'Name','')  %清除信号线名称
            end
        end

        OurportCell = find_system(gcs,'SearchDepth',1,'BlockType','Outport');  %获取顶层Outport模块路径
        for i = 1:length(OurportCell)
            OutportHandle = get_param(OurportCell{i},'Handle');  %信号线句柄
            LineHandleStruct = get(OutportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Inport;
            set(LineHandle,'MustResolveToSignalObject',0)

            if DeleteName == true
                set(LineHandle,'Name','')  %清除信号线名称
            end
        end
end
end
