library(shiny)
library(shinydashboard)
library(flow)
library(dplyr)
library(plotly)

ui <- dashboardPage(
  dashboardHeader(title = "COVID 19 Belgique"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    fluidRow(
      valueBoxOutput("duree_box", width = 6),
      valueBoxOutput("deathNb", width = 6),
      valueBoxOutput("icu", width = 6),
      valueBoxOutput("new_in", width = 6)
    ),
    fluidRow(
      column(width = 6,
             plotlyOutput("hospi_new_in", inline = TRUE),
             plotlyOutput("hospi_tot_icu", inline = TRUE)
        ),
      column(width = 6,
             plotlyOutput("death_new", inline = TRUE),
             plotlyOutput("hospi_tot_in", inline = TRUE)
        )
    )
  )
)

server <- function(input, output) {

  # préparation des données ----
  data.io::read("https://epistat.sciensano.be/Data/COVID19BE_HOSP.csv") %>.%
    dplyr::rename_all(., stringr::str_to_lower) %>.%
    dplyr::mutate(.,
      province = forcats::fct_recode(
        stringi::stri_trans_general(province, "ASCII-Latin"),
        "anvers" = "Antwerpen",
        "bruxelles" = "Brussels",
        "limbourg" = "Limburg",
        "liege" = "Li�ge",
        "flandre_orientale" = "OostVlaanderen",
        "brabant_wallon" = "BrabantWallon",
        "brabant_flamand" = "VlaamsBrabant",
        "flandre_occidentale" = "WestVlaanderen"),
      region = forcats::fct_recode(region,
        "flamande" = "Flanders",
        "bruxelles_capitale" = "Brussels",
        "wallonne" = "Wallonia")) -> hospi

  hospi %>.%
    group_by(., date) %>.%
    summarise(.,
      total_in = sum(total_in, na.rm = TRUE),
      total_in_icu = sum(total_in_icu, na.rm = TRUE),
      total_in_resp = sum(total_in_resp, na.rm = TRUE),
      total_in_ecmo = sum(total_in_ecmo, na.rm = TRUE),
      new_in = sum(new_in, na.rm = TRUE),
      new_out = sum(new_out, na.rm = TRUE)
    ) -> hospi

  data.io::read("https://epistat.sciensano.be/Data/COVID19BE_MORT.csv") %>.%
    dplyr::rename_all(., stringr::str_to_lower) %>.%
    dplyr::rename(., age_group = agegroup) %>.%
    dplyr::mutate(.,
      region = forcats::fct_recode(region,
      "flamande" = "Flanders",
      "bruxelles_capitale" = "Brussels",
      "wallonne" = "Wallonia"),
      age_group = factor(age_group,
        levels = c("0-24", "25-44", "45-64", "65-74", "75-84", "85+", NA),
        ordered = TRUE),
      sex = factor(sex)) -> death

  death %>.%
    group_by(., date) %>.%
    summarise(.,
      deaths = sum(deaths, na.rm = TRUE),
    ) -> death

  # Date importante

  deadline <- tibble::tibble(
    phase = c(
      "Confinement", "Déconfinement phase 1",
      "Déconfinement phase 2", "Déconfinement phase 3"),
    date = lubridate::as_date(
      c("2020-03-15", "2020-05-20", "2020-05-18", "2020-06-08"))
  )

  # Server ----
  output$duree_box <- renderValueBox({
    diff <- Sys.Date() - lubridate::as_date("2020-03-13")
    valueBox(
      paste0(as.numeric(diff), " jours"), "Durées des mesures", icon = icon("clock"),
      color = "aqua"
    )
  })

  output$icu <- renderValueBox({
    percent <- round((last(hospi$total_in_icu) / 1900)*100, 2)
    valueBox(
      paste0(percent, "%"), "Occupation des soins intensifs (objectif: max 40%)", icon = icon("list-alt"),
      color = "olive"
    )
  })

  output$new_in <- renderValueBox({
    newin <- last(hospi$new_in)
    valueBox(
      newin, "Dernières entrées à l'hopital (objectif: max 200)",
      icon = icon("list-alt"),
      color = "olive"
    )
  })

  output$deathNb <- renderValueBox({
    tot <- sum(death$deaths)

    valueBox(tot, "Nombre de décès", icon = icon("list-alt"),
      color = "red"
    )
  })

  output$hospi_tot_in <- renderPlotly({

    p <- ggplot(hospi, aes(x = date, y = total_in)) +
      geom_line() +
      geom_point() +
      geom_vline(xintercept = deadline$date) +
      labs(y = "Nombre de patients à l'hopital", x = "Temps") +
      chart::theme_sciviews()

    ggplotly(p)
  })

  output$hospi_tot_icu <- renderPlotly({

    p <- ggplot(hospi, aes(x = date, y = total_in_icu)) +
      geom_line() +
      geom_point() +
      labs(y = "Nombre de patients en ICU", x = "Temps") +
      chart::theme_sciviews()

    ggplotly(p)
  })

  output$hospi_new_in <- renderPlotly({

    p <- ggplot(hospi, aes(x = date, y = new_in)) +
      geom_line() +
      geom_point() +
      geom_vline(xintercept = deadline$date) +
      labs(y = "Nouvelles entrées à l'hopital", x = "Temps") +
      chart::theme_sciviews()

    ggplotly(p)
  })


  output$death_new <- renderPlotly({

    p <- ggplot(death, aes(x = date, y = deaths)) +
      geom_line() +
      geom_point() +
      labs(y = "Nouveaux décès", x = "Temps") +
      chart::theme_sciviews()

    ggplotly(p)
  })

  }

shinyApp(ui, server)
