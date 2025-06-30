function CheckLookupTableAxleSignal
    %& 检查查表模块轴和输出是否有观测信号
    blockCell = find_system(bdroot,'BlockType','Lookup_n-D');
    for i = 1:length(blockCell)
        BlockHandle = get_param(blockCell{i},'Handle');
        LineHandle = get_param(BlockHandle,'LineHandles') ;

        Inport = LineHandle.Inport;
            for j = 1:length(Inport)
                if Inport(j) ~= -1
                    InportName = get(Inport(j),'UserSpecifiedLogName');
                    if InportName == ""
                        warning(['Lookup Table axle no measurement signal : ', blockCell{i}]);
                    end
                end
            end

        Outport = LineHandle.Outport;
        if Outport ~= -1
            OutportName = get_param(Outport,'Name');
            if OutportName == ""
                warning(['Lookup Table Output no measurement signal : ', blockCell{i}]);
            end
        end
    end
end