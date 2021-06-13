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

ID<-dbGetQuery(db, "SELECT id FROM entries")$ID
PW1<-dbGetQuery(db, "SELECT pw1 FROM entries")$PW1
PW2<-dbGetQuery(db, "SELECT pw2 FROM entries")$PW2
DATE<-dbGetQuery(db, "SELECT date FROM entries")$DATE

if(length(DATE) > 0){
  today<-Sys.Date()
  tooOld<-which(today-as.Date(DATE) > 21)
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
    menuItem("Studierende", tabName = "studentInput", icon = icon("user-graduate")),
    menuItem("Lehrende", tabName = "teacherInput", icon = icon("chalkboard-teacher")),
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
                    helpText(HTML("Um Ihren Kurs anzumelden, machen Sie bitte die nötigen Angaben und drücken dann auf <i>Eingabe</i>. <b>Beachten Sie</b>: Ihre Daten werden nach sieben Tagen vollständig und unwiderruflich gelöscht."))),
                box(title = "Grundangaben", 
                    textInput("inputName", label = "Lehrender"), 
                    textInput("inputTitle", label = "Kurstitel"),
                    textInput("inputYear", label = "Semester"),
                    textInput("inputUni", label = "Institution"),
                    numericInput("inputParticipants", label = "Anzahl der Teilnehmenden", NA, 1, 1000)),
                box(title = "Kurs-ID und Passwörter",
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
                    helpText(HTML("Wählen Sie den richtigen Kurs aus der Dropdown-Liste aus und geben Sie das Passwort ein, das Ihnen Ihr Lehrender mitgeteilt hat. Das Passwort für das Beispielkurs lautet <i>Passwort1</i>. Wenn Ihr Kurs nicht angezeigt wird, warten Sie einige Minuten und laden Sie <i>InstantEva Deutsch</i> dann noch einmal. Geben Sie dann Ihre Einschätzung zu jeder Aussage ab, indem Sie den zugehörigen Schieberegler auf den passenden Wert einstellen. Wenn Sie keine Einschätzung abgeben möchten, wählen Sie die Frage ab, indem Sie auf das Häkchen klicken. Drücken Sie dann auf <i>Eingabe</i>."))),
                column(width = 6,
                       box(width = 12,
                           selectInput("selectSeminarInput", "Kurs auswählen", c("", ID)),
                           textInput("checkPW1", label = "Passwort")),
                       
                       box(title = "Persönliches", width = 12, 
                           numericInput("learnYears", HTML("<b>Wie viele Jahre lernen Sie schon Deutsch?</b>"), 2, min = 1, max = 100, step = 0.5),
                           radioButtons("germanCentral", HTML("<b>Ist Deutsch ein zentraler Bestandteil Ihres Studiums?</b>"), choices = c("Keine Ahnung" = "9", "Ja" = "1", "Nein" = "2")),
                           sliderInput("germanImportant", HTML("<b>Wie wichtig ist es Ihnen persönlich, Deutsch zu lernen?</b>"), 1, 5, 3), 
                           p(helpText(HTML("1 = überhaupt nicht wichtig &harr; 5 = sehr wichtig")), align = "center"),
                           numericInput("learnWeekly", HTML("<b>Wie viele Stunden lernen Sie Deutsch vor und nach dem Unterricht insgesamt jede Woche?</b>"), 2, min = 1, max = 100, step = 0.5)
                           ),
                       
                       box(title = "Allgemein", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           checkboxInput("boxSatisfied", HTML("<b>Insgesamt bin ich mit dem Kurs zufrieden.</b>"), TRUE),
                           sliderInput("sliderSatisfied", NULL, 1, 5, 3),
                           checkboxInput("boxRecommend", HTML("<b>Ich würde den Kurs an Kommilitonen weiterempfehlen.</b>"), TRUE),
                           sliderInput("sliderRecommend", NULL, 1, 5, 3)),
                       box(title = "Lehrender", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           checkboxInput("boxTeacherResponds", HTML("<b>Der Lehrende ist auf Bedürfnisse und Fragen der Teilnehmenden eingegangen.</b>"), TRUE),
                           sliderInput("sliderTeacherResponds", NULL, 1, 5, 3),
                           checkboxInput("boxTeacherHelps", HTML("<b>Der Lehrende hat mir bei Lernproblemen geholfen.</b>"), TRUE),
                           sliderInput("sliderTeacherHelps", NULL, 1, 5, 3),
                           checkboxInput("boxTeacherOrganizes", HTML("<b>Der Lehrende hat die Unterrichtszeit sinnvoll und nachvollziehbar eingeteilt.</b>"), TRUE),
                           sliderInput("sliderTeacherOrganizes", NULL, 1, 5, 3),
                           checkboxInput("boxTeacherAtmosphere", HTML("<b>Der Lehrende hat eine gute Arbeitsatmosphäre geschaffen.</b>"), TRUE),
                           sliderInput("sliderTeacherAtmosphere", NULL, 1, 5, 3)
                           )),
                       
                column(width = 6, 
                       
                       box(title = "Kursinhalte", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           checkboxInput("boxCourseLevel", HTML("<b>Der Kurs war gut auf mein Sprachniveau abgestimmt.</b>"), TRUE),
                           sliderInput("sliderCourseLevel", NULL, 1, 5, 3),
                           checkboxInput("boxCourseDiverse", HTML("<b>Der Unterricht war vielseitig und abwechslungsreich gestaltet.</b>"), TRUE),
                           sliderInput("sliderCourseDiverse", NULL, 1, 5, 3),
                           checkboxInput("boxCourseSpeaking", HTML("<b>Ich hatte im Unterricht genug Gelegenheit, Deutsch zu sprechen.</b>"), TRUE),
                           sliderInput("sliderCourseSpeaking", NULL, 1, 5, 3)
                           ),
                       
                       box(title = "Lernerfolg", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           checkboxInput("boxLearningSuccess", HTML("<b>Mein persönlicher Lernerfolg entspricht meinen Erwartungen.</b>"), TRUE),
                           sliderInput("sliderLearningSuccess", NULL, 1, 5, 3),
                           checkboxInput("boxMaterial", HTML("<b>Die eingesetzten Materialien, Arbeitsformen und Medien haben zu meinem Lernerfolg beigetragen.</b>"), TRUE),
                           sliderInput("sliderMaterial", NULL, 1, 5, 3)
                           ),
                       
                       box(title = "Mitarbeit", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           checkboxInput("boxParticipantsPresent", HTML("<b>Die meisten Teilnehmenden sind regelmäßig zum Kurs gekommen.</b>"), TRUE),
                           sliderInput("sliderParticipantsPresent", NULL, 1, 5, 3),
                           checkboxInput("boxParticipantsActive", HTML("<b>Die meisten Teilnehmenden haben aktiv im Kurs mitgearbeitet.</b>"), TRUE),
                           sliderInput("sliderParticipantsActive", NULL, 1, 5, 3),
                           checkboxInput("boxParticipantsAttentive", HTML("<b>Die meisten Teilnehmenden sind dem Kurs aufmerksam gefolgt.</b>"), TRUE),
                           sliderInput("sliderParticipantsAttentive", NULL, 1, 5, 3)),
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
                    helpText(HTML("Wählen Sie Ihr Kurs aus der Dropdown-Liste aus und geben Sie das Passwort für die Auswertung ein. Das Passwort für das Beispielkurslautet <i>Passwort2</i>. Wenn Ihr Kurs nicht angezeigt wird, warten Sie einige Minuten und laden Sie <i>InstantEva Deutsch</i> dann noch einmal. Drücken Sie dann auf <i>Auswertung beginnen</i>. Um eine Zusammenfassung im PDF-Format zu erzeugen, klicken Sie auf <i>Herunterladen</i>. Die Erzeugung dauert einen Moment.<br><br>Die Ergebnisse werden in Form von Boxplots abgebildet: Die orange Box steht für die mittleren 50 Prozent der Antworten, der vertikale Strich in der Box für den Median, die umgebenden gestrichelten Elemente für die tieferen und höheren Werte. Einzelne extreme Werte werden als Punkte angezeigt."))),
                column(width = 6,
                       box(width = 12,
                           selectInput("selectSeminarOutput", "Kurs auswählen", c("", ID)),
                           textInput("checkPW2", label = "Passwort"),
                           actionButton("outputGo", label = "Auswertung beginnen"),
                           br(),
                           br(),
                           useShinyjs(),
                           hidden(downloadButton("summary", "Herunterladen")),
                           textOutput("outputMessage")),
                       
                       box(title = "Teilnehmende", width = 12, 
                           tags$b("Wie viele Jahre lernen Sie schon Deutsch?"), 
                           tableOutput("tableLearnYears"), 
                           tags$b("Ist Deutsch ein zentraler Bestandteil Ihres Studiums?"), 
                           tableOutput("tableGermanCentral"), 
                           tags$b("Wie wichtig ist es Ihnen persönlich, Deutsch zu lernen?"), 
                           plotOutput("plotGermanImportant", height = "100px"),
                           p(helpText(HTML("1 = überhaupt nicht wichtig &harr; 5 = sehr wichtig")), align = "center"),
                           tags$b("Wie viele Stunden lernen Sie Deutsch vor und nach dem Unterricht insgesamt jede Woche?"), 
                           tableOutput("tableLearnWeekly")
                           ),
                       
                       box(title = "Allgemein", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           tags$b("Insgesamt bin ich mit dem Kurs zufrieden."), 
                           plotOutput("plotSatisfied", height = "100px"),
                           tags$b("Ich würde den Kurs an Kommilitonen weiterempfehlen."),
                           plotOutput("plotRecommend", height = "100px")
                       ),
                       
                       box(title = "Lehrender", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           tags$b("Der Lehrende ist auf Bedürfnisse und Fragen der Teilnehmenden eingegangen."), 
                           plotOutput("plotTeacherResponds", height = "100px"),
                           tags$b("Der Lehrende hat mir bei Lernproblemen geholfen."), 
                           plotOutput("plotTeacherHelps", height = "100px"),
                           tags$b("Der Lehrende hat die Unterrichtszeit sinnvoll und nachvollziehbar eingeteilt."), 
                           plotOutput("plotTeacherOrganizes", height = "100px"),
                           tags$b("Der Lehrende hat eine gute Arbeitsatmosphäre geschaffen."), 
                           plotOutput("plotTeacherAtmosphere", height = "100px")
                           )
                       ),
                       
                column(width = 6, 
                       box(title = "Kursinhalte", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           tags$b("Der Kurs war gut auf mein Sprachniveau abgestimmt."), 
                           plotOutput("plotCourseLevel", height = "100px"),
                           tags$b("Der Unterricht war vielseitig und abwechslungsreich gestaltet."), 
                           plotOutput("plotCourseDiverse", height = "100px"),
                           tags$b("Ich hatte im Unterricht genug Gelegenheit, Deutsch zu sprechen."), 
                           plotOutput("plotCourseSpeaking", height = "100px")
                       ),
                       
                       box(title = "Lernerfolg", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           tags$b("Mein persönlicher Lernerfolg entspricht meinen Erwartungen."), 
                           plotOutput("plotLearningSuccess", height = "100px"),
                           tags$b("Die eingesetzten Materialien, Arbeitsformen und Medien haben zu meinem Lernerfolg beigetragen."), 
                           plotOutput("plotMaterial", height = "100px")
                           ),
                       
                       box(title = "Mitarbeit", width = 12,
                           p(helpText(HTML("1 = Ich stimme überhaupt nicht zu. &harr; 5 = Ich stimme voll und ganz zu.")), align = "center"),
                           tags$b("Die meisten Teilnehmenden sind regelmäßig zum Kurs gekommen."), 
                           plotOutput("plotParticipantsPresent", height = "100px"),
                           tags$b("Die meisten Teilnehmenden haben aktiv im Kurs mitgearbeitet."), 
                           plotOutput("plotParticipantsActive", height = "100px"),
                           tags$b("Die meisten Teilnehmenden sind dem Kurs aufmerksam gefolgt."), 
                           plotOutput("plotParticipantsAttentive", height = "100px")
                           )
                       )
                )
                ),
      
      # contact
      tabItem(tabName = "contact",
              box(HTML("Kontaktieren Sie mich gern über meine Webseite, wenn Sie Fragen, Wünsche, Anregungen oder Kritik haben.<br><br>Daniel Jach<br>Shanghai Normal University<br>Shanghai, China<br><a href='https://daniel-jach.github.io/'>https://daniel-jach.github.io/</a><br><br>Den Code von InstantEva Deutsch und weitere Infos finden Sie hier:<br><a href='https://github.com/daniel-jach/instant-eva-deutsch' target='_blank'>https://github.com/daniel-jach/instant-eva-deutsch</a>")))
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
      return("Geben Sie bitte Ihren Namen, Kurstitel, Semester, Institution und die Anzahl der Teilnehmenden an.")
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
      dt<-data.table(matrix(ncol = 18, nrow = 0, dimnames = list(c(), c("satisfied", "recommend", "teacherResponds", "teacherHelps", "teacherOrganizes", "teacherAtmosphere", "courseLevel", "courseDiverse", "courseSpeaking", "learningSuccess", "material", "participantsPresent", "participantsActive", "participantsAttentive", "learnYears", "germanCentral", "germanImportant", "learnWeekly"))))
      
      # write new course to database
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
      
      return("Alles klar, Ihr Kurs ist jetzt angemeldet.")
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
      return("Bitte wählen Sie erst einen Kurs aus.")
    }
    else if(pw1 != PW1[which(id == ID)]){
      return("Das eingegebene Passwort ist falsch.")
    }
    else{
      
      # personal infos
      personal<-c(input$learnYears, input$germanCentral, input$germanImportant, input$learnWeekly)
      
      # input check boxes 
      boxes<-c(input$boxSatisfied, input$boxRecommend, input$boxTeacherResponds, input$boxTeacherHelps, input$boxTeacherOrganizes, input$boxTeacherAtmosphere, input$boxCourseLevel, input$boxCourseDiverse, input$boxCourseSpeaking, input$boxLearningSuccess, input$boxMaterial, input$boxParticipantsPresent, input$boxParticipantsActive, input$boxParticipantsAttentive)
      
      # input sliders
      sliders<-c(input$sliderSatisfied, input$sliderRecommend, input$sliderTeacherResponds, input$sliderTeacherHelps, input$sliderTeacherOrganizes, input$sliderTeacherAtmosphere, input$sliderCourseLevel, input$sliderCourseDiverse, input$sliderCourseSpeaking, input$sliderLearningSuccess, input$sliderMaterial, input$sliderParticipantsPresent, input$sliderParticipantsActive, input$sliderParticipantsAttentive)
      
      # replace unchecked with zero
      sliders[which(boxes == FALSE)]<-0
      
      # write input to database 
      query<-paste("INSERT INTO", id, sprintf("VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')", sliders[1],sliders[2],sliders[3],sliders[4],sliders[5],sliders[6],sliders[7],sliders[8],sliders[9],sliders[10],sliders[11],sliders[12],sliders[13],sliders[14],personal[1],personal[2],personal[3],personal[4]))
      
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
        
          rmv<-vector() # if no input was changed or if SD is zero, remove this line
          for(i in 1:nrow(data)){
            if(
              !any(data[i,] == c(rep(3,14), 2, 9, 2, 3)) | sd(data[i,1:14]) == 0){
              rmv<-append(rmv, i)
            }
          }
          if(length(rmv) != 0){
            data<-data[-rmv,]
          }
          
          data[, 1:14][data[, 1:14] == 0]<-NA # replace 0 with NA for plot data
      }
      return(data)
    }
    
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
      return(print("Für Ihren Kurs liegen noch keine Bewertungen vor."))
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
  
  output$plotSatisfied<-renderPlot({
    dt<-outData()
    dt<-dt[,"satisfied"]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plotRecommend<-renderPlot({
    dt<-outData()
    dt<-dt[,"recommend"]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plotTeacherResponds<-renderPlot({
    dt<-outData()
    dt<-dt[,"teacherResponds"]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plotTeacherHelps<-renderPlot({
    dt<-outData()
    dt<-dt[,"teacherHelps"]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plotTeacherOrganizes<-renderPlot({
    dt<-outData()
    dt<-dt[,"teacherOrganizes"]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plotTeacherAtmosphere<-renderPlot({
    dt<-outData()
    dt<-dt[,"teacherAtmosphere"]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plotCourseLevel<-renderPlot({
    dt<-outData()
    dt<-dt[,"courseLevel"]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plotCourseDiverse<-renderPlot({
    dt<-outData()
    dt<-dt[,"courseDiverse"]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plotCourseSpeaking<-renderPlot({
    dt<-outData()
    dt<-dt[,"courseSpeaking"]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plotLearningSuccess<-renderPlot({
    dt<-outData()
    dt<-dt[,"learningSuccess"]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plotMaterial<-renderPlot({
    dt<-outData()
    dt<-dt[,"material"]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plotParticipantsPresent<-renderPlot({
    dt<-outData() 
    dt<-dt[,"participantsPresent"]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plotParticipantsActive<-renderPlot({
    dt<-outData()
    dt<-dt[,"participantsActive"]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$plotParticipantsAttentive<-renderPlot({
    dt<-outData()
    dt<-dt[,"participantsAttentive"]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$tableLearnYears<-renderTable({
    dt<-outData()
    dt<-dt[,"learnYears"]
    n<-length(dt[!is.na(dt)])
    mean<-round(mean(dt, na.rm = TRUE),0)
    max<-max(dt, na.rm = TRUE)
    min<-min(dt, na.rm = TRUE)
    sd<-round(sd(dt, na.rm = TRUE),0)
    dt<-data.frame(n, mean, sd, min, max)
    colnames(dt)<-c("n", "M", "SD", "Min", "Max")
    dt
  }
  )
  
  output$tableGermanCentral<-renderTable({
    dt<-outData()
    dt<-dt[,"germanCentral"]
    n<-length(dt[!is.na(dt)])
    freq<-table(dt)
    prop<-round(prop.table(freq)*100,0)
    no<-paste(prop["2"], "%", sep = "")
    yes<-paste(prop["1"], "%", sep = "")
    kA<-paste(prop["9"], "%", sep = "")
    dt<-data.frame(n, yes, no, kA)
    dt[grep("NA", dt)]<-"0"
    colnames(dt)<-c("n", "Ja", "Nein", "k.A.")
    dt
  }
  )
  
  output$plotGermanImportant<-renderPlot({
    dt<-outData()
    dt<-dt[,"germanImportant"]
    n<-paste("n = ", length(dt[!is.na(dt)]), sep = "")
    par(mar=c(4,1,1,1))
    boxplot(dt, horizontal = TRUE, ylim = c(1,5), col = "orange", boxwex = .75, frame = FALSE); mtext(n,3)
  }
  )
  
  output$tableLearnWeekly<-renderTable({
    dt<-outData()
    dt<-dt[,"learnWeekly"]
    n<-length(dt[!is.na(dt)])
    mean<-round(mean(dt, na.rm = TRUE),0)
    max<-max(dt, na.rm = TRUE)
    min<-min(dt, na.rm = TRUE)
    sd<-round(sd(dt, na.rm = TRUE),0)
    dt<-data.frame(n, mean, sd, min, max)
    colnames(dt)<-c("n", "M", "SD", "Min", "Max")
    dt
  }
  )
  
  
  # generate PDF with LaTeX
  output$summary <- downloadHandler(
    filename = function() {
      "Zusammenfassung.pdf"
    },
    content = function(con) {
      
      params<-list(n = input$selectSeminarOutput)
      
      rmarkdown::render("summary-GFL.Rmd",
                        output_file = con,
                        envir = new.env())
    }
  )
  
  
  
}

# # Use this with remote MySQL db
# onStop(function() { # close all database connections on user exit
#   all_cons <- dbListConnections(MySQL())
#   for(con in all_cons)
#     + dbDisconnect(con)
# })

shinyApp(ui, server)
