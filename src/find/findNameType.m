function [dataType, ScSigPCMU, ScParamPCMU, ScSigVCU, ScParamVCU] = findNameType(name)
%%
    % 目的: 根据信号名，获取对应的信号类型
    % 输入：
    %       name： 信号名称
    % 返回： type: 信号类型及PCMU, VCU的storage class
    % 范例： [dataType, ScSigPCMU, ScParamPCMU, ScSigVCU, ScParamVCU] = findNameType('sTmIn_X_s32EexvPosSts')
    % 作者： Blue.ge
    % 日期： 20231009
%%
    clc
    shortTypes = {'i8','i16','i32','u8','u16','u32','s32','_B_','u64',''};
    dataTypes = {'int8','int16','int32','uint8','uint16','uint32','single','boolean','uint64','Inherit: auto'}; % 最后一项为默认项
    ScSigPCMUs = {'Global1','Global1','Global1','Global1','Global1','Global1','Global1','Global1','Global1',''}; % 最后一项为默认项
    ScSigVCUs = {'DATA8BIT_APP','DATA16BIT_APP','DATA32BIT_APP','DATA8BIT_APP','DATA16BIT_APP','DATA32BIT_APP','DATA32BIT_APP','DATABOOL_APP','DATA64BIT_APP',''}; % 最后一项为默认项
    ScParamPCMUs = {'CAL_8BIT','CAL_16BIT','CAL_32BIT','CAL_8BIT','CAL_16BIT','CAL_32BIT','CAL_32BIT','CAL_8BIT','CAL_64BIT',''}; % 最后一项为默认项
    ScParamVCUs = {'CAL8BIT','CAL16BIT','CAL32BIT','CAL8BIT','CAL16BIT','CAL32BIT','CAL32BIT','CAL8BIT','CAL64BIT',''}; % 最后一项为默认项

    typeLength = length(shortTypes);
    idx = 0;
    for j=1:typeLength
        type = shortTypes{j};
        if contains(name, type)
            idx=j;
            break
        end
    end
    dataType = dataTypes{idx};
    ScSigPCMU = ScSigPCMUs{idx};
    ScParamPCMU = ScParamPCMUs{idx};
    ScSigVCU = ScSigVCUs{idx};
    ScParamVCU = ScParamVCUs{idx};

end