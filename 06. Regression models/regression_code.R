# pkgs --------------------------------------------------------------------

library(tidyverse)
library(tsibble)
library(feasts)
library(fable)
library(tsibbledata)
library(fpp3)
library(patchwork)


# Ex. 1 - US_change -------------------------------------------------------

# The data
us_change

# Time plots
time_plots <- us_change %>% 
  pivot_longer(cols = -Quarter) %>% 
  ggplot(aes(x = Quarter, y = value, color = name))+
  geom_line() + 
  facet_wrap(~ name, scales = "free_y") +
  theme(legend.position = "none")

# Pairs plot
pairs <- us_change %>% 
  as_tibble() %>% 
  select(-Quarter) %>% 
  GGally::ggpairs()

# Fitting the model
cons_fit <- us_change %>% 
  model(tslm = TSLM(Consumption ~ Income + Production + Savings +
                      Unemployment)) 

# Reporting the resulting model
# cons_fit %>% 
#   report()

# Actual data vs. fitted values time plot
cons_data_fit <- augment(cons_fit) %>%
  ggplot(aes(x = Quarter)) +
  geom_line(aes(y = Consumption, colour = "Data")) +
  geom_line(aes(y = .fitted, colour = "Fitted")) +
  xlab("Year") + ylab(NULL) +
  ggtitle("Percent change in US consumption expenditure") +
  guides(colour=guide_legend(title=NULL))

# Data vs. fitted scatterplot
cons_data_fit2 <- augment(cons_fit) %>%
  ggplot(aes(x=Consumption, y=.fitted)) +
  geom_point() +
  ylab("Fitted (predicted values)") +
  xlab("Data (actual values)") +
  ggtitle("Percent change in US consumption expenditure") +
  geom_abline(intercept=0, slope=1)

# Residual diagnostics
# cons_fit %>% 
#   gg_tsresiduals()

# Ljung-Box tests
cons_lb <- augment(cons_fit) %>% 
  features(.resid, ljung_box, lag = 10, dof = 5)

df <- left_join(us_change, residuals(cons_fit), by = "Quarter")
# Residual plots against predictors
cons_resid_predictors <- df %>% 
  select(-c(Consumption,.model)) %>% 
  pivot_longer(cols = c(Income:Unemployment)) %>% 
  ggplot(aes(x = value, y = .resid, color = name)) +
  geom_point() + ylab("Residuals") + xlab("Predictors") +
  facet_wrap(~ name, scales = "free_x") +
  theme(legend.position = "none")

# Residuals vs. fitted values
cons_resid_fitted <- augment(cons_fit) %>%
  ggplot(aes(x=.fitted, y=.resid)) +
  geom_point() +
  labs(x = "Fitted", y = "Residuals")


# Ex 2. Beer production ---------------------------------------------------

# The data
recent_production <- aus_production %>%
  filter(year(Quarter) >= 1992)
recent_production %>%
  autoplot(Beer) +
  labs(x = "Year", y = "Megalitres")

# Trend predictor
 # ~ trend()

# Seasonal dummies
 # ~ season()

# The model
fit_beer <- recent_production %>%
  model(TSLM(Beer ~ trend() + season()))
report(fit_beer)

# Data vs. fitted
augment(fit_beer) %>%
  ggplot(aes(x = Quarter)) +
  geom_line(aes(y = Beer, colour = "Data")) +
  geom_line(aes(y = .fitted, colour = "Fitted")) +
  labs(x = "Year", y = "Megalitres",
       title = "Quarterly Beer Production")

augment(fit_beer) %>%
  ggplot(aes(x = Beer, y = .fitted,
             colour = factor(quarter(Quarter)))) +
  geom_point() +
  ylab("Fitted") + xlab("Actual values") +
  ggtitle("Quarterly beer production") +
  scale_colour_brewer(palette="Dark2", name="Quarter") +
  geom_abline(intercept=0, slope=1)


# intervention variables --------------------------------------------------

# spike variable for one period
# 
# level shift for permanent effect
# 
# change of slope
# 
# Fourier series
# better than dummy variables for long seasonality.

fourier_beer <- recent_production %>%
  model(TSLM(Beer ~ trend() + fourier(K=2)))
report(fourier_beer)
# max(K) = m / 2


# Selecting predictors ----------------------------------------------------
# Significancia estadística no siempre indica el valor 
# predictivo de una variable

glance(cons_fit) %>% 
  select(adj_r_squared, CV, AIC, AICc, BIC)

# Best subset regression
# Stepwise
#An approach that works quite well is backwards stepwise 
#regression:

# * Start with the model containing all potential predictors.
# * Remove one predictor at a time. Keep the model if it 
# improves the measure of predictive accuracy.
# * Iterate until no further improvement.



# Forecasting -------------------------------------------------------------

# Ex-ante
# 
# solo se usa información disponible hasta el último dato en 'y'
# son pronósticos reales. Las predictoras se deben pronosticar.
# 
# Ex-post 
# 
# Se utiliza información real disponible posterior sobre las
# predictoras. La 'y' se desconoce.
# 
# Scenario based forecasting
# 
fit_consBest <- us_change %>%
  model(lm = TSLM(Consumption ~ Income + Savings + Unemployment))
up_future <- new_data(us_change, 4) %>%
  mutate(Income = 1, Savings = 0.5, Unemployment = 0)
down_future <- new_data(us_change, 4) %>%
  mutate(Income = -1, Savings = -0.5, Unemployment = 0)
fc_up <- forecast(fit_consBest, new_data = up_future) %>%
  mutate(Scenario = "Increase") %>%
  as_fable(response="Consumption", key = "Scenario")
fc_down <- forecast(fit_consBest, new_data = down_future) %>%
  mutate(Scenario = "Decrease") %>%
  as_fable(response="Consumption", key = "Scenario")

us_change %>%
  autoplot(Consumption) +
  autolayer(bind_rows(fc_up, fc_down)) +
  ylab("% change in US consumption")

# Se pueden utilizar valores rezagados de las predictoras
# para generar pronósticos ex-ante


# Regresiones no lineales -------------------------------------------------

# modelos log-log
# las betas se interpretan como elasticidades (cambios 
# porcentuales promedio en y, de un cambio de 1% en x)
# 
# log-lin, lin-log
# 
# 
# Regresión lineal por partes
# 

boston_men <- boston_marathon %>%
  filter(Event == "Men's open division") %>%
  mutate(Minutes = as.numeric(Time)/60)

fit_trends <- boston_men %>%
  model(
    linear = TSLM(Minutes ~ trend()),
    exponential = TSLM(log(Minutes) ~ trend()),
    piecewise = TSLM(Minutes ~ trend(knots = c(1940, 1980)))
  )
fc_trends <- fit_trends %>% forecast(h=10)

boston_men %>%
  autoplot(Minutes) +
  geom_line(aes(y=.fitted, colour=.model), data = fitted(fit_trends)) +
  autolayer(fc_trends, alpha = 0.5, level = 95) +
  xlab("Year") +  ylab("Winning times in minutes") +
  ggtitle("Boston Marathon") +
  guides(colour=guide_legend(title="Model"))
