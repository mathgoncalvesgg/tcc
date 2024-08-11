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

#Verificando a estatística descritiva da base de produção de fertilizantes 

summary(base10$value)

sd(base10$value)

# Nomeando as colunas

colnames(base10)[3] = 'Fertilizantes'
colnames(base10)[2] = 'Data'

#Plotando o gráfico da time series produção de fertilizantes pelo ggplot

ggplotly(
  base10 %>%
    mutate(Data = as.Date(Data)) %>%
    ggplot() +
    geom_line(aes(x = Data, y = Fertilizantes)) + 
    labs(x = "Data",
         y = "Produção de Fertilizantes (em toneladas de produto)") +
    scale_x_date(date_labels = "%m-%Y", date_breaks = ("3 months")) +
    scale_y_continuous(limits = c(400000,1000000), labels = scales::comma_format(big.mark = ".")) +
    theme(axis.text.x = element_text(angle = 90, size = 6),
          panel.background = element_rect(fill = "white", color = "black"),
          panel.grid = element_line(color = "grey90"),
          panel.border = element_rect(color = "black", fill = NA),
    )
)

#Fazendo as estatísticas da Base de Exportação e Importação

summary(base9$value)

sd(base9$value)

summary(base8$value)

sd(base8$value)

#Montando o dataframe general

general = ts(matrix(1,137,4))

general = base10[181:317,2:3]
general[,3] = base8[181:317,3]
general[,4] = base9[,3]

#Nomeando as colunas da base general

colnames(general)[2] = "Produção"
colnames(general)[3] = "Importação"
colnames(general)[4] = "Exportação"

#Plotando o gráfico da produção, exportação e importação de fertilizantes

ggplotly(
  general %>%
    mutate(Data = as.Date(Data)) %>%
    ggplot() +
    geom_line(aes(x = Data, y = Produção, color = "Produção")) + 
    geom_line(aes(x = Data, y = Importação, color = "Importação")) +
    geom_line(aes(x = Data, y = Exportação, color = "Exportação")) +
    labs(color = "Legenda:",
         x = "Data",
         y = "Quantidade de Fertilzantes (ton)") +
    scale_x_date(date_labels = "%m-%Y", date_breaks = "3 months") +
    scale_y_continuous(limits = c(8000,4500000), breaks = seq(8000,4500000, by = 400000), labels = scales::comma_format(big.mark = ".")) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.4),
          panel.background = element_rect(fill = "white", color = "black"),
          panel.grid = element_line(color = "grey90"),
          panel.border = element_rect(color = "black", fill = NA),
          legend.title = element_text(colour = "black", size = 10, face = "bold"),
          legend.text = element_text(colour = "black", size = 9),
          legend.position = "right")
) %>% layout(showlegend = TRUE,
             legend = list(orientation = "v"))

#Fazendo a média móvel da produção de fertilizantes

media_movel = ma(general$Produção, order = 3, centre = TRUE)

view(media_movel)

#DataWrangling para inclusão do vetor media_movel na base generalmm

generalmm <- mutate(general,
                    media_movel)

#Visualizando a série da produção de fertilizantes com a média móvel

ggplotly(
  generalmm %>%
    mutate(Data = as.Date(Data)) %>% 
    ggplot() + 
    geom_line(aes(x = Data, y = Produção, color = "Produção")) +
    geom_line(aes(x = Data, y = media_movel, color = "Média Móvel"), linewidth = 0.5) +
    labs(color = "Legenda:",
         x = "Data",
         y = "Produção de Fertilizantes (em toneladas de produto)") +
    scale_x_date(date_labels = "%m-%Y", date_breaks = "3 months")+
    scale_y_continuous(limits = c(450000,900000), labels = scales::comma_format(big.mark = ".")) +
    theme(axis.text.x = element_text(angle = 90, size = 6),
          panel.background = element_rect(fill = "white", color = "black"),
          panel.grid = element_line(color = "grey90"),
          panel.border = element_rect(color = "black", fill = NA),
          legend.position = "right")
) %>% layout(showlegend = TRUE,
             legend = list(orientation = "v"))
#----------