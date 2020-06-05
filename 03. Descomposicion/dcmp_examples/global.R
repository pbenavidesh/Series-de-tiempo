library(shiny)
library(tidyverse)
library(fable)
library(feasts)
library(tsibble)
library(tsibbledata)
library(shinythemes)
library(plotly)

glob_econ <- global_economy %>%
  rename(PIB = GDP) %>% 
  mutate(`PIB per cápita` = PIB / Population)