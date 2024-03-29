#' Shiny Module UI for traitSolos
#' @return nothing returned
#' @rdname shinyTraitSolos
#' @export
shinyTraitSolosUI <- function(id) {
  ns <- shiny::NS(id)
  shiny::uiOutput(ns("shiny_solosPlot"))
}
#' Shiny Module Server for trait solos Plots
#'
#' @param id identifier for shiny reactive
#' @param input,output,session standard shiny arguments
#' @param panel_par,main_par reactive arguments from `server`
#' @param traitSolosObject reactive objects from `server`
#'
#' @return reactive object
#' 
#' @importFrom shiny moduleServer NS observeEvent plotOutput radioButtons reactive 
#'             renderPlot renderUI req tagList uiOutput
#' @importFrom DT renderDataTable dataTableOutput
#' @export
#'
shinyTraitSolos <- function(id, panel_par, main_par, traitSolosObject) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # INPUTS
    # Main inputs:
    #   panel_par$facet
    #   main_par$height
    
    # OUTPUTS
    # output$shiny_solosPlot
    
    # RETURNS
    # solosPlot()
    
    #############################################################
    # Output: Plots or Data
    output$shiny_solosPlot <- shiny::renderUI({
      shiny::req(main_par$height)
      
      shiny::plotOutput(ns("solosPlot"), height = paste0(main_par$height, "in"))
    })
    
    # Plot
    solosPlot <- shiny::reactive({
      shiny::req(traitSolosObject())

      ggplot_traitSolos(
        traitSolosObject(),
        facet_strain = panel_par$facet,
        boxplot = TRUE)
      },
      label = "solosPlot")
    output$solosPlot <- shiny::renderPlot({
      shiny::req(solosPlot())
      
      print(solosPlot())
    })
    
    #############################################################
    
    solosPlot
  })
}
