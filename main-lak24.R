library(tidyverse)
library(lme4)

source('lak24functions.R')

# Coded data
d_coded <- read_csv('lak24-coded-utterances.csv')

# # Tutor logs
d_tutor <- read_delim('ds5371_tx_All_Data_7671_2023_0520_042939.txt', delim='\t') %>%
  janitor::clean_names()

# Originally sampled utterances
df_utterance = read.csv("transcripts-with-logdata-reference-lak24.csv")

d_analysis <- aggregate_data(d_coded, d_tutor, df_utterance) %>%
  add_loop_variables()

write_csv(d_analysis, 'd_analysis.csv') # for RQ3 analysis in Python

# RQ1

tab <- xtabs(~outcome_next_bin+process, d_analysis)
tab; chisq.test(tab)
tab <- xtabs(~outcome_next_bin+plan, d_analysis)
tab; chisq.test(tab)
tab <- xtabs(~outcome_next_bin+act, d_analysis)
tab; chisq.test(tab)
tab <- xtabs(~outcome_next_bin+wrong, d_analysis)
tab; chisq.test(tab)

d_model <- d_analysis

sum(d_model$process=='No' & d_model$plan=='No' & d_model$act=='No' & d_model$wrong=='No')

m1 <- glmer(outcome_next_bin ~ (1|anon_student_id) + process+act+plan+wrong, d_model, family='binomial')
sjPlot::tab_model(m1)

# RQ2
# Simple LRT test unigram vs. bigram

d_tmp <- d_model %>% 
  select(outcome_next_bin, anon_student_id, process, plan,act,wrong) %>% 
  mutate(
    lp = lag(process, 1), la = lag(act, 1), lp = lag(plan, 1), lw = lag(wrong, 1)
  ) %>% 
  drop_na()
m2 <- glmer(outcome_next_bin ~ (1|anon_student_id) + process+act+plan+wrong + lp+la+lp+lw, d_tmp, family='binomial')
m0 <- glmer(outcome_next_bin ~ (1|anon_student_id), d_tmp, family='binomial')
m1 <- glmer(outcome_next_bin ~ (1|anon_student_id) + process+act+plan+wrong, d_tmp, family='binomial')
anova(m0, m1, m2, test = 'Chisq')

sjPlot::tab_model(m1)

# Comparing cycle features to in-the-moment features

d_tmp <- d_model %>% 
  select(outcome_next_bin, anon_student_id, process, plan,act,wrong, inout, n_unclosed_since, n_unclosed_since_inloop, cycle_count, cycles_per_attempt, attempts_per_cycle) %>% 
  drop_na()

m2 <- glmer(outcome_next_bin ~ (1|anon_student_id) + process+act+plan+wrong + inout + scale(attempts_per_cycle) + scale(n_unclosed_since_inloop), d_tmp, family='binomial')
m0 <- glmer(outcome_next_bin ~ (1|anon_student_id), d_tmp, family='binomial')
m1 <- glmer(outcome_next_bin ~ (1|anon_student_id) + process+act+plan+wrong, d_tmp, family='binomial')
anova(m0, m1, m2, test = 'Chisq')

sjPlot::tab_model(m2)

# Collinearity check
car::vif(m2)
car::vif(m1)

# RQ3 BH adjustment (Run RQ3 python notebook first)
ans_sorted <- read_csv("ans_sorted.csv")
ans_sorted

alpha.correction.bh::get_alphas_bh(ans_sorted$p, Q=0.1)
