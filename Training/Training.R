#Enable RSelenium
library(RSelenium)
rm(list=ls())
#Documentation Crhome
#https://sites.google.com/a/chromium.org/chromedriver/capabilities


for(i in 1:1000){
  rD <- rsDriver()
  
  #Client RSelenium
  remDr <- remoteDriver(port = 4567L, browserName = "chrome")
  
  #Open Browser
  remDr$open()
  
  #Maximiza a janela
  remDr$maxWindowSize()
  
  #Vai para a pagina de interesse
  site<-"http://fundamentus.com.br/balancos.php?papel=PETR4"
  remDr$navigate(site)
  
  #Wait the loading
  Sys.sleep(2)
  
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
  
  #Post
  req <- POST("http://api.dbcapi.me/api/captcha",
              body = list(
                username  = "pedrobsb",
                password = "XXXXXXXX",
                captchafile  = upload_file("teste.png", type = "image/png")
              ),
              add_headers("Content-Type" = "multipart/related")
  )
  
  #Answer
  r <- req$all_headers[[1]]$headers$location
  txt<-content(GET(r))$text
  
  #Delete file
  file.rename("teste.png",paste0("Download\\",txt,".png"))
  
  #Fecha as conexoes
  remDr$close()
  remDr$closeServer()
}
