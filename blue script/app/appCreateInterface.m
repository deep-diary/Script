%% 打开模型
MOUDLE_NAME = 'demo_interface';

if bdIsLoaded(MOUDLE_NAME)
    open_system(MOUDLE_NAME);
else
    new_system(MOUDLE_NAME);
    open_system(MOUDLE_NAME);
end

%% 创建 RX 到 CCM 内部SWC 的 Interface
creatIFIn()

%% SWC 输出信号转换
creatTmOut()

%% 创建CCM 内部SWC 到 TX 的 Interface
creatIFOut()

%% 导出Sldd
findSldd(bdroot)

%% 导入Sldd
% 执行以下步骤之前，需要手动将表格中的CustomStorageClass 统一改为 Globle
findSlddLoad([MOUDLE_NAME '_DD_PCMU_EXPORT.xlsx'])

