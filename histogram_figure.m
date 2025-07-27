clear
clc
% 示例数据
data_all = xlsread('D:\36_Australia\impact_built.xlsx',2);
data = data_all(:,5);
data = data(~isnan(data)); % 删除 NaN 值

% 定义区间边界（0 到 100，每 2% 一个区间）
edges = 0:0.5:100;

% 统计每个区间的数字数量
counts = histcounts(data, edges);

% 找到连续10个及以上为0的区间
minConsecutiveZeros = 10; % 最少连续为0的数量
isZero = counts == 0;
zeroRuns = regionprops(isZero, 'Area'); % 找连续区域长度
zeroLengths = [zeroRuns.Area];
longZeroIndices = find(zeroLengths >= minConsecutiveZeros); % 找到符合的区域

% 构造要保留的区间
keepIndices = true(size(counts)); % 默认全部保留
if ~isempty(longZeroIndices)
    zeroRegions = regionprops(isZero, 'PixelIdxList'); % 每个区域的索引
    for idx = longZeroIndices
        keepIndices(zeroRegions(idx).PixelIdxList) = false; % 将符合条件的区域移除
    end
end

% 保留非连续为0的区间和对应的横坐标
filteredCounts = counts(keepIndices);
filteredEdges = edges([keepIndices, true]); % 横坐标要多一个尾边界

% 可视化结果
figure;
bar(filteredEdges(1:end-1), filteredCounts, 'histc');

% 调整坐标轴刻度字体大小
ax = gca; % 获取当前坐标轴
ax.FontSize = 14; % 设置坐标轴刻度字体大小

% 修改横坐标显示为百分比
xticks(filteredEdges(1:end-1)); % 设置横坐标的刻度
xticklabels(arrayfun(@(x) sprintf('%d%%', x), filteredEdges(1:end-1), 'UniformOutput', false)); % 转换为百分比格式

% 在柱状图顶部显示数字
hold on; % 保持图形
xPositions = filteredEdges(1:end-1) + 1; % 柱的中心位置
for i = 1:length(filteredCounts)
    if filteredCounts(i) > 0 % 只显示非零值
        text(xPositions(i), filteredCounts(i), num2str(filteredCounts(i)), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
            'FontSize', 10, 'Color', 'k');
    end
end
hold off;

print('D:\36_Australia\Figures\histogram\Grass_to_forest_Amphibians', '-dpdf')