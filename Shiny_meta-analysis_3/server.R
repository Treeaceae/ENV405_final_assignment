library(shiny)
library(stats) # For power.t.test

# Helper function to ensure non-NULL values from input
`%||%` <- function(a, b) {
  if (is.null(a) || length(a) == 0 || is.na(a)) {
    b
  } else {
    a
  }
}

# --- 2. Server Logic ---
server <- function(input, output, session) {
  
  # --- 1. Parameter Aggregation ---
  
  # Aggregate all moderator parameters into a reactive list
  all_moderators <- reactive({
    list(
      list(label = input$mod_label_1 %||% "L1", beta = input$mod_beta_1 %||% 0, tau2 = input$mod_tau2_1 %||% 0),
      list(label = input$mod_label_2 %||% "L2", beta = input$mod_beta_2 %||% 0, tau2 = input$mod_tau2_2 %||% 0),
      list(label = input$mod_label_3 %||% "L3", beta = input$mod_beta_3 %||% 0, tau2 = input$mod_tau2_3 %||% 0)
    )
  })
  
  # --- 2. Dynamic UI ---
  
  # Dynamic generation of Tab 1 selection input (based on moderator names)
  output$prediction_selector_ui <- renderUI({
    mods <- all_moderators()
    labels <- sapply(mods, function(x) x$label)
    
    selectInput("selected_mod_level", "Select Level to Predict", 
                choices = labels, selected = labels[1])
  })
  
  # --- 3. Prediction Logic ---
  
  # Find parameters for selected level
  selected_mod_params <- reactive({
    req(input$selected_mod_level)
    mods <- all_moderators()
    
    for(mod in mods) {
      if (mod$label == input$selected_mod_level) {
        return(mod)
      }
    }
    return(mods[[1]]) # Default to first
  })
  
  # Calculate predicted g
  predicted_g <- reactive({
    (input$intercept_g %||% 0) + (selected_mod_params()$beta %||% 0)
  })
  
  # Get predicted tau2
  predicted_tau2 <- reactive({
    selected_mod_params()$tau2 %||% 0
  })
  
  # Tab 1: Output predicted values
  output$predicted_g_box <- renderText({ 
    paste(round(predicted_g(), 3))
  })
  
  output$predicted_tau2_box <- renderText({ 
    paste(round(predicted_tau2(), 3))
  })
  
  # Tab 1: Precision interpretation
  output$precision_interpretation <- renderUI({
    tau2_val <- predicted_tau2()
    
    precision_text <- if (tau2_val < 0.2) {
      paste0("<strong>High Precision:</strong> Predicted \\(\\tau^2\\) value of ", round(tau2_val, 3), " indicates high consistency in results.")
    } else if (tau2_val < 0.4) {
      paste0("<strong>Moderate Precision:</strong> Predicted \\(\\tau^2\\) value of ", round(tau2_val, 3), " suggests moderate variability.")
    } else {
      paste0("<strong>Low Precision:</strong> Predicted \\(\\tau^2\\) value of ", round(tau2_val, 3), " indicates substantial variability and high uncertainty in results.")
    }
    HTML(precision_text)
  })
  
  # --- 4. Power Analysis Logic ---
  
  required_n <- reactive({
    req(predicted_g(), input$desired_power, input$alpha_level)
    effect_size <- abs(predicted_g()) 
    if (effect_size < 0.01) return(Inf) 
    
    power_result <- tryCatch({
      power.t.test(
        n = NULL, delta = effect_size, sd = 1, 
        sig.level = (input$alpha_level %||% 0.05), 
        power = (input$desired_power %||% 0.8), 
        type = "two.sample", alternative = "two.sided"
      )
    }, error = function(e) { NULL })
    
    if(is.null(power_result)) return(NA)
    ceiling(power_result$n)
  })
  
  # Tab 2: Output required N
  output$required_n_box <- renderText({
    n_val <- required_n()
    g_val <- round(predicted_g(), 3)
    
    if(is.na(n_val)) { 
      "Calculation Error" 
    } else if (is.infinite(n_val)) { 
      "Effect Size Too Small" 
    } else { 
      paste(n_val, "(based on g =", g_val, ")") 
    }
  })
  
  # Tab 2: Output sample size recommendation
  output$n_recommendation <- renderUI({
    n_val <- required_n()
    tau2_val <- predicted_tau2()
    req(n_val, tau2_val)
    
    if (is.infinite(n_val)) { 
      return(HTML("<strong>Note:</strong> Predicted effect size is too small for meaningful power analysis.")) 
    }
    
    n_val <- as.numeric(n_val)
    
    if (tau2_val > 0.4) {
      adjusted_n <- ceiling(n_val * 1.3)
      advice <- paste0("<strong>🚨 High Heterogeneity Warning (\\(\\tau^2\\) > 0.4):</strong> Recommend increasing sample size by 30%.<br>",
                       "<strong>Recommended Adjusted N per Group ≈ ", adjusted_n, "</strong>")
    } else if (tau2_val > 0.2) {
      adjusted_n <- ceiling(n_val * 1.15)
      advice <- paste0("<strong>💡 Moderate Heterogeneity (\\(\\tau^2\\) > 0.2):</strong> Recommend increasing sample size by 15%.<br>",
                       "<strong>Recommended Adjusted N per Group ≈ ", adjusted_n, "</strong>")
    } else {
      advice <- paste0("<strong>✅ Low Heterogeneity:</strong> Proceed with calculated N = ", n_val, ".")
    }
    HTML(advice)
  })
}