function [fPCMU, fVCU, DataPCMU, DataVCU] = findSlddParam(path,  varargin)
%%
    % 目的: 获取模型的Paramters, 保存到excel中，用于生成sldd
    % 输入：
    %       path： 模型路径
    % 返回： type: 信号类型及PCMU, VCU的storage class
    % 范例： [DataPCMU, DataVCU] = findSlddParam('TmComprCtrl')
    % 作者： Blue.ge
    % 日期： 20231009
%%
    
    clc
    %% 参数处理
     clc
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'overwrite',false);  
   
    % 输入参数处理   
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    overwrite = p.Results.overwrite;
    %% 找到系统标定量
    [PathAll, parameters] = findParameters(path);

    %% 2. 构建标定量 sldd 数据矩阵
    [DataPCMU, DataVCU] = findParameterSlddData(path, parameters);

    %% 3. 保存sldd
    [fPCMU, fVCU] = saveSldd(path, DataPCMU, DataVCU, 'dataType','Parameters','overwrite',overwrite);

     %% 4. 获取look up table 标定量
    [PathLookup1D, PathLookup2D,Param1DLoopUp, Param2DLoopUp] = findParamLookupAll(bdroot);
    %% 5. 保存1维表
    [DataPCMU, DataVCU] = findParameterSlddData(bdroot, Param1DLoopUp);
    saveSlddTable(path, DataPCMU, 'dataType','1D','overwrite',overwrite)
    %% 6. 保存2维度
    [DataPCMU, DataVCU] = findParameterSlddData(bdroot, Param2DLoopUp);
    saveSlddTable(path, DataPCMU, 'dataType','2D','overwrite',overwrite)
end