clear;
clc;
%%获得物种的列表
% parentFolder = 'D:\36_Australia\mammals';
% subFolders = dir(parentFolder);
% subFolders = subFolders(3:length(subFolders),1);  %因为前两个读出来是空的，如果需要的话得再看看
% a = subFolders(3,1).name;
species='Acrobates_pygmaeus';

%%read the standard layer
[biodiversity_standard,R] = readgeoraster('D:\36_Australia\biodiversity_30.tif');
size1= size(biodiversity_standard);
info = geotiffinfo('D:\36_Australia\biodiversity_30.tif'); %获取影像的具体信息

%%read habitat suitbility data
name_wenjianjia = ['D:\36_Australia\mammals\',species,'\'];
biodiversity_name = ['D:\36_Australia\mammals\',species,'\',species,'_historic_baseline_1990_AUS_5km_EnviroSuit.tif'];
biodiversity = readgeoraster(biodiversity_name);
biodiversity = double(biodiversity);
biodiversity(biodiversity == 255) = NaN;

%%Resample
bio_resample = imresize(biodiversity, size1,'nearest');

%%read boundary
shp = shaperead(['D:\36_Australia\mammals_models\',species,'\mammals_',species,'_Extent_of_occurrence_buffered.shp']);

%%创建掩膜
%boundary = shp.BoundingBox; % 假设只有一个图形，适用于多边形情况
x=shp.X;
y=shp.Y;
x = x(~isnan(x));
y = y(~isnan(y));
cols = round((x - R.LongitudeLimits(1)) / R.CellExtentInLongitude) + 1;
rows = round((R.LatitudeLimits(2) - y) / R.CellExtentInLatitude) + 1;
mask = poly2mask(cols, rows, size(bio_resample, 1), size(bio_resample, 2));
bio_resample(~mask) = 0;

%%把边界值设成255
Boundary_non=(biodiversity_standard == 255);
bio_resample(Boundary_non)=255;

%%输出tif
%geotiffwrite([name_wenjianjia,species,'historic_resample_buffer.tif'],bio_resample,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);

%%读取面积图层，并计算生物多样性面积加权值
area=readgeoraster('D:\36_Australia\Area\Calculate TIF meters\Calculate TIF meters\rasters\biodiversity_30_area.tif');
[heng,shu]=size(bio_resample);
area_weight=[];
for i=1:heng
    for j=1:shu
        area_weight(i,j)=area(i,j).*bio_resample(i,j);
    end
end

%%读取土地利用数据(0_cropland,1_forestland,2_grassland,3_builtup,4_water,5_other)
landuse1990=readgeoraster('D:\36_Australia\Landuse\landuse_1990_project_clip.tif');

%%循环计算每种地类的每种物种的均值
for class=0:5
    num=0;
    sum=0;
    for i=1:heng
        for j=1:zong
            if landuse1990(i,j)==class
                sum=sum+area_weight(i,j);
                num=num+1;
            end
        end
    end
    species_average=sum./num;
end
