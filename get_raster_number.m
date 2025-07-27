clear;
clc;
[biodiversity,R] = readgeoraster('D:\36_Australia\mammals_mask\Acrobates_pygmaeus.tif');
[col,rol]= size(biodiversity);
info = geotiffinfo('D:\36_Australia\mammals_mask\Acrobates_pygmaeus.tif'); %获取影像的具体信息
number=[];
start=1;
for i = 1:col
    for j= 1:rol
        number(i,j)=start;
        start=start+1;
    end
end
 geotiffwrite(['D:\36_Australia\biodiversity_number.tif'],number,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);