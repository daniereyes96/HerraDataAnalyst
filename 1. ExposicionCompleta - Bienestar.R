# Carga de librerías necesarias
library(readr)
library(dplyr)
library(tidyr)
library(data.table)
library(readxl)
library(sqldf)

# Definición de la variable 'p' con el periodo deseado
p <- "2022-06"

# Definición de la fecha de corte
FECHA_CORTE <- as.Date("2022-06-30")

# Obtención del mes a partir de la fecha de corte
M <- month(FECHA_CORTE)

# Asignación de nombres de mes en español según el valor de 'M'
MES <- ifelse(M==3,"MARZO",M)
MES <- ifelse(M==6,"JUNIO",MES)
MES <- ifelse(M==9,"SEPTIEMBRE",MES)
MES <- ifelse(M==12,"DICIEMBRE",MES)

# Obtención del año a partir de la fecha de corte
AÑO <- year(FECHA_CORTE)

# Establecimiento del directorio de trabajo
setwd("C:\\Users\\danie\\Desktop\\Monografia1")

# Lectura de datos desde un archivo CSV y asignación de nombres a las columnas
BN <-  read_csv(paste("Bienestar_",p,".csv",sep=""),col_names = FALSE)

# Renombrar las columnas en 'BN'
names(BN) <- c("NUMERO_POLIZA","KEY_ID_ASEGURADO","CODIGO_RAMO_CONTABLE",
               "CODIGO_PRODUCTO","VT","VC","ACTIVO","SEXO","FECHA_NACIMIENTO","MUNICIPIO")

# Reordenar las columnas de 'BN'
BN_2 <- BN[names(BN)[c(3,2,1,4,5,6,7,8:10)]]

# Eliminar la columna 'ACTIVO'
BN_2 <- BN_2 %>% select(-ACTIVO)

# Renombrar columnas
names(BN_2)[c(5:6)]<-c("VALOR_ASEGURADO","VALOR_CEDIDO")

# Agregar columna 'CODIGO_COMPANIA' con valor 0
BN_2$CODIGO_COMPANIA <- 0

# Crear dos filas de datos adicionales y agregarlas a 'BN_2'
nuevas.filas=data.frame(CODIGO_RAMO_CONTABLE=c(24,25), KEY_ID_ASEGURADO=c("A99B","A98B"),
                        NUMERO_POLIZA=c(156322,167541), CODIGO_PRODUCTO=c(716,736),
                        VALOR_ASEGURADO=c(168000.596,178000.860), 
                        VALOR_CEDIDO=c(258000.73,10000.145),SEXO=c("NO INFO","NA"), 
                        FECHA_NACIMIENTO=c(as.Date("1975-09-12"), as.Date("1979-03-15")),
                        MUNICIPIO=c("Bogotá","Bogotá"), CODIGO_COMPANIA=c(0,0))
BN_2 <- rbind(BN_2,nuevas.filas)

# Redondear los valores en las columnas 'VALOR_ASEGURADO' y 'VALOR_CEDIDO'
BN_2$VALOR_ASEGURADO <- round(BN_2$VALOR_ASEGURADO,0)
BN_2$VALOR_CEDIDO <- round(BN_2$VALOR_CEDIDO,0)

# Agregar la columna 'LN' con valor 'Bienestar'
BN_2$LN <-'Bienestar'

# Asignar valores en la columna 'CODIGO_COMPANIA' según condiciones
BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==20 &
                            BN_2$CODIGO_PRODUCTO==764,2,BN_2$CODIGO_COMPANIA)
BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==25 &
                            BN_2$CODIGO_PRODUCTO==737,3,BN_2$CODIGO_COMPANIA)
# ... Agregar más condiciones para 'CODIGO_COMPANIA'

# Convertir registros 'NO INFO' en la columna 'SEXO' a 'NA'
BN_2$CODIGO_COMPANIA <- ifelse(BN_2$CODIGO_RAMO_CONTABLE==18,3,BN_2$CODIGO_COMPANIA)

# Convertir registros 'NO INFO' en la columna 'SEXO' a 'NA'
BN_2 <- mutate(BN_2,SEXO=ifelse(SEXO=="NO INFO",NA,as.character(SEXO)))

# Simplificar registros en la columna 'SEXO' (reemplazar 'FEMENINO' con 'F' y 'MASCULINO' con 'M')
BN_2 <- BN_2 %>% mutate(SEXO=replace(SEXO, SEXO=="FEMENINO", "F"),
                        SEXO=replace(SEXO, SEXO=="MASCULINO", "M")) %>% as.data.frame()

# Convertir la columna 'FECHA_NACIMIENTO' en formato de fecha
BN_2$FECHA_NACIMIENTO <- as.Date(BN_2$FECHA_NACIMIENTO)
BN_2$FECHA_CORTE <- as.Date(FECHA_CORTE)

# Calcular la edad y manejar valores negativos
BN_2$EDAD <- round(as.numeric(trunc((BN_2$FECHA_CORTE-BN_2$FECHA_NACIMIENTO)/365)))
BN_2$EDAD <- ifelse(BN_2$EDAD<0,NA,BN_2$EDAD)

# Segmentar la variable 'EDAD' en grupos etarios
BN_2$ETARIO_1 <- cut(BN_2$EDAD, breaks=seq(from=0,to=100,by=5),right = F)
BN_2$ETARIO_1 <- as.character(BN_2$ETARIO_1)
BN_2$ETARIO_2 <- cut(BN_2$EDAD, breaks=seq(from=0,to=100,by=10),right = F)
BN_2$ETARIO_2 <- as.character(BN_2$ETARIO_2)
BN_2$ETARIO_3 <- cut(BN_2$EDAD, breaks=seq(from=0,to=100,by=20),right = F)
BN_2$ETARIO_3 <- as.character(BN_2$ETARIO_3)

# Agregar columnas 'MES' y 'AÑO'
BN_2$MES <- MES
BN_2$AÑO <- AÑO

# Reemplazar valores en la columna 'MUNICIPIO'
BN_2 <- BN_2 %>% mutate(MUNICIPIO=replace(MUNICIPIO,MUNICIPIO=="Bogotá","BOGOTA D.C"),
                        MUNICIPIO=replace(MUNICIPIO,MUNICIPIO=="BOGOTA","BOGOTA D.C"))%>% 
  as.data.frame()

# Reemplazar valores NA en varias columnas con 'ND'
BN_2 <- BN_2 %>% replace_na(list(SEXO="ND",MUNICIPIO="ND",DEPARTAMENTO="ND",ETARIO_1="ND",
                                 ETARIO_2="ND",ETARIO_3="ND"))

# Contador de valores faltantes en todas las columnas de 'BN_2'
sapply(BN_2, function(x) sum(is.na(x)))

# Eliminar filas donde 'CODIGO_PRODUCTO' es igual a 716
BN_2 <- BN_2 %>% filter(CODIGO_PRODUCTO != 716) 

# Vista previa de las primeras dos filas de 'BN_2'
head(BN_2, n=2)

# Definir la ruta de exportación de 'BN_2'
setwd("C:\\Users\\danie\\Desktop\\Monografia1")

# Exportar 'BN_2' a un archivo CSV con nombre dependiente del valor de 'p'
fwrite(BN_2,paste("EXPUESTOS_BIENESTAR-",p,".csv",sep=""),dec=".")

# Limpiar el entorno eliminando objetos almacenados
rm(list=ls())
