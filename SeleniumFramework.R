library("RSelenium")
library("wdman")

# Disabling pop - up box and choosing default download directory
capB <- list(chromeOptions =
               list(
                 "useAutomationExtension" =  FALSE,
                 prefs =
                   list ("download.default_directory" = "C:\\Main\\Sub\\MyFolder")
               ))
# Specifying the chrome driver version according to the chrome version you have
my_driver <-
  rsDriver(
    browser = c("chrome"),
    chromever = "75.0.3770.140",
    extraCapabilities = capb
  )
rem_driver <- my_driver[["client"]]
rem_driver$open()
Sys.sleep(5)
# Navigate to quandl website
rem_driver$navigate("https://www.quandl.com/sign-up-modal")
# Send username
user <-
  rem_driver$findElement(using = "id", value = "ember128")
Sys.sleep(2)
user$clearElement()
Sys.sleep(2)
user$sendKeysToElement(list("youremail@email.com"))
Sys.sleep(2)
# Send password
pwd <-
  rem_driver$findElement(using = "id", value = "ember130")
Sys.sleep(2)
pwd$clearElement()
Sys.sleep(2)
pwd$sendKeysToElement(list("********", "\uE007"))
Sys.sleep(10)
# Navigate to the dataset page
rem_driver$navigate(
  "https://www.quandl.com/data/CHRIS/MGEX_IH1-Minneapolis-HRWI-Hard-Red-Wheat-Futures-Continuous-Contract-1-IH1-Front-Month"
)

Sys.sleep(4)
# Click download button
download <-
  rem_driver$findElement(using = "css", "#ember64 > span")

download$clickElement()
Sys.sleep(4)
# Choose file format to download
format <-
  rem_driver$findElement(using = "css",
                         "#ember65 > a.b-select-content__link.qa-dataset-download-item-csv")
format$clickElement()
Sys.sleep(10)
# Close server and browser windows
rem_driver$close()
my_driver$server$stop()
my_driver$server$process


# Download folder (as set up above in preferences) and file name (set up on vendor website)
down_loc <-
  "C:\\Main\\Sub\\MyFolder"
down_file <-
  paste0(down_loc, "\\", "CHRIS-MGEX_IH1.csv")
# Read downloaded file
down_data <-
  read.csv(
    file = down_file,
    header = FALSE,
    sep = ",",
    stringsAsFactors = FALSE
  )
Sys.sleep(5)
# Appending current date as a column to the dataset to keep a track of load date
down_data$DateLoaded <- Sys.Date()

library('odbc')
# Connecting to my DB
con <- dbConnect(odbc(), "My_Database")
# Sending dataframe to my table in DB
dbSendQuery(conn = con, "truncate table My_Table")
Sys.sleep(2)
dbWriteTable(conn = con,
             "My_Table",
             value = down_data,
             append = TRUE)
Sys.sleep(5)
# Deleting downloaded file
file.remove(down_file)