% function SetModelConfig
clc;
% clear;
try
    load('Configuration_VCU.mat');
catch
    warning(['"Configuration_VCU.mat"' 'is not fund!']);
end
% �˴���дģ��·��
SubmodelPath = 'D:\Model\HY11_Model\20231106_HY11_E4\HY11_TEM_VCU1\HP_subModels\SVN_HY11subModel\09_TmPumpCtrl\';
% �˴���дģ����
modelName={'TmPumpCtrl'};

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
    setFunctionDefault(mySCCodeMappingObj,'Execution','MemorySection','CODE_100MS');%�޸�Function Defaults�ڴ������
    setFunctionDefault(mySCCodeMappingObj,'InitializeTerminate','MemorySection','CODE_INT');%�޸�Function Defaults�ڴ������
    setFunctionDefault(mySCCodeMappingObj,'SharedUtility','MemorySection','CODE_100MS');%�޸�Function Defaults�ڴ������                                                                                                                                                                                                                                                                                                                                                                                       
    try
        if strcmp(modelName{idx},'TmSwArch')
            setFunction(mySCCodeMappingObj,'ExportedFunction','MemorySection','Model default');%�޸ļܹ�ģ��Functions ExportedFunction�ڴ������
        elseif strcmp(modelName{idx},'TEM_VCU1')|| strcmp(modelName{idx},'TmIn') || strcmp(modelName{idx},'TmOut')
            setFunction(mySCCodeMappingObj,'Periodic:D1','MemorySection','Model default');%�޸��������ģ�����ں���Functions ExportedFunction�ڴ������
        else
            setFunction(mySCCodeMappingObj,['ExportedFunction:' modelName{idx} '_100'],'MemorySection','Model default');%�޸���ģ�͵�������Functions ExportedFunction�ڴ������
        end
    catch
        warning([modelName{idx} ' No ExportedFuntion or Periodic !']);
    end
    setFunction(mySCCodeMappingObj,'Initialize','MemorySection','Model default');%�޸�Functions Initialize�ڴ������
    try
        setFunction(mySCCodeMappingObj,'Terminate','MemorySection','CODE_END');%�޸�Functions Terminate�ڴ������
    catch
        warning([modelName{idx} ' No Terminate !']);
    end
    disp([modelName{idx} ' ģ�� Embedded Coder Mapping�������------------------------------------------------------------------------------']);
    save_system(modelName{idx},'SaveDirtyReferencedModels','on');%����ģ�ͣ����Դ���

end
disp('����ģ���������------------------------------------------------------------------------------');
% end
