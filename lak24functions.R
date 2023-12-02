add_loop_variables <- function(d_analysis) {
  d_analysis <- d_analysis %>% 
    arrange(anon_student_id, time) 
  
  # Initialize check variables
  previous_student <- d_analysis$anon_student_id[1]
  previous_is_process <- d_analysis$process[1] == 'Yes'
  previous_is_plan <- d_analysis$plan[1] == 'Yes'
  previous_is_act <- d_analysis$act[1] == 'Yes'
  previous_is_wrong <- d_analysis$wrong[1] == 'Yes'
  current_process_loop <- FALSE
  current_plan_loop <- FALSE
  loop_just_closed <- FALSE
  out_of_loop <- FALSE
  n_unclosed_since <- 0
  n_unclosed_since_inloop <- 0
  # New variables
  d_analysis['out_of_loop'] <- NA
  d_analysis['ongoing_loop'] <- NA
  d_analysis['loop_just_ended'] <- NA
  d_analysis['state'] <- NA
  d_analysis['n_unclosed_since'] <- NA
  d_analysis['n_unclosed_since_inloop'] <- NA
  for (i in 1:nrow(d_analysis)){
    cat('row',i,'\n')
    current_student <- d_analysis$anon_student_id[i]
    current_is_process <- d_analysis$process[i] == 'Yes'
    current_is_plan <- d_analysis$plan[i] == 'Yes'
    current_is_act <- d_analysis$act[i] == 'Yes'
    current_is_wrong <- d_analysis$wrong[i] == 'Yes'
    if (current_student != previous_student) {
      previous_student <- current_student
      # Flush state vars
      current_process_loop <- FALSE
      current_plan_loop <- FALSE
      loop_just_closed <- FALSE
      out_of_loop <- FALSE
      last_closed_loop <- 0
      next
    }
    # Tag memory states
    # Start loop
    if (current_is_process & out_of_loop) { # Kick off new loop
      current_process_loop <- TRUE
      current_plan_loop <- FALSE
      out_of_loop <- FALSE
    }
    if (current_is_plan) {
      current_plan_loop <- TRUE
    }
    # Stop loop
    if (current_is_act & current_process_loop & current_plan_loop) {
      current_process_loop <- FALSE
      current_plan_loop <- FALSE
      out_of_loop <- FALSE
      loop_just_closed <- TRUE
    }
    if (!(current_process_loop) & !(loop_just_closed)) {
      out_of_loop <- TRUE
      loop_just_closed <- FALSE
      n_unclosed_since_inloop <- 0
    }
    # DF vars
    d_analysis$state[i] <- ifelse(loop_just_closed, 'just_closed', ifelse(current_process_loop, 'in_loop', ifelse(out_of_loop, 'out_of_loop', NA)))
    d_analysis$loop_just_ended[i] <- loop_just_closed
    d_analysis$out_of_loop[i] <- out_of_loop
    d_analysis$ongoing_loop[i] <- current_process_loop
    d_analysis$n_unclosed_since[i] <- n_unclosed_since
    d_analysis$n_unclosed_since_inloop[i] <- n_unclosed_since_inloop
    n_unclosed_since <- n_unclosed_since + 1
    n_unclosed_since_inloop <- n_unclosed_since_inloop + 1
    if (loop_just_closed) {
      loop_just_closed <- FALSE # Only state that needs to be forgotten each iteration
      n_unclosed_since <- 0
      n_unclosed_since_inloop <- 0
    }
    # State vars
    previous_is_process <- current_is_process
    previous_is_plan <- current_is_plan
    previous_is_act <- current_is_act
    previous_is_wrong <- current_is_wrong
  }
  
  # N completed cycles
  d_analysis <- d_analysis %>% 
    filter(!is.na(state)) %>%  # Removes three observations or so
    group_by(anon_student_id) %>% 
    mutate(
      cycle_count = cumsum(state == "just_closed"),
      attempt_id =  1:n()
    ) %>%
    ungroup() %>% 
    mutate(attempts_per_cycle = cycle_count/attempt_id) %>% 
    mutate(cycles_per_attempt = ifelse(cycle_count==0, 0, attempt_id/cycle_count)) %>% 
    mutate(inout = ifelse(state == 'out_of_loop', '1 out', '2 in'))
  
  # Check
  #d_analysis %>% select(anon_student_id, process, plan, act, wrong, ongoing_loop, loop_just_ended, out_of_loop, state) %>% View()
  return(d_analysis)
}

# Re-combining coded with log data
aggregate_data <- function(d_coded, d_tutor, df_utterance) {
  crosswalk <- list(
    'Stu_9a771c37547c1ce5bb0e3ccd2ffa890a' = 'user_1',
    'Stu_ef57d8fdab9d03a879b85fabdb5ce8c8' = 'user_2',
    'Stu_12784370c142151213cedf0d527455f9' = 'user_2',
    'Stu_b0e687db63e81cfbdd64f22804c5967d' = 'user_3',
    'Stu_651e714c97d469adf89a47bb73e81fdb' = 'user_4',
    'Stu_954e7ff89b99dedcd9aa613308a3b2ab' = 'user_5',
    'Stu_1279946571c2fb21a88d1f22340d6a21' = 'user_6',
    'Stu_a02379c766c89e55794be249dee8101a' = 'user_7',
    'Stu_eeea2cac9ae40df584566c798a0384e7' = 'user_8',
    'Stu_187d5dc77c2259af31b59badf210161b' = 'user_9',
    'Stu_6ae9d35793ea37302b302dee4b4d0c19' = 'user_10'
  )
  
  join_this <- data.frame(anon_student_id = names(crosswalk), user = unlist(crosswalk)) %>% tibble()
  
  d_tutor <- d_tutor %>%
    left_join(join_this, by='anon_student_id')
  
  # Utterance aggregation 
  df_utterance =
    df_utterance %>%
    fill(problem_id) %>%
    mutate(
      rowNumber = row_number(),
      instance = ifelse(selection_before == lag(selection_before),NA,rowNumber))
  
  df_utterance[c(1:4),19] = 1 #give values to the first 4 rows before running the while loop
  
  # Forward fill the missing values in df_utterance$instance
  df_utterance$instance <- zoo::na.locf(df_utterance$instance, na.rm = FALSE)
  
  df_utterance_combined =
    df_utterance %>%
    group_by(user,platform,problem_id,selection_before,input_before,feedback_before,instance) %>%
    summarise(utterance_combined = paste(unique(content), collapse = '/'),
              feedback_combined = paste(unique(feedback_before), collapse='##'),
              input_combined = paste(unique(input_before), collapse='##'),
              transaction_id_before_combined = paste(unique(transaction_id_before), collapse='#'),
              transaction_id_after_combined = paste(unique(transaction_id_after), collapse='#')) %>%
    arrange(user,platform,problem_id,instance) %>%
    filter(platform %in% c('Stoich', 'ORCCA')) %>%
    arrange(user, platform, problem_id, instance) %>%
    mutate(transaction_id_before = tail(strsplit(transaction_id_before_combined, '#')[[1]], 1))
  
  # Sorted equally, as aggregated equally -- re-merging data...
  d_coded['transaction_id_before'] <- df_utterance_combined$transaction_id_before
  
  d_join_code <- d_coded %>%
    select(transaction_id_before, utterance_combined, process, plan, act, wrong)
  
  # Join
  d_analysis <- d_tutor %>%
    left_join(d_join_code, by=c('transaction_id'='transaction_id_before')) %>%
    filter(!is.na(process))
  
  # Because the utterance is what comes after the transaction to which it was joined
  # NA if user is not the same or start of session
  d_analysis <- d_analysis %>%
    group_by(user) %>%
    mutate(outcome_next = lead(outcome)) %>%
    ungroup()
  
  d_analysis <- d_analysis %>%
    filter(!is.na(outcome_next)) %>%
    mutate(outcome_next_bin = case_when(
      outcome_next == 'CORRECT' ~ 1,
      TRUE ~ 0
    ))
  
  # Counts thus far
  d_analysis <- d_analysis %>% 
    arrange(anon_student_id, time) %>% 
    group_by(anon_student_id) %>% 
    mutate(process_count = cumsum(process == "Yes"),
           plan_count = cumsum(plan == "Yes"),
           act_count = cumsum(act == "Yes"),
           wrong_count = cumsum(wrong == "Yes")) %>%
    ungroup()
  
  #saveRDS(d_analysis, 'd_analysis.rds')
  return(d_analysis)
}

clean_codes <- function(d) {
  d <- d %>% 
    mutate(
      process = case_when(
        process %in% c('Yes', 'yes') ~ 'Yes',
        process %in% c('No', 'no') ~ 'No',
        is.na(process) ~ 'No',
        TRUE ~ 'No'
      ),
      plan = case_when(
        plan %in% c('Yes', 'yes') ~ 'Yes',
        plan %in% c('No', 'no') ~ 'No',
        is.na(plan) ~ 'No',
        TRUE ~ 'No'
      ),
      act = case_when(
        act %in% c('Yes', 'yes') ~ 'Yes',
        act %in% c('No', 'no') ~ 'No',
        is.na(act) ~ 'No',
        TRUE ~ 'No'
      ),
      wrong = case_when(
        wrong %in% c('Yes', 'yes') ~ 'Yes',
        wrong %in% c('No', 'no') ~ 'No',
        is.na(wrong) ~ 'No',
        TRUE ~ 'No'
      )
    )
  return(d)
}
