#Example import data

#Author: William Alexander Aguirre Antolínez
#Date: 15-11-2025

#Description: This script shows an example of how to use the function import_data.


source("https://raw.githubusercontent.com/AguirreAntolinez/Economics/refs/heads/main/Functions/import_data.R")

directory<-"https://raw.githubusercontent.com/AguirreAntolinez/Economics/refs/heads/main/Data/GEIH/"

years<- c("2024","2025")

name_months<-c("January",
               "February",
               "March",
               "April",
               "May",
               "June",
               "July",
               "August",
               "September",
               "October",
               "November",
               "December")



#Import migration data
import_data(name_list = "migration",
            name_directory = directory,
            names_years = years,
            names_months = name_months,
            root = "Migración.CSV"  )


#Import general characteristics data
import_data(name_list = "characteristics",
            name_directory = directory,
            names_years = years,
            names_months = name_months,
            root = "Características%20generales.CSV"  )

#Import household data
import_data(name_list = "household",
            name_directory = directory,
            names_years = years,
            names_months = name_months,
            root = "Datos%20del%20hogar%20y%20la%20vivienda.CSV"  )

#Import labor data
import_data(name_list = "labor",
            name_directory = directory,
            names_years = years,
            names_months = name_months,
            root = "Fuerza%20de%20trabajo.CSV"  )
