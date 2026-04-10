function createMergeArxml(component_file, implementation_file, output_file)
    %CREATEMERGEARXML 合并AUTOSAR组件定义文件和实现文件
    %
    %   CREATEMERGEARXML(COMPONENT_FILE, IMPLEMENTATION_FILE, OUTPUT_FILE) 
    %   将AUTOSAR组件定义文件(.arxml)和实现文件(.arxml)合并为一个完整的ARXML文件
    %
    %   输入参数:
    %       COMPONENT_FILE     - 组件定义文件路径 (字符向量或字符串标量)
    %       IMPLEMENTATION_FILE - 实现文件路径 (字符向量或字符串标量)  
    %       OUTPUT_FILE        - 输出文件路径 (字符向量或字符串标量)
    %
    %   输出:
    %       无返回值，合并后的文件保存到指定路径
    %
    %   示例:
    %       createMergeArxml('component.arxml', 'implementation.arxml', 'merged.arxml')
    %
    %   注意:
    %       - 输入文件必须是有效的ARXML格式
    %       - 组件文件应包含APPLICATION-SW-COMPONENT-TYPE节点
    %       - 实现文件应包含SWC-IMPLEMENTATION节点
    %       - 输出文件将包含完整的组件定义和实现信息
    %
    %   参见: xmlread, xmlwrite, fileread, fwrite
    
    % 参数验证
    narginchk(3, 3);
    
    % 验证输入参数类型
    if ~(ischar(component_file) || isstring(component_file))
        error('createMergeArxml:InvalidInput', ...
              'COMPONENT_FILE必须是字符向量或字符串标量');
    end
    
    if ~(ischar(implementation_file) || isstring(implementation_file))
        error('createMergeArxml:InvalidInput', ...
              'IMPLEMENTATION_FILE必须是字符向量或字符串标量');
    end
    
    if ~(ischar(output_file) || isstring(output_file))
        error('createMergeArxml:InvalidInput', ...
              'OUTPUT_FILE必须是字符向量或字符串标量');
    end
    
    % 转换为字符向量
    component_file = char(component_file);
    implementation_file = char(implementation_file);
    output_file = char(output_file);
    
    % 验证文件存在性
    if ~exist(component_file, 'file')
        error('createMergeArxml:FileNotFound', ...
              '组件文件不存在: %s', component_file);
    end
    
    if ~exist(implementation_file, 'file')
        error('createMergeArxml:FileNotFound', ...
              '实现文件不存在: %s', implementation_file);
    end
    
    try
        
        fprintf('开始使用MATLAB官方函数合并ARXML文件...\n');
        
        % 使用fileread读取文件内容（更可靠）
        fprintf('读取组件文件: %s\n', component_file);
        component_content = fileread(component_file);
        
        fprintf('读取实现文件: %s\n', implementation_file);
        implementation_content = fileread(implementation_file);
        
        % 使用正则表达式提取SWC-IMPLEMENTATION部分
        fprintf('解析XML内容...\n');
        
        % 从实现文件中提取完整的SWC-IMPLEMENTATION节点
        swc_impl_pattern = '<SWC-IMPLEMENTATION[^>]*>.*?</SWC-IMPLEMENTATION>';
        swc_impl_matches = regexp(implementation_content, swc_impl_pattern, 'match', 'dotall');
        
        if isempty(swc_impl_matches)
            error('createMergeArxml:NoImplementationFound', ...
                  '在实现文件中未找到SWC-IMPLEMENTATION节点: %s', implementation_file);
        end
        
        % 在组件文件中找到插入位置（在最后一个</AR-PACKAGE>之前）
        insert_pattern = '</AR-PACKAGE>\s*</AR-PACKAGES>';
        insert_match = regexp(component_content, insert_pattern, 'match');
        
        if isempty(insert_match)
            error('createMergeArxml:NoInsertionPoint', ...
                  '在组件文件中未找到插入位置: %s', component_file);
        end
        
        % 构建SwcImplementations包
        fprintf('构建SwcImplementations包...\n');
        swc_impl_package = [
            '                <AR-PACKAGE>' newline ...
            '                    <SHORT-NAME>SwcImplementations</SHORT-NAME>' newline ...
            '                    <ELEMENTS>' newline ...
            '                        ' strjoin(swc_impl_matches, [newline '                        ']) newline ...
            '                    </ELEMENTS>' newline ...
            '                </AR-PACKAGE>' newline ...
            '            '];
        
        % 合并内容
        fprintf('合并文件内容...\n');
        merged_content = regexprep(component_content, insert_pattern, [swc_impl_package insert_match{1}]);
        
        % 使用fwrite保存文件（更可靠）
        fprintf('保存合并后的ARXML文件: %s\n', output_file);
        fid = fopen(output_file, 'w', 'n', 'UTF-8');
        if fid == -1
            error('createMergeArxml:FileWriteError', ...
                  '无法创建输出文件: %s', output_file);
        end
        fwrite(fid, merged_content, 'char');
        fclose(fid);
        
        % 验证合并结果
        if exist(output_file, 'file')
            fprintf('合并成功！输出文件: %s\n', output_file);
            
            % 显示文件信息
            file_info = dir(output_file);
            fprintf('文件大小: %d 字节\n', file_info.bytes);
            
            % 验证XML格式
            try
                test_doc = xmlread(output_file);
                fprintf('XML格式验证通过\n');
                
                % 统计节点数量
                swc_impl_count = length(findElementsByTagName(test_doc.getDocumentElement(), 'SWC-IMPLEMENTATION'));
                app_swc_count = length(findElementsByTagName(test_doc.getDocumentElement(), 'APPLICATION-SW-COMPONENT-TYPE'));
                
                fprintf('合并后的Application Software Component Type数量: %d\n', app_swc_count);
                fprintf('合并后的Software Component Implementation数量: %d\n', swc_impl_count);
                
            catch ME
                fprintf('警告: XML格式验证失败 - %s\n', ME.message);
            end
            
        else
            error('createMergeArxml:MergeFailed', ...
                  '合并失败：输出文件未生成: %s', output_file);
        end
        
    catch ME
        % 重新抛出带有标识符的错误
        if contains(ME.identifier, 'createMergeArxml:')
            rethrow(ME);
        else
            error('createMergeArxml:UnexpectedError', ...
                  '合并过程中发生意外错误: %s', ME.message);
        end
    end
end

function elements = findElementsByTagName(parent, tagName)
    %FINDELEMENTSBYTAGNAME 查找指定标签名的所有XML元素
    %
    %   ELEMENTS = FINDELEMENTSBYTAGNAME(PARENT, TAGNAME) 在父节点中查找
    %   所有具有指定标签名的子元素
    %
    %   输入参数:
    %       PARENT  - XML父节点对象
    %       TAGNAME - 要查找的标签名 (字符向量)
    %
    %   输出:
    %       ELEMENTS - 包含找到的元素的元胞数组
    %
    %   注意:
    %       这是一个内部辅助函数，用于XML节点查找
    
    % 参数验证
    if nargin ~= 2
        error('findElementsByTagName:InvalidInput', ...
              '需要2个输入参数: parent 和 tagName');
    end
    
    if ~ischar(tagName)
        error('findElementsByTagName:InvalidInput', ...
              'tagName必须是字符向量');
    end
    
    % 查找元素
    node_list = parent.getElementsByTagName(tagName);
    elements = cell(node_list.getLength(), 1);
    
    for i = 1:node_list.getLength()
        elements{i} = node_list.item(i-1);
    end
end
