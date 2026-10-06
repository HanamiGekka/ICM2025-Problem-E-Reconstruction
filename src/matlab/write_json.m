function write_json(file,value)
% Engineering export helper; explicit UTF-8, no scientific transformation.
fid=fopen(file,'w'); assert(fid>=0,'export:open','Cannot open %s',file);
cleanup=onCleanup(@()fclose(fid));
fwrite(fid,unicode2native(jsonencode(value,PrettyPrint=true),'UTF-8'),'uint8');
end
