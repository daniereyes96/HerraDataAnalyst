#librerías para el análisis de datos
library(readr)
library(dplyr)
library(tidyr)
library(data.table)
library(readxl)
library(sqldf)

#Variables
p <- "2022-06"
#convierte una cadena de texto en formato fecha 
FECHA_CORTE <- as.Date("2022-06-30")
#extrae el mes y lo asigna a "M"
M <- month(FECHA_CORTE)

#definir un vector con los nombres de los meses
nombres_meses <- c("ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO","JULIO",
                   "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE")

#obtener el nombre del mes en español
MES <- nombres_meses[M]
#year() extrae el año de la variable "FECHA_CORTE"
AÑO <- year(FECHA_CORTE)

#establece la ruta donde se importaran y exportaran las bases
setwd("C:\\Users\\danie\\Desktop\\Monografia1")

####---- 1. Inicio Rutina Bienestar ----#######---- 1. Inicio Rutina Bienestar ----#######

#carga base formato CSV con read_csv() la asigna a BN. paste() junta texto.p variable
BN <-  read_csv(paste("Bienestar_",p,".csv",sep=""),
                col_names = FALSE, show_col_types = FALSE )

#asigna nombres a las columnas de "BN" con un vector de nombres
names(BN) <- c("NUMERO_POLIZA","KEY_ID_ASEGURADO","CODIGO_RAMO_CONTABLE",
               "CODIGO_PRODUCTO","VT","VC","ACTIVO","SEXO","FECHA_NACIMIENTO","MUNICIPIO")
#re ordena las columnas
BN_2 <- BN[names(BN)[c(3,2,1,4,5,6,7,8:10)]]

#eliminar columna "ACTIVO"
BN_2 <- BN_2 %>% select(-ACTIVO)
#modificar nombres de las columnas 5 y 6
names(BN_2)[c(5:6)]<-c("VALOR_ASEGURADO","VALOR_CEDIDO")

#se crea la columna "CODIGO_COMPANIA" con valor de ceros
BN_2$CODIGO_COMPANIA <- 0

#redondea los valores de ciertas columnas a cero decimales
BN_2$VALOR_ASEGURADO <- round(BN_2$VALOR_ASEGURADO,0)
BN_2$VALOR_CEDIDO <- round(BN_2$VALOR_CEDIDO,0)

#se crea la columna "LN" (línea de negocio) todos sus registros son "Bienestar".
BN_2$LN <-'Bienestar'

BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==20 &
                                 BN_2$CODIGO_PRODUCTO==764,2,BN_2$CODIGO_COMPANIA)
BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==25 &
                                 BN_2$CODIGO_PRODUCTO==737,3,BN_2$CODIGO_COMPANIA)
BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==20 & 
                                 BN_2$CODIGO_PRODUCTO==712,3,BN_2$CODIGO_COMPANIA)
BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==20 &
                                 BN_2$CODIGO_PRODUCTO==758,3,BN_2$CODIGO_COMPANIA)
#ifelse: SI "COD_RAMO_CONTABLE"=24, 26, 18  entonces asignar "CODIGO_COMPANIA"=2 o 3
BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==24,2,BN_2$CODIGO_COMPANIA)
BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==26,3,BN_2$CODIGO_COMPANIA)
BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==18,3,BN_2$CODIGO_COMPANIA)

#función mutate() anidada, remplaza registros "NO INFO" por carácter NA. 
BN_2 <- mutate(BN_2,SEXO=ifelse(SEXO=="NO INFO",NA,as.character(SEXO)))

#función mutate() anidada con comando %>% remplaza "FEMENINO" por "F", "MASCULINO" por "M"
BN_2 <- BN_2 %>% mutate(SEXO=replace(SEXO, SEXO=="FEMENINO", "F"),
                        SEXO=replace(SEXO, SEXO=="MASCULINO", "M")) %>% as.data.frame()

#as.Date() ajusta "FECHA_NACIMIENTO" como dato tipo Date
BN_2$FECHA_NACIMIENTO <- as.Date(BN_2$FECHA_NACIMIENTO)
BN_2$FECHA_CORTE <- as.Date(FECHA_CORTE)   #Se crea columna de tipo fecha FECHA_CORTE 

BN_2$EDAD <- round(as.numeric(trunc((BN_2$FECHA_CORTE-BN_2$FECHA_NACIMIENTO)/365)))

#si registro EDAD es negativo remplazar por NA
BN_2$EDAD <- ifelse(BN_2$EDAD<0,NA,BN_2$EDAD)

#segmentar la variable EDAD por grupos de 5 años
BN_2$ETARIO_1 <- cut(BN_2$EDAD, breaks=seq(from=0,to=100,by=5),right = F)
BN_2$ETARIO_1 <- as.character(BN_2$ETARIO_1)
#segmentar la variable EDAD por grupos de 10 años
BN_2$ETARIO_2 <- cut(BN_2$EDAD, breaks=seq(from=0,to=100,by=10),right = F)
BN_2$ETARIO_2 <- as.character(BN_2$ETARIO_2)
#segmentar la variable EDAD por grupos de 20 años
BN_2$ETARIO_3 <- cut(BN_2$EDAD, breaks=seq(from=0,to=100,by=20),right = F)
BN_2$ETARIO_3 <- as.character(BN_2$ETARIO_3)
#añadir columna MES con valor MES al principio de la rutina
BN_2$MES <- MES
#añadir columna AÑO con valor AÑO al principio de la rutina
BN_2$AÑO <- AÑO

BN_2 <- BN_2 %>% mutate(MUNICIPIO=replace(MUNICIPIO,MUNICIPIO=="Bogotá","BOGOTA D.C"),
                        MUNICIPIO=replace(MUNICIPIO,MUNICIPIO=="BOGOTA","BOGOTA D.C"))%>% 
  as.data.frame()

#remplazan los valores NA para diferentes columnas, con el texto ND
BN_2 <- BN_2 %>% replace_na(list(SEXO="ND",MUNICIPIO="ND",DEPARTAMENTO="ND",ETARIO_1="ND",
                                 ETARIO_2="ND",ETARIO_3="ND"))

#contador de valores faltantes en todo BN_2
sapply(BN_2, function(x) sum(is.na(x)))

#eliminar las filas donde "CODIGO_PRODUCTO" = 716
BN_2 <- BN_2 %>% filter(CODIGO_PRODUCTO != 716) 
#se llaman dos registros de la base "BN_2" como vista previa antes de exportar
head(BN_2, n=2)

#definir ruta de exportación de la base resultante "BN_2"
setwd("C:\\Users\\danie\\Desktop")

#exportar base "BN_2" formato CSV con el nombre "EXPUESTOS_BIENESTAR-" 
fwrite(BN_2,paste("EXPUESTOS_BIENESTAR-",p,".csv",sep=""),dec=".")

#elimina objetos almacenados
rm(list=ls())
