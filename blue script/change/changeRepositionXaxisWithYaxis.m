function changeRepositionXaxisWithYaxis(filePath)
%%
    % 目的: 调换A2L文件中的X, Y的顺序
    % 输入：
    %       filePath: A2L 所有在根目录
    % 返回： None
    % 范例： changeRepositionXaxisWithYaxis(filePath)
    % 作者： 原创：前辈，修改：Blue.ge 
    % 日期： 20240124
    %%
    clc
%{ 
    /begin RECORD_LAYOUT Lookup2D_FLOAT32_IEEE
      FNC_VALUES  1 FLOAT32_IEEE COLUMN_DIR DIRECT
    /end   RECORD_LAYOUT
%}
axisChange = {'Lookup2D_BOOLEAN','Lookup2D_UBYTE','Lookup2D_BYTE','Lookup2D_UWORD','Lookup2D_WORD','Lookup2D_ULONG','Lookup2D_LONG','Lookup2D_FLOAT32_IEEE','Lookup2D_FLOAT64_IEEE'};
axisChangeResult = {'Lookup2D_BOOLEAN','Lookup2D_UBYTE','Lookup2D_BYTE','Lookup2D_UWORD','Lookup2D_WORD','Lookup2D_ULONG','Lookup2D_LONG','Lookup2D_FLOAT32_IEEE','Lookup2D_FLOAT64_IEEE'};
% axisChangeResult = {'Lookup2D_BOOLEAN_RowFirst','Lookup2D_UBYTE_RowFirst','Lookup2D_BYTE_RowFirst','Lookup2D_UWORD_RowFirst','Lookup2D_WORD_RowFirst','Lookup2D_ULONG_RowFirst','Lookup2D_LONG_RowFirst','Lookup2D_FLOAT32_IEEE_RowFirst','Lookup2D_FLOAT64_IEEE_RowFirst'};
signResult = {'UBYTE','UBYTE','SBYTE','UWORD','SWORD','ULONG','SLONG','FLOAT32_IEEE','FLOAT64_IEEE'};
axisStr = '';
% for i = 1 : length(axisChangeResult)
%     axisStr = [axisStr char(10) '    /begin RECORD_LAYOUT ' axisChangeResult{i} char(10)  '      FNC_VALUES  1 ' signResult{i} ' ROW_DIR DIRECT' char(10) '    /end   RECORD_LAYOUT' char(10)];
% end
curDirFiles = dir(filePath);
for idx_i = 1 : length(curDirFiles)
    tempFileName = curDirFiles(idx_i).name;
    if length(tempFileName) >= 4 && isequal(tempFileName(end-3:end),'.a2l')
        a2lPath = [filePath '\' tempFileName];
        fid = fopen(a2lPath,'r'); % /begin AXIS_DESCR  /end AXIS_DESCR
        lineNum = 0;
        begin_CHARACTERISTIC = [];
        end_CHARACTERISTIC = [];
        begin_AXIS_DESCR = [];
        end_AXIS_DESCR = [];
        existRowFirst = 0;
        recordAddSign = 0;
        while feof(fid) == 0
            tline = fgetl(fid);
            lineNum = lineNum + 1;
            totalContent{lineNum} = tline;
            if ~isempty(strfind(tline,'/begin')) && ~isempty(strfind(tline,'CHARACTERISTIC'))
                begin_CHARACTERISTIC = [begin_CHARACTERISTIC; lineNum];
            elseif ~isempty(strfind(tline,'/end')) && ~isempty(strfind(tline,'CHARACTERISTIC'))
                end_CHARACTERISTIC = [end_CHARACTERISTIC; lineNum];
            elseif ~isempty(strfind(tline,'/begin')) && ~isempty(strfind(tline,'AXIS_DESCR'))
                begin_AXIS_DESCR = [begin_AXIS_DESCR; lineNum];
            elseif ~isempty(strfind(tline,'/end')) && ~isempty(strfind(tline,'AXIS_DESCR'))
                end_AXIS_DESCR = [end_AXIS_DESCR; lineNum];
            end
            if ~isempty(strfind(tline,'/end')) && ~isempty(strfind(tline,' RECORD_LAYOUT'))
                recordAddSign = lineNum;
            end
            if ~isempty(strfind(tline,'/begin')) && ~isempty(strfind(tline,' RECORD_LAYOUT')) && ~isempty(strfind(tline,'_RowFirst'))
                existRowFirst = 1;
            end
        end
        totalContentNew = totalContent;
        for i = 1 : length(begin_CHARACTERISTIC)
            % 在标定量字段中存在两个/begin AXIS_DESCR 即为二维查表
            begin_AXIS_DESCR_exist_count = sum((begin_AXIS_DESCR > begin_CHARACTERISTIC(i,1)) & (begin_AXIS_DESCR < end_CHARACTERISTIC(i,1)));
            if begin_AXIS_DESCR_exist_count == 2
                tempLineNumBegin = begin_AXIS_DESCR((begin_AXIS_DESCR > begin_CHARACTERISTIC(i,1)) & (begin_AXIS_DESCR < end_CHARACTERISTIC(i,1)));
                tempLineNumEnd = end_AXIS_DESCR((end_AXIS_DESCR > begin_CHARACTERISTIC(i,1)) & (end_AXIS_DESCR < end_CHARACTERISTIC(i,1)));
                % count = count + 1
                x_axis = 0;
                y_axis = 0;
                for j = begin_CHARACTERISTIC(i,1) : end_CHARACTERISTIC(i,1)   
                    if ~isempty(strfind(totalContent{j},'X-Axis')) && ~isempty(strfind(totalContent{j},'Description'))   % /* Description of X-Axis Points */
                       x_axis = j;
                    elseif ~isempty(strfind(totalContent{j},'Y-Axis')) && ~isempty(strfind(totalContent{j},'Description')) % /* Description of Y-Axis Points */
                       y_axis = j;
                    end
                end
                if y_axis > x_axis % change flag
                    for k = 1 : (tempLineNumEnd(2) - tempLineNumBegin(2) + 1)
                        totalContentNew{tempLineNumBegin(1)+k-1} = totalContent{tempLineNumBegin(2)+k-1};
                    end
                    for k = 1 : (tempLineNumEnd(1) - tempLineNumBegin(1) + 1)
                        totalContentNew{tempLineNumBegin(1)+tempLineNumEnd(2) - tempLineNumBegin(2)+k} = totalContent{tempLineNumBegin(1)+k-1};
                    end
                    for k = 1 : (tempLineNumBegin(2) - tempLineNumEnd(1) - 1)
                        totalContentNew{tempLineNumEnd(2) - tempLineNumBegin(2)+ tempLineNumEnd(1) + k + 1} = totalContent{tempLineNumEnd(1)+k};
                    end
                    for j = begin_CHARACTERISTIC(i,1) : end_CHARACTERISTIC(i,1)
                        for tempIdx = 1 : length(axisChange)
                            totalContentNew{j} = strrep(totalContentNew{j},[' ' axisChange{tempIdx} ' '],[' ' axisChangeResult{tempIdx} ' ']);
                            totalContentNew{j} = regexprep(totalContentNew{j},[' ' axisChange{tempIdx} '$'],[' ' axisChangeResult{tempIdx}]);
                        end
                    end
                end
            end
        end
        fclose(fid);
        if ~isequal(totalContent,totalContentNew)
            fid = fopen(a2lPath,'w+');
            for i = 1 : length(totalContentNew)
                if existRowFirst == 0 && i == recordAddSign
                    totalContentNew{i} = [totalContentNew{i} axisStr];
                end
                fprintf(fid,'%s\n',totalContentNew{i});
            end
            fclose(fid);
        end
    end
	clearvars totalContentNew totalContent;
end


