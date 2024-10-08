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

#Atribuindo o Box-plot a objetos

boxprodfert <- ggplot(general)+
  geom_boxplot(aes(x = Data, y = Produção, color = "Produção"), outlier.colour = "black") +
  labs(color = "Legenda:",
       x = "Data",
       y = "Quantidade de Fertilizantes (em toneladas de produto)") +
  scale_x_date(date_labels = "%m/%Y", date_breaks = "3 months")+
  scale_y_continuous(labels = scales::comma_format(big.mark = "."))+
  theme(axis.text.x = element_text(angle = 90, size = 8),
        panel.background = element_rect(fill = "white", color = "black"),
        panel.grid = element_line(color = "grey90"),
        panel.border = element_rect(color = "black", fill = NA),
        legend.position = "right") 
layout(showlegend = TRUE,
       legend = list(orientation = "v"))

boximport <- ggplot(general)+
  geom_boxplot(aes(x = Data, y = Importação, colour = "Importação"), outlier.colour = "black") +
  labs(color = "Legenda:",
       x = "Data",
       y = "Quantidade de Fertilizantes (em toneladas de produto)") +
  scale_x_date(date_labels = "%m/%Y", date_breaks = "3 months")+
  scale_y_continuous(labels = scales::comma_format(big.mark = "."))+
  scale_color_manual(values = "#481567FF")+
  theme(axis.text.x = element_text(angle = 90, size = 8),
        axis.title.y = element_text(size = 11),
        panel.background = element_rect(fill = "white", color = "black"),
        panel.grid = element_line(color = "grey90"),
        panel.border = element_rect(color = "black", fill = NA),
        legend.position = "right") 
layout(showlegend = TRUE,
       legend = list(orientation = "v"))

boxexport <- ggplot(general)+
  geom_boxplot(aes(x = Data, y = Exportação, color = "Exportação"), outlier.colour = "black") +
  labs(color = "Legenda:",
       x = "Data",
       y = "Quantidade de Fertilizantes (em toneladas de produto)") +
  scale_x_date(date_labels = "%m/%Y", date_breaks = "3 months")+
  scale_y_continuous(labels = scales::comma_format(big.mark = "."))+
  scale_color_manual(values = "#FDE725FF")+
  theme(axis.text.x = element_text(angle = 90, size = 8),
        axis.title.y = element_text(size = 11),
        panel.background = element_rect(fill = "white", color = "black"),
        panel.grid = element_line(color = "grey90"),
        panel.border = element_rect(color = "black", fill = NA),
        legend.position = "right") 
layout(showlegend = TRUE,
       legend = list(orientation = "v"))

boxprodfert
boximport
boxexport

#Plotando os box-plots no mesmo layout

grid.arrange(boxprodfert, arrangeGrob(boximport, boxexport), ncol = 2)

#Montando a time series da produção de fertilizantes

prodfert = ts(base10$Fertilizantes, start = c(1998,1), end = c(2024,1), frequency = 12)

#Decomposição pelo Método MULTIPLICATIVO

decompa = decompose(prodfert, type = "multiplicative") 

plot(decompa)

#Tendência, Sazonalidade e Erros Aleatórios por trimestre

triprodfert = ts(base10$Fertilizantes, start = c(1998,1), end = c(2024,1), frequency = 4)

decomp = decompose(triprodfert, type = "multiplicative")

decomp$trend
decomp$seasonal
decomp$random

########################Comparando os modelos de Previsão##################################

#Time series da produção de fertilizantes
prodfert = ts(base10$Fertilizantes, start = c(1998,1), end = c(2024,1), frequency = 12)

#Separando a base da produção de fertilizantes para rodar o modelo e para prever

modelprod = ts(base10$Fertilizantes, start = c(1998,1), end = c(2022,12), frequency = 12)

prevprod = ts(base10$Fertilizantes, start = c(2023,1), end = c(2024,1), frequency = 12)

#Acurácia Média móvel

newmm = ts(matrix(1,13,1))

view(newmm)

newmm = media_movel[121:133]

modmm = ts(newmm,start = c(2013,1), end = c(2024,1), frequency = 12)

modmm

qualimodmm = accuracy(newmm,prevprod)
qualimodmm

#Acurácia do Modelo de previsão Holt-Winters multiplicativo (Série temporal com tendência e com sazonalidade)

modholtsazonalmult = hw(modelprod,h = 13,seasonal = "multiplicative")

#Valores previstos

modholtsazonalmult

#Visualização do modelo gerado

modholtsazonalmult$model

#Utilização dos valores médios da previsão para comparar com os valores do prevprod

compmult = modholtsazonalmult$mean

compmodelmult = ts(compmult,start = c(2023,1), end = c(2024,1), frequency = 12)

#Verificando a qualidade do meu modelo por meio dos erros

qualihwmult = accuracy(compmodelmult, prevprod)
qualihwmult

###########Identificando qual a característica do Erro, da Tendência e da Sazonalidade########

modelprod.ets <- ets(modelprod, model = "ZZZ")

summary(modelprod.ets)

###########Acurácia do Modelo de Suavização Exponencial Simples (SES)#######################

modses = ses(modelprod,h = 13)

#Valores previstos

modses

#Visualização do modelo gerado

modses$model

options(scipen = 999)
autoplot(modses)

#Utilização dos valores médios da previsão para comparar com os valores do prevprod

compses = modses$mean

compmodses = ts(compses,start = c(2023,1), end = c(2024,1), frequency = 12)

#Verificando a qualidade do meu modelo por meio dos erros

qualises = accuracy(compmodses,prevprod)

qualises

###########Acurácia do Modelo de Suavização Exponencial Holt (SEH)#######################

modholt = holt(modelprod, h = 13)

#Valores previstos

modholt

#Modelo gerado

modholt$model

#Utilização dos valores médios da previsão para comparar com os valores do prevprod

compholt = modholt$mean

compmodholt = ts(compholt,start = c(2023,1), end = c(2024,1), frequency = 12)

#Verificando a qualidade do meu modelo por meio dos erros

qualiholt = accuracy(compmodholt, prevprod)

qualiholt

################Acurácia do Modelo de Holt com tendência e amortecido##########################

modholtdamped = holt(modelprod, h = 13, damped = TRUE)

#Valores previstos

modholtdamped

#Modelo gerado

modholtdamped$model

#Utilização dos valores médios da previsão para comparar com os valores do prevprod

compholtdamped = modholtdamped$mean

compmodholtdamped = ts(compholtdamped, start = c(2023,1), end = c(2024,1), frequency = 12)

#Verificando a qualidade do meu modelo por meio dos erros

qualiholtdamped = accuracy(compmodholtdamped, prevprod)

qualiholtdamped

#Acurácia do Modelo de previsão Holt-Winters aditivo (Série temporal com tendência e com sazonalidade)

modholtsazonalad = hw(modelprod,h = 13,seasonal = "additive")

#Valores previstos

modholtsazonalad

#Visualização do modelo gerado

modholtsazonalad$model

#Utilização dos valores médios da previsão para comparar com os valores do prevprod

comp = modholtsazonalad$mean

compmodel = ts(comp,start = c(2023,1), end = c(2024,1), frequency = 12)

#Verificando a qualidade do meu modelo por meio dos erros

qualihwadd = accuracy(compmodel,prevprod)
qualihwadd

#Tabela das acurácias das previsões

modelos = c("HWadditive", "Hwmultiplicative","SES", "Holt", "Holtdamped", "MediaMovel")
mape = c(qualihwadd[5],qualihwmult[5], qualises[5],qualiholt[5],qualiholtdamped[5], qualimodmm[5])
tabela = data.frame(modelos, mape)
tabela

# Analisando os resíduos (erros) das previsões
# Condições:
# não podem ser correlacionados; se forem correlacionados ficaram informações
# nos resíduos que deveriam estar no modelo
# devem possui média zero, caso não seja então as previsões são viesadas

autoplot(modholtsazonalmult$residuals)

acf(modholtsazonalmult$residuals)

autoplot(modholtsazonalad$residuals)

acf(modholtsazonalad$residuals)

#Observando o gráfico percebemos que existem lags que ultrapassam a linha tracejada,
#ou seja, existem lags que ultrapassam a linha de autocorrelação
# O fato de muitos lags passarem a linha de autocorrelação indica que os meus resíduos
#tem autocorrelação com os meus dados

checkresiduals(modholtsazonalmult)

checkresiduals(modholtsazonalad)

#Ao observar o gráfico da função de autocorrelação verificamos que existem lags 
#que indicam a autocorrelação dos meus resíduos com os meus dados
#principalmente a cada término de ciclo anual
#no histograma nota-se uma curva normal, ou seja, uma boa aproximação desse modelo a uma distribuição normal.

#Porém ao fazer o L-jung-Box Test o p-valor deu muito abaixo que 1% de significância
#deu 0,0000128. Sendo assim eu rejeito H0 e aceito H1 (hipótese alternativa) que diz
#os resíduos são correlacionados e o mesmo o modelo Hw multiplicativo apresentando
#MAPE de 8,91% o modelo não seria o mais adequado para realizar tal tipo de 
#previsão

#####Teste de Kolmogorov-Smirnov#######

ks.test(modholtsazonalmult$residuals,"pnorm", mean(modholtsazonalmult$residuals), 
        sd(modholtsazonalmult$residuals))

# p-valor = 0.8862 >> 0,05 - Rejeita-se H0 e aceita-se a Hipótese alternativa H1
#ou seja, os resíduos não seguem uma distribuição normal

# confirmada a existência de autocorrelação serial e não normalidade dos resíduos
# Podemos verificar a não estacionariedade de variância
#Como existe autocorrelação entre os resíduos e/ou eles não tem uma distribuição normal 
#nós teríamos de fazer um outro tipo de modelagem como modelos heterocedasticos ou 
#redes neurais

ks.test(modholtsazonalad$residuals,"pnorm", mean(modholtsazonalad$residuals), 
        sd(modholtsazonalad$residuals))

# verificar se existe efeitos ARCH

ArchTest(modholtsazonalmult$residuals)

ArchTest(modholtsazonalad$residuals)
