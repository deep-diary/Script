function CheckDivideZero
    %%检查除法是否有防除0处理
    DivideObj = find_system(bdroot,'BlockType','Product');
    if ~isempty(DivideObj)
        for i = 1:length(DivideObj)
            handle_Dv = get_param(DivideObj{i},'Handle');
            inputs = get_param(handle_Dv,'Inputs');
            PortCnnt = get_param(handle_Dv,'PortConnectivity');
            
            No = strfind(inputs,'/');
            if ~isempty(No)
                for j = No(1):No(length(No))
                    SrcBlock = PortCnnt(j).SrcBlock;
                    if SrcBlock ~= -1
         
                            srcBlockType = get_param(SrcBlock, 'BlockType');
                            srcBlockMaskType = get_param(SrcBlock,'MaskType');
                            BlockTypes = {'Switch','MinMax','Saturate'};
                            % 检查除数是否可能为零
                            if strcmp(srcBlockType, 'Constant')
                                divisorValue = str2double(get_param(SrcBlock, 'Value'));
                                if divisorValue == 0
                                    warning('[严重错误] 除数为0!');
                                end
                            elseif strcmp(srcBlockType, 'Ground')
                                warning('[严重错误] 除数接地(值为0)!');
               
                            elseif ~nnz(strcmp(srcBlockType, BlockTypes)) 
                                warning('请检查是否有防除0措施!');
                            elseif ~isempty(srcBlockMaskType) 
                                if ~(strcmp(srcBlockType,'subsystem') && strcmp(srcBlockMaskType,'GL_Saturation_1.0'))
                                warning('请检查是否有防除0措施!');
                                end
                                                           
                            end
                        
                    end
                end
            end
        end

    end

end