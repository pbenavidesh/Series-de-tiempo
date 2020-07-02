# ARIMA models examples
# Pablo Benavides-Herrera
# 2020-07-02
# pkgs --------------------------------------------------------------------

library(tidyverse)
library(tsibble)
library(feasts)
library(fable)
library(tsibbledata)
library(fpp3)


# electric equipment (season_adjust) --------------------------------------

elec_equip <- as_tsibble(fpp2::elecequip)

elec_dcmp <- elec_equip %>%
  model(STL(value ~ season(window="periodic"))) %>%
  components() %>%
  select(-.model) %>%
  as_tsibble()
elec_dcmp %>%
  autoplot(season_adjust)

elec_dcmp %>% 
  features(season_adjust, unitroot_kpss)

elec_dcmp %>% 
  features(difference(season_adjust), unitroot_kpss)

elec_dcmp %>% 
  features(season_adjust, unitroot_ndiffs)

elec_dcmp %>% 
  features(difference(season_adjust), unitroot_ndiffs)

elec_dcmp %>%
  gg_tsdisplay(difference(season_adjust), plot_type='partial')

elec_dcmp %>% 
  features(season_adjust, ljung_box, lag = 10, dof = 0)


fit <- elec_dcmp %>%
  model(
    arima310 = ARIMA(season_adjust ~ pdq(3,1,0) + PDQ(0,0,0)),
    arima410 = ARIMA(season_adjust ~ pdq(4,1,0) + PDQ(0,0,0)),
    arima210 = ARIMA(season_adjust ~ pdq(2,1,0) + PDQ(0,0,0)),
    arima311 = ARIMA(season_adjust ~ pdq(3,1,1) + PDQ(0,0,0)),
    arima211 = ARIMA(season_adjust ~ pdq(2,1,1) + PDQ(0,0,0)),
    arima111 = ARIMA(season_adjust ~ pdq(1,1,1) + PDQ(0,0,0)),
    arima_h = ARIMA(season_adjust ~ pdq(1:3,1,0:2) + PDQ(0,0,0))
  )

fit %>% select(arima_h) %>% report()

glance(fit) %>% arrange(AICc)

fit %>% select(arima311) %>% gg_tsresiduals()

fit %>% select(arima311) %>% report()

augment(fit) %>% 
  filter(.model %in% c("arima311","arima310","arima410")) %>% 
  features(.resid, ljung_box, lag = 10, dof = 4)


fit %>% select(arima311) %>% forecast() %>% autoplot(elec_dcmp)


# EU retail trade index ---------------------------------------------------

eu_retail <- as_tsibble(fpp2::euretail)
eu_retail %>% autoplot(value) + ylab("Retail index") + xlab("Year")

eu_retail

eu_retail %>% 
  features(value, unitroot_nsdiffs)

eu_retail %>% 
  features(difference(value, 4), unitroot_ndiffs)

eu_retail %>% 
  features(value %>% difference(4) %>% difference(1), unitroot_kpss)

fit <- eu_retail %>%
  model(arima011_011 = ARIMA(value ~ pdq(0,1,1) + PDQ(0,1,1)),
        arima111_111 = ARIMA(value ~ pdq(1,1,1) + PDQ(1,1,1)),
        arima_h = ARIMA(value ~ pdq(d=1) + PDQ(D=1))
        )

fit %>% select(arima_h) %>% report()

glance(fit) %>% arrange(AICc)

fit %>% select(arima_h) %>%  gg_tsresiduals()

augment(fit) %>% 
  features(.resid, ljung_box, lag = 8, dof = 4)

fit %>% select(arima_h) %>% forecast(h = 12) %>% 
  autoplot(eu_retail)

eu_retail %>% 
  model(ARIMA(value, stepwise = FALSE, approximation = FALSE)) %>% 
  report()


# H02 drug sales ----------------------------------------------------------

h02 <- PBS %>%
  filter(ATC2 == "H02") %>%
  summarise(Cost = sum(Cost)/1e6)
h02 %>%
  mutate(log(Cost)) %>%
  gather() %>%
  ggplot(aes(x = Month, y = value)) +
  geom_line() +
  facet_grid(key ~ ., scales = "free_y") +
  xlab("Year") + ylab("") +
  ggtitle("Cortecosteroid drug scripts (H02)")

h02

h02 %>% 
  features(log(Cost), unitroot_nsdiffs)

h02 %>% 
  features(log(Cost) %>% difference(12), unitroot_ndiffs)

h02 %>% gg_tsdisplay(log(Cost) %>% difference(12), 
                     plot_type='partial', lag_max = 24)

h02 %>% 
  gg_tsdisplay(log(Cost) %>% difference(12) %>% difference(1), 
                     plot_type='partial', lag_max = 24)

h02 %>% 
  model(ARIMA(log(Cost), stepwise = FALSE, 
              approximation = FALSE)) %>% 
  report()

h02_train <- h02 %>% 
  filter(year(Month) <= 2005)

fit <- h02_train %>% 
  model(SNAIVE = SNAIVE(log(Cost)),
        ETS = ETS(log(Cost)),
        `ARIMA(2,1,3)(0,1,1)` = ARIMA(log(Cost) ~ pdq(2,1,3) +
                                        PDQ(0,1,1))
        )

fc <- fit %>% forecast(h = 30)

fit %>% select(ETS) %>% report()

fc %>% autoplot(h02, level = NULL)
fc %>% autoplot(h02 %>% filter_index("2005 jan"~ .),level = NULL)

accuracy(fc,h02) %>% arrange(MAPE)

h02 %>% 
  model(`ARIMA(2,1,3)(0,1,1)` = ARIMA(log(Cost) ~ pdq(2,1,3) +
                                        PDQ(0,1,1))) %>% 
  forecast(h = 30) %>% autoplot(h02) +
  ggtitle("Pronóstico generado con un modelo ARIMA(2,1,3)(0,1,1)")

h02 %>% 
  model(SNAIVE = SNAIVE(log(Cost))) %>% 
  forecast(h = 30) %>% autoplot(h02) +
  ggtitle("Pronóstico generado con un modelo Ingenuo estacional")



