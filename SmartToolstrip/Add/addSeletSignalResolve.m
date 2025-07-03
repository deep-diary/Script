function addSeletSignalResolve(varargin)
%功能：为选中的信号线添加求解Signal对象设置
%输入：无
%输出：添加完成的信号线名称列表
%示例：
%版本：V1.0
%日期：205-06-27
%作者：Chen Yuanfei

% 创建输入解析器
p = inputParser;
addParameter(p, 'Resolve', 1, @islogical);
% 解析输入参数
parse(p, varargin{:});
Resolve = p.Results.Resolve;


selectedLines = find_system(gcs, 'FindAll', 'on', 'type', 'line', 'Selected', 'on');

if isempty(selectedLines)
    disp('没有选中任何信号线');
else
    disp(['共选中了 ', num2str(length(selectedLines)), ' 条信号线']);
    
    % 显示每条选中信号线的信息
    for i = 1:length(selectedLines)
        lineHandle = selectedLines(i);
              
        try
            % 获取信号线的源端口句柄
            srcPort = get_param(lineHandle, 'SrcPortHandle');
            if Resolve == false
                % 设置源端口的 MustResolveToSignalObject 属性
                set_param(srcPort, 'MustResolveToSignalObject', 'off');
            else
                % 设置源端口的 MustResolveToSignalObject 属性
                set_param(srcPort, 'MustResolveToSignalObject', 'on');
            end
            
            % 获取信号线信息用于显示
            lineName = get_param(lineHandle, 'Name');
            if isempty(lineName)
                lineName = '[未命名信号]';
            end
            
            % 获取源模块信息
            srcBlock = get_param(srcPort, 'Parent');
            srcBlockName = get_param(srcBlock, 'Name');
            if Resolve == true
            disp(['已设置信号线 "', lineName, '" 求解为Signal类型']);
            else
                disp(['已取消信号线 "', lineName, '" 求解为Signal类型']);
            end
            
        catch ME
            disp(['设置信号线 #', num2str(i), ' 属性时出错: ', ME.message]);
        end
    end

end
end