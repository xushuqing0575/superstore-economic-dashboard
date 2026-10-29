# Sales don't tell the whole story

### Superstore performance, in R + Tableau

I wanted to know where Superstore was selling well, and where those sales were actually turning into profit. I used R Shiny to bring in GDP, population and income, then built a Tableau dashboard to compare regions, monthly sales and products.

![Tableau dashboard](tableau-dashboard.png)

**West generated 31.6% of sales. Texas ranked third by sales, but lost $25,729.** That gap between revenue and profit became the main thread of the analysis.

- [Detailed analysis and charts](ANALYSIS.md)
- [Original ten-page report](analysis-report.pdf) · [Complete report text](REPORT_FULL_TEXT.md)
- [Download Tableau workbook with data](Superstore_R_Tableau.twbx?raw=true) · [Original saved .twb](tableau.twb)
- [Notebook](project.ipynb) · [Portfolio](https://xushuqing0575.github.io/#superstore)

## Run it

Open `Superstore_R_Tableau.twbx` in Tableau Public/Desktop. It includes the saved workbook and data. The original `tableau.twb` retains the paths from my Mac.

For R, open this repository as your working directory:

```r
install.packages(c("shiny", "tidyverse", "plotly", "scales", "readxl"))
shiny::runApp("app.R")
```

`app.R` uses the included `combined_state_year.csv`. Run `source("prepare_data.R")` to rebuild it from the four included source files. The preparation script is also preserved under its original filename, `xushuqing35051388.R`.

US transactions, 2011–2014. R adds state economic context; Tableau provides four complementary retail views. [Methods, sources and limitations →](ANALYSIS.md#data-and-methods)

Chloe Shuqing Xu
