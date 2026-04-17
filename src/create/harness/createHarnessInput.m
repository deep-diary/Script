function inCells = createHarnessInput(in)
%%
% 目的: 为输入元素进行遍历，如果是数组，则对其打散
% 输入：{{[1 2 3], [4 5], 6}}
% 返回：{{1 4 6},{1 5 6},{2 4 6},{2 5 6},{3 4 6},{3 5 6}}
% 范例： inCells = createHarnessInput({{[1 2 3], [4 5], 6}})
% 作者： Blue.ge
% 日期： 20240410
%%
%     clc
%     in = {{[1 2 3], [4 5], 6}};
    cellNum = length(in);
    inCells = in;
    for i=1:cellNum
        input = in{i};
        arrNum = length(input);
        for j=1:arrNum
            el = input{j};
            elNum = numel(el);
            if isnumeric(el) && elNum > 1
                
                for k=1:elNum
                    newCell = in{i};
                    newCell{j} = el(k);
                    inCells{end+1} = newCell;
                end
                inCells(i) = []; % 清空原来的元素
                inCells = createHarnessInput(inCells);
                return
            end
        end

    end
    
end
