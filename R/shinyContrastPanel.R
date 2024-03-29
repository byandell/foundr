#' Shiny Module Input for Contrast Panel
#' @return nothing returned
#' @rdname shinyContrastPanel
#' @export
shinyContrastPanelInput <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::uiOutput(ns("shinyInput")),
    shiny::radioButtons(ns("contrast"), "Contrast by ...",
                        c("Sex", "Time", "Module"), inline = TRUE))
}
#' Shiny Module Output for Contrast Panel
#' @return nothing returned
#' @rdname shinyContrastPanel
#' @export
shinyContrastPanelOutput <- function(id) {
  ns <- shiny::NS(id)
  shiny::uiOutput(ns("shinyOutput"))
}
#' Shiny Module Server for Contrast Panel
#'
#' @param id identifier for shiny reactive
#' @param main_par reactive arguments 
#' @param traitSignal,traitStats,traitModule static objects
#' @param customSettings list of custom settings
#'
#' @return reactive object 
#' @importFrom shiny column fluidRow h3 isTruthy moduleServer NS radioButtons
#'             reactive renderText renderUI tagList uiOutput
#' @importFrom stringr str_to_title
#' @export
#'
shinyContrastPanel <- function(id, main_par,
                            traitSignal, traitStats, traitModule,
                            customSettings = NULL) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # INPUTS
    # RETURNS
    #   contrastOutput
    
    # Identify all Time Traits.
    timetrait_all <- timetraitsall(traitSignal)
    # Subset Stats to time traits.
    traitStatsTime <- time_trait_subset(traitStats, timetrait_all)
    
    # MODULES
    # Contrast Trait Table
    contrastOutput <- shinyContrastTable("shinyContrastTable",
      input, main_par, traitSignal, traitStats, customSettings)
    # Contrast Trait Plots by Sex
    shinyContrastSex("shinyContrastSex",
      input, main_par, contrastOutput, customSettings)
    # Contrast Time Trait Table
    contrastTimeOutput <- shinyContrastTable("shinyContrastTimeTable",
      input, main_par, traitSignal, traitStatsTime, customSettings, TRUE)
    # Contrast Time Traits
    timeOutput <- shinyContrastTime("shinyContrastTime", input, main_par,
      traitSignal, traitStatsTime, contrastTimeOutput, customSettings)
    # Contrast Time Plots and Tables
    shinyTimePlot("shinyTimePlot", input, main_par, traitSignal, timeOutput)
    # Contrast Modules.
    moduleOutput <- shinyContrastModule("shinyContrastModule",
      input, main_par, traitContrPval, traitModule)
    
    # SERVER-SIDE Inputs
    output$strains <- shiny::renderUI({
      choices <- names(foundr::CCcolors)
      shiny::checkboxGroupInput(ns("strains"), "Strains",
                                choices = choices, selected = choices, inline = TRUE)
    })
    
    traitContrPval <- reactive({
      shiny::req(contrastOutput())
      
      if(is.null(traitModule))
        return(NULL)
      pvalue <- attr(traitModule, "p.value") # set by construction of `traitModule`
      if(is.null(pvalue)) pvalue <- 1.0
      dplyr::filter(shiny::req(contrastOutput()), .data$p.value <= pvalue)
    })
    
    
    # Input
    output$shinyInput <- shiny::renderUI({
      shiny::req(input$contrast)
      switch(
        input$contrast,
        Sex =, Module = {
          shiny::tagList(
            shinyContrastTableInput(ns("shinyContrastTable")))
        },
        Time = {
          shiny::tagList(
            shinyContrastTableInput(ns("shinyContrastTimeTable")),
            shinyContrastTimeInput(ns("shinyContrastTime")))
        })
    })
    
    # Output
    output$shinyOutput <- shiny::renderUI({
      shiny::req(input$contrast)
      shiny::tagList(
        shiny::uiOutput(ns("text")),
        
        if(input$contrast == "Time") {
          shiny::fluidRow(
            shiny::column(9, shiny::uiOutput(ns("strains"))),
            shiny::column(3, shiny::checkboxInput(ns("facet"), "Facet by strain?", TRUE)))
        },
        
        switch(input$contrast,
          Sex = shinyContrastSexOutput(ns("shinyContrastSex")),
          Time = {
            shiny::tagList(
              shinyTimePlotUI(ns("shinyTimePlot")),
              shinyTimePlotOutput(ns("shinyTimePlot"))
            )
          },
          Module = shinyContrastModuleOutput(ns("shinyContrastModule"))))
    })
    
    output$text <- shiny::renderUI({
      condition <- customSettings$condition
      if(shiny::isTruthy(condition))
        condition <- stringr::str_to_title(condition)
      else
        condition <- "Condition"
      
      shiny::tagList(
        shiny::h3(paste(condition, "Contrasts")),
        shiny::renderText({
          out <- paste0(
            "This panel examines contrasts (differences or ratios) of ",
            condition, " means by strain and sex.",
            "These may be viewed by sex or averaged over sex",
            " (Both Sexes) or by contrast of Female - Male",
            " (Sex Contrast).")
          if(shiny::req(input$contrast) == "Time")
            out <- paste(out, "Contrasts over time are by trait.")
          if(shiny::req(input$contrast) == "Module")
            out <- paste(out, "WGCNA modules by dataset and sex have",
                         "power=6, minSize=4.",
                         "Select a Module to see module members.")
          out
        }))
    })

    ###############################################################
    contrastOutput
  })
}
