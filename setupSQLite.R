# Run this script to setup the local SQLite database

library(data.table)
library(RSQLite)
library(dplyr)

# Setup database
db<-dbConnect(RSQLite::SQLite(), "evasdatabase.db")

# Create entries table and example seminar
entries<-data.frame(matrix(ncol = 9, nrow = 0))
colnames(entries)<-c("ID", "PW1", "PW2", "DATE", "NAME", "TITLE", "SEMESTER", "UNIVERSITY", "PARTICIPANTS")
entries<-entries %>%
  mutate_all(as.character)
dt<-data.table(matrix(ncol = 18, nrow = 0))

# Write tables to database
query<-sprintf("INSERT INTO entries VALUES('%s','%s','%s','%s','%s','%s','%s','%s', '%s')", "Beispielseminar", "Passwort1" , "Passwort2", "2030-12-12", "Dr phil Max Mustermann", "Was heißt und zu welchem Ende studiert man Geisteswissenschaften? Eine Einführung in die Arbeitslosigkeit", "Wintersemester 2007", "Universität Mannheim", "25")
dbWriteTable(db, "entries", entries, row.names = FALSE, overwrite=TRUE)
dbExecute(db, query)
dbWriteTable(db, "Beispielseminar", dt, row.names = FALSE, overwrite = TRUE)

# Add values to example seminar
dbExecute(db, sprintf("INSERT INTO Beispielseminar VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')", "5", "3" , "2", "4", "1", "2", "3", "0", "5","5", "3", "2", "4", "1", "2", "3", "0", "5"))
dbExecute(db, sprintf("INSERT INTO Beispielseminar VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')", "4", "2" , "4", "4", "0", "4", "1", "2", "4","0", "2", "1", "5", "4", "3", "1", "5", "3"))
dbExecute(db, sprintf("INSERT INTO Beispielseminar VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')", "2", "1" , "2", "5", "3", "4", "0", "4", "1", "2", "4", "0", "3", "1", "1", "5", "2", "4"))
dbExecute(db, sprintf("INSERT INTO Beispielseminar VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')", "3", "0" , "3", "4", "5", "1", "2", "5", "2", "1", "4", "1", "2", "3", "2", "4", "0", "5"))
dbExecute(db, sprintf("INSERT INTO Beispielseminar VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')", "1", "2" , "5", "1", "2", "0", "3", "5", "2", "1", "5", "2", "0", "3", "1", "5", "2", "4"))
dbExecute(db, sprintf("INSERT INTO Beispielseminar VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')", "2", "1" , "4", "0", "2", "1", "4", "4", "1", "2", "4", "1", "1", "3", "1", "5", "3", "5"))
dbExecute(db, sprintf("INSERT INTO Beispielseminar VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')", "1", "2" , "3", "1", "3", "0", "4", "4", "1", "2", "3", "2", "2", "2", "1", "5", "3", "4"))
dbExecute(db, sprintf("INSERT INTO Beispielseminar VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')", "2", "1" , "4", "0", "2", "1", "4", "4", "1", "2", "4", "1", "1", "3", "1", "5", "3", "5"))
dbExecute(db, sprintf("INSERT INTO Beispielseminar VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')", "2", "1" , "2", "5", "3", "4", "0", "4", "1", "2", "4", "0", "3", "1", "1", "5", "2", "4"))
dbExecute(db, sprintf("INSERT INTO Beispielseminar VALUES('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')", "5", "3" , "2", "4", "1", "2", "3", "0", "5","5", "3", "2", "4", "1", "2", "3", "0", "5"))

dbDisconnect(db)