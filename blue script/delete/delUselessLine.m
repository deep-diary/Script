function delUselessLine(path)
    delete_line(find_system(path,'findall','on','Type','Line','Connected','off'))
end
