% 功能：根据输入输出端口名添加信号线名，并解析为Signal类型对象
% 示例:
%      params = AddSignalNameAndResolve('port','Inport','resolve',true)
%      params = AddSignalNameAndResolve('port','both','resolve',false)
% 版本：V2.0
% 作者：Chen Yuanfei
% 日期：2025-6-26
function AddSignalNameAndResolve(varargin)
% 创建输入解析器
p = inputParser;
expectedShapes = {'Inport','Outport','both'};
addParameter(p, 'port', 'both',@(x) any(validatestring(x,expectedShapes)));
addParameter(p, 'resolve', true, @islogical);

% 解析输入参数
parse(p, varargin{:});

% 获取参数值
port = p.Results.port;
resolve = p.Results.resolve;

switch port

    case 'Inport'

        InportCell = find_system(gcs,'SearchDepth',1,'BlockType','Inport');  %获取顶层Inport模块路径
        for i = 1:length(InportCell)
            InportName = get_param(InportCell{i},'Name');  %输入模块名称
            InportHandle = get_param(InportCell{i},'Handle');  %信号线句柄
            LineHandleStruct = get(InportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Outport;
            set(LineHandle,'Name',InportName)  %设置信号线名称为输入模块名称
            if resolve == true
                set(LineHandle,'MustResolveToSignalObject',1)   %设置信号线关联Simulink Signal Object
            end
        end
    case 'Outport'

        OurportCell = find_system(gcs,'SearchDepth',1,'BlockType','Outport');  %获取顶层Outport模块路径
        for i = 1:length(OurportCell)
            OutportName = get_param(OurportCell{i},'Name');  %输入模块名称
            OutportHandle = get_param(OurportCell{i},'Handle');  %信号线句柄
            LineHandleStruct = get(OutportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Inport;
            set(LineHandle,'Name',OutportName)  %设置信号线名称为输入模块名称
            if resolve == true
                set(LineHandle,'MustResolveToSignalObject',1)   %设置信号线关联Simulink Signal Object
            end
        end
    otherwise
        InportCell = find_system(gcs,'SearchDepth',1,'BlockType','Inport');  %获取顶层Inport模块路径
        for i = 1:length(InportCell)
            InportName = get_param(InportCell{i},'Name');  %输入模块名称
            InportHandle = get_param(InportCell{i},'Handle');  %信号线句柄
            LineHandleStruct = get(InportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Outport;
            set(LineHandle,'Name',InportName)  %设置信号线名称为输入模块名称

            if resolve == true
                set(LineHandle,'MustResolveToSignalObject',1)   %设置信号线关联Simulink Signal Object
            end
        end

        OurportCell = find_system(gcs,'SearchDepth',1,'BlockType','Outport');  %获取顶层Outport模块路径
        for i = 1:length(OurportCell)
            OutportName = get_param(OurportCell{i},'Name');  %输入模块名称
            OutportHandle = get_param(OurportCell{i},'Handle');  %信号线句柄
            LineHandleStruct = get(OutportHandle,'LineHandles');
            LineHandle = LineHandleStruct.Inport;
            set(LineHandle,'Name',OutportName)  %设置信号线名称为输入模块名称
            if resolve == true
                set(LineHandle,'MustResolveToSignalObject',1)   %设置信号线关联Simulink Signal Object
            end
        end
end

% %% 给封装模块输出信号线求解Signal类型
% blockCell = find_system(gcs,'SearchDepth',1,'MaskType','Signal_In');
% for i = 1:length(blockCell)
%     blockHandle = get_param(blockCell{i},'Handle');
%     LineHandleStruct = get_param(blockHandle,'LineHandles');
%     LineHandle = LineHandleStruct.Outport;
%     blockConn = get_param(blockCell{i},'PortConnectivity');
% %     InportHandle = blockConn.SrcBlock;
% %     SrcName = get_param(InportHandle,'Name');
%     InportHandle = blockConn.DstBlock;
%     DstName = get_param(InportHandle,'Name');
% %     set(LineHandle,'Name',SrcName);
%     set(LineHandle,'Name',DstName);
%     set(LineHandle,'MustResolveToSignalObject',1)   %设置信号线关联Simulink Signal Object
% 
% end
end
