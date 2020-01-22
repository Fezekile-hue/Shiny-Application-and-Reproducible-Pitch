
# Importing required packages
library(shiny)
require(shinydashboard)
library(DT)
library(rAmCharts)
library(dplyr)

#Importing the dataset
movie <-read.csv("Movie-Data.csv",stringsAsFactors = F)
movie <- movie[complete.cases(movie), ]

#Data cleaning to separate features of the movies
genre <- unlist(strsplit(movie$Genre,","))
genre <- unique(genre)

actors <- unlist(strsplit(movie$Actors,","))
actors <- unique(actors)

directors <- unique(movie$Director)

genre_choices <- append(genre, "Select All", after = 0)
directors_choices <- append(directors, "Select All", after = 0)
actors_choices <- append(actors, "Select All", after = 0)
genre_choices


genre_choices <- append(genre, "Select All", after = 0)
directors_choices <- append(directors, "Select All", after = 0)
actors_choices <- append(actors, "Select All", after = 0)
genre_choices

# Define UI for application for the dashboard

header <- dashboardHeader(title = "Your Movie Pick App") 

sidebar <- dashboardSidebar(
    sidebarMenu(
        sliderInput("Rating", "Select Movie Rating",0,10,c(0,10)),
        sliderInput("Year", "Select Year released", 2006, 2016, c(2006, 2016)),
        selectInput("genre_input", "Select Genre",genre_choices, selected = "Select All"),
        selectInput("directors_input","Select Director",directors_choices, selected = "Select All"),
        selectInput("actors_input","Select Actor",actors_choices, selected = "Select All"),
        submitButton("Submit")
        
        
    )
)

body <- dashboardBody(
    fluidRow(
        box(width = 6, amChartsOutput("top_imdb_ratings"), title = "Top Rated Movies"),
        box(width = 6, amChartsOutput("total_movies"), title = "Total Movies Release each Year")
    ),
    fluidRow(
        box(width = 12, DT::DTOutput("movies_table"), title = "All Filtered Movies")
    )
)



ui <- dashboardPage(skin = "purple",
    header,
    sidebar,
    body
   
)


# Define server logic required 

server <- (function(input,output){
     filtered_data <- reactive({
         movies <- movie
#      
        movieYear1 <- input$Year[1]
        movieYear2 <- input$Year[2]
        movieRating1 <- input$Rating[1]
        movieRating2 <- input$Rating[2]
        moviegenre<-  input$genre_input
        movieDirector <- input$directors_input
        movieActor <- input$actors_input

        movie <- movie[(movies$Year>=movieYear1) & (movies$Year>= movieYear2), ]
        movie <- movie[(movies$Rating>=movieRating1) & (movies$Rating>=movieRating2), ]

        if (moviegenre != "Select All") {
            movies <- movies[grepl(moviegenre, movies$Genre), ]
        }

        if (movieDirector != "Select All") {
            movies <- movies[grepl(movieDirector,movies$Director),]
        }

        if (movieActor!= "Select All") {
            movies <- movies[grepl(movieActor, movies$Actors), ]
        }
        movies
    })
#     
    output$movies_table <- renderDT({ 
     filtered_movies_table <- filtered_data()
     filtered_movies_table <- filtered_movies_table[, c("Title", "Genre", "Description", "Director", "Actors", "Rating")]
     DT::datatable(filtered_movies_table)
     
})
    output$top_imdb_ratings <- renderAmCharts({
        top_imdb_ratings_plot <- filtered_data()
        top_imdb_ratings_plot <- top_imdb_ratings_plot[order(top_imdb_ratings_plot$Rating, decreasing = T), ]
        top_imdb_ratings_plot <- head(top_imdb_ratings_plot, 10)
        amBarplot(x = "Title", y = "Rating", data = top_imdb_ratings_plot, labelRotation = -45)
    })
    
    output$total_movies <- renderAmCharts({
        total_movies <- filtered_data()
        total_movies <- as.data.frame(table(total_movies$Year))
        colnames(total_movies) <- c("Year", "Movies")
        amBarplot(x = "Year", y = "Movies", data = total_movies,labelRotation = -45)
    })
      
 })

# # Running the App

shinyApp(ui,server)


