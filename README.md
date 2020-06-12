IstantEva Deutsch
================

Description
-----------

-   **InstantEva Deutsch** stands for *Instant Evaluation in German*.
-   Instant**Eva** Deutsch is an interactive online application for student course evaluations.
-   **Instant**Eva Deutsch is like instant noodles: quick, easy, and all-in-one (survey, analysis, and summary).
-   InstantEva **Deutsch** is currently only available in German.
-   Recently, the application sometimes does not load because of connectivity problems related to the COVID-19 shutdown.

A demo version of InstantEva Deutsch is available <a href='https://danieljach.shinyapps.io/instant-eva-deutsch/' target='_blank'>here</a>.

The application is written in *R* (R Core Team 2013) and uses *shiny* (Chang et al. 2020).

Usage
-----

For the **demo version** of InstantEva Deutsch, do the following:

1.  Clone the repository to your local machine.
2.  Run the script file *setupSQLite.R*.
3.  Upload the files *app.R*, *evasdatabase.db*, and *summary.Rmd* to shinyapps.io.

For the **full version** of InstantEva Deutsch, a remote MySQL database is needed. Then, do the following:

1.  Clone the repository to your local machine.
2.  Run the script file *setupMySQL.R*.
3.  Go through the *app.R* script file. Comment out the code chunks that are for use with SQLite databases and uncomment the code chunks that are for use with MySQL databases.
4.  Specify the credentials of your remote MySQL database where needed (i.e. in the files *app.R* and *summary.Rmd*).
5.  Upload the files *app.R* and *summary.Rmd* to shinyapps.io.

Author
------

Daniel Jach &lt;danieljach@protonmail.com&gt;

License and Copyright
---------------------

© Daniel Jach, University of Zhengzhou, China

Licensed under the [MIT License](LICENSE).

References
----------

Chang, Winston, Joe Cheng, JJ Allaire, Yihui Xie, and Jonathan McPherson. 2020. *Shiny: Web Application Framework for R*. <https://CRAN.R-project.org/package=shiny>.

R Core Team. 2013. *R: A Language and Environment for Statistical Computing*. Vienna, Austria: R Foundation for Statistical Computing. <https://www.R-project.org/>.
