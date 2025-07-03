function createModBusCreator(mdPath,  creatorPath)
%%
% 目的: 为模型生成输出bus creator, 
% 输入：
%       模型路径
% 返回：None
% 范例：createModBusCreator(gcb, creatorPath)
% 说明：1. 鼠标点击在子模型上，2. 在命令窗口运行此函数
% 作者： Blue.ge
% 日期： 20240513
%%
    %% 参数处理


    %% 创建creator
    disp('------------------------------------');
    ModelName = get_param(mdPath,'ModelName');
    ModelPath = get_param(mdPath,'Parent');
    %根据参考模型，在架构模型中建立BusCreator
    TemHan = get_param(mdPath,'Handle');
    TemPc = get_param(mdPath,'PortConnectivity');
    
    %找到参考模型连接的BusCreator的句柄
    if strcmp(creatorPath,'NA')
        DesBlk = 0;
        for j = 1 : length(TemPc)
            if(~isempty(TemPc(j).DstBlock))
                DesBlk = TemPc(j).DstBlock;
                break;
            end
        end
        if ~DesBlk
            error([ModelName ': No creatorPath Info and existed creator connected to the model,pls connect the model and creator manually at least 1 line'])
        end
    else
        DesBlk = get_param(creatorPath,'Handle');
    end
    
    %清除当前参考模型和BusCreator之间的已有连线
    modelLh = get(TemHan,'LineHandles');
    for k = 1 : length(modelLh.Outport)
        if(modelLh.Outport(k)>0)
            delete_line(modelLh.Outport(k));
        end
    end
    DesBlkLh = get(DesBlk,'LineHandles');
    for k = 1 : length(DesBlkLh.Inport)
        if(DesBlkLh.Inport(k)>0)
            delete_line(DesBlkLh.Inport(k));
        end
    end
    
    
    %根据参考模型的输出信号，确定BusCreator的信号数目，并且实现参考模型和BusCreator的连线
    ModelPh = get(TemHan,'PortHandles');
    BusCreatorPh = get(DesBlk,'PortHandles');
    nums = length(ModelPh.Outport);
    for m = 1 : nums
        set(DesBlk,'Inputs',num2str(length(ModelPh.Outport)));
        add_line(ModelPath,ModelPh.Outport(m),BusCreatorPh.Inport(m));
    end

    %% 调整bus尺寸
      posMd = get_param(mdPath,'Position');
      posSelector = [posMd(3)+300-15, posMd(2) posMd(3)+300+15 posMd(4)];
      set_param(DesBlk,'Position',posSelector);

      %% 显示结果信息
      fprintf('%s: 所有输出信号均已匹配连接成功! 成功匹配了%d个. \n',ModelName,nums);

end
