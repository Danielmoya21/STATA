
# Factor de Expansión y Medidas de Concentración

---
## Factor de expansión
Vamos a empezar cargando la base de datos 

```stata
use "la ubicacion del archivo en la computadora", clear
```

La base tiene ~30,000 mil observaciones, sin embargo, cuando el INEC publica resultados de la situación socioeconómica del país presenta datos extrapolados para todo el país.

!!! warning "Pregunta"
    ¿Cómo es entonces que puede hacer estadísticas sobre 5 millones de personas con una encuesta de 30 mil observaciones?

Si utilizamos el comando tab, podemos hacer una tabla descriptiva de algunas variables. Realicemos una tabla para el nivel de pobreza según la región.

```stata title="Tab normal"
tab region np
```
```stata
. tab region np
        Región de |         Nivel de pobreza
    planificación | Pobreza e  Pobreza n   No pobre |     Total
------------------+---------------------------------+----------
          Central |       650      1,966     15,197 |    17,813 
        Chorotega |       223        548      1,843 |     2,614 
 Pacífico Central |       148        450      1,561 |     2,159 
           Brunca |       298        569      1,729 |     2,596 
    Huetar Caribe |       376        659      2,103 |     3,138 
     Huetar Norte |       213        450      1,830 |     2,493 
------------------+---------------------------------+----------
            Total |     1,908      4,642     24,263 |    30,813 
```

Como podrá observar la tabla nos muestra el total de personas según su condición de pobreza y región de planificación, en total hay  30,813  observaciones. Si queremos saber a cuanto equivalen estos datos con respecto al total de la población, debemos usar el **factor de ponderación o expansión**

### Usar Factor de expansión
!!! tip "factor de expansión"
    El factor de ponderación se utiliza para ajustar la representación en
    una encuesta. Nos dice cuánto representa una observación en términos poblacionales.

Por ejemplo, si en el país hay más mujeres que hombres, pero en la encuesta se entrevistan igual número de mujeres que de hombres, entonces el factor de expansión da mayor peso a las mujeres.

En Stata simplemente añadimos la opción **[w=variable]** aquí w significa weight, es decir el peso de cada observación y la variable que tiene el peso de cada observación es "factor"

```stata title="Tab con factor de expansión"
tab region np [w=factor]
```

```stata
. tab region np [w=factor]
(frequency weights assumed)
        Región de |         Nivel de pobreza
    planificación | Pobreza e  Pobreza n   No pobre |     Total
------------------+---------------------------------+----------
          Central |   116,190    355,625  2,789,945 | 3,261,760 
        Chorotega |    33,839     83,656    297,416 |   414,911 
 Pacífico Central |    22,887     67,654    229,579 |   320,120 
           Brunca |    42,368     81,485    253,049 |   376,902 
    Huetar Caribe |    56,591     99,416    323,299 |   479,306 
     Huetar Norte |    37,386     80,979    333,053 |   451,418 
------------------+---------------------------------+----------
            Total |   309,261    768,815  4,226,341 | 5,304,417 
```

Como puede ver la tabla ahora muestra un total de 5,304,417 de observaciones. Esto quiere decir que estamos expandiendo los datos para todo el país.

!!! note "Diferentes tipos de pesos"

    **Frecuency weights (fweight):**  Se le indica a Stata que una sola
    línea representa observaciones de múltiples personas

    **Analytic weights (aweight)**: Se usan cuando cada observación
    es una media calculada a partir de una muestra de tamaño n.

    **Sample weights (pweight)**: También conocidas como
    ponderaciones de probabilidad, son adecuadas cuando se
    realiza un muestreo aleatorio sin reemplazo.

Podríamos también usarlo con variables que hayamos creado nosotros.

Por ejemplo, creemos una variable dicotómica que indique si 1 si la persona es pobre o 2 si no lo es

```stata title="Creamos variable de pobreza"
*Ponemos personas pobres en categoría 1 y no pobres en categoría 2
recode np (1/2=1) (3=2), gen(pobre_dicotomica)
*Creamos la tabla
tab pobre_dicotomica [w=factor]
```

```stata
  RECODE of |
  np (Nivel |
de pobreza) |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |  1,078,076       20.32       20.32
          2 |  4,226,341       79.68      100.00
------------+-----------------------------------
      Total |  5,304,417      100.00
```

<br>



--- 
## Medidas de concentración

### Repaso sobre percentiles

A veces es muy útil dividir a la población en percentiles, sobre todo cuando se estudia un tema como la desigualdad

Para esto trabajabamos con 2 comandos principales en Stata

!!! danger "xtile"
    Genera una variable categórica que indica el percentil al que pertenece la observación.

    Syntaxis
    ```stata
    xtile nueva_variable = expresión, nquantiles(#)
    ```
```stata title="Crear indicador de quintiles"
xtile quintil = ipcn if ipcn>0, nquantiles(5)
```
Esto genera una variable con números del 1 al 5 indicando el quintil de ingreso al que pertenece la persona

Ahora podemos hacer análisis por quintiles, por ejemplo ver los años de escolaridad promedio:
```stata title="Años de escolaridad según quintil de ingreso"
tab quintil [w=factor], sum(escolari)
```

```stata title="Tamaño del hogar según quintil de ingreso"
tab quintil [w=factor], sum(tamhog)
```

```stata title="Ingreso per cápita neto según quintil de ingreso"
tab quintil [w=factor], sum(ipcn)
```

<br>

---

### Coeficiente de Gini y Curva de Lorenz


En esta sección vamos a trabajar con el uso de paquetes externos que nos permiten computar la Curva de Lorenz y el Coeficiente de Gini

#### Instalación
!!! tip "Paquetes de terceros"
    Recuerde que para instalar paquetes de terceros usamos ```ssc install [nombre del paquete]```

```stata title="Instalar paquete - Curva de Lorenz"
ssc install glcurve
```

Si no estamos seguros de como instalar un paquete podemos escribir ```help [nombre del paquete]```, por ejemplo

```stata
help ginidesc
```

Este comando abrirá un menú con opciones de paquetes a descargar. Si el paquete ya está instalado, abre el menú de ayuda.

<br>

---
#### Uso de los comandos
Una vez instalados los comandos podemos calcular el coeficiente de Gini con el comando ```ginidesc```

### Coeficiente de Gini
```stata title="Calcular Coeficiente de Gini"
ginidesc ipcn if ipcn>0 [w=factor]
```
`ginidesc` muestra una tabla en la consola con el coeficiente de Gini. Además, muestra la desigualdad que puede ser atribuida a desigualdad entre grupos y dentro de los grupos 

Como ejemplo, podemos ver el coeficiente de Gini por región y analizar cuánto de la desigualdad se debe a brechas entre grupos

```stata title="Coeficiente de Ginir por regiones"
ginidesc ipcn if ipcn>0 [w=factor], by(region)
```

### Curva de Lorenz
También podemos computar la Curva de Lorenz con ```glcurve```, para tener una representación visual de la desigualdad del país

```stata title="Graficar Curva de Lorenz"
glcurve ipcn if ipcn>0 [w=factor], ///
lorenz title("Curva de Lorenz Costa Rica 2024") ///
scheme(plotplain) ///
ytitle("Porcentaje acumulado de ingreso") ///
xtitle("Porcentaje acumulado de personas") plot(function equality=x, color(blue))
```

#### Ejemplo con 2 años

```stata title="Cargar bases de datos"
*Primero se cargan las bases de 2024 y 2015
use "C:\Users\dmoya\OneDrive\Desktop\UCR\bases_de_datos\ENAHO\dta\enaho_2024.dta", clear
gen anno=2024
append using "C:\Users\dmoya\OneDrive\Desktop\UCR\bases_de_datos\ENAHO\dta\enaho_2015.dta"
recode anno (.=2015)
```

```stata title="Curva de Lorenz para múltiples años"
*Luego se crea el gráfico con la curva de lorenz
glcurve ipcn [w=factor] if ipcn>0, by(anno) split ///
lorenz title("Curva de Lorenz Costa Rica 2024") ///
scheme(plotplain) ///
ytitle("Porcentaje acumulado de ingreso") ///
xtitle("Porcentaje acumulado de personas") plot(function equality=x, color(blue)) lcolor(red black)
```

<a href="dofiles/dofile_semana13.do" download>Puede descargar el dofile aquí</a>



<!-- Borradores -->
<!-- Algo muy común que sucede cuando se está realizando una investigación es querer analizar un problema a lo largo del tiempo, sin embargo, todas las bases de datos con las que hemos trabajado hasta el momento incluyen solo las observaciones para un año en específico.

Suponga que usted quiere ver la evolución de la pobreza a lo largo de los últimos 3 años. Para poder realizar esto deberíamos analizar las bases de datos del 2023, 2024 y 2025. Sería más práctico combinar las bases de datos, que analizar una base a la vez.

!!! danger "Comando append"
    El comando **append** nos permite juntar bases de datos de manera vertical

```stata
append using "base_2.dta"
``` -->


<!-- # Combinar bases de datos

Utilizando `append` podemos juntar las bases de datos de ambos años (2023 y 2024) y trabajar con una sola base de datos.

Hasta ahora todo funciona bien, pero si observa la base de datos, notará que no puede diferenciar cuáles observaciones pertenecen a cada año. 

!!! tip "Generar identificadores"
    Podemos evitar este problema generando un **identificador** con la opción gen(variable)
    ```stata
    append using "base_2.dta", gen(anno)
    ```

Una vez hecho esto podríamos analizar por ejemplo como cambió el porcentaje de personas según su condición de pobreza.

Podemos hacerlo mediante un gráfico de barras.

```stata
*Note que para un gráfico de porcentaje no es necesario poner una variable antes de la coma
*con asyvars le decimos que a STATA que use diferentes colores para la variable que pusimos en el primer over()
*En este caso el anno
graph bar (percent) [w=factor], over(anno) over(np) asyvars
graph box Escolari [w=factor] if Escolari!=99, over(anno)
```

!!! danger "Nota"
    Note el uso del factor de expansión para hacer el gráfico

!!! warning "Otras manipulaciones"
    - **Merge**: Une bases de datos con una columna en común de forma horizontal
    - **Collapse**: Resume datos. Permite reducir la base de datos a estadísticas descriptivas
   
    *Estas no son cubiertas en el curso  -->


<!-- !!! danger "pctile"
    Nos indica el valor de los percentiles

    Syntaxis
    ```stata
    pctile nueva_variable = expresión, nquantiles(#)
    ```
```stata
pctile valores = ipcn if ipcn>0, nquantiles(5)
tab valores
```
Esto nos muestra una tabla con el valor del ingreso que corresponde al quintil 1, 2, 3 y 4 -->
