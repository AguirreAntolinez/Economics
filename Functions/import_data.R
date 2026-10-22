#Import data function
#Author: William Alexander Aguirre Antol??nez
#Date: 15-11-2025

#Description: This function imports data from this repository.

#Arguments
#name_list: character string. 
#name_directory: character string.
#name_years: vector.
#names_months: vector.
#root: character string.

#See Processing scripts for examples of use.


library(readr)

import_data <- function(name_list,
                        name_directory,
                        names_years,
                        names_months,
                        root) {
  create_list <- list()
  missing_months <- character()

  for (y in names_years) {
    data_year <- list()
    for (m in names_months) {
      df_year <- tryCatch(
        read_delim(
          paste0(name_directory, y, "/", m, "/", root),
          delim = ";",
          escape_double = FALSE,
          trim_ws = TRUE,
          show_col_types = FALSE
        ),
        error = function(e) NULL
      )
      if (is.null(df_year)) {
        missing_months <- c(missing_months, paste(y, m))
      } else {
        data_year[[m]] <- df_year
      }
    }
    create_list[[y]] <- data_year
  }

  assign(name_list, create_list, envir = .GlobalEnv)

  if (length(missing_months) > 0) {
    message("Meses no disponibles: ", paste(missing_months, collapse = ", "))
  }
}
