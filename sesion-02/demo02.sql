use CobranzaDB

--Liste los clientes cuyo primer nombre inicia con una vocal.

Select * from tbCliente 
where nombres LIKE '[aeiou]%'

--Liste los clientes cuyo primer nombre inicia con una consonante

Select * from tbCliente 
where nombres LIKE '[^aeiou]%' and nombres NOT LIKE '^%'

--Liste los clientes cuyo apellido materno tenga como segunda letra una “a” y como penúltima, la letra “r”.
Select * from tbCliente 
where apellidoMat LIKE '_a%r_'

--Liste los clientes cuyo apellido materno tenga como segunda letra una “a” y como penúltima, una letra diferente a “r”.
Select * from tbCliente 
where apellidoMat LIKE '_a%[^r]_'

--Liste los clientes cuyo apellido materno tenga como segunda letra una “a” y además contenga un sombrero seguido de una r
Select * from tbCliente 
where apellidoMat LIKE '_a%^[r]_'

--Liste los clientes cuyo apellido paterno contenga una vocal seguida de la letra n y seguida de una consonante.

Select apellidoPat,* from tbCliente 
where apellidoPat LIKE '%[aeiou]n[^aeiou]%'

Manrique
Muñante
Gonzales
