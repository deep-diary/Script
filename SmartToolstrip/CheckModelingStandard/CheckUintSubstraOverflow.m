function CheckUintSubstraOverflow
    %% 检查无符号整型减法是否做仿溢出处理
    AddObj = find_system(bdroot,'BlockType','Sum');
    if ~isempty(AddObj)
        for i = 1:length(AddObj)
            inputs = get_param(AddObj{i},'Inputs');
            No = strfind(inputs,'-');
            if nnz(No)
                OverflowSwitch = get_param(AddObj{i},'SaturateOnIntegerOverflow');
                if strcmp(OverflowSwitch,'off')
                    warning('Please turn on "Saturate On Integer Overflow" switch');
                end
            end
        end
    end
   
end