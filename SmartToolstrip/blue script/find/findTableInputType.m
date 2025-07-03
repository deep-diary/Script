function [X,Y] = findTableInputType(path)
% 目的: 根据表格，找到对应的输入信号类型
% 输入：
%       path: Lookup Table 路径
% 返回： typeX: X轴类型，typeY：Y轴类型
% 范例： [typeX,typeY] = findTableInputType(gcb)
% 引用： 可以被应用于批量找到表格的输入变量类型
% 作者： Blue.ge
% 日期： 2023102
%%
    clc
    X=struct;
    Y=struct;
    %% 判断表格是1D还是2D
     % 根据path判断该模块是否是Lookup_n-D， 如果不是，则直接返回
%     path=gcb; % for test only
    h = get_param(path, 'Handle');
    bk = get(h);
    NumberOfTableDimensions = bk.NumberOfTableDimensions;
    tableName = bk.Table;
    % 根据NumberOfTableDimensions属性判断表格维度
    %% 1D逻辑
    if NumberOfTableDimensions == '1' 
        % 找到输入模块的句柄hX
        hX = get(bk.LineHandles.Inport).SrcBlockHandle;
        % 判断是否是输入端口
        blockType = get_param(hX, "BlockType");
        if strcmp(blockType, 'Inport')
            name = get_param(hX, "Name");
        elseif strcmp(blockType, 'From')
            name = get_param(hX, "GotoTag");
        elseif strcmp(blockType, 'SubSystem')
            set_param(hX,'Commented', 'through')
            hX = get_param(get_param(hX,'LineHandles').Inport,'SrcBlockHandle');
%             hIn = get(get(hIn).LineHandles.Inport).SrcBlockHandle;
            blockType = get_param(hX, "BlockType");
            if strcmp(blockType, 'Inport')
                name = get_param(hX, "Name");
            end
        else
            name = 'error_X_s32error';
        end
        %         如何输入的名字是error, 则重命名下，便于输出single类型
        if strcmp(name, 'error') || strcmp(name, 'Error') || strcmp(name, 'err')
            name = 'error_X_s32error';
        end
        X.name = name;
        [X.dataType, ~, X.StorageClassParamPCMU, ~, X.StorageClassParamVCU] = findNameType(name);
        % 根据句柄得到这个变量的类型typeX并返回
    end
    %% 2D 逻辑
    if NumberOfTableDimensions == '2' 
        % 找到输入模块的句柄hX, hY
        hX = get(bk.LineHandles.Inport(2)).SrcBlockHandle;
        % 判断是否是输入端口
        blockType = get_param(hX, "BlockType");
        if strcmp(blockType, 'Inport')
            name = get_param(hX, "Name");
        elseif strcmp(blockType, 'From')
            name = get_param(hX, "GotoTag");
        elseif strcmp(blockType, 'SubSystem')
            set_param(hX,'Commented', 'through')
            hX = get_param(get_param(hX,'LineHandles').Inport,'SrcBlockHandle');
%             hIn = get(get(hIn).LineHandles.Inport).SrcBlockHandle;
            blockType = get_param(hX, "BlockType");
            if strcmp(blockType, 'Inport')
                name = get_param(hX, "Name");
            end
        else
            name = 'error_X_s32error';
        end
        %         如何输入的名字是error, 则重命名下，便于输出single类型
        if strcmp(name, 'error') || strcmp(name, 'Error') || strcmp(name, 'err')
            name = 'error_X_s32error';
        end
        % 根据句柄得到这个变量的类型typeX,typeY并返回
        X.name = name;
        [X.dataType, ~, X.StorageClassParamPCMU, ~, X.StorageClassParamVCU] = findNameType(name);
%% Y轴
        hY = get(bk.LineHandles.Inport(1)).SrcBlockHandle;
        % 判断是否是输入端口
        blockType = get_param(hY, "BlockType");
        if strcmp(blockType, 'Inport')
            name = get_param(hY, "Name");
        elseif strcmp(blockType, 'From')
            name = get_param(hY, "GotoTag");
        elseif strcmp(blockType, 'SubSystem')
            set_param(hY,'Commented', 'through')
            hY = get_param(get_param(hY,'LineHandles').Inport,'SrcBlockHandle');
%             hIn = get(get(hIn).LineHandles.Inport).SrcBlockHandle;
            blockType = get_param(hY, "BlockType");
            if strcmp(blockType, 'Inport')
                name = get_param(hY, "Name");
            end
        else
            name = 'error_X_s32error';
        end
        %         如何输入的名字是error, 则重命名下，便于输出single类型
        if strcmp(name, 'error') || strcmp(name, 'Error') || strcmp(name, 'err')
            name = 'error_X_s32error';
        end
        % 根据句柄得到这个变量的类型typeX,typeY并返回
        Y.name = name;
        [Y.dataType, ~, Y.StorageClassParamPCMU, ~, Y.StorageClassParamVCU] = findNameType(name);
    end



end





    

