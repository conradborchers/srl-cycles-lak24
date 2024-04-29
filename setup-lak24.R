library(tidyverse)
library(lme4)
library(languageserver)

source('lak24functions.R')

# Coded data
d_coded <- read_csv('lak24-coded-utterances.csv')

# # Tutor logs
d_tutor <- read_delim('ds5371_tx_All_Data_7671.txt', delim='\t') %>%
  janitor::clean_names()

# Originally sampled utterances
df_utterance = read.csv("transcripts-with-logdata-reference-lak24.csv")

d_analysis <- aggregate_data(d_coded, d_tutor, df_utterance) %>%
  add_loop_variables()

write_csv(d_analysis, 'd_analysis.csv') # For analysis
