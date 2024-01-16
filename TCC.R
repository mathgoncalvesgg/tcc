########################################################################
          # Trabalho de Conclusão de Curso (TCC) 
  # Inserção da população brasileira em situação de vulnerabilidade 

# Data Science & Analytics
# USP ESALQ
# Aluno Matheus Gonçalves Graça
# Número USP 13978990
#########################################################################

# Instalação e carregamento de Todos os Pacotes ------------------------

pacotes <- c("readxl","plotly","tidyverse","gridExtra","forecast","TTR",
             "smooth","tsibble","fable","tsibbledata", "fpp3",
             "urca","ipeadatar")

if(sum(as.numeric(!pacotes %in% installed.packages())) != 0){
  instalador <- pacotes[!pacotes %in% installed.packages()]
  for(i in 1:length(instalador)) {
    install.packages(instalador, dependencies = T)
    break()}
  sapply(pacotes, require, character = T)
} else {
  sapply(pacotes, require, character = T)
}

#-------------------------------------------------------------------------

#Executando a biblioteca--------------------------------------------------

library(ipeadatar)

#-------------------------------------------------------------------------

#Importando as bases de dados do site Ipeadata---------------------------

database <- available_series(language = 'br')

View(database)

PPC <- ipeadata(code = "WEO_PIBPPCWEOBRA",language = 'br')

View(PPC)

territory <- available_territories(language = c("br"))

View(territory)

pobreza_nacional <- ipeadata(code = "PNADCA_TXPNUF", language = 'br')

View(pobreza_nacional)

pobreza_internacional <-ipeadata(code = "PNADCA_TXPIUF", language = 'br')

View(pobreza_internacional)

#Limpando a base de dados-----------------------------------------------

#Preciso de um filtro para selecionar apenas as colunas 1 e 2

pnacional = pobreza_nacional[1:11,2:3]

#Dúvida: Pesquisar como colocar o filtro nas rows, exemplo tcode == 0
            
pinternacional = pobreza_internacional[1:11,2:3]
