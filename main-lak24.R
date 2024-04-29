library(tidyverse)
library(lme4)

source('lak24functions.R')

# Analysis data
d_analysis <- read_csv('d_analysis.csv')

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
sjPlot::tab_model(m1, file = "./rq1_results.html")

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

sjPlot::tab_model(m1, file = "./rq2_lrt_unigram_bigram.html")

# Comparing cycle features to in-the-moment features

d_tmp <- d_model %>% 
  select(outcome_next_bin, anon_student_id, process, plan,act,wrong, inout, n_unclosed_since, n_unclosed_since_inloop, cycle_count, cycles_per_attempt, attempts_per_cycle) %>% 
  drop_na()

m2 <- glmer(outcome_next_bin ~ (1|anon_student_id) + process+act+plan+wrong + inout + scale(attempts_per_cycle) + scale(n_unclosed_since_inloop), d_tmp, family='binomial')
m0 <- glmer(outcome_next_bin ~ (1|anon_student_id), d_tmp, family='binomial')
m1 <- glmer(outcome_next_bin ~ (1|anon_student_id) + process+act+plan+wrong, d_tmp, family='binomial')
anova(m0, m1, m2, test = 'Chisq')

sjPlot::tab_model(m2, file = "./rq2_lrt_cycle_moment_features.html")

# Collinearity check
car::vif(m2)
car::vif(m1)
