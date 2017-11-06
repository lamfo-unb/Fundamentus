#Enable RSelenium
library(RSelenium)
#Check drivers
rD <- rsDriver()
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
writeBin(base64decode(img[[1]], "raw"), 'teste.png')

#Cut the image
library(magick)
img <- image_read("teste.png")
crop<-image_crop(img, "500x120+708+851")
image_write(crop, 'teste.png')

#Usa o DeathByCaptcha http://static.deathbycaptcha.com/files/dbc_api_v4_2_wincli.zip
system(paste("deathbycaptcha.exe -l pedrobsb -p pedroh -c ","teste.png"," -t 60",sep="" ))
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
