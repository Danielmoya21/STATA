
use "C:\Users\dmoya\OneDrive\Desktop\UCR\Papaer migracion\ENAHOS\enaho_2023.dta", clear

*Tab Normal
tab REGION np

*Tab con expansion
tab REGION np [w=FACTOR]

*Ponemos personas pobres en categoría 1 y no pobres en categoría 0
recode np (2=1) (3=0), gen(pobre_dicotomica)
*Creamos la tabla
tab pobre_dicotomica [w=FACTOR]

*Anadir base de datos 2
append using "C:\Users\dmoya\OneDrive\Desktop\UCR\Papaer migracion\ENAHOS\enaho_2022.dta", gen(anno)

*Cambiamos los valores de
recode anno (0=2023) (1=2024) 

*Note que para un gráfico de porcentaje no es necesario poner una variable antes de la coma
*con asyvars le decimos que a STATA que use diferentes colores para la variable que pusimos en el primer over()
*En este caso el anno
graph bar (percent) [w=FACTOR], over(anno) over(np) asyvars
graph box Escolari [w=FACTOR] if Escolari!=99, over(anno)

*Falta boxplot y quintiles
xtile quintil = ipcn if ipcn>0, nquantiles(5)
tab quintil, sum(Escolari) mean

pctile valores = ipcn if ipcn>0, nquantiles(5)
tab valores

*Medidas de concentración
ssc install glcurve
help ginidesc

*Calculo del indice de Gini
ginidesc ipcn if ipcn>0

*Gini por region
ginidesc ipcn if ipcn>0, by(REGION)

*Curva de Lorenz
glcurve ipcn if ipcn>0 & anno==2024, lorenz title("Curva de Lorenz Costa Rica 2024") scheme(plotplain) ///
ytitle("Porcentaje acumulado de ingreso") xtitle("Porcentaje acumulado de personas") plot(function equality=x, color(blue))

