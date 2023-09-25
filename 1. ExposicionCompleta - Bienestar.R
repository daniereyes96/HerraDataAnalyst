library(readr)
library(dplyr)
library(data.table)
library(writexl)
library(lubridate)
library(tidyr)

# Fecha corte
p <- "2022-06"
# as.Date extrae la fecha de un texto
FECHA_CORTE <- as.Date("2022-06-30")

# Variables de tiempo
M <- month(FECHA_CORTE)
MES <- ifelse(M==3,"MARZO",M)
MES <- ifelse(M==6,"JUNIO",MES)
MES <- ifelse(M==9,"SEPTIEMBRE",MES)
MES <- ifelse(M==12,"DICIEMBRE",MES)

AÑO <- year(FECHA_CORTE)

# Definir ruta de trabajo
setwd("C:\\Users\\1020817169\\Desktop\\POWERCAT\\Informacion GCP\\Bienestar")

#### ---- 1. Bienestar ---- ####

# Recipe inputs
BN <-  read_csv(paste("Bienestar_",p,".csv",sep=""),col_names = F)

names(BN) <- c("NUMERO_POLIZA 1","KEY_ID_ASEGURADO22","CODIGO_RAMO_CONTABLE33","CODIGO_PRODUCTO44",
               "CODIGO_COBERTURA55","VT77","VC88","VR99","VF10","ACTIVO11",
               "17SEXO","18FECHA_NACIMIENTO","19MUNICIPIO","20DEPARTAMENTO")

BN_2 <- BN[names(BN)[c(1,2,3,4,5,7:10,11)]]
BN_2 <- BN_2 %>% select(-NE,-ACTIVO)

# Modificar nombres variables
names(BN_2)[c(10:13)]<-c("VALOR_ASEGURADO","VALOR_CEDIDO","VALOR_RETENIDO","VALOR_FACULTATIVO")

# Ajustar Codigo_Compania
BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==18 & BN_2$CODIGO_PRODUCTO==754,2,BN_2$CODIGO_COMPANIA)
BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==24 & BN_2$CODIGO_PRODUCTO==500,3,BN_2$CODIGO_COMPANIA)
BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==45 & BN_2$CODIGO_PRODUCTO==30,2,BN_2$CODIGO_COMPANIA)

# Ajustar valor asegurado
BN_2$VALOR_ASEGURADO <- round(BN_2$VALOR_ASEGURADO,0)

# Ajustar variable VA_CEDIDO (Valor asegurado cedido)
BN_2$VALOR_CEDIDO <- round(BN_2$VALOR_CEDIDO,0)

# Ajustar variable VA_RETENIDO (Valor asegurado retenido)
BN_2$VALOR_RETENIDO <- round(BN_2$VALOR_RETENIDO,0)

# Ajustar variable VA_FACULTATIVO (Valor asegurado facultativo)
BN_2$VALOR_FACULTATIVO <- round(BN_2$VALOR_FACULTATIVO,0)

# Agregar Linea de negocio
BN_2$LN <-'Bienestar'

# Ajustar posibles errores Sexo
BN_2 <- mutate(BN_2,SEXO=ifelse(SEXO=="NO INFO",NA,as.character(SEXO)))
BN_2 <- BN_2 %>% mutate(SEXO=replace(SEXO, SEXO=="FEMENINO", "F"),
                        SEXO=replace(SEXO, SEXO=="MASCULINO", "M")) %>%
  as.data.frame()

# Ajustar fecha de nacimiento 
BN_2$FECHA_NACIMIENTO <- as.Date(BN_2$FECHA_NACIMIENTO)

# Ajustar fecha de corte
BN_2$FECHA_CORTE <- as.Date(FECHA_CORTE)

# Ajustar variable Edad
BN_2$EDAD <- round(as.numeric(trunc((BN_2$FECHA_CORTE-BN_2$FECHA_NACIMIENTO)/365)))
BN_2$EDAD <- ifelse(BN_2$EDAD<0,NA,BN_2$EDAD)

# Segmentar la variable EDAD por grupos de 5 años
BN_2$ETARIO_1 <- cut(BN_2$EDAD, breaks=seq(from=0,to=100,by=5),right = F)
BN_2$ETARIO_1 <- as.character(BN_2$ETARIO_1)

# Segmentar la variable EDAD por grupos de 10 años
BN_2$ETARIO_2 <- cut(BN_2$EDAD, breaks=seq(from=0,to=100,by=10),right = F)
BN_2$ETARIO_2 <- as.character(BN_2$ETARIO_2)

# Segmentar la variable EDAD por grupos de 20 años
BN_2$ETARIO_3 <- cut(BN_2$EDAD, breaks=seq(from=0,to=100,by=20),right = F)
BN_2$ETARIO_3 <- as.character(BN_2$ETARIO_3)

# Añadir mes
BN_2$MES <- MES

# Añadir año
BN_2$AÑO <- AÑO

# Posibles errores Municipio
BN_2 <- BN_2 %>% mutate(MUNICIPIO=replace(MUNICIPIO, MUNICIPIO=="BOGOTA, D.C.", "BOGOTA D.C"),
                        MUNICIPIO=replace(MUNICIPIO, MUNICIPIO=="BOGOTA", "BOGOTA D.C")) %>%
  as.data.frame()

# Posibles errores Departamento 
BN_2 <- BN_2 %>% mutate(DEPARTAMENTO=replace(DEPARTAMENTO, DEPARTAMENTO=="BOGOTA, D.C.", "BOGOTA D.C"),
                        DEPARTAMENTO=replace(DEPARTAMENTO, DEPARTAMENTO=="ARCHIPIELAGO DE SAN ANDRES, PROVIDENCIA Y SANTA CATALINA",
                                             "SAN ANDRES Y PROVIDENCIA"),
                        DEPARTAMENTO=replace(DEPARTAMENTO,DEPARTAMENTO=="VACIO",NA)) %>%
  as.data.frame()

BN_2 <- BN_2 %>% mutate(DEPARTAMENTO=replace(DEPARTAMENTO,MUNICIPIO=="BOGOTA D.C","BOGOTA D.C")) %>%
  as.data.frame()

# Reemplazar valores faltantes
BN_2 <- BN_2 %>% replace_na(list(SEXO="ND",MUNICIPIO="ND",DEPARTAMENTO="ND",ETARIO_1="ND",
                                 ETARIO_2="ND",ETARIO_3="ND"))

# Valores faltantes
sapply(BN_2, function(x) sum(is.na(x)))

# Eliminar información Producto 756 (Es de Bancaseguros)
BN_2 <- BN_2 %>% filter(CODIGO_PRODUCTO != 756)


#### ---- 2. Exportar exposicón completa ---- ####

# Definir ruta de exportación
setwd("C:\\Users\\1020817169\\Desktop\\POWERCAT\\Informacion Procesada\\Exposicion Completa\\Bienestar")

# Expotar archivo Bienestar
fwrite(BN_2,paste("EXPUESTOS_BIENESTAR-",p,".csv",sep=""),dec=".")

 
s2-s

# Limpiar ambiente
rm(list=ls())
