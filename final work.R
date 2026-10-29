library(readxl)
library(dplyr)
library(tidyr)

clean_number <- function(value) {
  as.numeric(gsub(",", "", as.character(value)))
}
clean_state <- function(state_name) {
  state_name <- as.character(state_name)
  state_name <- gsub(" \\*", "", state_name)
  state_name <- gsub("\\*", "", state_name)
  state_name
}
superstore <- read_excel("superstore.xlsx")
superstore <- superstore %>%
  filter(Country == "United States",
         Year >= 2011,
         Year <= 2014)
superstore_summary <- superstore %>%
  group_by(State, Year, Region) %>%
  summarise(
    Sales = sum(Sales, na.rm = TRUE),
    Profit = sum(Profit, na.rm = TRUE),
    Quantity = sum(Quantity, na.rm = TRUE),
    Orders = length(unique(Order.ID)),
    Avg_Discount = mean(Discount, na.rm = TRUE),
    Shipping_Cost = sum(Shipping.Cost, na.rm = TRUE)
  ) %>%
  ungroup()
state_list <- unique(superstore_summary$State)
gdp_raw <- read_excel("GDP.xlsx", skip = 5)
gdp <- gdp_raw %>%
  mutate(State = clean_state(GeoName)) %>%
  filter(State %in% state_list) %>%
  select(State, `2011`, `2012`, `2013`, `2014`) %>%
  pivot_longer(
    cols = c(`2011`, `2012`, `2013`, `2014`),
    names_to = "Year",
    values_to = "GDP_Million"
  ) %>%
  mutate(
    Year = as.numeric(Year),
    GDP_Million = clean_number(GDP_Million)
  )
population_raw <- read.csv("population.tsv",
                           sep = "\t",
                           check.names = FALSE)
population <- population_raw %>%
  mutate(State = clean_state(State)) %>%
  filter(State %in% state_list) %>%
  select(State, `2011`, `2012`, `2013`, `2014`) %>%
  pivot_longer(
    cols = c(`2011`, `2012`, `2013`, `2014`),
    names_to = "Year",
    values_to = "Population"
  ) %>%
  mutate(
    Year = as.numeric(Year),
    Population = clean_number(Population)
  )
income_raw <- read_excel("income.xlsx", skip = 5)
income <- income_raw %>%
  mutate(State = clean_state(GeoName)) %>%
  filter(State %in% state_list) %>%
  select(State, `2011`, `2012`, `2013`, `2014`) %>%
  pivot_longer(
    cols = c(`2011`, `2012`, `2013`, `2014`),
    names_to = "Year",
    values_to = "Income_Per_Capita"
  ) %>%
  mutate(
    Year = as.numeric(Year),
    Income_Per_Capita = clean_number(Income_Per_Capita)
  )
combined <- superstore_summary %>%
  left_join(gdp, by = c("State", "Year")) %>%
  left_join(population, by = c("State", "Year")) %>%
  left_join(income, by = c("State", "Year"))
combined <- combined %>%
  mutate(
    Profit_Margin = Profit / Sales,
    Sales_Per_Capita = Sales / Population,
    Profit_Per_Capita = Profit / Population,
    GDP_Dollars = GDP_Million * 1000000,
    Sales_to_GDP = Sales / GDP_Dollars
  )
colSums(is.na(combined))
write.csv(superstore, "clean_superstore.csv", row.names = FALSE)
write.csv(combined, "combined_state_year.csv", row.names = FALSE)
head(combined)
