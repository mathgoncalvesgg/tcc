########################################################################
# Trabalho de Conclusão de Curso (TCC) 
# Cenário da agroindústria brasileira nos anos 2013/2024 

# Data Science & Analytics
# USP ESALQ
# Aluno Matheus Gonçalves Graça
# Número USP 13978990
##########################################################################

# Instalação e carregamento de Todos os Pacotes ------------------------

pacotes <- c("readxl","plotly","tidyverse","gridExtra","forecast","TTR",
             "smooth","tsibble","fable","tsibbledata", "fpp3",
             "urca","ipeadatar", "measurements", "viridis", "FinTS")

if(sum(as.numeric(!pacotes %in% installed.packages())) != 0){
  instalador <- pacotes[!pacotes %in% installed.packages()]
  for(i in 1:length(instalador)) {
    install.packages(instalador, dependencies = T)
    break()}
  sapply(pacotes, require, character = T)
} else {
  sapply(pacotes, require, character = T)
}

#--------------------------------------------------------------------------

#Executando as bibliotecas--------------------------------------------------

library(ipeadatar)

library(dplyr)

library(measurements)

library(viridis)

library(ggplot2)

library(plotly)

library(gridExtra)

library(grid)

library(lattice)

#----------------------------------------------------------------------

########Importando as bases de dados do site Ipeadata---------------------------

database <- available_series(language = 'br')

View(database)

#Base 8: Importação de Fertilizantes

base8 <- ipeadata(code = "ANDA12_MFERTILIZ12", language = 'br')

#Base 9: Exportações de Fertilizantes

base9 <- ipeadata(code = "ANDA12_NPKFERTILIZ12", language = 'br')

#Base 10: Produção de fertilizantes

base10 <- ipeadata(code = "ANDA12_PFERTILIZ12", language = 'br')

#------------------------------------------------------------------------