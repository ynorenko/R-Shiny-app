library(dplyr)
library(data.table)
library(ggplot2)
library(plotly)
library(DT)
library(tools)
library(stringr)
library(rlang)
library(ggalt)
library(ggcorrplot)

# data 
data = data.table(read.csv('inpatientCharges.csv', stringsAsFactors = F))

#chart table 1
data_by_code_state = data %>% 
  select(DRG.Definition, Provider.State, Total.Discharges, Average.Total.Payments, Average.Covered.Charges, Average.Medicare.Payments) %>%
  group_by(DRG.Definition, Provider.State) %>% 
  summarise(total_discharges = sum(Total.Discharges), average_covered_charges = mean(Average.Covered.Charges),average_total_payment = mean(Average.Total.Payments), average_medicare_payments = mean(Average.Medicare.Payments))

procedure_codes = unique(data_by_code_state$DRG.Definition)

data_by_state = data_by_code_state %>%
  group_by(Provider.State) %>% 
  summarise(total_discharges = sum(total_discharges), average_covered_charges = round(mean(average_covered_charges),0), average_total_payment = round(mean(average_total_payment),0), average_medicare_payments = round(mean(average_medicare_payments),0))

data_by_state_1 = data_by_state %>%
  select(Provider.State, total_discharges, average_covered_charges, average_total_payment, average_medicare_payments) %>%
  setNames(c('Provider state', 'Total discharges', 'Average covered charges', 'Average total payments', 'Average Medicare payments'))
  
# help data for bar chart
data_by_code = data %>%
  select(DRG.Definition, Total.Discharges, Average.Total.Payments, Average.Covered.Charges, Average.Medicare.Payments) %>%
  group_by(DRG.Definition) %>%
  summarise(total_discharges=sum(Total.Discharges), average_covered_charges = round(mean(Average.Covered.Charges),0), average_total_payment = round(mean(Average.Total.Payments),0), average_medicare_payments = round(mean(Average.Medicare.Payments),0))

data_by_code_2 = data_by_code %>%
  select(DRG.Definition, total_discharges, average_covered_charges, average_total_payment, average_medicare_payments) %>%
  setNames(c('DRG definition', 'Total discharges', 'Average covered charges', 'Average total payments', 'Average Medicare payments'))

choice = colnames(select(data_by_code_2, 'Total discharges', 'Average total payments', 'Average Medicare payments', 'Average covered charges'))

#adding Medicare beneficiaries info 
pop_data = data.table(read.csv('population.csv', stringsAsFactors = F))

data_merge = data_by_code_state %>%
  group_by(Provider.State) %>%
  summarise(total_discharges = sum(total_discharges)) %>%
  merge(pop_data, by = 'Provider.State') %>%
  select(Provider.State, total_discharges, Total.Medicare.Beneficiaries) %>%
  mutate(Percent = round(((total_discharges/Total.Medicare.Beneficiaries)*100),0)) %>%
  arrange(desc(Percent))

#data by diagnosis
choices = sort(c(as.character(data_merge$Provider.State)))
Diagnosis = data_by_code$DRG.Definition

#correlations
c_data = data %>%
  select(Total.Discharges, Average.Total.Payments, Average.Covered.Charges, Average.Medicare.Payments) %>%
  setNames(c('Total discharges', 'Average total payments','Average covered charges', 'Average Medicare payments'))







