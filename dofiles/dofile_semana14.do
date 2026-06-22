import excel using "ruta del archivo.xlsx", sheet("Hoja2") firstrow clear

* Revise los nombres importados desde Excel antes de renombrar
describe

* Preparar variable de tiempo
format Anno %ty
tsset Anno

* Preparar variable del PIB
rename ProductoInternoBrutoapr PIB
label var PIB "Producto Interno Bruto"
replace PIB = PIB/1000000

* Graficar serie
tsline PIB

* Promedio movil simple
tssmooth ma media_movil = PIB, window(2,1,2)
order media_movil, after(PIB)
label var media_movil "Promedio movil del PIB"

tsline PIB media_movil

* Promedio movil ponderado
tssmooth ma media_movil_pesos = PIB, weights(1/2 <4> 2/1)
order media_movil_pesos, after(media_movil)
label var media_movil_pesos "Promedio movil ponderado del PIB"

tsline PIB media_movil media_movil_pesos

* Rezago de cinco periodos
gen PIB_rezagos = L5.PIB
order PIB_rezagos, after(PIB)

* Tasa de crecimiento del PIB
gen crecimiento = D.PIB/L.PIB*100
order crecimiento, after(PIB_rezagos)

tsline crecimiento
