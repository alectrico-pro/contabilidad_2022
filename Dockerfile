# syntax=docker/dockerfile:1
FROM cupercupu/clipspy AS build
ARG ANO

ENV ANO=${ANO}
#oputput from contabilidad.py
RUN mkdir /doc
RUN mkdir /doc/alectrico-${ANO}
RUN mkdir /doc/_posts
RUN mkdir /doc/_data

#input to contabilidad.py
COPY *.bat                    ./
COPY *.clp                    ./

COPY alectrico-${ANO}-facts.txt              ./
COPY alectrico-${ANO}-revisiones.txt         ./
COPY alectrico-${ANO}-revisiones-cuentas.txt ./
COPY alectrico-${ANO}-valor-activos.txt      ./
COPY alectrico-${ANO}-tasas.txt              ./

COPY contratos.txt                ./
copy cuentas.txt                  ./
copy proveedores.txt              ./
COPY remuneraciones.txt           ./
COPY trabajadores.txt             ./
COPY salud.txt                    ./
COPY tipos_de_depreciaciones.txt  ./
COPY selecciones.txt              ./
COPY accionistas.txt              ./
COPY afc.txt                      ./
COPY afps.txt                     ./
COPY tramos-de-impuesto-unico.txt ./
COPY 404.html                     ./
COPY contabilidad.py              ./

WORKDIR .

RUN ./contabilidad.py

FROM jekyll/jekyll 
ARG ANO
ENV ANO=${ANO}
#Estos son manuales
#OPY ./*.markdown         ./
COPY ./contaible.markdown ./
COPY ./acerca.markdown    ./
COPY ./nota.markdown      ./

#estos resultan de contabilidad.py
COPY --from=build ./doc/alectrico-${ANO}/ ./alectrico-${ANO}/

#Este copy a veces falla y hace abortar el proceso
#Ocurre cuando no hay *.markdown que copiar
COPY --from=build ./doc/*.markdown      ./




#Estos son manuales
#En alectrico-2021 se guardan los archivos que se son referidos 
#dese las paginas del servidor que pone en funcionamiento jekyll
COPY ./alectrico-$ANO/ ./alectrico-$ANO/
COPY ./_config.yml     ./


WORKDIR ./
VOLUME /doc
