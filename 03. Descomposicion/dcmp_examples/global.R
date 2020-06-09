library(shiny)
library(tidyverse)
library(fable)
library(feasts)
library(tsibble)
library(tsibbledata)
library(shinythemes)
library(plotly)
library(fpp3)

glob_econ <- global_economy %>%
  rename(PIB = GDP) %>% 
  mutate(`PIB per cápita` = PIB / Population)


us_retail_employment <- us_employment %>%
  filter(year(Month) >= 1990, Title == "Retail Trade") %>%
  select(-Series_ID)