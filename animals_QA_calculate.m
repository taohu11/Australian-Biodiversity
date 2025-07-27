clear;
clc;
%%获得物种的列表
parentFolder = '\\school-les-m.shares.deakin.edu.au\school-les-m\Planet-A\Data-Master\Biodiversity\Climate-suitability\Annual-species-suitability_20-year_snapshots_5km\amphibians';
subFolders = dir(parentFolder);
subFolders = subFolders(3:length(subFolders),1);  %因为前两个读出来是空的，如果需要的话得再看看

biodiversity_standard = readgeoraster('F:\TAO\New_calculation\Acrobates_pygmaeus_historic_baseline_1990_AUS_5km_EnviroSuit.tif');
area = readgeoraster('F:\TAO\New_calculation\Area\Acrobates_pygmaeus_area.tif');

for i = 1:length(subFolders)
    species = subFolders(i,1).name;
    %%read habitat suitbility data
    name_wenjianjia = ['\\school-les-m.shares.deakin.edu.au\school-les-m\Planet-A\Data-Master\Biodiversity\Climate-suitability\Annual-species-suitability_20-year_snapshots_5km\amphibians\',species,'\'];
    biodiversity_name = ['\\school-les-m.shares.deakin.edu.au\school-les-m\Planet-A\Data-Master\Biodiversity\Climate-suitability\Annual-species-suitability_20-year_snapshots_5km\amphibians\',species,'\',species,'_historic_baseline_1990_AUS_5km_EnviroSuit.tif'];
    [biodiversity,R] = readgeoraster(biodiversity_name);
    info = geotiffinfo(biodiversity_name); %获取影像的具体信息
    biodiversity = single(biodiversity);
    biodiversity(biodiversity == 255) = 0;

    %%read boundary
    shp = shaperead(['\\school-les-m.shares.deakin.edu.au\school-les-m\Planet-A\Data-Master\Biodiversity\Climate-suitability\Species-occurance-points\amphibians\models\',species,'\amphibians_',species,'_Extent_of_occurrence_buffered.shp']);

    %%创建掩膜
    %boundary = shp.BoundingBox; % 假设只有一个图形，适用于多边形情况
    x=shp.X;
    y=shp.Y;
    x = x(~isnan(x));
    y = y(~isnan(y));
    cols = round((x - R.LongitudeLimits(1)) / R.CellExtentInLongitude) + 1;
    rows = round((R.LatitudeLimits(2) - y) / R.CellExtentInLatitude) + 1;
    mask = poly2mask(cols, rows, size(biodiversity, 1), size(biodiversity, 2));
    biodiversity(~mask) = 0;

    %%把边界值设成255
    Boundary_non=(biodiversity_standard == 255);
    quality_biodiversity=biodiversity.*area/100;
    quality_biodiversity(Boundary_non)=NaN;

    %%输出tif
    geotiffwrite(['F:\TAO\New_calculation\Quality_biodiversity\Amphibians\',species,'.tif'],quality_biodiversity,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
end
