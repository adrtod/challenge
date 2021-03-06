release_questions <- function() {
  c(
    "Have you updated the docs? devtools::document()",
    "Have you updated the website? pkgdown::build_site()"
  )
}

#' @section Installation:
#' Install the R package from \href{https://cran.r-project.org/package=rchallenge}{CRAN} repositories
#' 
#' \code{install.packages("rchallenge")}
#' 
#' or install the latest development version from \href{https://github.com/adrtod/rchallenge}{GitHub}
#' 
#' \code{# install.packages("devtools")}
#' 
#' \code{devtools::install_github("adrtod/rchallenge")}
#' 
#' A recent version of \href{https://pandoc.org/}{pandoc} (>= 1.12.3) is also required. 
#' See the \href{https://pandoc.org/installing.html}{pandoc installation instructions} 
#' for details on installing pandoc for your platform.
#' 
#' @section Getting started:
#' Install a new challenge in \code{Dropbox/mychallenge}:
#' 
#' \code{setwd("~/Dropbox/mychallenge")}
#' 
#' \code{library(rchallenge)}
#' 
#' \code{\link{new_challenge}()}
#' 
#' or for a french version:
#' 
#' \code{\link{new_challenge}(template = "fr")}
#' 
#' You will obtain a ready-to-use challenge in the folder \code{Dropbox/mychallenge} containing:
#' \itemize{ 
#'  \item \code{challenge.rmd}: Template R Markdown script for the webpage.
#'  \item \code{data}: Directory of the data containing \code{data_train} and \code{data_test} datasets.
#'  \item \code{submissions}: Directory of the submissions. It will contain one subdirectory per team where they can submit their submissions. The subdirectories are shared with Dropbox.
#'  \item \code{history}: Directory where the submissions history is stored.
#' }
#' The default challenge provided is a binary classification problem on the \href{https://archive.ics.uci.edu/ml/datasets/South+German+Credit}{South German Credit} data set.
#' 
#' You can easily customize the challenge in two ways:
#'
#' \itemize{ 
#'  \item \emph{During the creation of the challenge}: by using the options of the \code{\link{new_challenge}} function.
#'  \item \emph{After the creation of the challenge}: by manually replacing the data files in the \code{data} subdirectory and the baseline predictions in \code{submissions/baseline} and by customizing the template \code{challenge.rmd} as needed.
#' }
#' 
#' @section Next steps:
#' To complete the installation:
#' \enumerate{
#'  \item Create and \href{https://help.dropbox.com/fr-fr/files-folders/share/share-with-others}{share} subdirectories in \code{submissions} for each team:
#'  
#'    \code{\link{new_team}("team_foo", "team_bar")}
#' 
#'  \item Render the HTML page:
#'    \code{\link{publish}()}
#'    Use the \code{output_dir} argument to change the output directory.
#'    Make sure the output HTML file is rendered, e.g. using \href{https://pages.github.com/}{GitHub Pages}.
#' 
#'  \item Give the URL to your HTML file to the participants.
#'  
#'  \item Refresh the webpage by repeating step 2 on a regular basis. See below for automating this step.
#' }
#' 
#' From now on, a fully autonomous challenge system is set up requiring no further 
#' administration. With each update, the program automatically performs the following
#' tasks using the functions available in our package:
#'   
#' \itemize{ 
#'  \item \code{\link{store_new_submissions}}: Reads submitted files and save new files in the history.
#'  \item \code{\link{print_readerr}}: Displays any read errors.
#'  \item \code{\link{compute_metrics}}: Calculates the scores for each submission in the history.
#'  \item \code{\link{get_best}}: Gets the highest score per team.
#'  \item \code{\link{print_leaderboard}}: Displays the leaderboard.
#'  \item \code{\link{plot_history}}: Plots a chart of score evolution per team.
#'  \item \code{\link{plot_activity}}: Plots a chart of activity per team.
#' }
#' 
#' @section Automating the updates on \strong{Unix/OSX}:
#' 
#' For the step 4, you can setup the following line to your \href{https://en.wikipedia.org/wiki/Cron}{crontab} 
#' using \code{crontab -e} (mind the quotes):
#' 
#' \code{0 * * * * Rscript -e 'rchallenge::publish("~/Dropbox/mychallenge/challenge.rmd")'}
#' 
#' This will render a HTML webpage every hour.
#' Use the \code{output_dir} argument to change the output directory.
#' 
#' If your challenge is hosted on a Github repository you can automate the push:
#' 
#' \code{0 * * * * cd ~/Dropbox/mychallenge && Rscript -e 'rchallenge::publish()' && git commit -m "update html" index.html && git push}
#' 
#' You might have to add the path to Rscript and pandoc at the beginning of your crontab:
#'  
#' \code{PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin}
#'
#' Depending on your system or pandoc version you might also have to explicitly add the encoding option to the command:
#' 
#' \code{0 * * * * Rscript -e 'rchallenge::publish("~/Dropbox/mychallenge/challenge.rmd", encoding = "utf8")'}
#' 
#' @section Automating the updates on \strong{Windows}:
#' 
#' You can use the \href{https://www.windowscentral.com/how-create-automated-task-using-task-scheduler-windows-10}{Task Scheduler} 
#' to create a new task with a \emph{Start a program} action with the settings (mind the quotes):
#'   
#' \itemize{ 
#'  \item \emph{Program/script}: \code{Rscript.exe}
#'  \item \emph{options}: \code{-e rchallenge::publish('~/Dropbox/mychallenge/challenge.rmd')}
#' }
#' 
#' @note The rendering of HTML content provided by Dropbox will be discontinued from the 
#' 3rd October 2016 for Basic users and the 1st September 2017 for Pro and Business users. 
#' See \url{https://help.dropbox.com/files-folders/share/public-folder}. Alternatively, \href{https://pages.github.com/}{GitHub Pages}
#' provide an easy HTML publishing solution via a simple GitHub repository.
#' 
#' @note version 1.16 of pandoc fails to fetch font awesome css, see \url{https://github.com/jgm/pandoc/issues/2737}.
#' 
#' @section Examples:
#' \itemize{ 
#'  \item \href{https://adrien.tspace.fr/challenge-mimse2014/}{Credit approval} (in french) by Adrien Todeschini (Bordeaux).
#'  \item \href{https://chavent.github.io/challenge-mmas/}{Spam filter} (in french) by Marie Chavent (Bordeaux).
#' }
#' 
#' Please \href{https://adrien.tspace.fr/}{contact me} to add yours.
"_PACKAGE"


#' Defunct functions in package \sQuote{rchallenge}
#' 
#' These functions are defunct and no longer available.
#' @name rchallenge-defunct
#' @aliases glyphicon 
#' @export 
#' @param ... parameters 
#' @details Defunct functions are: \code{glyphicon}
glyphicon <- function(...) {
  .Defunct("icon", "rchallenge")
}