#Limpa o workspace
rm(list=ls())
setwd("C:/Users/Pedro/Dropbox/Pessoal/Corretora/RSelenium")

#Instalação do RSelenium
library(RSelenium)

#Confere se o RSelenium esta instalado
checkForServer()

#Baixa o driver: http://chromedriver.storage.googleapis.com/index.html
bool<-FALSE
bool<-file.exists("chromedriver.exe")
if(!bool)
{
  #Baixa o arquivo zip
  down<-"http://chromedriver.storage.googleapis.com/2.13/chromedriver_win32.zip"
  download.file(down,paste(getwd(),"/chromedriver.zip",sep=""))
  
  #Extrai o arquivo
  unzip(paste(getwd(),"/chromedriver.zip",sep=""))
  
  #Deleta o arquivo
  file.remove((paste(getwd(),"/chromedriver.zip",sep="")))
}


#Inicia o servidor
startServer(args = c(paste("-Dwebdriver.chrome.driver=",getwd(),"/chromedriver.exe -Dwebdriver.chrome.args='--disable-logging'",sep="")), log = FALSE, invisible = FALSE)
remDr <- remoteDriver(browserName = "chrome")

#Abre o navegador
remDr$open()

#Maximiza a janela
remDr$maxWindowSize()

#Vai para a pagina de interesse
site<-"http://fundamentus.com.br/balancos.php?papel=PETR4"
remDr$navigate(site)

#Faz um printscreen do site
library(base64enc)
img<-remDr$screenshot(display = FALSE, useViewer = TRUE, file = NULL)
writeBin(base64Decode(img, "raw"), 'teste.png')

#Recorta o captcha
library(installr)
#install.ImageMagick()
local<-system("where convert", intern = TRUE)
system('"C:/Program Files/ImageMagick-6.9.0-Q16/convert.exe" -crop 202x62+475+340 teste.png teste2.png', intern = TRUE)

#Usa o DeathByCaptcha http://static.deathbycaptcha.com/files/dbc_api_v4_2_wincli.zip
system(paste("deathbycaptcha.exe -l pedrobsb -p pedroh -c ",getwd(),"/teste2.png"," -t 60",sep="" ))
txt<-scan("answer.txt", what = "character")

#Encontra o objeto da caixa de texto
webElem <- remDr$findElement(using = "name", "codigo_captcha")

#Manda o resultado dp captcha
webElem$sendKeysToElement(list(txt))

#Executa o botao
webElem$sendKeysToElement(list(initializing_parcel_number, key = "enter"))

#Encontra o objeto da caixa de texto
webElem <- remDr$findElement(using = "name", "submit")

#Clica no botao
webElem$clickElement()

#Fecha as conexoes
remDr$close()
remDr$closeServer()
