function createModBusAll(rootPath)
%%
% 目的: 为所有模型创建对应的输入输出bus, 
% 输入：
%       模型路径
% 返回：None
% 范例：createModBusAll(gcs)
% 说明：
% 作者： Blue.ge
% 日期： 20240513
%%
    clc
    SigDismatchAll = {};
    SigMatchAll = {};
    ModelReference = find_system(rootPath,'SearchDepth',1,'BlockType','ModelReference');

    %% 创建所有的creator
    for i=1:length(ModelReference)
        createModBus(ModelReference{i},'mode', 'creator');
    end

    %% 创建所有的selector
    for i=1:length(ModelReference)
        ModelName = get_param(ModelReference{i},'ModelName');
        disp(['-------------->' ModelName]);
        [SigMatch, SigDismatch] = createModBus(ModelReference{i},'mode', 'selector');
        SigMatchAll = [SigMatchAll;SigMatch];
        SigDismatchAll = [SigDismatchAll;SigDismatch];
    end


      %% 显示结果信息
      disp('------------------------Conclusion:');
      matchSize = size(SigMatchAll,1);
      dismatchSize = size(SigDismatchAll,1);
      fprintf('Selector和模型连接成功: 成功匹配%d个，未匹配%d个. \n',matchSize, dismatchSize);

      if dismatchSize
          warning('未匹配信号如下:\n');
          for i=1:size(SigDismatchAll,1)
              warning('%s---->%s\n',SigDismatchAll{1}, SigDismatchAll{2});
          end
            % 保存没有匹配的信号
              path = 'MissMatchSignals.xlsx';
            if exist(path, 'file')
                delete(path)
            end
          xlswrite('MissMatchSignals.xlsx',SigDismatchAll);
        %生成MissMatch报告
        disp('需修复MisMatch:');
        error('          未匹配成功信号见文件：MissMatchSignals.xlsx');
      else
        fprintf('所有输入信号均已匹配连接成功!\n');
      end
      disp('------------------------End');
end
