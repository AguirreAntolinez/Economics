#Import data function
#Author: William Alexander Aguirre Antolínez
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
  
  #Create the list 
  create_list<-list()
  
  #For in years
  for (y in names_years) {
    data_year<- list()
    #For in months
    for (m in names_months) {
      tryCatch(
        df_year <- read_delim(
          paste0(name_directory,y,"/",m,"/",root),
          delim = ";",
          escape_double = FALSE,
          trim_ws = TRUE
        ),
        error = function(e) {
          message(paste("Can´t was imported:", y, m, "->", e$message))
          return(NULL)
        }
      )
      ifelse(
        exists("df_year"),
        yes = data_year[[m]]<-NULL,
        no = data_year[[m]]<-df_year
        )
      
      df_year<-NULL
      rm(df_year)
    }
    
    ifelse(
      exists("data_year"),
      yes=create_list[[y]]<-NULL,
      create_list[[y]]<-data_year
    )
    data_year<-NULL
    rm(data_year)
    
  }
  
  #Rename de list
  assign(name_list, create_list, envir = .GlobalEnv)
  
}

