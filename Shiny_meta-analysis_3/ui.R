library(shiny)

# --- 1. User Interface (UI) ---
# Add MathJax for LaTeX rendering
header = tags$head(
  tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.7/MathJax.js?config=TeX-MML-AM_CHTML")
),

ui <- navbarPage(
  title = "Universal Meta-Analysis Predictor",
  
  # --- Tab 1: Setup & Prediction ---
  tabPanel("1. Setup & Prediction",
           icon = icon("gears"),
           sidebarLayout(
             # --- Sidebar: All Parameter Inputs ---
             sidebarPanel(
               width = 4,
               h4("1. Baseline Parameters"),
               numericInput("intercept_g", "Global Intercept (Beta 0)", value = 0.5),
               
               hr(),
               h4("2. Moderator Levels (Max 3)"),
               
               # Level 1 (e.g., 'Multimodal')
               wellPanel(
                 textInput("mod_label_1", "Level 1 Name", value = "Multimodal"),
                 numericInput("mod_beta_1", "Level 1 Beta Coefficient", value = 0.0),
                 numericInput("mod_tau2_1", "Level 1 Subgroup Tau2", value = 0.15, min = 0)
               ),
               
               # Level 2 (e.g., 'Unimodal')
               wellPanel(
                 textInput("mod_label_2", "Level 2 Name", value = "Unimodal"),
                 numericInput("mod_beta_2", "Level 2 Beta Coefficient", value = -0.15),
                 numericInput("mod_tau2_2", "Level 2 Subgroup Tau2", value = 0.40, min = 0)
               ),
               
               # Level 3 (Reserved)
               wellPanel(
                 textInput("mod_label_3", "Level 3 Name", value = "Other"),
                 numericInput("mod_beta_3", "Level 3 Beta Coefficient", value = 0.0),
                 numericInput("mod_tau2_3", "Level 3 Subgroup Tau2", value = 0.25, min = 0)
               ),
               
               hr(),
               h4("3. Select Prediction"),
               # Dynamic dropdown with options from above inputs
               uiOutput("prediction_selector_ui")
             ),
             
             # --- Main Panel: Display Prediction Results ---
             mainPanel(
               width = 8,
               h3("Prediction Results"),
               wellPanel(
                 h4(withMathJax("Predicted Mean Effect Size \\( (Hedge's \\ g) \\)")),
                 h3(textOutput("predicted_g_box"))
               ),
               wellPanel(
                 h4(withMathJax("Predicted Residual Heterogeneity \\( (\\tau^2) \\) (Precision)")),
                 h3(textOutput("predicted_tau2_box"))
               ),
               wellPanel(
                 h4("Precision Interpretation"),
                 htmlOutput("precision_interpretation")
               )
             )
           )
  ),
  
  # --- Tab 2: Power Analysis ---
  tabPanel("2. Power Analysis",
           icon = icon("flask"),
           fluidRow(
             column(4,
                    wellPanel(
                      h4("Power Analysis Parameters"),
                      sliderInput("desired_power", "Desired Power",
                                  min = 0.7, max = 0.95, value = 0.8, step = 0.05),
                      numericInput("alpha_level", "Significance Level (Alpha)",
                                   value = 0.05, min = 0.01, max = 0.1, step = 0.01)
                    )
             ),
             column(8,
                    wellPanel(
                      style = "background-color: #dff0d8;", # Green background
                      h4(withMathJax("Minimum Required Sample Size \\( (N) \\) per Group")),
                      h3(textOutput("required_n_box"))
                    ),
                    wellPanel(
                      style = "background-color: #fcf8e3;", # Yellow background
                      h4(withMathJax("Sample Size Recommendation & \\( \\tau^2 \\) Adjustment")),
                      htmlOutput("n_recommendation")
                    )
             )
           )
  )
)