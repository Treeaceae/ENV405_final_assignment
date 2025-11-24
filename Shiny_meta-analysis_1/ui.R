# Basic UI interface, regardless of the research topic

# LOAD REQUIRED LIBRARIES
library(shiny)
library(shinythemes)
library(DT)

# DEFINE THE USER INTERFACE (UI)
fluidPage(
  theme = shinytheme("flatly"),
  
  titlePanel("Interactive Meta-Analysis App"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      tags$h4("1. Upload Your Data"),
      
      fileInput("file1", "Choose .csv or .xlsx File",
                multiple = FALSE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv",
                           ".xls",
                           ".xlsx")),
      
      conditionalPanel(
        condition = "output.fileType == 'csv'",
        checkboxInput("header", "Data has Header?", TRUE),
        radioButtons("sep", "Separator",
                     choices = c(Comma = ",",
                                 Semicolon = ";",
                                 Tab = "\t"),
                     selected = ",")
      ),
      
      tags$hr(),
      
      tags$h4("2. Define Analysis"),
      
      radioButtons("dataType", "Select Data Type:",
                   choices = c("Binary (Events / N)" = "binary",
                               "Continuous (Mean / SD / N)" = "continuous"),
                   selected = "binary"),
      
      tags$p(strong("Map your data columns:")),
      uiOutput("dataMappingControls"),
      
      tags$hr(),
      
      tags$h4("3. Set Model Parameters"),
      
      uiOutput("measureControls"),
      
      radioButtons("model", "Model Type",
                   choices = c("Random effects" = "random",
                               "Fixed effect" = "fixed"),
                   selected = "random"),
      
      selectInput("method", "Random Effects Method (if random)",
                  choices = c("DerSimonian-Laird" = "DL",
                              "REML (recommended)" = "REML",
                              "Paule-Mandel" = "PM",
                              "Hartung-Knapp" = "HK"),
                  selected = "REML"),
      
      tags$hr(),
      
      actionButton("runAnalysis", "Run Meta-Analysis", class = "btn-primary btn-lg btn-block")
    ),
    
    mainPanel(
      width = 9,
      tabsetPanel(
        type = "tabs",
        
        tabPanel(
          "Data Preview",
          icon = icon("table"),
          h4("Uploaded Data Preview"),
          p("Please check to ensure your data loaded correctly before running the analysis."),
          DT::dataTableOutput("contents")
        ),
        
        tabPanel(
          "Summary Results",
          icon = icon("file-alt"),
          h4("Meta-Analysis Summary"),
          verbatimTextOutput("summary")
        ),
        
        tabPanel(
          "Forest Plot",
          icon = icon("tree"),
          h4("Forest Plot"),
          p("The diamond represents the pooled effect estimate."),
          plotOutput("forestPlot", height = "800px")
        ),
        
        tabPanel(
          "Funnel Plot",
          icon = icon("chart-funnel"),
          h4("Funnel Plot (Publication Bias)"),
          p("Asymmetry in this plot can suggest publication bias or other heterogeneity."),
          plotOutput("funnelPlot", height = "600px")
        )
      )
    )
  )
)