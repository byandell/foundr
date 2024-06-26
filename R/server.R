#' Shiny Server for foundr Package
#'
#' @param input,output,session shiny server parameters
#' @param traitData,traitSignal,traitStats,traitModule static objects
#' @param customSettings list of custom settings
#'
#' @return reactive server
#' 
#' @export
#' 
#' @importFrom shiny checkboxGroupInput hideTab observeEvent reactive reactiveVal
#'             renderUI req showTab
#' @importFrom grDevices dev.off pdf
#' @importFrom utils write.csv
#'
server <- function(input, output, session,
                   traitData = NULL, traitSignal = NULL, traitStats = NULL,
                   customSettings = NULL, traitModule = NULL) {
  # INPUTS
  #    input$dataset
  #    input$height
  #    input$tabpanel
  
  # CALL MODULES
  shinyTraitPanel("tabTraits", input, traitData, traitSignal, traitStats,
                  customSettings)
  shinyTimePanel("tabTimes", input, traitData, traitSignal, traitStats)
  shinyStatsPanel("tabStats", input, traitStats, customSettings)
  shinyContrastPanel("tabContrasts", input,
                     traitSignal, traitStats, traitModule, customSettings)
  
  output$intro <- foundrIntro(customSettings$help)
  
  # SERVER-SIDE INPUTS
  output$dataset <- shiny::renderUI({
    # Dataset selection.
    datasets <- unique(traitStats$dataset)
    selected <- data_selection()
    
    # Get datasets.
    shiny::selectInput("dataset", "Datasets:", datasets, selected, multiple = TRUE)
  })
  data_selection <- shiny::reactiveVal(unique(traitStats$dataset)[1], label = "data_selection")
  shiny::observeEvent(input$dataset, data_selection(input$dataset))
  
  
  # Entry key
  entrykey <- shiny::reactive({
    out <- !shiny::isTruthy(customSettings$entrykey)
    if(!out & shiny::isTruthy(input$appEntry)) {
      out <- (input$appEntry == customSettings$entrykey)
    }
    out
  })

  # Hide all tabs unless Entry word provided.
  shiny::observeEvent(
    shiny::tagList(input$height, entrykey()),
    {
      if(shiny::isTruthy(entrykey())) {
        shiny::showTab(inputId = "tabpanel", target = "Traits")
        if(length(timetraits_all()))
          shiny::showTab(inputId = "tabpanel", target = "Times")
        shiny::showTab(inputId = "tabpanel", target = "Contrasts")
        shiny::showTab(inputId = "tabpanel", target = "Stats")
        shiny::showTab(inputId = "tabpanel", target = "About")
      } else {
        shiny::hideTab(inputId = "tabpanel", target = "Traits")
        shiny::hideTab(inputId = "tabpanel", target = "Times")
        shiny::hideTab(inputId = "tabpanel", target = "Contrasts")
        shiny::hideTab(inputId = "tabpanel", target = "Stats")
        shiny::hideTab(inputId = "tabpanel", target = "About")
      }
    })
  # Hide Time tab unless we have time entries.
  shiny::observeEvent(
    input$height,
    {
      if(shiny::isTruthy(entrykey())) {
        if(length(timetraits_all())) {
          shiny::showTab(inputId = "tabpanel", target = "Times")
          # Hidden for calcium study for now.
          shiny::showTab(inputId = "tabpanel", target = "Contrasts")
        } else {
          shiny::hideTab(inputId = "tabpanel", target = "Times")
          # Hidden for calcium study for now.
          shiny::hideTab(inputId = "tabpanel", target = "Contrasts")
        }}
    })
  timetraits_all <- shiny::reactive({
    foundr::timetraitsall(traitSignal)
  })
  
  output$sideInput <- shiny::renderUI({
    shiny::req(input$tabpanel)

    if(shiny::isTruthy(entrykey())) {
      # Tab-specific side panel.
      shiny::req(input$tabpanel)
      shiny::tagList(
        shiny::fluidRow(
          shiny::column(3, shiny::uiOutput("dataset")),
          if(input$tabpanel %in% c("Traits","Times","Contrasts")) {
            shiny::column(9, 
              switch(input$tabpanel,
                Traits = shinyTraitPanelInput("tabTraits"),
                Contrasts = shinyContrastPanelInput("tabContrasts"),

                Times  = if(length(timetraits_all())) shinyTimePanelInput("tabTimes")))
          }),
        
        switch(input$tabpanel,
          Traits    = shinyTraitPanelUI("tabTraits"),
          Contrasts = if(length(timetraits_all()))
                        shinyContrastPanelUI("tabContrasts"),
          Times     = if(length(timetraits_all()))
                        shinyTimePanelUI("tabTimes")),
        
        shiny::hr(style="border-width:5px;color:black;background-color:black"),
        
        shiny::sliderInput("height", "Plot height (in):", 3, 10, 6,
                           step = 1))
      }
  })
  # Don't show Entry Key if there is no need.
  output$entrykey <- shiny::renderUI({
    if(shiny::isTruthy(customSettings$entrykey))
      shiny::textInput("appEntry", "Entry Key:")
  })
  
  # Main Output
  output$mainOutput <- shiny::renderUI({
    if(shiny::isTruthy(entrykey())) {
      shiny::tabsetPanel(
        type = "tabs", header = "", id = "tabpanel",
        shiny::tabPanel("Traits", shinyTraitPanelOutput("tabTraits")),
        shiny::tabPanel("Contrasts",  shinyContrastPanelOutput("tabContrasts")),
        shiny::tabPanel("Stats",  shinyStatsPanelOutput("tabStats")),
        shiny::tabPanel("Times",  shinyTimePanelOutput("tabTimes")),
        shiny::tabPanel("About",  shiny::uiOutput("intro"))
      )
    }
  })
}
