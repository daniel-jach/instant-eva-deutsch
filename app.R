library(shiny)
library(shinydashboard)
library(shinyjs)
library(data.table)

# # Use this to connect to your remote MySQL database
# library(RMySQL)
# # Specify the credential sof your remote MySQL database
# options(mysql = list(
#   "host" = "",
#   "port" = ,
#   "user" = "",
#   "password" = ""
# ))
# databaseName<-""
# # 

# Use this to connect to your local SQLite database
library(RSQLite)
#

### Connect to database and retrieve entries

# # Use this with remote MySQL db
# db<-dbConnect(RMySQL::MySQL(), dbname = databaseName, host = options()$mysql$host, port = options()$mysql$port, user = options()$mysql$user, password = options()$mysql$password)
# #

# Use this with local SQLite db
Sys.chmod("./evasdatabase.db", mode = "777", use_umask = TRUE)
db<-dbConnect(RSQLite::SQLite(), "evasdatabase.db")
#

ID<-dbGetQuery(db, "SELECT id FROM entries")$id
PW1<-dbGetQuery(db, "SELECT pw1 FROM entries")$pw1
PW2<-dbGetQuery(db, "SELECT pw2 FROM entries")$pw2
DATE<-dbGetQuery(db, "SELECT date FROM entries")$date

if(length(DATE) > 0){
  today<-Sys.Date()
  tooOld<-which(today-as.Date(DATE) > 7)
  if(length(tooOld) > 0){
    on.exit(dbDisconnect(db))
    tooOld<-ID[tooOld]
    lapply(tooOld, function(x) dbRemoveTable(db, x))
    lapply(tooOld, function(x) dbGetQuery(db, paste("DELETE FROM entries WHERE id = '", x, "'", sep = "", collapse = "")))
    ID<-ID[-tooOld]
    PW1<-PW1[-tooOld]
    PW2<-PW2[-tooOld]
    DATE<-DATE[-tooOld]
  }
}

dbDisconnect(db)

###

ui <- dashboardPage(
  dashboardHeader(title = "InstantEva Deutsch"),
  
  dashboardSidebar(sidebarMenu(
    menuItem("Lehrende", tabName = "teacherInput", icon = icon("chalkboard-teacher")),
    menuItem("Studierende", tabName = "studentInput", icon = icon("user-graduate")),
    menuItem("Auswertung", tabName = "output", icon = icon("chart-bar")),
    menuItem("Kontakt", tabName = "contact", icon = icon("id-card"))
  )
  ),
  
  dashboardBody(
    tabItems(
      
      # teacher input
      tabItem(tabName = "teacherInput",
              fluidRow(
                box(title = "Anleitung", width = 12, 
                    helpText(HTML("<b>Dies ist eine Demo. Eingegebene Daten werden gelöscht, wenn Sie InstantEva schließen (&bdquo;no persistent data storage&ldquo;), und die parallele Eingabe mehrerer Nutzer ist nicht möglich (&bdquo;no user input concurrency&ldquo;). Hierfür benötigen Sie eine Remote-Datenbank. Wie Sie Ihre Remote-Datenbank mit InstantEva verbinden, erfahren Sie hier: <a href='https://github.com/daniel-jach/instant-eva-deutsch' target='_blank'>https://github.com/daniel-jach/instant-eva-deutsch</a>.</b>")),
                    helpText(HTML("Um Ihr Seminar anzumelden, machen Sie bitte die nötigen Angaben und drücken dann auf <i>Eingabe</i>. <b>Beachten Sie</b>: Ihre Daten werden nach sieben Tagen vollständig und unwiderruflich gelöscht."))),
                box(title = "Grundangaben", 
                    textInput("inputName", label = "Lehrender"), 
                    textInput("inputTitle", label = "Seminartitel"),
                    textInput("inputYear", label = "Semester"),
                    textInput("inputUni", label = "Institution"),
                    numericInput("inputParticipants", label = "Anzahl der Teilnehmenden", NA, 1, 1000)),
                box(title = "Seminar-ID und Passwörter",
                    helpText(HTML("Geben Sie als ID ein geeignetes Kürzel (z.B. <i>LingoIntroJena2019</i> für eine Einführung in die Linguistik in Jena im Jahr 2019), ein Passwort für Ihre Studierenden und ein Passwort für die Auswertung ein. Bitte vermeiden Sie Umlaute, Punktuation, Leer- und Sonderzeichen.")),
                    textInput("inputID", label = "ID"),
                    textInput("inputPW1", label = "Studierenden-Passwort"),
                    textInput("inputPW2", label = "Passwort Auswertung")),
                box(
                  useShinyjs(),
                  actionButton("teacherInputGo", label = "Eingabe"),
                  textOutput("teacherEntryMessage"))
              )),
      
      # student input
      tabItem(tabName = "studentInput",
              fluidRow(
                box(title = "Anleitung", width = 12, 
                    helpText(HTML("Wählen Sie das richtige Seminar aus der Dropdown-Liste aus und geben Sie das Passwort ein, das Ihnen Ihr Lehrender mitgeteilt hat. Das Passwort für das Beispielseminar lautet <i>Passwort1</i>. Wenn Ihr Seminar nicht angezeigt wird, warten Sie einige Minuten und laden Sie <i>InstantEva Deutsch</i> dann noch einmal. Geben Sie dann Ihre Einschätzung zu jeder Aussage ab, indem Sie den zugehörigen Schieberegler auf den passenden Wert einstellen. Wenn Sie keine Einschätzung abgeben möchten, wählen Sie die Frage ab, indem Sie auf das Häkchen klicken. Drücken Sie dann auf <i>Eingabe</i>."))),
                column(width = 6,
                       box(width = 12,
                           selectInput("selectSeminarInput", "Seminar auswählen", c("", ID)),
                           textInput("checkPW1", label = "Passwort")),
                       box(title = "Allgemein", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           checkboxInput("inputBox1", HTML("<b>Insgesamt bin ich mit dem Seminar zufrieden.</b>"), TRUE),
                           sliderInput("inputSlider1", NULL, 1, 5, 3),
                           checkboxInput("inputBox2", HTML("<b>Insgesamt bin ich mit dem/n erworbenen Wissen und Fähigkeiten zufrieden.</b>"), TRUE),
                           sliderInput("inputSlider2", NULL, 1, 5, 3),
                           checkboxInput("inputBox3", HTML("<b>Ich würde das Seminar an Kommilitonen weiterempfehlen.</b>"), TRUE),
                           sliderInput("inputSlider3", NULL, 1, 5, 3)),
                       box(title = "Lehrender", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           checkboxInput("inputBox7", HTML("<b>Der Lehrende hat die Lernziele des Seminars eindeutig vermittelt.</b>"), TRUE),
                           sliderInput("inputSlider7", NULL, 1, 5, 3),
                           checkboxInput("inputBox8", HTML("<b>Der Lehrende ist auf Bedürfnisse, Fragen und Vorschläge der Teilnehmenden eingegangen.</b>"), TRUE),
                           sliderInput("inputSlider8", NULL, 1, 5, 3),
                           checkboxInput("inputBox9", HTML("<b>Der Lehrende war bei Problemen der Teilnehmenden ansprechbar.</b>"), TRUE),
                           sliderInput("inputSlider9", NULL, 1, 5, 3),
                           checkboxInput("inputBox10", HTML("<b>Der Lehrende hat die Unterrichtszeit sinnvoll und nachvollziehbar eingeteilt.</b>"), TRUE),
                           sliderInput("inputSlider10", NULL, 1, 5, 3),
                           checkboxInput("inputBox11", HTML("<b>Der Lehrende hat eine gute Arbeitsatmosphäre geschaffen.</b>"), TRUE),
                           sliderInput("inputSlider11", NULL, 1, 5, 3),
                           checkboxInput("inputBox12", HTML("<b>Der Lehrende hat den Zusammenhang zwischen einzelnen Themen und dem Seminar als Ganzem verdeutlicht.</b>"), TRUE),
                           sliderInput("inputSlider12", NULL, 1, 5, 3))),
                column(width = 6, 
                       box(title = "Seminarinhalte", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           checkboxInput("inputBox13", HTML("<b>Die Seminarinhalte waren gut auf meinen Wissensstand abgestimmt.</b>"), TRUE),
                           sliderInput("inputSlider13", NULL, 1, 5, 3),
                           checkboxInput("inputBox14", HTML("<b>Das Seminar war inhaltlich nachvollziehbar aufgebaut.</b>"), TRUE),
                           sliderInput("inputSlider14", NULL, 1, 5, 3)),
                       box(title = "Lernerfolg", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           checkboxInput("inputBox15", HTML("<b>Das Seminar hat mir das Wissen und die Fähigkeiten vermittelt, mich selbstständig auf diesem Themengebiet weiterzubilden.</b>"), TRUE),
                           sliderInput("inputSlider15", NULL, 1, 5, 3),
                           checkboxInput("inputBox16", HTML("<b>Das Seminar hat meine Fähigkeit verbessert, die vermittelten Inhalte kritisch zu reflektieren.</b>"), TRUE),
                           sliderInput("inputSlider16", NULL, 1, 5, 3)),
                       box(title = "Arbeitsformen und Medien", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           checkboxInput("inputBox17", HTML("<b>Der Unterricht war vielseitig und abwechslungsreich gestaltet.</b>"), TRUE),
                           sliderInput("inputSlider17", NULL, 1, 5, 3),
                           checkboxInput("inputBox18", HTML("<b>Die eingesetzten Arbeitsformen und Medien haben zu meinem Verständnis und Lernerfolg beigetragen.</b>"), TRUE),
                           sliderInput("inputSlider18", NULL, 1, 5, 3)),
                       box(title = "Teilnehmende", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           checkboxInput("inputBox4", HTML("<b>Die meisten Teilnehmenden sind regelmäßig zum Seminar gekommen.</b>"), TRUE),
                           sliderInput("inputSlider4", NULL, 1, 5, 3),
                           checkboxInput("inputBox5", HTML("<b>Die meisten Teilnehmenden haben aktiv im Seminar mitgearbeitet.</b>"), TRUE),
                           sliderInput("inputSlider5", NULL, 1, 5, 3),
                           checkboxInput("inputBox6", HTML("<b>Die meisten Teilnehmenden sind dem Seminar aufmerksam gefolgt.</b>"), TRUE),
                           sliderInput("inputSlider6", NULL, 1, 5, 3)),
                       box(width = 12,
                           useShinyjs(),
                           actionButton("studentInputGo", label = "Eingabe"),
                           textOutput("studentEntryMessage"))
                ))
      ),
      
      # output
      tabItem(tabName = "output", 
              fluidRow(
                box(title = "Anleitung", width = 12, 
                    helpText(HTML("Wählen Sie Ihr Seminar aus der Dropdown-Liste aus und geben Sie das Passwort für die Auswertung ein. Das Passwort für das Beispielseminar lautet <i>Passwort2</i>. Wenn Ihr Seminar nicht angezeigt wird, warten Sie einige Minuten und laden Sie <i>InstantEva Deutsch</i> dann noch einmal. Drücken Sie dann auf <i>Auswertung beginnen</i>. Um eine Zusammenfassung im PDF-Format zu erzeugen, klicken Sie auf <i>Herunterladen</i>. Die Erzeugung dauert einen Moment.<br><br>Die Ergebnisse werden in Form von Boxplots abgebildet: Die orange Box steht für die mittleren 50 Prozent der Antworten, der vertikale Strich in der Box für den Median, die umgebenden gestrichelten Elemente für die tieferen und höheren Werte. Einzelne extreme Werte werden als Punkte angezeigt."))),
                column(width = 6,
                       box(width = 12,
                           selectInput("selectSeminarOutput", "Seminar auswählen", ID),
                           textInput("checkPW2", label = "Passwort"),
                           actionButton("outputGo", label = "Auswertung beginnen"),
                           br(),
                           br(),
                           useShinyjs(),
                           hidden(downloadButton("summary", "Herunterladen")),
                           textOutput("outputMessage")),
                       box(title = "Allgemein", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           tags$b("Insgesamt bin ich mit dem Seminar zufrieden."), 
                           plotOutput("plot1", height = "100px"),
                           tags$b("Insgesamt bin ich mit dem/n erworbenen Wissen und Fähigkeiten zufrieden."),
                           plotOutput("plot2", height = "100px"),
                           tags$b("Ich würde das Seminar an Kommilitonen weiterempfehlen."),
                           plotOutput("plot3", height = "100px")
                       ),
                       box(title = "Lehrender", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           tags$b("Der Lehrende hat die Lernziele des Seminars eindeutig vermittelt."), 
                           plotOutput("plot7", height = "100px"),
                           tags$b("Der Lehrende ist auf Bedürfnisse, Fragen und Vorschläge der Teilnehmenden eingegangen."), 
                           plotOutput("plot8", height = "100px"),
                           tags$b("Der Lehrende war bei Problemen der Teilnehmenden ansprechbar."), 
                           plotOutput("plot9", height = "100px"),
                           tags$b("Der Lehrende hat die Unterrichtszeit sinnvoll und nachvollziehbar eingeteilt."), 
                           plotOutput("plot10", height = "100px"),
                           tags$b("Der Lehrende hat eine gute Arbeitsatmosphäre geschaffen."), 
                           plotOutput("plot11", height = "100px"),
                           tags$b("Der Lehrende hat den Zusammenhang zwischen einzelnen Themen und dem Seminar als Ganzem verdeutlicht."), 
                           plotOutput("plot12", height = "100px"))),
                column(width = 6, 
                       box(title = "Seminarinhalte", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           tags$b("Die Seminarinhalte waren gut auf meinen Wissensstand abgestimmt."), 
                           plotOutput("plot13", height = "100px"),
                           tags$b("Das Seminar war inhaltlich nachvollziehbar aufgebaut."), 
                           plotOutput("plot14", height = "100px")),
                       box(title = "Lernerfolg", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           tags$b("Das Seminar hat mir das Wissen und die Fähigkeiten vermittelt, mich selbstständig auf diesem Themengebiet weiterzubilden."), 
                           plotOutput("plot15", height = "100px"),
                           tags$b("Das Seminar hat meine Fähigkeit verbessert, die vermittelten Inhalte kritisch zu reflektieren."), 
                           plotOutput("plot16", height = "100px")),
                       box(title = "Arbeitsformen und Medien", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           tags$b("Der Unterricht war vielseitig und abwechslungsreich gestaltet."), 
                           plotOutput("plot17", height = "100px"),
                           tags$b("Die eingesetzten Arbeitsformen und Medien haben zu meinem Verständnis und Lernerfolg beigetragen."), 
                           plotOutput("plot18", height = "100px")),
                       box(title = "Teilnehmende", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           tags$b("Die meisten Teilnehmenden sind regelmäßig zum Seminar gekommen."), 
                           plotOutput("plot4", height = "100px"),
                           tags$b("Die meisten Teilnehmenden haben aktiv im Seminar mitgearbeitet."), 
                           plotOutput("plot5", height = "100px"),
                           tags$b("Die meisten Teilnehmenden sind dem Seminar aufmerksam gefolgt."), 
                           plotOutput("plot6", height = "100px"))
                       
                )
                
                
              )),
      
      # contact
      tabItem(tabName = "contact",
              box(HTML("Kontaktieren Sie mich gern über meine Webseite, wenn Sie Fragen, Wünsche, Anregungen oder Kritik haben.<br><br>Daniel Jach<br>Zhengzhou Universität<br>Henan, China<br><a href='https://daniel-jach.github.io/'>https://daniel-jach.github.io/</a><br><br>Den Code von InstantEva Deutsch und weitere Infos finden Sie hier:<br><a href='https://github.com/daniel-jach/instant-eva-deutsch target='_blank''>https://github.com/daniel-jach/instant-eva-deutsch</a>")))
    )
  )
)



server <- function(input, output) { 
  
  # teacher input ID and password
  teacherEntryMessage<-eventReactive( input$teacherInputGo, {
    
    id<-as.character(input$inputID)
    pw1<-as.character(input$inputPW1)
    pw2<-as.character(input$inputPW2)
    name<-as.character(input$inputName)
    title<-as.character(input$inputTitle)
    year<-as.character(input$inputYear)
    uni<-as.character(input$inputUni)
    part<-as.character(input$inputParticipants)
    
    if(nchar(name) < 1 | nchar(title) < 1 | nchar(year) < 1 | nchar(uni) < 1 | is.na(part)){
      return("Geben Sie bitte Ihren Namen, Seminartitel, Semester, Institution und die Anzahl der Teilnehmenden an.")
    }
    else if(nchar(id) < 1){
      return("Bitte geben Sie eine ID ein.")
    }
    else if(id %in% ID){
      return("Diese ID ist schon vorhanden.")
    }
    else if(nchar(pw1) < 1 | nchar(pw2) < 1){
      return("Bitte geben Sie zwei Passwörter ein.")
    }
    else if(pw1 %in% PW1 | pw2 %in% PW2){
      return("Dieses Passwörter sind schon vergeben.")
    }
    else if(pw1 == pw2){
      return("Bitte geben Sie zwei verschiedene Passwörter ein.")
    }
    else{
      
      # prepare
      entry<-list(ID=id, PW1=pw1, PW2=pw2, DATE=as.character(Sys.Date()), NAME=name, TITLE=title, YEAR=year, UNI=uni, PART=part)
      dt<-data.table(matrix(ncol = 18, nrow = 0))
      
      # write new seminar to database
      query<-sprintf("INSERT INTO entries VALUES('%s','%s','%s','%s','%s','%s','%s','%s', '%s')", id, pw1 , pw2, as.character(Sys.Date()), name, title, year, uni, part)
      
      # # Use this with remote MySQL db
      # db<-dbConnect(RMySQL::MySQL(), dbname = databaseName, host = options()$mysql$host, port = options()$mysql$port, user = options()$mysql$user, password = options()$mysql$password)
      # # 
      
      # Use this with local SQLite db
      db<-dbConnect(RSQLite::SQLite(), "evasdatabase.db")
      # 
      
      dbExecute(db, query)
      dbWriteTable(db, id, dt, row.names = FALSE) # add empty datatable
      
      on.exit(dbDisconnect(db))
      
      # disable student submit button after successful submission
      
      hide("teacherInputGo")
      
      return("Alles klar, Ihr Seminar ist jetzt angemeldet.")
    }
  })
  
  # generate text output for teacher
  output$teacherEntryMessage <- renderText({
    teacherEntryMessage()
  })
  
  
  # write student input to database
  studentEntryMessage<-eventReactive( input$studentInputGo, {
    
    id<-as.character(input$selectSeminarInput) 
    pw1<-as.character(input$checkPW1)
    
    if(nchar(id) < 1){
      return("Bitte wählen Sie erst ein Seminar aus.")
    }
    else if(pw1 != PW1[which(id == ID)]){
      return("Das eingegebene Passwort ist falsch.")
    }
    else{
      
      # input check boxes 
      boxes<-c(input$inputBox1, input$inputBox2, input$inputBox3, input$inputBox4, input$inputBox5, input$inputBox6, input$inputBox7, input$inputBox8, input$inputBox9, input$inputBox10, input$inputBox11, input$inputBox12, input$inputBox13, input$inputBox14, input$inputBox15, input$inputBox16, input$inputBox17, input$inputBox18)
      
      # input sliders
      sliders<-c(input$inputSlider1, input$inputSlider2, input$inputSlider3, input$inputSlider4, input$inputSlider5, input$inputSlider6, input$inputSlider7, input$inputSlider8, input$inputSlider9, input$inputSlider10, input$inputSlider11, input$inputSlider12, input$inputSlider13, input$inputSlider14, input$inputSlider15, input$inputSlider16, input$inputSlider17, input$inputSlider18)
      
      # replace unchecked with zero
      sliders[which(boxes == FALSE)]<-0
      
      # write input to database 
      query<-paste("INSERT INTO", id, sprintf("VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')", sliders[1],sliders[2],sliders[3],sliders[4],sliders[5],sliders[6],sliders[7],sliders[8],sliders[9],sliders[10],sliders[11],sliders[12],sliders[13],sliders[14],sliders[15],sliders[16],sliders[17],sliders[18]))
      
      # # Use this with remote MySQL db
      # db<-dbConnect(RMySQL::MySQL(), dbname = databaseName, host = options()$mysql$host, port = options()$mysql$port, user = options()$mysql$user, password = options()$mysql$password)
      # # 
      
      # Use this with local SQLite db
      db<-dbConnect(RSQLite::SQLite(), "evasdatabase.db")
      # 
      
      dbExecute(db, query)
      on.exit(dbDisconnect(db))
      
      # disable student submit button after successful submission
      if(nchar(id) > 0 & pw1 == PW1[which(id == ID)]){
        hide("studentInputGo")}
      
      return("Vielen Dank für Ihre Eingabe.")
    }
  }
  )
  
  # generate text output for students
  output$studentEntryMessage<-renderText({
    studentEntryMessage()
  }
  )
  
  
  ### data output #############
  outData<-eventReactive( input$outputGo, {
    
    id<-as.character(input$selectSeminarOutput)
    pw2<-as.character(input$checkPW2)
    
    # load database
    queryData<-paste("SELECT * FROM", id, collapse = "")
    
    # # Use this with remote MySQL db
    # db<-dbConnect(RMySQL::MySQL(), dbname = databaseName, host = options()$mysql$host, port = options()$mysql$port, user = options()$mysql$user, password = options()$mysql$password)
    # # 
    
    # Use this with local SQLite db
    db<-dbConnect(RSQLite::SQLite(), "evasdatabase.db")
    # 
    
    data<-dbGetQuery(db, queryData)
    on.exit(dbDisconnect(db))
    
    if(pw2 == PW2[which(id == ID)]){
      if(nrow(data) > 0){
        data[data==0]<-NA
      }
      return(data)}
    else{
      return(NULL)
    }
  }
  )
  
  outputMessage<-eventReactive( input$outputGo, {
    data<-outData()
    if(is.null(data)){
      return(print("Das eingegebene Passwort ist falsch."))
    }else if(nrow(data) == 0){
      return(print("Für Ihr Seminar liegen noch keine Bewertungen vor."))
    }else{
      shinyjs::show("summary") # trigger download button
      
      id<-as.character(input$selectSeminarOutput)
      date<-DATE[which(id == ID)]
      days<-(Sys.Date()-(as.Date(date)+7))*-1
      return(print(paste("Ihr Ergebnisse sind noch für", days, "Tage gespeichert.")))
    }
  })
  
  output$outputMessage<-renderText({
    outputMessage()
  })
  
  
  # generate output
  output$plot1<-renderPlot({
    dt<-outData()
    dt<-dt[,1]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plot2<-renderPlot({
    dt<-outData()
    dt<-dt[,2]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plot3<-renderPlot({
    dt<-outData()
    dt<-dt[,3]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plot4<-renderPlot({
    dt<-outData()
    dt<-dt[,4]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plot5<-renderPlot({
    dt<-outData()
    dt<-dt[,5]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plot6<-renderPlot({
    dt<-outData()
    dt<-dt[,6]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plot7<-renderPlot({
    dt<-outData()
    dt<-dt[,7]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plot8<-renderPlot({
    dt<-outData()
    dt<-dt[,8]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plot9<-renderPlot({
    dt<-outData()
    dt<-dt[,9]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plot10<-renderPlot({
    dt<-outData()
    dt<-dt[,10]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plot11<-renderPlot({
    dt<-outData()
    dt<-dt[,11]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plot12<-renderPlot({
    dt<-outData()
    dt<-dt[,12]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plot13<-renderPlot({
    dt<-outData()
    dt<-dt[,13]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plot14<-renderPlot({
    dt<-outData()
    dt<-dt[,14]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  
  output$plot15<-renderPlot({
    dt<-outData() 
    dt<-dt[,15]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plot16<-renderPlot({
    dt<-outData()
    dt<-dt[,16]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plot17<-renderPlot({
    dt<-outData()
    dt<-dt[,17]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plot18<-renderPlot({
    dt<-outData()
    dt<-dt[,18]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  # generate PDF with LaTeX
  output$summary <- downloadHandler(
    filename = function() {
      "Zusammenfassung.pdf"
    },
    content = function(con) {
      
      params<-list(n = input$selectSeminarOutput)
      
      rmarkdown::render("summary.Rmd",
                        output_file = con,
                        envir = new.env())
    }
  )
  
  
  
}


onStop(function() { # close all database connections on user exit
  all_cons <- dbListConnections(MySQL())
  for(con in all_cons)
    + dbDisconnect(con)
})

shinyApp(ui, server)
