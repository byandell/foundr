#' User Interface for Founder Shiny App
#'
#' See foundrServer for needed user-supplied functions.
#' 
#' @param title title of shiny app
#'
#' @return A UI definition that can be passed to the `shinyUI` function.
#' 
#' @export
#' @importFrom shiny fluidPage mainPanel sidebarLayout sidebarPanel sliderInput titlePanel uiOutput
#'
#' @examples
foundrUI <- function(title) {
  shiny::fluidPage(
    
    shiny::titlePanel(title),
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::uiOutput("intro"),
        shiny::uiOutput("settings"),
        shiny::uiOutput("strains"),
        shiny::sliderInput("height", "Plot height (in):", 3, 10, 6, step = 1),
        shiny::uiOutput("downloads"),
        shiny::uiOutput("trait")),
      
      # Main panel for displaying outputs ----
      shiny::mainPanel(
        shiny::uiOutput("outs")
      )
    )
  )
}

#' Server for Founder Shiny App
#'
#' User needs to supply the following routines:
#'   foundrIntro() # introductory remarks about study
#'   foundrSettings() # settings to be used in later parts
#'   foundrScatplot() # wrapper for foundr::scatplot
#'   foundrData() # routine to subset data
#'   foundrMean() # routine to subset mean summaries
#'   
#' @param input,output,session shiny parameters
#' @param traitdat data frame with trait data
#' @param traitsumdat data frame with summary data
#'
#' @return A Server definition that can be passed to the `shinyServer` function.
#' @export
#' @importFrom shiny checkboxGroupInput column conditionalPanel
#'             downloadButton downloadHandler fluidRow isTruthy observeEvent
#'             plotOutput radioButtons reactive renderPlot renderUI req
#'             selectizeInput tagList textInput textAreaInput uiOutput updateSelectizeInput
#' @importFrom dplyr across everything filter mutate
#' @importFrom tidyselect where
#' @importFrom DT dataTableOutput renderDataTable
#' @importFrom ggplot2 ggplot
#' @importFrom grDevices pdf dev.off
#' @importFrom utils combn write.csv
#'
#' @examples
foundrServer <- function(input, output, session, traitdat, traitsumdat) {

  traitdata <- shiny::reactive({traitdat})
  traitsumdata <- shiny::reactive({traitsumdat})
  
  output$intro <- foundrIntro()
  output$settings <- foundrSettings()
  output$strains <- shiny::renderUI({
    choices <- names(CCcolors)
    shiny::checkboxGroupInput("strains", "Strains",
                       choices = choices, selected = choices, inline = TRUE)
  })
  
  # Trait summaries (for ordering traits, and summary table)
  dataset <- shiny::reactive({
    shiny::req(input$datatype)
    dplyr::filter(traitdata(), datatype %in% input$datatype)
  })
  traitarrange <- shiny::reactive({
    shiny::req(input$order, input$datatype)
    foundrArrange(traitsumdata(), input$order, input$datatype)
  })
  traitorder <- shiny::reactive({
    traitarrange()$trait
  })
  
  # Select traits
  output$trait <- shiny::renderUI({
    shiny::req(traitorder(), input$order, dataset())
    shiny::selectizeInput("trait", "Traits:", choices = NULL, multiple = TRUE)
  })
  shiny::observeEvent({
    shiny::req(dataset(), input$order)
  },
  {
    shiny::updateSelectizeInput(session, "trait", choices = traitorder(),
                         server = TRUE)
  })
  
  # Data for selected traits
  datatraitslong <- shiny::reactive({
    shiny::req(dataset(), input$trait, input$strains)
    dplyr::filter(
      dataset(),
      trait %in% input$trait,
      strain %in% input$strains)
  })
  datatraits <- shiny::reactive({
    shiny::req(datatraitslong(), input$trait)
    foundrData(datatraitslong(), input$trait)
  })
  
  # Output: Plots or Data
  output$outs <- shiny::renderUI({
    shiny::tagList(
      shiny::radioButtons("button", "", c("Plots", "Pair Plots", "Data Means", "Data Summary"), "Plots", inline = TRUE),
      shiny::conditionalPanel(
        condition = "input.button == 'Plots'",
        shiny::uiOutput("plots")),
      shiny::conditionalPanel(
        condition = "input.button == 'Pair Plots'",
        shiny::uiOutput("scatPlot")),
      shiny::conditionalPanel(
        condition = "input.button == 'Data Means'",
        DT::dataTableOutput("datatable")),
      shiny::conditionalPanel(
        condition = "input.button == 'Data Summary'",
        DT::dataTableOutput("tablesum")))
  })
  
  # Plots
  distplot <- shiny::reactive({
    if(!shiny::isTruthy(dataset()) | !shiny::isTruthy(input$trait)) {
      return(ggplot2::ggplot())
    }
    if(!all(input$trait %in% dataset()$trait)) {
      return(ggplot2::ggplot())
    }
    
    shiny::req(input$facet)
    foundr::strainplot(datatraits(), facet_strain = (input$facet == "strain"))
  })
  output$distPlot <- shiny::renderPlot({
    distplot()
  })
  output$plots <- shiny::renderUI({
    shiny::req(input$height)
    shiny::plotOutput("distPlot", height = paste0(input$height, "in"))
  })
  output$downloads <- foundrDownloads(shiny::req(input$trait), shiny::req(input$datatype))
  
  output$downloadPlot <- shiny::downloadHandler(
    filename = function() {
      paste0(shiny::req(input$plotname), ".pdf") },
    content = function(file) {
      shiny::req(input$height)
      grDevices::pdf(file, width = 9, height = input$height)
      print(distplot())
      grDevices::dev.off()
    })
  
  # Data Table
  datameans <- shiny::reactive({
    foundrMean(datatraits())
  })
  output$datatable <- DT::renderDataTable(
    datameans(),
    escape = FALSE,
    options = list(scrollX = TRUE, pageLength = 10))
  output$tablesum <- DT::renderDataTable(
    dplyr::mutate(
      traitarrange(),
      dplyr::across(
        tidyselect::where(is.numeric),
        function(x) signif(x, 4))),
    escape = FALSE,
    options = list(scrollX = TRUE, pageLength = 10))
  output$tablename <- shiny::renderUI({
    filename <- shiny::req(input$datatype)
    shiny::textInput("tablename", "Summary File Prefix", filename)
  })
  output$downloadMean <- shiny::downloadHandler(
    filename = function() {
      paste0(shiny::req(input$plotname), ".csv") },
    content = function(file) {
      utils::write.csv(datameans(), file, row.names = FALSE)
    }
  )
  output$downloadTable <- shiny::downloadHandler(
    filename = function() {
      shiny::req(input$datatype)
      paste0(shiny::req(input$tablename), ".csv") },
    content = function(file) {
      utils::write.csv(traitarrange(), file, row.names = FALSE)
    }
  )
  
  output$pair <- shiny::renderUI({
    # Somehow when input$height is changed this is reset.
    shiny::req(input$trait)
    if(length(input$trait) < 2)
      return(NULL)
    choices <- 
      as.vector(
        unlist(
          dplyr::mutate(
            as.data.frame(utils::combn(input$trait, 2)),
            dplyr::across(
              dplyr::everything(), 
              function(x) {
                c(paste(x, collapse = " ON "),
                  paste(rev(x), collapse = " ON "))
              }))))
    
    shiny::selectInput(
      "pair", "Select pairs for scatterplots",
      choices = choices, selected = choices[1],
      multiple = TRUE, width = '100%')
  })
  output$scatPlot <- shiny::renderUI({
    shiny::req(input$trait, input$datatype, input$order)
    shiny::tagList(
      shiny::uiOutput("pair"),
      shiny::plotOutput("scatplot", height = paste0(input$height, "in"))
    )
  })
  output$scatplot <- shiny::renderPlot({
    if(!shiny::isTruthy(input$pair)) {
      return(ggplot2::ggplot())
    }
    
    foundrScatplot(req(input$trait), datatraitslong(), req(input$pair))
  })
}

#' Arrange Founder Traits in Order
#'
#' @param traitsumdata data frame with summary
#' @param order name to use to order traits
#' @param datatypes type to subset `traitsumdata`
#'
#' @return data frame reordered
#' @export
#' @importFrom dplyr arrange desc filter
#' @importFrom rlang .data
#'
#' @examples
foundrArrange <- function(traitsumdata, order, datatypes = "") {
  out <- dplyr::filter(traitsumdata, datatype %in% datatypes)
  # Can automate this by pulling names from traitsumdata.
  if(order == "variability") {
    out <- dplyr::arrange(out, dplyr::desc(rawSD))
  } else if(order == "alphabetical") {
    out <- dplyr::arrange(out, trait)
  } else {
    if(order != "original") {
      out <- dplyr::arrange(out, .data[[order]])
    }
  }
  out
}

#' Downloads for Founder App
#'
#' See `foundrServer` for details of download outputs.
#' 
#' @param trait trait name(s)
#' @param datatype type of data
#'
#' @return uses shiny downloadHandler
#' 
#' @export
#'
#' @examples
foundrDownloads <- function(trait, datatype) {
  shiny::renderUI({
    ltrait <- length(trait)
    filename <- paste0(paste(datatype, collapse = "."),
                       "_",
                       paste(abbreviate(trait, ceiling(60 / ltrait)),
                             collapse = "."))
    
    shiny::tagList(
      shiny::fluidRow(
        shiny::column(
          6,
          shiny::textAreaInput("plotname", "File Prefix", filename)),
        shiny::column(
          3,
          shiny::downloadButton("downloadPlot", "Plots")),
        shiny::column(
          3,
          shiny::downloadButton("downloadMean", "Means"))),
      shiny::fluidRow(
        shiny::column(
          6,
          shiny::uiOutput("tablename")),
        shiny::column(
          3,
          shiny::downloadButton("downloadTable", "Summary"))))
  })
}