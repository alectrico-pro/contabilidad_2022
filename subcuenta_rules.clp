( defmodule SUBCUENTA ( import MAIN deftemplate ?ALL))

;---- este modulo se concentra en presentar en forma de T el comportamiento de las partidas para cada cuenta
;---- también totaliza sumas calificadas para alimentar al balance inicial y a otros informes
;---- los hechos de totales y subtotales ayudan a obtener los estados de síntesis para cada nivel de agregación
;---- la granularidad de los datos es a nivel de partida, donde intervienen las cuentas.
;---- luego las cuentas tienen diferentes estados que han sido establecidos por los movimientos entre cuentas de cada partida
;---- hay un resumen por cuentas, sin clasificarlas por estados, solo un listado con debe, haber, y los valora canonizados 
;---- deber y acreedor
;---- No es necesario filtrar por dia, mes, año o empresa pues los modulos anteriores eliminan o evitan reglas fuera de estos filtos.


(deffunction mes_to_numero ( ?mes )
  ( switch ?mes
    ( case enero      then 1)
    ( case febrero    then 2)
    ( case marzo      then 3)
    ( case abril      then 4)
    ( case mayo       then 5)
    ( case junio      then 6)
    ( case julio      then 7)
    ( case agosto     then 8)
    ( case septiembre then 9)
    ( case octubre    then 10)
    ( case noviembre  then 11)
    ( case diciembre  then 12)
  )
)

(deffunction to_serial_date( ?dia ?mes ?ano)
  (+ (* 10000 ?ano) (* 100 ( mes_to_numero ?mes)) ?dia)
)



( defrule inicio-de-modulo-TC
   (declare (salience 9000))
;  (empresa (nombre ?empresa))
  =>
   ( printout t "--módulo----------------------- SUBCUENTAS ---------------------" crlf)
   ( set-strategy depth )
)


;esto genera un markdown para que jekyll lo publique en el blog necios
(defrule inicio-kindle-k-sub-cuentas-rules
   ( declare (salience 10000))
   ( empresa (nombre ?empresa))
  =>

   ( bind ?archivo (str-cat "./doc/" ?empresa "/subcuentas.markdown"))
   ( open ?archivo k "w")

   ( printout k "--- " crlf)
;   ( printout k "title: Subcuentas-" ?empresa crlf)
;   ( printout k "permalink: /" ?empresa "/subcuentas " crlf)
   ( printout k "layout: page" crlf)
   ( printout k "--- " crlf)
)

(defrule fin-kindle-k
  ( declare (salience -100) )
 =>
  ( close k )
)


( defrule encabezado

?cuenta <- ( cuenta
    ( partida ?Numero & nil )
    ( nombre ?nombre)
    ( padre ?padre )
    ( nombre-sii ?nombre-sii)
    ( descripcion ?descripcion)
    ( origen nominativo  )
 )

  (exists
    ( cuenta
      ( mostrado-en-t false)
      ( nombre  ?nombre)
      ( partida ?Numero2 & ~?Numero)
      ( saldo ?saldo )
    )
  ) 

;  ?cuenta <- ( cuenta
;     ( partida nil)
;     ( mostrado-en-t false)
;     ( nombre ?nombre)
;     ( origen nominativo)
;     ( padre ?padre )
;     ( saldo  ?saldo )
;  )
  (test (neq false ?padre))
 =>
  ( printout t crlf crlf crlf )
  ( printout t ?nombre "#" ?padre crlf )
  ( printout t "----------------------------" crlf)
  ( assert ( subtotales ( cuenta ?nombre)))
  ( assert ( hacer ?nombre))


  ( printout k "<table>" crlf)
  ( printout k "<thead><th colspan='6'> " ?nombre "</th><th colspan='3'>" ?nombre-sii "</th></thead>" crlf)
  ( printout k "<thead><th colspan='9'> " ?descripcion "</th></thead>" crlf)

  ( printout k "<thead><th> voucher </th><th> partida </th><th> debe </th> <th> | </th> <th> haber </th><th> mes </th> <th>recibida</th> <th>activo-fijo</th> <th> tipo documento</th></thead>"crlf)
  ( printout k "<tbody>" crlf)



)

( defrule t-filas-de-resultados


  ( empresa (nombre ?empresa))
  ( balance (dia ?top) (mes ?mes_top) (ano ?ano_top))

  ( partida (numero ?partida) (dia ?dia) (mes ?mes) (ano ?ano))

  ( test (>= (to_serial_date ?top ?mes_top ?ano_top) (to_serial_date ?dia ?mes ?ano)))

  ?hacer  <- ( hacer ?nombre )

  ?cuenta <- ( cuenta
     ( partida ?partida)
     ( nombre ?nombre)
     ( debe    ?debe)
     ( haber   ?haber)
     ( recibida ?recibida)
     ( activo-fijo ?activo-fijo)
     ( mes ?mes)
     ( tipo-de-documento ?tipo-de-documento)
     ( de-resultado true)
     ( mostrado-en-t false)
     ( origen  nominativo ) )

  ?subtotales <- ( subtotales
    ( mostrado   false)
    ( totalizado false)
    ( cuenta ?nombre )
    ( debe ?total_debe)
    ( haber ?total_haber) )

  (revision
     ( partida ?partida)
     ( voucher ?voucher))


  ( test (or (> ?debe 0) (> ?haber 0)))

 =>
  ( printout t "r " ?partida tab ?debe tab "|" tab ?haber crlf )

  ( printout k "<tr> <td>" ?voucher "</td> <td align='right'>" ?partida "</td> <td align='right'>" ?debe "</td> <td> | </td> <td align='right'> " ?haber  "</td> <td>" ?mes "</td><td>" ?recibida "</td><td> " ?activo-fijo "</td><td> " ?tipo-de-documento "</td> </tr>" crlf )



  ( modify ?cuenta (mostrado-en-t true ))
  ( modify ?subtotales
       (debe  (+ ?total_debe  ?debe))
       (haber (+ ?total_haber ?haber)))
)


 
( defrule t-filas


  ( empresa (nombre ?empresa))
  ( balance (dia ?top) (mes ?mes_top) (ano ?ano_top))
  ( partida (numero ?partida) (dia ?dia) (mes ?mes) (ano ?ano))

  ( test (>= (to_serial_date ?top ?mes_top ?ano_top) (to_serial_date ?dia ?mes ?ano)))


  ?hacer  <- ( hacer ?nombre )

  ?cuenta <- ( cuenta 
     ( tipo-de-documento ?tipo-de-documento)
     ( de-resultado false)
     ( nombre ?nombre)
     ( mes ?mes)
     ( partida ?partida) 
     ( debe    ?debe)
     ( haber   ?haber)
     ( mostrado-en-t false)
     ( origen  ?origen ) )

  ?subtotales <- ( subtotales
    ( mostrado   false)
    ( totalizado false)
    ( cuenta ?nombre )
    ( debe ?total_debe)
    ( haber ?total_haber) )

  ( test (and (neq nil ?partida) (> ?partida 0)))
  ( test (or (> ?debe 0) (> ?haber 0)))
 =>
  ( printout t ?partida tab ?debe tab "|" tab ?haber tab ?mes tab tipo-de-documento tab ?tipo-de-documento crlf )
  ( modify ?cuenta (mostrado-en-t true ))
  ( modify ?subtotales
       (debe  (+ ?total_debe  ?debe))
       (haber (+ ?total_haber ?haber)))
)


( defrule t-diferencia-deudora
   ?subtotales <- ( subtotales
     ( mostrado false)
     ( haber ?haber )
     ( debe  ?debe )
     ( acreedor ?acreedor)
     ( deber ?deber)
     ( totalizado false)
   )
   ( test (> ?debe ?haber))
  =>
   ( bind ?diferencia (- ?debe ?haber ))
   ( modify ?subtotales (deber ?diferencia) (totalizado true))
)



( defrule t-diferencia-acreedora
   ?subtotales <- ( subtotales
     ( haber ?haber )
     ( debe  ?debe )
     ( acreedor ?acreedor)
     ( deber ?deber)
     ( totalizado false)
     ( mostrado false)
   )
   ( test (< ?debe ?haber))
  =>
   ( bind ?diferencia (- ?haber ?debe ))
   ( modify ?subtotales (acreedor ?diferencia) (totalizado true))
)



( defrule t-footer-deudor
  ?subtotales <- ( subtotales 
    ( haber ?haber )
    ( debe  ?debe )
    ( totalizado true)
    ( mostrado false)
  )
  ( test (> ?debe ?haber))
  =>
   ( bind ?diferencia (- ?debe ?haber ))
   ( printout t "----------------------------" crlf)
   ( printout t tab ?debe tab "|" tab ?haber crlf )
   ( printout t tab "--------------------" crlf)
   ( printout t "$" tab ?diferencia crlf )

   ( printout k "<tr> <td></td> <td></td> <td align='right'>" ?debe "</td> <td>|</td> <td align='right'>" ?haber "</td></tr>" crlf )
   ( printout k "<tr> <td></td> <td>$</td> <td align='right'>"  ?diferencia "</td></tr>" crlf )

   ( printout k "</tbody>" crlf)
   ( printout k "</table>" crlf)


)



( defrule t-footer-acreedor
  ?subtotales <- ( subtotales
    ( haber ?haber )
    ( debe  ?debe )
    ( totalizado true)
    ( mostrado false )
  )
  ( test (< ?debe ?haber))
  =>
   ( bind ?diferencia (- ?haber ?debe ))
   ( printout t "----------------------------" crlf)
   ( printout t tab ?debe tab "|" tab ?haber crlf )
   ( printout t tab "---------------------" crlf)
   ( printout t tab tab "|" tab  ?diferencia tab "$" crlf )

   ( printout k "<tr> <td> </td><td></td> <td align='right'>" ?debe "</td> <td>|</td> <td align='right'>" ?haber "</td> </tr>" crlf )
   ( printout k "<tr> <td> </td><td> </td> <td></td> <td>|</td> <td align='right'>"  ?diferencia "</td> <td>$</td> </tr>" crlf )

   ( printout k "</tbody>" crlf)
   ( printout k "</table>" crlf)


)


