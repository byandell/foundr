dirpath <- file.path("~", "founder_diet_study")
dirpath <- file.path(dirpath, "HarmonizedData")
traitStats <- readRDS(file.path(dirpath, "traitStats.rds"))

################################################################

title <- "Test Shiny Trait Names"

ui <- function() {
  # INPUTS
  #   see shinyTraitNames 
  #
  # OUTPUTS (see shinyTraitNames)
  #   output$name: Traits

  shiny::fluidPage(
    shiny::titlePanel(title),
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::uiOutput("name")),
      
      shiny::mainPanel(
        shiny::tagList(
          shiny::uiOutput("inputs"),
          
          foundr::shinyTraitNamesUI("shinyTest")))
      ))
}

server <- function(input, output, session) {
  
  # INPUTS (see shinyTraitNames)
  #   input$dataset: Dataset
  # OUTPUTS (see shinyTraitNames)
  #   output$name: Traits
  
  # MODULES
  moduleOutput <- foundr::shinyTraitNames("shinyTest", input, traitStatsInput)
  
  datasets <- shiny::reactive({
      unique(traitStats$dataset)
    },
    label = "datasets")

  # INPUTS  
  output$inputs <- renderUI({
    shiny::selectInput("dataset", "Dataset:", datasets(), multiple = TRUE)
  })

  # DATA OBJECTS 
  traitStatsInput <- shiny::reactive({
    if(shiny::isTruthy(input$dataset)) {
      dplyr::filter(
        traitStats,
        .data$dataset %in% input$dataset)
    } else {
      NULL
    }
   },
   label = "traitStatsInput")
  
  # I/O FROM MODULE
  output$name <- renderUI({
    shiny::req(moduleOutput())
    name <- paste(moduleOutput(), collapse = ", ")
    shiny::textAreaInput("name", "Traits", name)
  })
}

shiny::shinyApp(ui = ui, server = server)
