clear;
clc;
%%获得物种的列表
%Amphibians;Birds;Mammals;Reptiles;Plants
parentFolder = 'F:\TAO\Histrorical_impact\Quality_bili\Amphibians';
subFolders = dir(parentFolder);
subFolders = subFolders(3:length(subFolders),1);  %因为前两个读出来是空的，如果需要的话得再看看
%[landuse,R] = readgeoraster('F:\TAO\New_landuse\grass_to_forest.tif');
[landuse,R] = readgeoraster('F:\TAO\New_landuse\grass_to_built.tif');
% info = geotiffinfo('F:\TAO\New_landuse\builtup1990.tif'); %获取影像的具体信息
result=[];
for i = 1:length(subFolders)
    species = subFolders(i,1).name;
    %%read habitat suitbility data
    biodiversity_name = ['F:\TAO\Histrorical_impact\Quality_bili\Amphibians\',species];
    biodiversity = readgeoraster(biodiversity_name);
    impact=landuse.*biodiversity;
    sum_impact=nansum(impact(:));
    result(i,1)=sum_impact;
end