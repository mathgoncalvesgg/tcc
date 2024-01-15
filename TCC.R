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

library(ipeadatar)

database <- available_series(language = 'br')

View(database)

PPC <- ipeadata(code = "WEO_PIBPPCWEOBRA",language = 'br')

View(PPC)

territory <- available_territories(language = c("br"))

View(territory)