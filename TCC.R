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

#Montando uma nova base para plotar gráfico da taxa de pobreza

taxa_pobreza = ts(matrix(1,11,3))
taxa_pobreza = pinternacional
taxa_pobreza[,3] = pnacional[2]

colnames(taxa_pobreza)[1] = 'Data'
colnames(taxa_pobreza)[2] = 'Taxa_Pobreza_Internacional'
colnames(taxa_pobreza)[3] = 'Taxa_Pobreza_Nacional'

#Plotar Gráfico Time Series das Taxas de Pobreza

ggplotly(
  taxa_pobreza %>%
    mutate(Data = as.Date(Data)) %>%
    ggplot() +
    geom_line(aes(x = Data, y = Taxa_Pobreza_Internacional), colour = 'blue') + #Dúvida: como fazer para a cor mudar?
    geom_line(aes(x = Data, y = Taxa_Pobreza_Nacional),colour = 'yellow') + #Dúvida: como fazer para a cor mudar?
    labs(color = "Legenda:", #Dúvida: qual a coerência do nome dessas cores?
         x = "Data",
         y = "Taxa de Pobreza") +
    scale_x_date(date_labels = "%m-%Y", date_breaks = "1 year") +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.4),
          panel.background = element_rect(fill = "white", color = "black"),
          panel.grid = element_line(color = "grey90"),
          panel.border = element_rect(color = "black", fill = NA),
          legend.position = "none")
)
#Preciso que o eixo y seja melhor graduado, para observar melhor o valor no eixo

#Limpando a base de dados do PPC e transformando em time series

ppc_brasil = PPC[33:43,2:3]

view(ppc_brasil)

colnames(ppc_brasil)[1] = 'Data'
colnames(ppc_brasil)[2] = 'PPC'

rm(ppc_nacional)

#Plotando o gráfico ppc_brasil

ggplotly(
  ppc_brasil %>%
    mutate(Data = as.Date(Data)) %>%
    ggplot() +
    geom_line(aes(x = Data, y = PPC), colour = 'blue') + #Dúvida: como fazer para a cor mudar?
    labs(color = "Legenda:", #Dúvida: qual a coerência do nome dessas cores?
         x = "Data",
         y = "PPC brasileiro") +
    scale_x_date(date_labels = "%m-%Y", date_breaks = "1 year") +
    scale_y_continuous(limits = c(14000, 16000), breaks = scales::breaks_extended()) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.4),
          panel.background = element_rect(fill = "white", color = "black"),
          panel.grid = element_line(color = "grey90"),
          panel.border = element_rect(color = "black", fill = NA),
          legend.position = "none")
)

