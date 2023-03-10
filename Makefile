

contabilidad:  
	docker build . -t contabilidad_${ANO} --build-arg ANO=${ANO} --no-cache
	docker run -rm -p 4000:4000 --name store_contabilidad_${ANO} -v $(pwd)/docs_${ANO}:/doc contabilidad_${ANO} bash -c 'jekyll build . && cp * /doc -r && chown 1000:1000 /doc -R'
 

2021: 
	make contabilidad ANO=2021
2022: 
	make contabilidad ANO=2022

