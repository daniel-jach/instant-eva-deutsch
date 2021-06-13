IstantEva Deutsch
================

## Beschreibung

-   **InstantEva Deutsch** steht für *Tafelfertige Evaluation auf
    Deutsch*
-   Instant**Eva** Deutsch ist eine interaktive online Anwendung für
    studentische Kursevaluationen.
-   **Instant**Eva Deutsch ist wie Fertignudeln: schnell, einfach und
    alles in einem (Umfrage, Analyse und Zusammenfassung).
-   InstantEva **Deutsch** ist im Moment nur auf Deutsch verfügbar.

Eine Demoversion von InstantEva Deutsch gibt’s
<a href='https://danieljach.shinyapps.io/instant-eva-deutsch/' target='_blank'>hier</a>.

Die Anwendung ist in *R* (R Core Team 2013) geschrieben und nutzt
*shiny* (Chang et al. 2020).

## Anwendung

Um die **Demoversion** von InstantEva Deutsch zu installieren, führen
Sie folgende Schritte aus:

1.  Clonen Sie das Repository auf Ihren Computer.
2.  Führen Sie die Skript-Datei *setupSQLite.R* aus.
3.  Laden Sie *app.R*, *evasdatabase.db* und *summary.Rmd* auf
    <a href='https://www.shinyapps.io/' target='_blank'>shinyapps.io</a>
    hoch.

Für eine **Vollversion** von InstantEva Deutsch benötigen Sie eine
Remote-MySQL-Datenbank. Anschließend führen Sie folgende Schritte aus:

1.  Clonen Sie das Repository auf Ihren Computer.
2.  Führen Sie die Skript-Datei *setupMySQL.R* aus.
3.  Lesen Sie durch die Skript-Datei *app.R*. Kommentieren Sie alle
    Code-Chunks für die Nutzung von SQLite-Datenbanken aus und
    aktivieren Sie stattdessen alle Code-Chunks für die Nutzung von
    MySQL-Datenbanken.
4.  Tragen Sie die Anmeldedaten zu Ihrer Datenbank in *app.R* und
    *summary.Rmd* ein.
5.  Laden Sie *app.R* und *summary.Rmd* auf
    <a href='https://www.shinyapps.io/' target='_blank'>shinyapps.io</a>
    hoch.

## GFL-Dateien

Die *GFL*-Dateien enthalten einen anderen Fragebogen mit Fragen für
Fremdsprachenkurse. Um diesen Fragebogen zu nutzen, führen Sie die
Installationsschritte mit den *GFL*-Dateien aus.

## Description

-   **InstantEva Deutsch** stands for *Instant Evaluation in German*.
-   Instant**Eva** Deutsch is an interactive online application for
    student course evaluations.
-   **Instant**Eva Deutsch is like instant noodles: quick, easy, and
    all-in-one (survey, analysis, and summary).
-   InstantEva **Deutsch** is currently only available in German.

A demo version of InstantEva Deutsch is available
<a href='https://danieljach.shinyapps.io/instant-eva-deutsch/' target='_blank'>here</a>.

The application is written in *R* (R Core Team 2013) and uses *shiny*
(Chang et al. 2020).

## Usage

For the **demo version** of InstantEva Deutsch, do the following:

1.  Clone the repository to your local machine.
2.  Run the script file *setupSQLite.R*.
3.  Upload the files *app.R*, *evasdatabase.db*, and *summary.Rmd* to
    <a href='https://www.shinyapps.io/' target='_blank'>shinyapps.io</a>.

For the **full version** of InstantEva Deutsch, a remote MySQL database
is needed. Then, do the following:

1.  Clone the repository to your local machine.
2.  Run the script file *setupMySQL.R*.
3.  Go through the *app.R* script file. Comment out the code chunks that
    are for use with SQLite databases and uncomment the code chunks that
    are for use with MySQL databases.
4.  Specify the credentials of your remote MySQL database in the files
    *app.R* and *summary.Rmd*.
5.  Upload the files *app.R* and *summary.Rmd* to
    <a href='https://www.shinyapps.io/' target='_blank'>shinyapps.io</a>.

## GFL files

The *GFL* files contain another questionnaire with questions adapted to
the use in German as a foreign language classrooms. To use this version,
run through the setup with the *GFL* files instead.

## Author

Daniel Jach &lt;danieljach@protonmail.com&gt;

## License and Copyright

© Daniel Jach, University of Zhengzhou, China

Licensed under the [MIT License](LICENSE).

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-Chang.2020" class="csl-entry">

Chang, Winston, Joe Cheng, JJ Allaire, Yihui Xie, and Jonathan
McPherson. 2020. *Shiny: Web Application Framework for r*.
<https://CRAN.R-project.org/package=shiny>.

</div>

<div id="ref-RCT.2013" class="csl-entry">

R Core Team. 2013. *R: A Language and Environment for Statistical
Computing*. Vienna, Austria: R Foundation for Statistical Computing.
<https://www.R-project.org/>.

</div>

</div>
