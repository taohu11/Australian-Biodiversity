# ==========================================
# 1. 导入必要的包 
# ==========================================
library(readxl)
library(dplyr)
library(tidyr)
library(glmmTMB)
library(ggplot2)
library(scales)
library(emmeans)
library(multcomp)

# ==========================================
# 2. 导入与清洗数据
# ==========================================
# ⚠️ 注意：请确保此处的文件名是你最新的 1990-2020 数据文件
file_path <- "E:/36_Australia/1990_2020.xlsx" 
sheet_names <- c("Amphibian", "Bird", "Mammal", "Reptile", "Plant")

data_list <- list()
for (sheet in sheet_names) {
  temp_df <- read_excel(file_path, sheet = sheet)
  temp_df$Taxa_Group <- sheet 
  data_list[[sheet]] <- temp_df
}
df_wide <- bind_rows(data_list)

# ✨ 核心修改 1：换成 6 种新的土地转变类型列名，并将变量名改为 Transition
df_long <- df_wide %>%
  pivot_longer(
    cols = c("Forest to cropland", "Forest to grassland", "Cropland to forest", 
             "Forest to built-up land", "Grassland to built-up land", "Grassland to forest"),
    names_to = "Transition",
    values_to = "Exposure"
  )

df_long$Taxa_Group <- as.factor(df_long$Taxa_Group)
df_long$Transition <- as.factor(df_long$Transition)
df_long$Name <- as.factor(df_long$Name)

# 把百分数除以 100，并处理极值
df_long$Exposure <- df_long$Exposure / 100
df_long$Exposure <- ifelse(df_long$Exposure >= 1, 0.9999, df_long$Exposure)

# ==========================================
# 3. 拟合零膨胀贝塔混合效应模型 (GLMM)
# ==========================================
# ✨ 核心修改 2：公式中的 Land_Cover 替换为 Transition
fit_transition <- glmmTMB(
  Exposure ~ Transition * Taxa_Group + (1 | Name), 
  data = df_long,
  ziformula = ~ Transition + Taxa_Group, 
  family = beta_family()
)

# ==========================================
# 4. 计算事后多重比较 (生成显著性字母 a, b, c)
# ==========================================
# 按 Transition 分组比较 Taxa_Group
emm_results <- emmeans(fit_transition, ~ Taxa_Group | Transition, type = "response")

# 使用 sidak 校正生成字母
cld_results <- cld(emm_results, alpha = 0.05, Letters = letters, adjust = "sidak")
cld_results <- as.data.frame(cld_results)
cld_results$.group <- trimws(cld_results$.group) 

colnames(cld_results)[which(names(cld_results) %in% c("response", "prob"))] <- "predicted"
colnames(cld_results)[which(names(cld_results) == "asymp.LCL")] <- "conf.low"
colnames(cld_results)[which(names(cld_results) == "asymp.UCL")] <- "conf.high"

# ==========================================
# 5. 绘制带有显著性字母的最终图表
# ==========================================
ggplot(cld_results, aes(x = Taxa_Group, y = predicted, color = Taxa_Group)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2, linewidth = 0.8) +
  geom_text(
    aes(y = conf.high, label = .group), 
    vjust = -0.8,      
    size = 4.5, 
    color = "black",   
    fontface = "bold"
  ) +
  # ✨ 核心修改 3：按照 6 种转变类型进行分面，设为 3 列排版更好看
  facet_wrap(~ Transition, ncol = 3, scales = "free_y") + 
  scale_y_continuous(
    labels = scales::percent, 
    expand = expansion(mult = c(0.1, 0.15)) 
  ) + 
  labs(
    title = "Exposure to Land Cover Transitions (1990-2020)",
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