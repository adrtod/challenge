
#' Install a new challenge
#' @param path         string. install path of the challenge (should be somewhere in your Dropbox)
#' @param recursive    logical. should elements of the path other than the last be created? see \code{\link{dir.create}}
#' @param overwrite    logical. should existing destination files be overwritten? see \code{\link{file.copy}}
#' @param quiet        logical. deactivate text output.
#' @param showWarnings logical. should the warnings on failure be shown? see \code{\link{dir.create}}
#' @param data_dir     string. subdirectory of the data
#' @param submissions_dir string. subdirectory of the submissions. see \code{\link{store_new_submissions}}
#' @param hist_dir     string. subdirectory of the history. see \code{\link{store_new_submissions}}
#' @param install_data logical. activate installation of the data files of the template challenge.
#' @param baseline     string. name of the team considered as the baseline.
#' @param add_baseline logical. activate installation of baseline submission files of the template challenge.
#' @param clear_history logical. activate deletion of the existing history folder.
#' @param template     string. name of the template Rmarkdown script to be installed.
#'   two scripts are available: \code{"challenge.rmd"} (english) and\code{"challenge_fr.rmd"} (french)
#' @param title        string. title displayed on the webpage.
#' @param author       string. author displayed on the webpage.
#' @param date         string. date displayed on the webpage.
#' @param email        string. email of the challenge administrator.
#' @param date_start   string. start date of the challenge.
#' @param deadline     string. deadline of the challenge.
#' @export
new_challenge <- function(path = ".", recursive = FALSE, overwrite = recursive, 
                          quiet = FALSE, showWarnings = FALSE,
                          template = "challenge.rmd",
                          data_dir = "data", 
                          submissions_dir = "submissions",
                          hist_dir = "history", 
                          install_data = TRUE, 
                          baseline = "baseline",
                          add_baseline = TRUE,
                          clear_history = overwrite,
                          title = "Challenge",
                          author = "",
                          date = "",
                          email = "EDIT_EMAIL@DOMAIN.com",
                          date_start = format(Sys.Date(), "%d %b %Y"),
                          deadline = paste(Sys.Date()+90, "23:59:59")) {
  
  dir.create(path, recursive = recursive, showWarnings = showWarnings)
  if (!file.exists(path))
    stop("could not create directory ", path)
  
  dir.create(file.path(path, "data"), recursive = recursive, showWarnings = showWarnings)
  
  if (install_data) {
    data(data_train, data_test, Y_test, package = 'challenge')
    tmpdir = tempdir()
    
    save('data_train', file = file.path(tmpdir, 'data_train.rda'))
    file.copy(file.path(tmpdir, 'data_train.rda'), file.path(path, data_dir),
              overwrite=overwrite, recursive=recursive)
    
    save('data_test', file = file.path(tmpdir, 'data_test.rda'))
    file.copy(file.path(tmpdir, 'data_test.rda'), file.path(path, data_dir),
              overwrite=overwrite, recursive=recursive)
    
    save('Y_test', file = file.path(tmpdir, 'Y_test.rda'))
    file.copy(file.path(tmpdir, 'Y_test.rda'), file.path(path, data_dir),
              overwrite=overwrite, recursive=recursive)
    
    unlink(tmpdir)
  }
  
  dir.create(file.path(path, submissions_dir), recursive = recursive, showWarnings = showWarnings)
  
  if (add_baseline) {
    team_dir = new_team(baseline, path=path, submissions_dir = submissions_dir,
                        quiet = TRUE, showWarnings = showWarnings)
    
    data(data_test, package = 'challenge')
    
    # Predict all Good
    Y_pred <- rep("Good", nrow(data_test))
    tmpfile = tempfile()
    write(Y_pred, file = tmpfile)
    file.copy(tmpfile, file.path(team_dir, 'all_good.csv'), overwrite=overwrite)
    
    # Predict all Bad
    Y_pred <- rep("Bad", nrow(data_test))
    write(Y_pred, file = tmpfile)
    file.copy(tmpfile, file.path(team_dir, 'all_bad.csv'), overwrite=overwrite)
    
    unlink(tmpfile)
  }
  
  if (clear_history)
    unlink(file.path(path, hist_dir), recursive = TRUE)
  
  dir.create(file.path(path, hist_dir), recursive = recursive, showWarnings = showWarnings)
  
  expr = list(title = title, author = author, date = date, email = email, 
              date_start = date_start, deadline = deadline, baseline = baseline,
              data_dir = data_dir, submissions_dir = submissions_dir,
              hist_dir = hist_dir)
  
  tpl = system.file('template', template, package = 'challenge')
  if (nchar(tpl)==0)
    stop("could not find template ", template)
  
  text = readLines(tpl)
  
  for (n in names(expr))
    text = gsub(paste0("@", toupper(n), "@"), expr[[n]], text)
  
  tmpfile = tempfile()
  
  writeLines(text, tmpfile)
  
  file.copy(tmpfile, file.path(path, template), overwrite=overwrite)
  
  unlink(tmpfile)  
  
  if (!quiet) {
    cat('New challenge installed in:', normalizePath(path), "\n")
    cat('Follow the next steps to complete:\n')
    cat('1. Replace the data files in the data subdirectory\n')
    cat('2. Edit the template', template, 'as needed\n')
    cat('3. Create and share directories in', submissions_dir, 'for each team:\n')
    cat('    challenge::new_team("TEAM_A", path="', path, '", submissions_dir="', submissions_dir, '")\n', sep="")
    cat('4. Setup a crontab for automatic updates:\n')
    cat('    0 * * * * Rscript -e challenge::publish("', normalizePath(file.path(path, template)) , '")\n', sep="")
  }
  
  invisible(normalizePath(path))
}

#' Create a new team submissions folder in your challenge
#' @param name         string. name of the team subdirectory
#' @param path         string. root path of the challenge. see \code{\link{new_challenge}}
#' @param submissions_dir string. subdirectory of the submissions. see \code{\link{new_challenge}}
#' @param quiet        logical. deactivate text output.
#' @param showWarnings logical. should the warnings on failure be shown? see \code{\link{dir.create}}
new_team <- function(name, path = ".", submissions_dir = "submissions", 
                     quiet = FALSE, showWarnings = FALSE) {
  if (!file.exists(file.path(path, submissions_dir)))
    stop("could not find submissions directory:", normalizePath(file.path(path, submissions_dir)))
  
  if (!quiet) cat("Creating team subdirectory:", file.path(submissions_dir, name), "\n")
  dir.create(file.path(path, submissions_dir, name), recursive = FALSE, showWarnings = showWarnings)
  
  if (!quiet) cat("Next step: share the folder with the team.\n")
  
  invisible(normalizePath(file.path(path, submissions_dir, name)))
}

#' Publish your challenge Rmarkdown script to a html page
#' @param input string. name of the Rmarkdown input file
#' @param output_file output file. If \code{NULL} then a default based on the name 
#'   of the input file is chosen.
#' @param output_dir string. output directory. default=\code{"~/Dropbox/Public"} 
#'   so that the rendered page can easily be shared on the web with Dropbox.
#' @export
#' @seealso \code{\link[rmarkdown]{render}}
publish <- function(input="challenge.rmd", output_file = NULL, output_dir = file.path("~/Dropbox/Public")) {
  setwd(dirname(input))
  rmarkdown::render(basename(input), output_file = output_file, output_dir = output_dir)
}