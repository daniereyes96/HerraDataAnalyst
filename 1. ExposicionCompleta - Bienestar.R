library(readr)
library(dplyr)
library(tidyr)
library(data.table)
library(readxl)
library(sqldf)

p <- "2022-06"
FECHA_CORTE <- as.Date("2022-06-30")
M <- month(FECHA_CORTE)

MES <- ifelse(M==3,"MARZO",M)
MES <- ifelse(M==6,"JUNIO",MES)
MES <- ifelse(M==9,"SEPTIEMBRE",MES)
MES <- ifelse(M==12,"DICIEMBRE",MES)

AÑO <- year(FECHA_CORTE)
setwd("C:\\Users\\danie\\Desktop\\Monografia1")

BN <-  read_csv(paste("Bienestar_",p,".csv",sep=""),col_names = FALSE)

names(BN) <- c("NUMERO_POLIZA","KEY_ID_ASEGURADO","CODIGO_RAMO_CONTABLE",
               "CODIGO_PRODUCTO","VT","VC","ACTIVO","SEXO","FECHA_NACIMIENTO","MUNICIPIO")

BN_2 <- BN[names(BN)[c(3,2,1,4,5,6,7,8:10)]]

BN_2 <- BN_2 %>% select(-ACTIVO)

names(BN_2)[c(5:6)]<-c("VALOR_ASEGURADO","VALOR_CEDIDO")

BN_2$CODIGO_COMPANIA <- 0

nuevas.filas=data.frame(CODIGO_RAMO_CONTABLE=c(24,25), KEY_ID_ASEGURADO=c("A99B","A98B"),
                        NUMERO_POLIZA=c(156322,167541), CODIGO_PRODUCTO=c(716,736),
                        VALOR_ASEGURADO=c(168000.596,178000.860), 
                        VALOR_CEDIDO=c(258000.73,10000.145),SEXO=c("NO INFO","NA"), 
                        FECHA_NACIMIENTO=c(as.Date("1975-09-12"), as.Date("1979-03-15")),
                        MUNICIPIO=c("Bogotá","Bogotá"), CODIGO_COMPANIA=c(0,0))

BN_2 <- rbind(BN_2,nuevas.filas)

BN_2$VALOR_ASEGURADO <- round(BN_2$VALOR_ASEGURADO,0)
BN_2$VALOR_CEDIDO <- round(BN_2$VALOR_CEDIDO,0)

BN_2$LN <-'Bienestar'

BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==20 &
                            BN_2$CODIGO_PRODUCTO==764,2,BN_2$CODIGO_COMPANIA)
BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==25 &
                            BN_2$CODIGO_PRODUCTO==737,3,BN_2$CODIGO_COMPANIA)
BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==20 & 
                            BN_2$CODIGO_PRODUCTO==712,3,BN_2$CODIGO_COMPANIA)
BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==20 &
                            BN_2$CODIGO_PRODUCTO==758,3,BN_2$CODIGO_COMPANIA)

BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==24,2,BN_2$CODIGO_COMPANIA)
BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==26,3,BN_2$CODIGO_COMPANIA)
BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==18,3,BN_2$CODIGO_COMPANIA)

BN_2 <- mutate(BN_2,SEXO=ifelse(SEXO=="NO INFO",NA,as.character(SEXO)))

BN_2 <- BN_2 %>% mutate(SEXO=replace(SEXO, SEXO=="FEMENINO", "F"),
                        SEXO=replace(SEXO, SEXO=="MASCULINO", "M")) %>% as.data.frame()

BN_2$FECHA_NACIMIENTO <- as.Date(BN_2$FECHA_NACIMIENTO)
BN_2$FECHA_CORTE <- as.Date(FECHA_CORTE)

BN_2$EDAD <- round(as.numeric(trunc((BN_2$

