# Read in environment properties
readRenviron(".properties")

# If the autoload property is set, activate renv
if (Sys.getenv("AUTOLOAD_RENV_DEVENV", unset = "FALSE")) {
    source("renv/activate.R")
} else if (Sys.getenv("AUTOLOAD_RENV", unset = "FALSE")) {
    source("renv/activate.R")
    renv::restore(prompt = FALSE)
} else {
    # Otherwise, print message
    print(paste(
        "renv autoloading has been disabled.",
        "If you would like to turn on renv,",
        "set AUTOLOAD_RENV to 'TRUE' in '.properties'."
    ))
}
