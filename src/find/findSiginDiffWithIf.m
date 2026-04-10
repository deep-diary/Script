function [samePortsIn,diffPortsIn, samePortsOut,diffPortsOut]= findSiginDiffWithIf()
%%
    % 目的: 在TmIn 和TmOut 子模型中，对比输入和输出的数据类型是否不一致
    % 输入：
    %       None
    % 返回： samePortsIn， diffPortsIn： 输入数据类型相同及不相同的，
    % 返回： samePortsOut， diffPortsOut： 输出数据类型相同及不相同的，
    % 范例： [samePortsIn,diffPortsIn, samePortsOut,diffPortsOut]= findSiginDiffWithIf()
    % 状态： 待优化确认！！！
    % 作者： Blue.ge
    % 日期： 20231031
%%
    clc
    % 获取输入信号列表
    [ModelName,PortsIn,PortsOut] = findModPorts(gcs, 'SubSystem');
    inportList=cell(1,length(PortsIn));
    for i=1:length(PortsIn)
        inportList{i} = get_param(PortsIn{i},'Name');
    end
    % 获取输出信号列表
    outportList=cell(1,length(PortsOut));
    for i=1:length(PortsOut)
        outportList{i} = get_param(PortsOut{i},'Name');
    end

    PortsIn = find_system('SigIn_Tot','SearchDepth',1,'BlockType','Inport');
    PortsOut = find_system('GlTmSigOut','SearchDepth',1,'BlockType','Outport');

    samePortsIn={};
    diffPortsIn={};
    samePortsOut={};
    diffPortsOut={};

    % 检查输入信号
    for i=1:length(PortsIn)
        name=getInputName(PortsIn{i});
        if ismember(name,inportList)
            samePortsIn=[samePortsIn,name];
        else
            diffPortsIn=[diffPortsIn,name];
        end
    end

    % 检查输出信号
    for i=1:length(PortsOut)
        name=get_param(PortsOut{i}, 'Name');
        if ismember(name,outportList)
            samePortsOut=[samePortsOut,name];
        else
            diffPortsOut=[diffPortsOut,name];
        end
    end

end