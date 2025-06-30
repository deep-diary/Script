function Align_Lines
% clear

port_handles = get_param(gcbh,'PortHandles');
%% 输入端口对齐
inport_handles = port_handles.Inport;

line_handles1 = get_param(inport_handles(1),'Line');
src_handles1 = get_param(line_handles1,'SrcBlockHandle');
scr_blocktype= get_param(src_handles1,'BlockType');
if strcmp(scr_blocktype,'BusCreator')~=1

    src_pos1 = get_param(src_handles1,'Position');

    for i = 1:length(inport_handles)

        line_handles = get_param(inport_handles(i),'Line');
        src_handles = get_param(line_handles,'SrcBlockHandle');

        port_pos = get_param(inport_handles(i),'Position');
        src_pos = get_param(src_handles,'Position');

        src_len = src_pos(3) - src_pos(1);
        src_width = src_pos(4) - src_pos(2);

        new_pos(1) = src_pos1(1);
        new_pos(3) = new_pos(1) + src_len;
        new_pos(2) = port_pos(2) - fix(src_width/2);
        new_pos(4) = port_pos(2) + fix(src_width/2);            

        set_param(src_handles,'Position',new_pos);

    end
end

% 输出端口对齐
outport_handles = port_handles.Outport;

line_handles2 = get_param(outport_handles(1),'Line');
src_handles2 = get_param(line_handles2,'DstBlockHandle');
scr_blocktype= get_param(src_handles2,'BlockType');
if strcmp(scr_blocktype,'BusCreator')~=1
    src_pos2 = get_param(src_handles2,'Position');

    for i = 1:length(outport_handles)

        line_handles = get_param(outport_handles(i),'Line');
        Dst_handles = get_param(line_handles,'DstBlockHandle');

        port_pos = get_param(outport_handles(i),'Position');

        src_pos = get_param(Dst_handles,'Position');
        src_len = src_pos(3) - src_pos(1);
        src_width = src_pos(4) - src_pos(2);

        new_pos(1) = src_pos2(1);
        new_pos(3) = new_pos(1) + src_len;
        new_pos(2) = port_pos(2) - fix(src_width/2);
        new_pos(4) = port_pos(2) + fix(src_width/2);

        set_param(Dst_handles,'Position',new_pos);

    end
end
end