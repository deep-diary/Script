function name = findLineName(h)
% findLineName 根据信号线，找到信号线名称
%   name = findLineName(h)
%   输入:
%       h - 信号线句柄
%   输出:
%       name - 信号线名称
%
%   例子:
%       name = findLineName(h)
%
%   作者: Blue.ge
%   日期: 20250702

    %% 获取信号线名称
    name = get_param(h, 'Name');
    if isempty(name)
        % 获取信号线源端口和源模块
        srcPort = get_param(h, 'SrcPortHandle');
        srcBlock = get_param(h, 'SrcBlockHandle');
        nameSrc = '';
        if srcBlock ~= -1
            blockType = get_param(srcBlock, 'BlockType');
            try
                switch blockType
                    case 'Inport'
                        nameSrc = get_param(srcBlock, 'Name');
                    case 'SubSystem'
                        SubSystemP = [get(srcBlock).Path '/' get(srcBlock).Name ]
                        PortNumber = get_param(srcPort, 'PortNumber');
                        % 根据端口号从子模型中找到对应的端口，并获取名称
                        outports = find_system(SubSystemP,'BlockType','Outport','Port', num2str(PortNumber));
                        nameSrc = get_param(outports{1},'Name');
                    case 'From'
                        nameSrc = get_param(srcBlock, 'GotoTag');
                    otherwise
                        % 其他类型可扩展
%                         nameSrc = get_param(srcBlock, 'Name');

                        nameSrc = '';
                end
            catch
                nameSrc = '';
            end
        end
        % 若源端口/模块无有效名称，再尝试目标端口/模块
        if isempty(nameSrc)
            dstPort = get_param(h, 'DstPortHandle');
            dstBlock = get_param(h, 'DstBlockHandle');
            nameDst = '';
            if dstBlock ~= -1
                blockTypeDst = get_param(dstBlock, 'BlockType');
                try
                    switch blockTypeDst
                        case 'Outport'
                            nameDst = get_param(dstBlock, 'Name');
                        case 'SubSystem'
                            SubSystemP = [get(dstBlock).Path '/' get(dstBlock).Name ]
                            PortNumber = get_param(dstPort, 'PortNumber');
                            % 根据端口号从子模型中找到对应的端口，并获取名称
                            inports = find_system(SubSystemP,'BlockType','Inport','Port', num2str(PortNumber));
                            nameDst = get_param(inports{1},'Name');
                        case 'Goto'
                            nameDst = get_param(dstBlock, 'GotoTag');
                        otherwise
                            nameDst = '';
%                             nameDst = get_param(dstBlock, 'Name');
                    end
                catch
                    nameDst = '';
                end
            end
            name = nameDst;
        else
            name = nameSrc;
        end
    end
    disp(['----the line name is ' name])

    
end
