clear;
clc;
parentFolder = 'F:\TAO\Histrorical_impact\Quality_biodiversity\Plants';
subFolders = dir(parentFolder);
subFolders = subFolders(3:length(subFolders),1);  %因为前两个读出来是空的，如果需要的话得再看看
for i = 1:length(subFolders)
    species = subFolders(i,1).name;
    %%read habitat suitbility data
    biodiversity_name = ['F:\TAO\Histrorical_impact\Quality_biodiversity\Plants\',species];
    [biodiversity,R] = readgeoraster(biodiversity_name);
    info = geotiffinfo(biodiversity_name); %获取影像的具体信息
    sum=nansum(biodiversity(:));
    bili=(biodiversity/sum)*100;
    %%输出tif
    geotiffwrite(['F:\TAO\Histrorical_impact\Quality_bili\Plants\',species,'.tif'],bili,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
end

% image=imread('F:\TAO\Histrorical_impact\Quality_bili\Reptiles\Anomalopus_gowi.tif.tif');
% sum=nansum(image(:));
