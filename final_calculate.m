clear;
clc;

%%get the standard biodiversity raster
[biodiversity,R]=readgeoraster('D:\36_Australia\mammals_QA\Acrobates_pygmaeus.tif');
info = geotiffinfo('D:\36_Australia\mammals_QA\Acrobates_pygmaeus.tif'); %获取影像的具体信息

land_cover_change_proportion=xlsread('D:\36_Australia\Landuse_transfer\Land_cover_change.xlsx');
land_cover=reshape(land_cover_change_proportion(:,2),978,808)';
%%get the land use proportion raster
% landuse_proportion=xlsread('C:\Landuse90_2020\Landuse_proportion.xlsx');
% number=landuse_proportion(:,1);
% forest_reduction=landuse_proportion(:,9);
% forest_restoration=landuse_proportion(:,10);
% cropland_expansion=landuse_proportion(:,11);
% urban_expansion=landuse_proportion(:,12);
% grassland_restoration=landuse_proportion(:,13);
% grassland_reduction=landuse_proportion(:,14);
% number_shape=reshape(number,978,808)';
% forest_reduction_reshape=reshape(forest_reduction,978,808)';
% forest_restoration_reshape=reshape(forest_restoration,978,808)';
% cropland_expansion_reshape=reshape(cropland_expansion,978,808)';
% urban_expansion_reshape=reshape(urban_expansion,978,808)';
% grassland_restoration_reshape=reshape(grassland_restoration,978,808)';
% grassland_reduction_reshape=reshape(grassland_reduction,978,808)';
% geotiffwrite(['D:\36_Australia\Landuse_proportion\forest_reduction.tif'],forest_reduction_reshape,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
number=readgeoraster('D:\36_Australia\biodiversity_number.tif');
cropland_expansion=readgeoraster('D:\36_Australia\Landuse_proportion\cropland_expansion.tif');
forest_reduction=readgeoraster('D:\36_Australia\Landuse_proportion\forest_reduction.tif');
forest_restoration=readgeoraster('D:\36_Australia\Landuse_proportion\forest_restoration.tif');
grassland_reduction=readgeoraster('D:\36_Australia\Landuse_proportion\grassland_reduction.tif');
grassland_restoration=readgeoraster('D:\36_Australia\Landuse_proportion\grassland_restoration.tif');
urban_expansion=readgeoraster('D:\36_Australia\Landuse_proportion\urban_expansion.tif');

%%get the area raster
% area=readgeoraster('D:\36_Australia\Area\Calculate TIF meters\Calculate TIF meters\rasters\Acrobates_pygmaeus_area.tif');

%%change the data
biodiversity=biodiversity(:);
number=number(:);
area=area(:);
cropland_expansion=cropland_expansion(:);
forest_reduction=forest_reduction(:);
forest_restoration=forest_restoration(:);
grassland_reduction=grassland_reduction(:);
grassland_restoration=grassland_restoration(:);
urban_expansion=urban_expansion(:);

%%find the valide raster
rowIndices1 = find(biodiversity ~= 255);
rowIndices2 = find(~isnan(cropland_expansion));
rowIndices3 = intersect(rowIndices1,rowIndices2);

%%calculate the area of land use change
Sum_area=0;
for i=1:length(rowIndices3)
    Sum_area=Sum_area+forest_reduction(rowIndices3(i,1),1)/100*area(rowIndices3(i,1),1);
end

%%calculate the area of land use impact on each species
%for example: urban expansion impact on each species
Habitat_sus=[];
parentFolder = 'D:\36_Australia\mammals';
subFolders = dir(parentFolder);
subFolders = subFolders(3:length(subFolders),1);  %因为前两个读出来是空的，如果需要的话得再看看

for i = 1:length(subFolders)
    species = subFolders(i,1).name;
    %%read habitat suitbility data
    biodiversity_name = ['D:\36_Australia\mammals_mask\',species,'.tif'];
    biodiversity_species = readgeoraster(biodiversity_name);
    biodiversity_species = biodiversity_species(:);
    species_area=0;
    for j=1:length(rowIndices3)
        %revise the name here to change the land use impact
        species_area=species_area+urban_expansion(rowIndices3(j,1),1)/100*area(rowIndices3(j,1),1)*biodiversity_species(rowIndices3(j,1),1)/100;
    end
    Habitat_sus(i,1)=species_area;
end


