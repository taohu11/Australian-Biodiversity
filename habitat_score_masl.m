clear;
clc;
%%获得物种的列表
parentFolder = 'F:\TAO\Histrorical_impact\Quality_biodiversity\Reptiles\';
subFolders = dir(parentFolder);
subFolders = subFolders(3:length(subFolders),1);  %因为前两个读出来是空的，如果需要的话得再看看
% subFolders = subFolders(440:length(subFolders),1);  %因为前两个读出来是空的，如果需要的话得再看看

biodiversity_standard = readgeoraster('F:\TAO\Histrorical_impact\Acrobates_pygmaeus_historic_baseline_1990_AUS_5km_EnviroSuit.tif');
area = readgeoraster('F:\TAO\Histrorical_impact\Area\Acrobates_pygmaeus_area.tif');

for i = 1:length(subFolders)
    species = subFolders(i,1).name;
    %%read habitat suitbility data
    name_wenjianjia = ['F:\TAO\Histrorical_impact\Quality_biodiversity\Reptiles\'];
    biodiversity_name = ['F:\TAO\Histrorical_impact\Quality_biodiversity\Reptiles\',species];
    [biodiversity,R] = readgeoraster(biodiversity_name);
    info = geotiffinfo(biodiversity_name); %获取影像的具体信息
    biodiversity = single(biodiversity);
    biodiversity(biodiversity == 255) = 0;
    %%把边界值设成255
    Boundary_non=(biodiversity_standard == 255);
    quality_biodiversity=biodiversity./area*100;
    quality_biodiversity(Boundary_non)=NaN;
    %%输出tif
    geotiffwrite(['F:\TAO\Histrorical_impact\Habitat_score_mask\Reptiles\',species,'.tif'],quality_biodiversity,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
end