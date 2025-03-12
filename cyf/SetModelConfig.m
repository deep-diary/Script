function SetModelConfig
clc;
clear;
try
    load('Configuration_VCU.mat');
catch
    warning(['"Configuration_VCU.mat"' 'is not fund!']);
end
proj = currentProject;
rootPath = proj.RootFolder;
SubmodelPath = rootPath+'\HP_subModels\SVN_HY11subModel\';
DDPath = rootPath+'\HP_subModels\DD\';

modelName={'TEM_VCU1','TmSwArch','TmIn','TmOut','TmSigProces','TmRefriModeMgr',...
    'TmRefriVlvCtrl','TmSovCtrl','TmComprCtrl','TmColtModeMgr','TmColtVlvCtrl',...
    'TmPumpCtrl','TmHvchCtrl','TmAfCtrl','TmEnergyMgr','TmDiag'};

% modelHandle = load_system(modelName);
% a=get(modelHandle);
for idx=1:length(modelName)
    %% ģ��Configration����
    load_system(modelName{idx})
    k=getConfigSet(modelName{idx},'Reference_VCU');%����ģ�����Ե�ģ����������
    if isempty(k)
        configRef=Simulink.ConfigSetRef;%�½�ģ������
        set_param(configRef,'Name','Reference_VCU');%��ģ����������
        set_param(configRef,'SourceName','Configuration_VCU');%����ģ������Դ
        attachConfigSet(modelName{idx},configRef);%��ģ��������ģ�͹���
    else
        set_param(k,'SourceName','Configuration_VCU');%����ģ������Դ
    end
    setActiveConfigSet(modelName{idx},'Reference_VCU');%����ģ������
    disp([modelName{idx} ' ģ�� Configration�������----------------------------------------------------------------------------------------------']);
    %% ģ��CoderMapping����
    coder.mapping.create(modelName{idx});
    coder.mapping.defaults.set(modelName{idx},'LocalParameters','StorageClass','Default');
    coder.mapping.defaults.set(modelName{idx},'ModelParameters','StorageClass','Default');
    coder.mapping.defaults.set(modelName{idx},'ExternalParameterObjects','StorageClass','Default');
    coder.mapping.defaults.set(modelName{idx},'GlobalParameters','StorageClass','Default');
    coder.mapping.defaults.set(modelName{idx},'InternalData','StorageClass','Default');
    %     coder.mapping.defaults.set(modelName{idx},'InitializeTerminate','FunctionCustomizationTemplate','CODE_INT');
    %     coder.mapping.defaults.set(modelName{idx},'Execution','FunctionCustomizationTemplate','CODE_10MS');
    %     coder.mapping.defaults.set(modelName{idx},'SharedUtility','FunctionCustomizationTemplate','CODE_10MS');
    %     coder.mapping.defaults.set(modelName{idx},'InitializeTerminate','MemorySection','CODE_INI');

    coderDictionaryObj = coder.dictionary.open(modelName{idx});%��ȡģ�ʹ��������ֵ�
    %     storageClassesSect = getSection(coderDictionaryObj, 'StorageClasses');
    coderDictionaryObj.loadPackage('GeelyPack');%�������ֵ��м���GeelyPack��


    mySCCodeMappingObj = coder.mapping.api.get(modelName{idx},'EmbeddedCoderC');%��ȡģ�ʹ���ӳ������
    %     value = getFunctionDefault(mySCCodeMappingObj, 'Execution', 'MemorySection');
    setFunctionDefault(mySCCodeMappingObj,'Execution','MemorySection','CODE_10MS');%�޸��ڴ������
    setFunctionDefault(mySCCodeMappingObj,'InitializeTerminate','MemorySection','CODE_INT');%�޸��ڴ������
    setFunctionDefault(mySCCodeMappingObj,'SharedUtility','MemorySection','CODE_10MS');%�޸��ڴ������
    try
        if strcmp(modelName{idx},'TmSwArch')
            setFunction(mySCCodeMappingObj,'ExportedFunction','MemorySection','Model default');%�޸��ڴ������
        elseif strcmp(modelName{idx},'TEM_VCU1')|| strcmp(modelName{idx},'TmIn') || strcmp(modelName{idx},'TmOut')
            setFunction(mySCCodeMappingObj,'Periodic:D1','MemorySection','Model default');%�޸��ڴ������
        else
            setFunction(mySCCodeMappingObj,['ExportedFunction:' modelName{idx} '_100'],'MemorySection','Model default');%�޸��ڴ������
        end
    catch
        warning([modelName{idx} ' No ExportedFuntion or Periodic !']);
    end
    setFunction(mySCCodeMappingObj,'Initialize','MemorySection','Model default');%�޸��ڴ������
    try
        setFunction(mySCCodeMappingObj,'Initialize','MemorySection','CODE_100MS');%�޸��ڴ������
    catch
        warning([modelName{idx} ' No Terminate !']);
    end
    disp([modelName{idx} ' ģ�� Embedded Coder Mapping�������------------------------------------------------------------------------------']);
    save_system(modelName{idx},'SaveDirtyReferencedModels','on');%����ģ�ͣ����Դ���

end
disp('����ģ���������------------------------------------------------------------------------------');
end
%% ������������

% dictionaryName = 'AllData_GeelyMap.sldd';
% set_param(modelHandle,'DataDictionary',dictionaryName);
% set_param(modelHandle,'ProdHWDeviceType','Infineon->TriCore');
% %% set_param(modelHandle,'SimCustomHeaderCode',rootPath+'\Include\data_import.h');
% set_param(modelHandle,'PackageName','App_TriCore.zip');
% %% save_system(modelHandle, '..\Models\Controller\PMA2_YlAPP_V5_Auto.slx');
% coder.mapping.defaults.set(modelHandle,'LocalParameters','StorageClass','GEELYCONST');
% coder.mapping.defaults.set(modelHandle,'ModelParameters','StorageClass','GEELYCONST');
% coder.mapping.defaults.set(modelHandle,'ExternalParameterObjects','StorageClass','GEELYCONST');
% coder.mapping.defaults.set(modelHandle,'GlobalParameters','StorageClass','GEELYCONST');
% coder.mapping.defaults.set(modelHandle,'InternalData','StorageClass','GEELYLOCDATA');
% coder.mapping.defaults.set(modelHandle,'InitializeTerminate','FunctionCustomizationTemplate','CODE_INIT');
% coder.mapping.defaults.set(modelHandle,'Execution','FunctionCustomizationTemplate','CODE_STEP');
% coder.mapping.defaults.set(modelHandle,'SharedUtility','FunctionCustomizationTemplate','CODE_LIB');
% 
% %% ���ɴ���
% slbuild(modelHandle);
% 
% save_system(modelHandle);
% close_system(modelHandle);