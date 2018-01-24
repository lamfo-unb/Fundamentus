#Enable RSelenium
library(RSelenium)
library(readxl)

#Documentation Crhome
#https://sites.google.com/a/chromium.org/chromedriver/capabilities

#Define the download folder
eCaps <- list(
  chromeOptions = 
    list(prefs = list(
      "profile.default_content_settings.popups" = 0L,
      "download.prompt_for_download" = FALSE,
      "download.default_directory" = getwd()
    )
    )
)

#Check drivers
rD <- rsDriver(extraCapabilities = eCaps)

#rD <- rsDriver()

#Client RSelenium
remDr <- rD$client
remDr <- remoteDriver(port = 4567L, browserName = "chrome")

#Open Browser
remDr$open()

#Maximiza a janela
remDr$maxWindowSize()

#Vai para a pagina de interesse
site<-"http://fundamentus.com.br/balancos.php?papel=PETR4"
remDr$navigate(site)

#Faz um printscreen do site
library(base64enc)
img<-remDr$screenshot(display = FALSE, useViewer = TRUE, file = NULL)
writeBin(base64decode(img[[1]], output=NULL), 'teste.png')

#Cut the image
library(magick)
img <- image_read("teste.png")
crop<-image_crop(img, "500x120+708+851")
image_write(crop, 'teste.png')

#Upload image
library(httr)

#Post PRECISA COLOCAR O PASSWORD
req <- POST("http://api.dbcapi.me/api/captcha",
            body = list(
              username  = "pedrobsb",
              password = "XXXXXXX",
              captchafile  = upload_file("teste.png", type = "image/png")
            ),
            add_headers("Content-Type" = "multipart/related")
)

#Answer
r <- req$all_headers[[1]]$headers$location
txt<-content(GET(r))$text

#Delete file
file.remove("teste.png")

#Encontra o objeto da caixa de texto
webElem <- remDr$findElement(using = "name", "codigo_captcha")

#Manda o resultado dp captcha
webElem$sendKeysToElement(list(txt))

#Encontra o objeto da caixa de texto
webElem <- remDr$findElement(using = "name", "submit")

#Clica no botao
webElem$clickElement()

#Wait the download
Sys.sleep(5)

#Fecha as conexoes
remDr$close()
remDr$closeServer()

#Acha o arquivo
strDir<-"C:\\Users\\Pedro Albuquerque\\Downloads"
files <- file.info(paste0(strDir,"\\",list.files(strDir)))
fileZIP <- rownames(files)[order(files$ctime, decreasing = T)][1]

#Extrai o arquivo
unzip(fileZIP,exdir="Download")

#Pega o arquivo
files <- list.files("Download",pattern = "\\.xls$")
balanco <- read_xls(paste0("Download\\",files),sheet = 1, col_types="text", skip=2, col_names=F)
balanco<-t(balanco)
balanco.df<-as.data.frame(t(apply(balanco[2:nrow(balanco),],1, as.numeric)))
balanco.df$Trimestre<-seq(nrow(balanco.df),1)
colnames(balanco.df)<-c(balanco[1,],"Trimestre")

demonstrativo <- read_xls(paste0("Download\\",files),sheet = 2, col_types="text", skip=2, col_names=F)
demonstrativo<-t(demonstrativo)
demonstrativo.df<-as.data.frame(t(apply(demonstrativo[2:nrow(demonstrativo),],1, as.numeric)))
demonstrativo.df$Trimestre<-seq(nrow(demonstrativo.df),1)
colnames(demonstrativo.df)<-c(demonstrativo[1,],"Trimestre")

#Deleta o arquivo xls
file.remove(paste0("Download\\",files))
