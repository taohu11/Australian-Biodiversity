# 1. 导入必要的包 (新增了 scales 包用于百分比坐标轴)
library(readxl)
library(dplyr)
library(tidyr)
library(glmmTMB)
library(ggeffects)
library(ggplot2)
library(scales)

# 2. 导入与清洗数据
file_path <- "E:/36_Australia/1990.xlsx" 
sheet_names <- c("Amphibian", "Bird", "Mammal", "Reptile", "Plant")

data_list <- list()
for (sheet in sheet_names) {
  temp_df <- read_excel(file_path, sheet = sheet)
  temp_df$Taxa_Group <- sheet 
  data_list[[sheet]] <- temp_df
}
df_wide <- bind_rows(data_list)

df_long <- df_wide %>%
  pivot_longer(
    cols = c("Built-up land in 1990", "Cropland in 1990", "Grassland in 1990", "Forest in 1990"),
    names_to = "Land_Cover",
    values_to = "Exposure"
  ) %>%
  mutate(Land_Cover = gsub(" in 1990", "", Land_Cover))

df_long$Taxa_Group <- as.factor(df_long$Taxa_Group)
df_long$Land_Cover <- as.factor(df_long$Land_Cover)
df_long$Name <- as.factor(df_long$Name)

# ==========================================
# 🚨 关键修复区 🚨
# ==========================================
# 第一步：把 85.5 这种百分数除以 100，转为 0.855 这样的比例
df_long$Exposure <- df_long$Exposure / 100

# 第二步：极值微调。如果有刚好 100% 的数据（变为 1.0），微调为 0.9999 以防 Beta 模型报错。
# (等于 0 的数据会被模型的零膨胀机制自动完美处理，不需要改)
df_long$Exposure <- ifelse(df_long$Exposure >= 1, 0.9999, df_long$Exposure)

# ==========================================
# 3. 重新拟合模型
# ==========================================
fit_1990 <- glmmTMB(
  Exposure ~ Land_Cover * Taxa_Group + (1 | Name), 
  data = df_long,
  ziformula = ~ Land_Cover + Taxa_Group, 
  family = beta_family()
)

# ==========================================
# 4. 提取预测结果 (不重命名，保持原生结构)
# ==========================================
pred_df <- as.data.frame(
  predict_response(
    fit_1990,
    terms = c("Taxa_Group", "Land_Cover"), 
    bias_correction = TRUE
  )
)

# ==========================================
# 5. 绘制全新图表 (直接使用默认变量名 x 和 group)
# ==========================================
ggplot(pred_df, aes(x = x, y = predicted, color = x)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2, linewidth = 0.8) +
  facet_wrap(~ group, ncol = 2, scales = "free_y") + 
  scale_y_continuous(labels = scales::percent) + # ✨ Y轴自动转为百分比格式
  labs(
    title = "Baseline Exposure to Land Cover Types in 1990",
    x = "Taxonomic Group",
    y = "Predicted Exposure"
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10, face = "bold"),
    axis.title = element_text(size = 12, face = "bold"),
    strip.text = element_text(size = 11, face = "bold"),
    legend.position = "none",
    panel.grid.minor = element_blank()
  )