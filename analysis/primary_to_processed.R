library(tidyverse) # munging
library(here) # for finding files
library(assertthat) # for testing

# specify the words in each vocabulary set
importance_elife <- c('useful','valuable','important','fundamental','landmark')
importance_alt <- c('very low importance','low importance','moderate importance','high importance','very high importance')
support_elife <- c('inadequate','incomplete','solid','convincing','compelling','exceptional')
support_alt <- c('very weak support','weak support','moderate support','strong support','very strong support')

# load the data
d <- read_csv(here('data','primary','data.csv'), show_col_types = FALSE)

# get number of participants
N <- nrow(d)

# pivot from wide to long format
d <- d %>% pivot_longer(cols = -c(id, duration, attention_check, education_level, education_level_other, subject_area, subject_area_other), # pivot all except these columns
                   names_to = "phrase", values_to = "response")

# test
## each participant responded to 21 phrases, so after we convert to long format there should be N*21 rows
assert_that(
  N*21 == nrow(d),
  msg = "Unexpected number of rows!"
)


# identify vocabularies and evaluative dimensions
d <- d %>%
  mutate(
    phrase = str_replace_all(phrase, "_signif", ""),
    phrase = str_replace_all(phrase, "_", " "),
    phrase = case_when(
      phrase == "exceptional support" ~ "exceptional",
      phrase == "compelling support" ~ "compelling",
      phrase == "convincing support" ~ "convincing",
      phrase == "solid support" ~ "solid",
      phrase == "incomplete support" ~ "incomplete",
      phrase == "inadequate support" ~ "inadequate",
      TRUE ~ phrase),
    vocab = case_when(
      phrase %in% importance_elife ~ "elife",
      phrase %in% support_elife ~ "elife",
      phrase %in% importance_alt ~ "alt",
      phrase %in% support_alt ~ "alt",
      TRUE ~ "ERROR"
    ),
    dimension = case_when(
      phrase %in% importance_elife ~ "importance",
      phrase %in% support_elife ~ "support",
      phrase %in% importance_alt ~ "importance",
      phrase %in% support_alt ~ "support",
      TRUE ~ "ERROR"
    )
  )

# test
## there should be no errors in the vocab or dimension columns
assert_that(
  any(d$vocab != "ERROR"),
  msg = "Vocab classification errors detected!"
)

assert_that(
  any(d$dimension != "ERROR"),
  msg = "Dimension classification errors detected!"
)

# set the order for factor levels
d <- d %>%
  mutate(phrase = factor(phrase, levels = c(support_alt,support_elife, importance_alt, importance_elife)))

# add intended ranks
d <- d %>% 
  group_by(id) %>%
  mutate(rank_intended = c(seq(5,1),seq(6,1),seq(5,1),seq(5,1))) %>% # add intended ranks
  ungroup()

# save the data
write_csv(d, here('data','processed','data.csv'))
