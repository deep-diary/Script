Simulink.data.dictionary.closeAll;
clear;
%% None Geely Dictionary

proj = currentProject;
rootPath = proj.RootFolder;
dataPathSl = rootPath+'\';
dataPathGl = rootPath+'\';
CaliD_DictObj = Simulink.data.dictionary.open(dataPathSl+'TmVcThemal_DD_LPbase_addNHP_new.sldd');
CaliD_DictSec = getSection(CaliD_DictObj,'Design Data');

%% Geely Calibration Dictionary: CalData_GeelyMap.sldd
dataNameGl = 'TmVcThemal_DD_LPbase_addNHP_new_VCU.sldd';
dataNameFGl = dataPathGl+dataNameGl;
if(exist(dataNameFGl, 'file') ==2)
    delete(dataNameFGl);
end

CaliD_DictObj_Gl = Simulink.data.dictionary.create(dataNameFGl);
CaliD_DictSec_Gl = getSection(CaliD_DictObj_Gl,'Design Data');

nDataLength = CaliD_DictObj.NumberOfEntries;
entriseCal = evalin(CaliD_DictSec,'whos');

for i = 1:nDataLength
    tmpName = entriseCal(i).name;
    tmpEntry = getEntry(CaliD_DictSec,tmpName);
    tmpValue = tmpEntry.getValue();
    if(isa(tmpValue,'GeelyPack.Parameter'))
        tmpParGL = AUTOSAR4.Parameter;
        tmpParGL.Value = tmpValue.Value;
        tmpParGL.DataType = tmpValue.DataType;
        tmpParGL.Min = tmpValue.Min;
        tmpParGL.Max = tmpValue.Max;
        tmpParGL.DataType = tmpValue.DataType;
        tmpParGL.CoderInfo.StorageClass = 'Custom';
        switch tmpParGL.DataType
            case 'boolean'
                tmpParGL.CoderInfo.CustomStorageClass = 'CAL_8BIT';
            case 'uint8'
                tmpParGL.CoderInfo.CustomStorageClass = 'CAL_8BIT';
            case 'int8'
                tmpParGL.CoderInfo.CustomStorageClass = 'CAL_8BIT';
            case 'uint16'
                tmpParGL.CoderInfo.CustomStorageClass = 'CAL_16BIT';
            case 'int16'
                tmpParGL.CoderInfo.CustomStorageClass = 'CAL_16BIT';
            case 'uint32'
                tmpParGL.CoderInfo.CustomStorageClass = 'CAL_32BIT';
            case 'int32'
                tmpParGL.CoderInfo.CustomStorageClass = 'CAL_32BIT';
            case 'single'
                tmpParGL.CoderInfo.CustomStorageClass = 'CAL_32BIT';
            otherwise
                tmpParGL.CoderInfo.CustomStorageClass = 'CAL_32BIT';
        end
        addEntry( CaliD_DictSec_Gl,tmpName,tmpParGL);
    elseif(isa(tmpValue,'GeelyPack.Signal'))
        tmpSigGL = AUTOSAR4.Signal;
        tmpSigGL.DataType = tmpValue.DataType;
        tmpSigGL.Min = tmpValue.Min;
        tmpSigGL.Max = tmpValue.Max;
        tmpSigGL.DataType = tmpValue.DataType;
        tmpSigGL.CoderInfo.StorageClass = 'Custom';
        tmpSigGL.Dimensions = 1;
        tmpSigGL.DimensionsMode = 'Fixed';
        tmpSigGL.Complexity = 'real';

        switch tmpSigGL.DataType
            case 'boolean'
                tmpSigGL.CoderInfo.CustomStorageClass = 'Global1';
            case 'uint8'
                tmpSigGL.CoderInfo.CustomStorageClass = 'Global1';
            case 'int8'
                tmpSigGL.CoderInfo.CustomStorageClass = 'Global1';
            case 'uint16'
                tmpSigGL.CoderInfo.CustomStorageClass = 'Global1';
            case 'int16'
                tmpSigGL.CoderInfo.CustomStorageClass = 'Global1';
            case 'uint32'
                tmpSigGL.CoderInfo.CustomStorageClass = 'Global1';
            case 'int32'
                tmpSigGL.CoderInfo.CustomStorageClass = 'Global1';
            case 'single'
                tmpSigGL.CoderInfo.CustomStorageClass = 'Global1';
            otherwise
                tmpSigGL.CoderInfo.CustomStorageClass = 'Global1';
        end
    end
    addEntry( CaliD_DictSec_Gl,tmpName,tmpSigGL);
end
saveChanges(CaliD_DictObj_Gl);
