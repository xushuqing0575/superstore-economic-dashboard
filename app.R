# app.R

library(shiny)
library(tidyverse)
library(plotly)
library(scales)

combined <- read.csv("combined_state_year.csv", stringsAsFactors = FALSE)
combined <- combined %>%
  mutate(
    Year = as.numeric(Year),
    Profit_Margin = as.numeric(Profit_Margin),
    Sales_Per_Capita = as.numeric(Sales_Per_Capita),
    GDP_Million = as.numeric(GDP_Million),
    Population = as.numeric(Population),
    Income_Per_Capita = as.numeric(Income_Per_Capita)
  )
ui <- fluidPage(
  titlePanel("Superstore State Economic Performance Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      width = 2,
      selectInput("region", "Region",
                  choices = c("All", sort(unique(combined$Region)))),
      
      sliderInput("year", "Year Range",
                  min = min(combined$Year),
                  max = max(combined$Year),
                  value = c(min(combined$Year), max(combined$Year)),
                  step = 1,
                  sep = ""),
      
      selectInput("economic", "Economic Factor",
                  choices = c("GDP" = "GDP_Million",
                              "Population" = "Population",
                              "Income per Capita" = "Income_Per_Capita"))
    ),
    mainPanel(
      width = 10,
      fluidRow(
        column(4, h4("Total Sales"), textOutput("total_sales")),
        column(4, h4("Total Profit"), textOutput("total_profit")),
        column(4, h4("Profit Margin"), textOutput("overall_margin"))
      ),
      hr(),
      fluidRow(
        column(6,
               h4("Sales Composition by Region"),
               plotlyOutput("pie_region", height = "280px")
        ),
        column(6,
               h4("Sales vs Economic Factor"),
               plotlyOutput("scatter_economic", height = "280px")
        )
      ),
      
      fluidRow(
        column(6,
               h4("Profit Margin Distribution"),
               plotlyOutput("hist_margin", height = "280px")
        ),
        column(6,
               h4("Sales and Profit Trend"),
               plotlyOutput("line_trend", height = "280px")
        )
      ),
      
      fluidRow(
        column(12,
               h4("Top 10 States by Sales"),
               plotlyOutput("bar_state", height = "320px")
        )
      )
    )
  )
)

server <- function(input, output) {
  
  filtered_data <- reactive({
    data <- combined
    
    if (input$region != "All") {
      data <- data %>%
        filter(Region == input$region)
    }
    
    data <- data %>%
      filter(Year >= input$year[1],
             Year <= input$year[2])
    data
  })
  
  output$total_sales <- renderText({
    sales_total <- sum(filtered_data()$Sales, na.rm = TRUE)
    dollar(sales_total)
  })
  
  output$total_profit <- renderText({
    profit_total <- sum(filtered_data()$Profit, na.rm = TRUE)
    dollar(profit_total)
  })
  
  output$overall_margin <- renderText({
    margin <- sum(filtered_data()$Profit, na.rm = TRUE) /
      sum(filtered_data()$Sales, na.rm = TRUE)
    
    paste0(round(margin * 100, 1), "%")
  })
  
  output$pie_region <- renderPlotly({
    region_data <- filtered_data() %>%
      group_by(Region) %>%
      summarise(
        Sales = sum(Sales, na.rm = TRUE),
        GDP_Million = mean(GDP_Million, na.rm = TRUE),
        Population = mean(Population, na.rm = TRUE),
        Income_Per_Capita = mean(Income_Per_Capita, na.rm = TRUE),
        .groups = "drop"
      )
    
    plot_ly(
      data = region_data,
      labels = ~Region,
      values = ~Sales,
      type = "pie",
      textinfo = "label+percent",
      text = ~paste("Region:", Region,
                    "<br>Sales:", dollar(Sales),
                    "<br>Average GDP:", comma(round(GDP_Million, 0)),
                    "<br>Average Population:", comma(round(Population, 0)),
                    "<br>Average Income:", dollar(round(Income_Per_Capita, 0))),
      hoverinfo = "text"
    ) %>%
      layout(title = "")
  })
  
  output$scatter_economic <- renderPlotly({
    scatter_data <- filtered_data()
    scatter_data$Economic_Value <- scatter_data[[input$economic]]
    
    economic_label <- switch(input$economic,
                             GDP_Million = "GDP",
                             Population = "Population",
                             Income_Per_Capita = "Income per Capita")
    plot_ly(
      data = scatter_data,
      x = ~Economic_Value,
      y = ~Sales,
      type = "scatter",
      mode = "markers",
      text = ~paste("State:", State,
                    "<br>Year:", Year,
                    "<br>Region:", Region,
                    "<br>Sales:", dollar(Sales),
                    "<br>Profit:", dollar(Profit),
                    "<br>GDP:", comma(round(GDP_Million, 0)),
                    "<br>Population:", comma(round(Population, 0)),
                    "<br>Income:", dollar(round(Income_Per_Capita, 0))),
      hoverinfo = "text"
    ) %>%
      layout(
        xaxis = list(title = economic_label),
        yaxis = list(title = "Sales")
      )
  })
  output$hist_margin <- renderPlotly({
    margin_data <- filtered_data() %>%
      filter(!is.na(Profit_Margin))
    
    plot_ly(
      data = margin_data,
      x = ~Profit_Margin,
      type = "histogram",
      hovertemplate = "Profit Margin: %{x:.1%}<br>Count: %{y}<extra></extra>"
    ) %>%
      layout(
        xaxis = list(title = "Profit Margin", tickformat = ".0%"),
        yaxis = list(title = "Number of Records")
      )
  })
  output$line_trend <- renderPlotly({
    trend_data <- filtered_data() %>%
      group_by(Year) %>%
      summarise(
        Sales = sum(Sales, na.rm = TRUE),
        Profit = sum(Profit, na.rm = TRUE),
        GDP_Million = mean(GDP_Million, na.rm = TRUE),
        Population = mean(Population, na.rm = TRUE),
        Income_Per_Capita = mean(Income_Per_Capita, na.rm = TRUE),
        .groups = "drop"
      )
    plot_ly(data = trend_data, x = ~Year) %>%
      add_lines(
        y = ~Sales,
        name = "Sales",
        mode = "lines+markers",
        text = ~paste("Year:", Year,
                      "<br>Sales:", dollar(Sales),
                      "<br>Average GDP:", comma(round(GDP_Million, 0)),
                      "<br>Average Population:", comma(round(Population, 0)),
                      "<br>Average Income:", dollar(round(Income_Per_Capita, 0))),
        hoverinfo = "text"
      ) %>%
      add_lines(
        y = ~Profit,
        name = "Profit",
        mode = "lines+markers",
        text = ~paste("Year:", Year,
                      "<br>Profit:", dollar(Profit),
                      "<br>Average GDP:", comma(round(GDP_Million, 0)),
                      "<br>Average Population:", comma(round(Population, 0)),
                      "<br>Average Income:", dollar(round(Income_Per_Capita, 0))),
        hoverinfo = "text"
      ) %>%
      layout(
        xaxis = list(title = "Year", dtick = 1),
        yaxis = list(title = "Amount")
      )
  })
  
  output$bar_state <- renderPlotly({
    state_data <- filtered_data() %>%
      group_by(State) %>%
      summarise(
        Sales = sum(Sales, na.rm = TRUE),
        Profit = sum(Profit, na.rm = TRUE),
        GDP_Million = mean(GDP_Million, na.rm = TRUE),
        Population = mean(Population, na.rm = TRUE),
        Income_Per_Capita = mean(Income_Per_Capita, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(desc(Sales)) %>%
      head(10)
    
    state_data$State <- factor(state_data$State, levels = state_data$State)
    
    plot_ly(
      data = state_data,
      x = ~State,
      y = ~Sales,
      type = "bar",
      hovertext = ~paste("State:", State,
                         "<br>Sales:", dollar(Sales),
                         "<br>Profit:", dollar(Profit),
                         "<br>Average GDP:", comma(round(GDP_Million, 0)),
                         "<br>Average Population:", comma(round(Population, 0)),
                         "<br>Average Income:", dollar(round(Income_Per_Capita, 0))),
      hoverinfo = "text"
    ) %>%
      layout(
        xaxis = list(title = "State"),
        yaxis = list(title = "Sales"),
        margin = list(b = 90)
      )
  })
}

shinyApp(ui = ui, server = server)