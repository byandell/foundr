#' Shiny Module UI for Time Plots
#' @return nothing returned
#' @rdname shinyTimePlot
#' @export
shinyTimePlotInput <- function(id) {
  ns <- shiny::NS(id)
  shiny::uiOutput(ns("plotfront"))
}
#' Shiny Module UI for Time Plots
#' @return nothing returned
#' @rdname shinyTimePlot
#' @export
shinyTimePlotUI <- function(id) {
  ns <- shiny::NS(id)
  shiny::fluidRow(
    shiny::column(4, shiny::radioButtons(ns("butshow"),
      "", c("Plots","Tables"), "Plots", inline = TRUE)),
    shiny::column(8, shinyDownloadsOutput(ns("downloads"))))
}
#' Shiny Module Output for Time Plots
#' @return nothing returned
#' @rdname shinyTimePlot
#' @export
shinyTimePlotOutput <- function(id) {
  ns <- shiny::NS(id)
  shiny::uiOutput(ns("plotstables")) # Plots and Tables
}
#' Shiny Module Server for Time Plots
#'
#' @param id identifier for shiny reactive
#' @param panel_par,main_par reactive arguments 
#' @param traitSignal static object
#' @param traitTimesData reactive object
#' @param responses possible types of responses
#'
#' @return nothing returned
#' @importFrom shiny column fluidRow h3 moduleServer NS observeEvent plotOutput
#'             radioButtons reactive reactiveVal renderPlot renderUI req
#'             selectInput selectizeInput tagList uiOutput updateSelectizeInput
#' @importFrom DT renderDataTable
#' @importFrom stringr str_remove str_replace_all
#' @export
#'
shinyTimePlot <- function(id, panel_par, main_par,
                          traitSignal, traitTimesData) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # INPUTS
    # passed inputs:
    #   main_par$height
    #   panel_par$facet
    #   panel_par$strains
    
    # MODULES
    shinyDownloads("downloads", "Time", input, postfix,
                   plotObject, tableObject)
    
    # OUTPUTS

    # Identify all Time Traits.
    timetrait_all <- timetraitsall(traitSignal)

    keyTrait <- shiny::reactive({
      shiny::req(traitTimesData())
      
      timetraits_filter(traitSignal, traitTimesData())
    })
    relTraits <- shiny::reactiveVal(NULL)
    
    output$plotfront <- shiny::renderUI({
      if(shiny::req(input$butshow) == "Tables") {
        shiny::radioButtons(ns("buttable"), "Download:",
          c("Cell Means","Stats"), "Cell Means", inline = TRUE)
      }
    })
    output$plotstables <- shiny::renderUI({
      switch(shiny::req(input$butshow),
             Plots  = shiny::uiOutput(ns("plots")),
             Tables = shiny::uiOutput(ns("tables")))
    })

    # Tables.
    statstable <- shiny::reactive({
      shiny::req(traitTimesData())
      
      stats_time_table(traitTimesData()$stats)
    }, label = "statstable")
    traitstable <- shiny::reactive({
      shiny::req(traitTimesData())
      
      summary_traitTime(traitTimesData())
    }, label = "statstable")
    output$tables <- shiny::renderUI({
      shiny::req(statstable())
      
      shiny::tagList(
        shiny::h3("Cell Means"),
        DT::renderDataTable(traitstable(), escape = FALSE,
                            options = list(scrollX = TRUE, pageLength = 10)),
      
        shiny::h3("Stats: p.value"),
        DT::renderDataTable(statstable(), escape = FALSE,
                            options = list(scrollX = TRUE, pageLength = 10)))
    })
  
    output$plots <- shiny::renderUI({
      shiny::req(timeplots(), timestats())
      
      shiny::tagList(
        shiny::h3("Plot over Time"),
        shiny::plotOutput(ns("timeplots"),
                          height = paste0(main_par$height, "in")),
        shiny::h3("Plot of Time Summaries"),
        shiny::plotOutput(ns("timestats"),
                          height = paste0(main_par$height, "in")))
    })
    output$timeplots <- shiny::renderPlot(print(timeplots()))
    output$timestats <- shiny::renderPlot(print(timestats()))

    timeplots <- shiny::reactive({
      shiny::req(traitTimesData(), panel_par$strains)
      
      ggplot_traitTimes(traitTimesData()$traits, facet_strain = panel_par$facet)
    }, label = "timeplots")
    timestats <- shiny::reactive({
      shiny::req(traitTimesData())
      
      ggplot_traitTimes(traitTimesData()$stats)
    }, label = "timestats")
    
    # DOWNLOADS
    postfix <- shiny::reactive({
      filename <- paste(names(traitTimesData()$traits), collapse = ",")
      if(shiny::req(input$butshow) == "Tables")
        filename <- paste0(stringr::str_remove(input$buttable, " "), "_",
                           filename)
      stringr::str_replace_all(filename, ": ", "_")
    })
    plotObject <- shiny::reactive({
      print(shiny::req(timeplots()))
      print(shiny::req(timestats()))
    })
    tableObject <- shiny::reactive({
      shiny::req(traitTimesData())
      switch(shiny::req(input$buttable),
             "Cell Means" = traitstable(),
             Stats        = statstable())
    })
 })
}