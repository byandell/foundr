dirpath <- file.path("~", "founder_diet_study")
dirpath <- file.path(dirpath, "HarmonizedData")
traitSignal <- readRDS(file.path(dirpath, "liverSignal.rds"))
traitStats <- readRDS(file.path(dirpath, "liverStats.rds"))
traitModule <- readRDS(file.path(dirpath, "traitModule.rds"))

################################################################

title <- "Test Shiny Module"

ui <- function() {
  
  shiny::fluidPage(
    shiny::titlePanel(title),
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::uiOutput("dataset"),
        foundr::shinyContrastTableInput("shinyContrastTable")),
      
      shiny::mainPanel(
        shiny::tagList(
          foundr::shinyContrastSexInput("shinyContrastSex"),
          shiny::fluidRow(
            shiny::column(4, shiny::uiOutput("sex")),
            shiny::column(8, foundr::shinyContrastSexUI("shinyContrastSex"))),
          foundr::shinyContrastSexOutput("shinyContrastSex")
        )
      )
    ))
}

server <- function(input, output, session) {
  
  # *** need persistent module choice (reactiveVal)
  # *** table from traits()
  # *** sliders from Volcano
  # *** simplify using traitModule as below
  # *** move module choice to side panel
  
  # MODULE
  # Contrast Trait Table
  contrastOutput <- foundr::shinyContrastTable("shinyContrastTable",
    input, input, traitSignal, traitStats, customSettings)
  # Contrast Modules.
  moduleOutput <- foundr::shinyContrastSex("shinyContrastSex",
    input, input, traitContrPval, traitModule)
  
  traitContrPval <- reactive({
    shiny::req(contrastOutput())

    pvalue <- attr(traitModule, "p.value") # set by construction of `traitModule`
    if(is.null(pvalue)) pvalue <- 1.0
    
    dplyr::filter(shiny::req(contrastOutput()), .data$p.value <= pvalue)
  })
  
  # SERVER-SIDE INPUTS
  output$dataset <- shiny::renderUI({
    # Dataset selection.
    datasets <- unique(traitStats$dataset)
    
    # Get datasets.
    shiny::selectInput("dataset", "Datasets:",
                       datasets, datasets[1], multiple = TRUE)
  })
  output$strains <- shiny::renderUI({
    choices <- names(foundr::CCcolors)
    shiny::checkboxGroupInput(
      "strains", "Strains",
      choices = choices, selected = choices, inline = TRUE)
  })
  sexes <- c(B = "Both Sexes", F = "Female", M = "Male", C = "Sex Contrast")
  output$sex <- shiny::renderUI({
    shiny::selectInput("sex", "", as.vector(sexes))
  })
  
  output$intro <- renderUI({
    shiny::renderText("intro", {
      paste("Guideline is to have power of 6 and size of 4 for unsigned modules.")
    })
  })
}

shiny::shinyApp(ui = ui, server = server)
