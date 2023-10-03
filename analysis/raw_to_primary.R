# loads the raw data from Qualtrics and converts it to the primary data

library(tidyverse) # munging
library(here) # for finding files

# load the data
d <- read_csv(here('data','raw','eLife assessments live_September 15, 2023_06.07.csv'), show_col_types = FALSE)

# remove the first and second rows (meta-data)
d <- d %>% slice(-1, -2)

# create an id column
d <- d %>%
  mutate(id = 1:n())

# select relevant columns and rename
d <- d %>%
  select(id,Duration = `Duration (in seconds)`,attention_check_1,
         landmark_signif_1, fundamental_signif_1, important_signif_1, valuable_signif_1, useful_signif_1, 
         exceptional_support_1, compelling_support_1, convincing_support_1, solid_support_1, incomplete_support_1, inadequate_support_1,
         very_high_importance_1, high_importance_1, moderate_importance_1, low_importance_1, very_low_importance_1, 
         very_strong_support_1, strong_support_1, moderate_support_1, weak_support_1, very_weak_support_1,
         education_level, education_level_other = education_level_4_TEXT, subject_area, subject_area_other = subject_area_5_TEXT) %>%
  rename_all(~str_to_lower(str_replace_all(., "_1", ""))) # Remove "_1" from column names and make lower case

# save the primary data
write_csv(d, here('data','primary','data.csv'))

