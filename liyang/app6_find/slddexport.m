  Block_name=get(gcbh,'Name');
  strlist1=split( Block_name,'_');
  md_name= char(strlist1(1,1)); %带一个下划线直接用后面的cell即可
 % if (DictionaryObj)
try
    DictionaryObj = Simulink.data.dictionary.create(strcat(md_name,'.sldd'));
    importFromBaseWorkspace(DictionaryObj);
    saveChanges(DictionaryObj);
    close(DictionaryObj);
catch
msgbox('报异常了,不用害怕，可能是没关sldd');
 close(DictionaryObj);
end
%  end

% clear GenQf1
[file,path] = uigetfile('*.m');
filename=[path,file]; 
filetext =fileread(filename);
expr = '(?<=Simulink.defineIntEnumType\(\s).*?(?=\,)';%匹配表名
EnumCell=regexp(filetext,expr,'match');%匹配表名

% EnumCell={'CCMLifeCycleModeGroup',  。。。需要导入的枚举变量列表};
[importedTypes,importFailures]=importEnumTypes(DictionaryObj,EnumCell)
 close(DictionaryObj);