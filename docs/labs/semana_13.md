
# Factor de Expansión

Vamos a empezar cargando la base de datos 

```stata
use "la ubicacion del archivo en la computadora", clear

```

La base tiene ~30,000 mil observaciones, sin embargo, cuando el INEC publica resultados de la situación socioeconómica del país presenta datos extrapolados para todo el país. 

!!! warning "Pregunta"
    ¿Cómo es entonces que puede hacer estadísticas sobre 5 millones de personas con una encuesta de 30 mil observaciones?

Si utilizamos el comando tab, podemos hacer una tabla descriptiva de algunas variables. Realicemos una tabla para el nivel de pobreza según la región.

```stata title="Tab normal"
tab REGION np

```
Como podrá observar la tabla nos muestra el total de personas según su condicón de pobreza y región de planificación, en total hay  30,514 observaciones. Si queremos saber a cuanto equivalen estos datos con respecto al total de la población, debemos usar el **factor de ponderación o expansión**

!!! tip "Factor de ponderación"
    El factor de ponderación se utiliza para ajustar la representación en
    una encuesta. Nos dice cuánto representa una observación en términos poblacionales.

Por ejemplo, si en el país hay más mujeres que hombres, pero en la encuesta se entrevistan igual número de mujeres que de hombres, entonces el factor de expansión da mayor peso a las mujeres.

En Stata simplemente añadimos la opción **[w=variable]** aquí w significa weight, es decir el peso de cada observación y la variable que tiene el peso de cada observación es "FACTOR"

```stata title="Tab con pesos"
tab REGION np [w=FACTOR]

```
Como puede ver la tabla ahora muestra un total de 5,257,304 de observaciones. Esto quiere decir que estamos expandiendo los datos para todo el país.

!!! note "Diferentes tipos de pesos"

    **Frecuency weights (fweight):**  Se le indica a Stata que una sola
    línea representa observaciones de múltiples personas

    **Analytic weights (aweight)**: Se usan cuando cada observación
    es una media calculada a partir de una muestra de tamaño n.

    **Sample weights (pweight)**: También conocidas como
    ponderaciones de probabilidad, son adecuadas cuando se
    realiza un muestreo aleatorio sin reemplazo.

Podríamos también usarlo con variables que hayamos creado nosotros.

```stata title="Creamos variable de pobreza"
*Ponemos personas pobres en categoría 1 y no pobres en categoría 0
recode np (2=1) (3=0), gen(pobre_dicotomica)
*Creamos la tabla
tab pobre_dicotomica [w=FACTOR]
```

---

# Combinar bases de datos


Algo muy común que sucede cuando se está realizando una investigación es querer analizar un problema a lo largo del tiempo, sin embargo, todas las bases de datos con las que hemos trabajado hasta el momento incluyen solo las observaciones para un año en específico.

Suponga que usted quiere ver la evolución de la pobreza a lo largo de los últimos 3 años. Para poder realizar esto deberíamos analizar las bases de datos del 2023, 2024 y 2025. Sería más práctico combinar las bases de datos, que analizar una base a la vez.

!!! danger "Comando append"
    El comando **append** nos permite juntar bases de datos de manera vertical

```stata
append using "base_2.dta"
```

Utilizando append podemos juntar las bases de datos de ambos años y trabajar con una sola base de datos.

Hasta ahora todo funciona bien, pero si observa la base de datos, notará que no puede diferenciar cuales observaciones pertenecen a cada año. 

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
graph bar (percent) [w=FACTOR], over(anno) over(np) asyvars
graph box Escolari [w=FACTOR] if Escolari!=99, over(anno)
```

!!! danger "Nota"
    Note el uso del factor de expansión para hacer el gráfico

!!! warning "Otras manipulaciones"
    - **Merge**: Une bases de datos con una columna en común de forma horizontal
    - **Collapse**: Resume datos. Permite reducir la base de datos a estadísticas descriptivas
   
    *Estas no son cubiertas en el curso 

---

# Medidas de concentración

## Repaso sobre percentiles

A veces es muy útil dividir a la población en percentiles, sobretodo cuando se estudia un tema como la desigualdad

Para esto trabajabamos con 2 comandos principales en Stata

!!! danger "xtile"
    Genera una variable categórica que indica el percentil al que pertenece la observación.

    Syntaxis
    ```stata
    xtile nueva_variable = expresión, nquantiles(#)
    ```
```stata
xtile quintil = ipcn if ipcn>0, nquantiles(5)
```
Esto genera una variable con números del 1 al 5 indicando el quintil de ingreso al que pertenece la persona

Ahora podemos hacer análisis por quintiles, por ejemplo ver los años de escolaridad promedio:
```stata
tab quintil, sum(Escolari) mean
```

!!! danger "pctile"
    Nos indica el valor de los percentiles

    Syntaxis
    ```stata
    pctile nueva_variable = expresión, nquantiles(#)
    ```
```stata
pctile valores = ipcn if ipcn>0, nquantiles(5)
tab valores
```
Esto nos muestra una tabla con el valor del ingreso que corresponde al quintil 1, 2, 3 y 4


## Coeficiente de Gini y Curva de Lorenz

En esta sección vamos a trabajar con el uso de paquetes externos que nos permiten computar la Curva de Lorenz y el Coeficiente de Gini

!!! tip "Paquetes de terceros"
    Recuerde que para instalar paquetes de terceros usamos ```ssc install [nombre del paquete]```

```stata
ssc install glcurve
```

Si no estamos seguros de como instalar un paquete podemos escribir ```help [nombre del paquete]```, por ejemplo

```stata
help ginidesc
```

Este comando abrirá un menú con opciones de paquetes a descargar. Si el paquete ya está instalado, abre el menú de ayuda.

Una vez instalados los comandos podemos calcular el índice de Gini con el comando ```ginidesc```

```stata
ginidesc ipcn if ipcn>0 & anno==2024
```
```ginidesc``` muestra una tabla en la consola con el coeficiente de Gini. Además, muestra la desigualdad que puede ser atribuida a desigualdad entre grupos y dentro de los grupos 

Como ejemplo podemos ver el coeficiente de Gini por region y analizar cuánto de la desigualdad se debe a brechas entre grupos

```stata
ginidesc ipcn if ipcn>0 & anno==2024, by(REGION)
```

También podemos computar la Curva de Lorenz con ```glcurve```, para tener una representación visual de la desigualdad del país

```stata
glcurve ipcn if ipcn>0 & anno==2024, ///
lorenz title("Curva de Lorenz Costa Rica 2024") ///
scheme(plotplain) ///
ytitle("Porcentaje acumulado de ingreso") ///
xtitle("Porcentaje acumulado de personas") plot(function equality=x, color(blue))
```

<a href="dofiles/dofile_semana13.do" download>Puede descargar el dofile aquí</a>