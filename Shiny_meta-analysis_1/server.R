# Basic server, regardless of the research topic

# LOAD REQUIRED LIBRARIES
library(shiny)
library(meta)     # For all meta-analysis functions
library(readxl)   # For reading .xlsx files
library(DT)       # For renderDataTable

# DEFINE THE SERVER LOGIC
function(input, output, session) {
  
  # *Reactive: Load Data
  loaded_data <- reactive({
    req(input$file1)
    
    inFile <- input$file1
    
    # Get file extension
    ext <- tools::file_ext(inFile$name)
    
    # Read file based on extension
    df <- switch(ext,
                 "csv" = read.csv(inFile$datapath,
                                  header = input$header,
                                  sep = input$sep),
                 "xls" = read_excel(inFile$datapath),
                 "xlsx" = read_excel(inFile$datapath),
                 stop("Invalid file type. Please upload a .csv or .xlsx file.")
    )
    
    return(df)
  })
  
  # *Output: File Type
  output$fileType <- reactive({
    req(input$file1)
    tools::file_ext(input$file1$name)
  })
  outputOptions(output, "fileType", suspendWhenHidden = FALSE)
  
  # *Output: Data Preview Table 
  output$contents <- DT::renderDataTable({
    df <- loaded_data()
    DT::datatable(df, options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
  })
  
  # *Output: Dynamic UI for Data Mapping
  output$dataMappingControls <- renderUI({
    req(loaded_data())
    col_names <- colnames(loaded_data())
    
    if (input$dataType == "binary") {
      tagList(
        selectInput("study_col", "Study/Author Column:", col_names, selected = col_names[1]),
        selectInput("e1_col", "Events (Group 1 / Exposed):", col_names, selected = col_names[2]),
        selectInput("n1_col", "Total N (Group 1 / Exposed):", col_names, selected = col_names[3]),
        selectInput("e2_col", "Events (Group 2 / Control):", col_names, selected = col_names[4]),
        selectInput("n2_col", "Total N (Group 2 / Control):", col_names, selected = col_names[5])
      )
    } else if (input$dataType == "continuous") {
      tagList(
        selectInput("study_col", "Study/Author Column:", col_names, selected = col_names[1]),
        selectInput("n1_col", "N (Group 1 / Exposed):", col_names, selected = col_names[2]),
        selectInput("m1_col", "Mean (Group 1 / Exposed):", col_names, selected = col_names[3]),
        selectInput("sd1_col", "SD (Group 1 / Exposed):", col_names, selected = col_names[4]),
        selectInput("n2_col", "N (Group 2 / Control):", col_names, selected = col_names[5]),
        selectInput("m2_col", "Mean (Group 2 / Control):", col_names, selected = col_names[6]),
        selectInput("sd2_col", "SD (Group 2 / Control):", col_names, selected = col_names[7])
      )
    }
  })
  
  # *Output: Dynamic UI for Effect Measure
  output$measureControls <- renderUI({
    if (input$dataType == "binary") {
      selectInput("measure", "Effect Measure",
                  choices = c("Odds Ratio" = "OR",
                              "Risk Ratio" = "RR",
                              "Risk Difference" = "RD"),
                  selected = "OR")
    } else if (input$dataType == "continuous") {
      selectInput("measure", "Effect Measure",
                  choices = c("Mean Difference" = "MD",
                              "Standardized Mean Difference (Hedges' g)" = "SMD"),
                  selected = "MD")
    }
  })
  
  # *Reactive: Run Analysis
  meta_results <- eventReactive(input$runAnalysis, {
    withProgress(message = 'Running Meta-Analysis...', value = 0.5, {
      df <- loaded_data()
      
      tryCatch({
        if (input$dataType == "binary") {
          e1 <- as.numeric(df[[input$e1_col]])
          n1 <- as.numeric(df[[input$n1_col]])
          e2 <- as.numeric(df[[input$e2_col]])
          n2 <- as.numeric(df[[input$n2_col]])
          studlab <- df[[input$study_col]]
          
          m <- metabin(event.e = e1,
                       n.e = n1,
                       event.c = e2,
                       n.c = n2,
                       studlab = studlab,
                       sm = input$measure,
                       comb.fixed = (input$model == "fixed"),
                       comb.random = (input$model == "random"),
                       method.tau = input$method,
                       hakn = (input$method == "HK"))
        } else if (input$dataType == "continuous") {
          n1 <- as.numeric(df[[input$n1_col]])
          m1 <- as.numeric(df[[input$m1_col]])
          sd1 <- as.numeric(df[[input$sd1_col]])
          n2 <- as.numeric(df[[input$n2_col]])
          m2 <- as.numeric(df[[input$m2_col]])
          sd2 <- as.numeric(df[[input$sd2_col]])
          studlab <- df[[input$study_col]]
          
          m <- metacont(n.e = n1,
                        mean.e = m1,
                        sd.e = sd1,
                        n.c = n2,
                        mean.c = m2,
                        sd.c = sd2,
                        studlab = studlab,
                        sm = input$measure,
                        comb.fixed = (input$model == "fixed"),
                        comb.random = (input$model == "random"),
                        method.tau = input$method,
                        hakn = (input$method == "HK"))
        }
        
        incProgress(1, detail = "Done.")
        return(m)
        
      }, error = function(e) {
        showModal(modalDialog(
          title = "Analysis Error",
          paste("An error occurred. Please check your data and column mappings.",
                "Common errors include:",
                "\n- Mapping a non-numeric column (e.g., text) to a numeric input (e.g., 'Events' or 'Mean').",
                "\n- Having missing values (NA) in your data.",
                "\n\nError details: ", e$message),
          easyClose = TRUE,
          footer = NULL
        ))
        return(NULL)
      })
    })
  })
  
  # *Output: Summary Text
  output$summary <- renderPrint({
    m <- meta_results()
    req(m)
    summary(m)
  })
  
  # *Output: Forest Plot
  output$forestPlot <- renderPlot({
    m <- meta_results()
    req(m)
    forest(m,
           cex = 1,
           cex.studlab = 1,
           cex.summary = 1.2)
  })
  
  # *Output: Funnel Plot
  output$funnelPlot <- renderPlot({
    m <- meta_results()
    req(m)
    funnel(m)
  })
}