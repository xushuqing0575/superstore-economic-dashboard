# Superstore Economic Performance Dashboard

[Open the notebook portfolio](https://xushuqing0575.github.io/#superstore)

I wanted to look beyond which region sold the most. This dashboard puts Superstore sales next to population, GDP and income so those differences are easier to investigate.

## What I built

An R Shiny dashboard with region and year filters, a choice of economic indicator, sales and profit totals, regional sales composition, profit-margin distributions, trends and a ranking of the ten highest-selling states.

The preparation script filters US transactions to 2011–2014, groups retail records by state, year and region, reshapes the external spreadsheets and joins them using state and year. It derives profit margin and sales per capita for comparisons.

## A few things the data shows

The supplied 181 state-year records give the West approximately 31.6% of total sales. A high sales total does not necessarily imply healthy profit: the dashboard lets readers inspect that difference rather than ranking every market by sales alone. These are descriptive comparisons, not estimates of a causal economic effect.

## Run the dashboard

Install R, then run the following from this directory:

```r
install.packages(c("shiny", "tidyverse", "plotly", "scales"))
shiny::runApp("app.R")
```

`app.R` loads `combined_state_year.csv` from its working directory. `prepare_data.R` records the original preparation workflow and additionally requires `readxl` and the raw files listed below.

## Data sources and provenance

The local preparation script reads `superstore.xlsx`, `GDP.xlsx`, `population.tsv` and `income.xlsx`. State names and year formats must match before joining. Raw source datasets are not bundled here.

These are the Kaggle links I supplied while documenting the project:

- [US Census State Population Estimates 2010–2019](https://www.kaggle.com/datasets/kbrookshier/us-census-state-population-estimates-20102019)
- [USA Census Income Data](https://www.kaggle.com/datasets/manishkc06/usa-census-income-data)
- [Poverty-Level Wages in the USA 1973–2022](https://www.kaggle.com/datasets/asaniczka/poverty-level-wages-in-the-usa-dataset-1973-2022)
- [Incomes of 30K USA Citizens](https://www.kaggle.com/datasets/jacopoferretti/incomes-of-30k-usa-citizens)

The code confirms the four local input filenames above, but does not record a URL-to-file mapping. The links are documented as supplied references; this repository does not claim that all four Kaggle datasets feed the dashboard. In particular, individual-level income records cannot be treated as state-year per-capita income without an explicit aggregation step. The original GDP and income spreadsheet download URLs remain unverified.

## Files

- `app.R` — original interactive dashboard
- `prepare_data.R` — original data preparation script
- `combined_state_year.csv` — aggregated data consumed by the dashboard
- `project.ipynb` — portfolio overview

## Limits

Missing matches, different geographic coverage and inconsistent measurement years can affect comparisons. Inspect joined rows before interpreting state differences. The browser portfolio is a presentation of the project; the R Shiny app is the original analysis interface.


---
Chloe Shuqing Xu · [GitHub](https://github.com/xushuqing0575)
