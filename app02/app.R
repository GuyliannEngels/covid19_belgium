library(shiny)
library(shinydashboard)
library(dplyr)
library(chart)
library(flow)

data.io::read("https://epistat.sciensano.be/Data/COVID19BE_CASES_AGESEX.csv")%>.%
  rename_all(., stringr::str_to_lower) %>.%
  select(., date, cases) %>.%
  group_by(., date) %>.%
  summarise(., tot_posi = sum(cases, na.rm = TRUE))-> confirmed_tests

data.io::read("https://epistat.sciensano.be/Data/COVID19BE_tests.csv") %>.%
  rename_all(., stringr::str_to_lower) %>.%
  select(., date, tests_all) %>.%
  group_by(., date) %>.%
  summarise(., tot = sum(tests_all, na.rm = TRUE)) %>.%
  left_join(., confirmed_tests, by = "date") %>.%
  mutate(., ratio = tot_posi/tot) -> test_ratio

test_ratio <- data.io::labelise(test_ratio,
                       label = list(date = "Date",
                                    tot = "Nombre de tests effectués",
                                    tot_posi = "Nombre de tests positifs",
                                    ratio = "Rapport de tests positifs/effectués"),
                       unit = list(date = "J"))

data.io::read("https://epistat.sciensano.be/Data/COVID19BE_HOSP.csv") %>.%
  rename_all(., stringr::str_to_lower) %>.%
  select(., -province, -region) %>.%
  group_by(., date) %>.%
  summarise(.,
            total_in = sum(total_in, na.rm = TRUE),
            total_in_icu = sum(total_in_icu, na.rm = TRUE),
            total_in_resp = sum(total_in_resp, na.rm = TRUE),
            total_in_ecmo = sum(total_in_ecmo, na.rm = TRUE),
            new_in = sum(new_in, na.rm = TRUE),
            new_out = sum(new_out, na.rm = TRUE)) -> hospi_cases

hospi_cases <- data.io::labelise(
  hospi_cases,
  label = list(
    date = "Date",
    total_in = "Nombre total de patients",
    total_in_icu = "Nombre total de patients en unité de soins intensifs",
    total_in_resp = "Nombre total de patients sous respirateur",
    total_in_ecmo = "Nombre total de patients sous ECMO",
    new_in = "Nombre de nouvelles personnes hospitalisées",
    new_out = "Nombre de personnes quittant l'hopital en vie"))


header <- dashboardHeader(title = "COVID 19 Belgique")

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Hopitaux", icon = icon("hospital-symbol"), tabName = "hospi"),
    menuItem("Cas confirmés", icon = icon("syringe"), tabName = "cases")
  )
)

body <- dashboardBody(

  # tab ------
  tabItems(
    tabItem(tabName = "hospi",
            h2("Situation dans les hopitaux"),
            box(
              plotOutput("nb_icu"), title = "Nombre de patients en soins inensifs",
              status = "danger", width = 12, solidHeader = TRUE, collapsible = TRUE),
            fluidRow(
                     box(plotOutput("nb_hospi"), title = "Nombre de patients hospitalisées",
                         status = "primary", solidHeader = TRUE, collapsible = TRUE),
                     box(plotOutput("new_in"), title = "Nouvelles entrées à l'hopital",
                         status = "primary", solidHeader = TRUE, collapsible = TRUE)
                     ),
            fluidRow(
              box(plotOutput("nb_resp"), title = "Nombre total de patients sous respirateur",
                  status = "primary", solidHeader = TRUE, collapsible = TRUE, collapsed = TRUE),
              box(plotOutput("nb_ecmo"), title = "Nombre total de patients sous ECMO",
                  status = "primary", solidHeader = TRUE, collapsible = TRUE, collapsed = TRUE)
            )
            ),
    tabItem(tabName = "cases",
            h2("Les cas confirmés"),
            box(
              plotOutput("nb_posi"), title = "Cas (tests) positifs",
              status = "warning", width = 12, solidHeader = TRUE, collapsible = TRUE),
            hr(),
            fluidRow(
              box(plotOutput("nb_test"), title = "Tests effectués",
                  status = "primary", solidHeader = TRUE, collapsible = TRUE),
              box(plotOutput("ratio"), title = "Tests positifs/tests effectués",
                  status = "primary", solidHeader = TRUE, collapsible = TRUE)
            )
    )
  )
)

ui <- dashboardPage(header, sidebar, body)

server <- function(input, output) {

  output$nb_icu <- renderPlot({
    chart(hospi_cases, total_in_icu ~ date) +
      geom_line() +
      geom_point()
  })

  output$nb_hospi <- renderPlot({
    chart(hospi_cases, total_in ~ date) +
      geom_line() +
      geom_point()
  })

  output$new_in <- renderPlot({
    chart(hospi_cases, new_in ~ date) +
      geom_line() +
      geom_point()
  })

  output$nb_resp <- renderPlot({
    chart(hospi_cases, total_in_resp ~ date) +
      geom_line() +
      geom_point()
  })

  output$nb_ecmo <- renderPlot({
    chart(hospi_cases, total_in_ecmo ~ date) +
      geom_line() +
      geom_point()
  })

  output$nb_posi <- renderPlot({
    chart(test_ratio, tot_posi ~ date) +
      geom_line() +
      geom_point()
  })

  output$nb_test <- renderPlot({
    chart(test_ratio, tot ~ date) +
      geom_line() +
      geom_point()
  })

  output$ratio <- renderPlot({
    chart(test_ratio, ratio ~ date) +
      geom_line() +
      geom_point()
  })


}

shinyApp(ui, server)
