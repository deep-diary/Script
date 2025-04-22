function creatRefPCMU(modelName, varargin)
%CREATEREFPCMU 创建PCMU配置的模型引用
%   creatRefPCMU(modelName) 为指定的模型创建PCMU配置的模型引用。
%
%   输入参数:
%       modelName - 模型名称，例如 'TmSovCtrl'
%
%   可选参数:
%       'SLDD' - 自定义SLDD文件路径，默认为 'None'
%       'DCM' - DCM文件路径，默认为 'None'
%
%   示例:
%       creatRefPCMU('TmSovCtrl')
%       creatRefPCMU('TmComprCtrl', 'SLDD', 'custom_DD.xlsx')
%
%   作者: 葛维冬 (Blue Ge)
%   日期: 2024-02-04
%   版本: 1.1

    try
        %% 输入参数处理
        p = inputParser;
        addParameter(p, 'SLDD', 'None');
        addParameter(p, 'DCM', 'None');
        parse(p, varargin{:});
        
        slddPath = p.Results.SLDD;
        dcmPath = p.Results.DCM;
        
        %% 加载SLDD文件
        slddPathArch = 'TmSwArch_DD_PCMU.xlsx';
        
        % 指定模型SLDD路径
        if strcmp(slddPath, 'None')
            slddPathMod = [modelName, '_DD_PCMU.xlsx'];
        else
            slddPathMod = slddPath;
        end
        
        % 根据DCM更新SLDD
        if ~strcmp(dcmPath, 'None')
            changeArchSldd(dcmPath, slddPathMod);
        end
        
        %% 加载SLDD数据
        findSlddLoad(slddPathArch);
        findSlddLoad(slddPathMod);
        
        %% 配置采样时间参数
        cTmSwArch_t_s32SampleTime = AUTOSAR4.Parameter(0.05);
        cTmSwArch_t_s32SampleTime.DataType = 'single';
        
        %% 创建或打开引用模型
        refModelName = 'subModRefPCMU';
        createOrOpenModel(refModelName);
        
        %% 清理模型
        delGcsAll();
        
        %% 配置模型位置
        stpX = 0;
        posOrg = [0 0 500 5000];
        pos = posOrg + [stpX * 4, 0, stpX * 4, 0];
        
        %% 添加模型引用
        root = gcs;
        modelPath = [root, '/', modelName];
        
        add_block('built-in/ModelReference', modelPath, ...
            'ModelName', modelName, 'Position', pos);
        
        changeModPos(modelPath, pos);
        
        %% 配置AUTOSAR
        changeCfgAutosar(modelName);
        changeCfgAutosar(refModelName);
        
        %% 清理代码生成目录
        cleanCodeGenDirectory();
        
        fprintf('PCMU模型引用创建完成: %s\n', modelName);
        
    catch ME
        error('创建PCMU模型引用时发生错误: %s', ME.message);
    end
end

function createOrOpenModel(modelName)
%CREATEOROPENMODEL 创建或打开模型
%   如果模型存在则打开，不存在则创建新模型

    if exist([modelName '.slx'], 'file')
        open_system(modelName);
    else
        new_system(modelName);
        save_system(modelName);
        open_system(modelName);
    end
end

function cleanCodeGenDirectory()
%CLEANCODEGENDIRECTORY 清理代码生成目录

    proj = currentProject;
    rootPath = proj.RootFolder;
    codeFold = 'CodeGen';
    fLists = dir(codeFold);
    
    for i = 3:length(fLists)
        T = fLists(i);
        path = fullfile(rootPath, codeFold, T.name);
        if T.isdir
            rmdir(path, 's');
        else
            delete(path);
        end
    end
end

