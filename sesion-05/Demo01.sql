--SEMANA 05
--04.5
--05.1 . Obtenga el siguiente resumen en base a la cantidad de registros por tabla
SELECT
(SELECT count(1) from tbTipoDocumento) as TotTipoDocumento,
(SELECT count(1) from tbProducto) as TotProducto,
(SELECT count(1) from tbTipoCliente) as TotTipoCliente,
(SELECT count(1) from tbUbigeo) as TotUbigeo
--05.2. Obtenga por cada cliente sus datos personales, datos de ubigeo y promedio de d�as mora por ubigeo.
--Paso 01.Obtener datos del cliente
select 
cli.id,
tipoDoc.descripcion,
cli.numDoc,
cli.nombres,
cli.apellidoPat,
cli.apellidoMat,
ubi.departamento,
ubi.provincia,
ubi.distrito
from tbCliente cli inner join tbUbigeo ubi on cli.idUbigeo=ubi.id
inner join tbTipoDocumento tipoDoc on cli.tipoDoc=tipoDoc.tipo
--Paso 02.Obtener promedio de d�as mora por ubigeo
--AVG (Promedio)
--Detalle
select cta.numcuenta,cta.diasMoraNuevo,cte.idUbigeo
from tbCuenta cta inner join tbCliente cte on cta.idCliente=cte.id
--Agrupado
select cte.idUbigeo,AVG(cta.diasMoraNuevo) as promDiasMora
from tbCuenta cta inner join tbCliente cte on cta.idCliente=cte.id
group by cte.idUbigeo
--Paso 03. Juntar resultados de 1 y 2
select 
--Datos parte 1
cli.id,tipoDoc.descripcion,cli.numDoc,cli.nombres,cli.apellidoPat,
cli.apellidoMat,
ubi.departamento,ubi.provincia,ubi.distrito,
ubigeoResumen.promDiasMora--Pinto el dato obtenido.
from tbCliente cli inner join tbUbigeo ubi on cli.idUbigeo=ubi.id
inner join tbTipoDocumento tipoDoc on cli.tipoDoc=tipoDoc.tipo
--Datos parte 2
inner join
(
select cte.idUbigeo,AVG(cta.diasMoraNuevo) as promDiasMora
from tbCuenta cta inner join tbCliente cte on cta.idCliente=cte.id
group by cte.idUbigeo
) ubigeoResumen 
--Enlace entre Datos parte 1 con parte 2
on cli.idUbigeo=ubigeoResumen.idUbigeo
order by cli.idUbigeo
--05.3 Mostrar dentro de cada ubigeo el total de clientes y el m�ximo d�as mora dentro de cada ubigeo.
--Forma 01
select 
ubi.departamento,
ubi.provincia,
ubi.distrito,
resumenTotales.totClientes,
resumenMaxDiasMora.maxDiasMora
from tbUbigeo ubi
inner join
(
select ubi.id as idUbigeo,count(cli.id) as totClientes
from tbCliente cli inner join tbUbigeo ubi on cli.idUbigeo=ubi.id
group by ubi.id
) resumenTotales on ubi.id=resumenTotales.idUbigeo
inner join
(
select cli.idUbigeo,max(cta.diasMoraNuevo) as maxDiasMora
from tbCliente cli inner join tbCuenta cta on cta.idCliente=cli.id
group by cli.idUbigeo
) resumenMaxDiasMora on ubi.id=resumenMaxDiasMora.idUbigeo
order by ubi.id
--Forma 02
 select
  ubi.departamento,ubi.provincia,ubi.distrito ,count(cli.id)as total_cliente,
 ubigeoResumen.MaxDiasMora --pinto el dato obtenido
 from tbUbigeo  ubi inner join tbCliente cli on ubi.id= cli.idUbigeo

 inner join
 (
 select cte.idUbigeo,Max(cta.diasMoraNuevo) as MaxDiasMora
from tbCuenta cta inner join tbCliente cte on cta.idCliente= cte.id
group by cte.idUbigeo
)ubigeoResumen 
--enlace entre datos parte 1 con parte 2
on cli.idUbigeo = ubigeoResumen.idUbigeo
 group by ubi.departamento,ubi.provincia,ubi.distrito,ubigeoResumen.MAxDiasMora
 order by count(cli.id) desc
--Forma 03
select u.departamento , u.provincia , u.distrito,count( c.id) as TotalCliente,ubigeoResumen.MaxDiasMora
from tbUbigeo u inner join tbCliente c on u.id=c.idUbigeo
inner join 
(
select  cte.idUbigeo, max(cta.diasMoraNuevo)as MaxDiasMora
from tbCuenta cta inner join tbCliente cte on  cta.idCliente=cte.id
group by cte.idUbigeo) ubigeoResumen on c.idUbigeo=ubigeoResumen.idUbigeo
group by  u.departamento , u.provincia , u.distrito,ubigeoResumen.MaxDiasMora
order by ubigeoResumen.MaxDiasMora desc
--05.4 Mostrar por producto la m�nima y m�xima deuda total en soles.
--Informaci�n de productos
select nombre
from tbProducto pdto
--M�nima deuda total en soles por producto
---Detalle
--Registr�  nuevo tipo de cambio del d�a.
insert into tbTipoCambio
select getdate(),3.270,0.305,getdate(),NULL,'GMV'
--Obtener tipo de cambio del d�a.
select conversionDOL from tbTipoCambio where CONVERT(VARCHAR(8),fecha,112)=CONVERT(VARCHAR(8),GETDATE(),112)
--Aplicar la conversi�n para obtener deuda total en soles
select idProducto,
case when cta.moneda='SOL' then cta.deudaTotal else 
(select conversionDOL from tbTipoCambio where CONVERT(VARCHAR(8),fecha,112)=CONVERT(VARCHAR(8),GETDATE(),112))*cta.deudaTotal
end as deudaTotalSOL
from tbCuenta cta
---Agrupado
select reporteDeudaTotal.idProducto,
min(reporteDeudaTotal.deudaTotalSOL) as minDeudaTotalSOL,
max(reporteDeudaTotal.deudaTotalSOL) as maxDeudaTotalSOL
from
(
	select idProducto,
	case when cta.moneda='SOL' then cta.deudaTotal else 
	(select conversionDOL from tbTipoCambio where CONVERT(VARCHAR(8),fecha,112)=CONVERT(VARCHAR(8),GETDATE(),112))*cta.deudaTotal
	end as deudaTotalSOL
	from tbCuenta cta
	where  idProducto is not null
) reporteDeudaTotal
group by reporteDeudaTotal.idProducto
--Juntar resultados
select 
reporteDeudaTotal.idProducto,
pdtoDet.nombre,
min(reporteDeudaTotal.deudaTotalSOL) as minDeudaTotalSOL,
max(reporteDeudaTotal.deudaTotalSOL) as maxDeudaTotalSOL
from
(
	select idProducto,
	case when cta.moneda='SOL' then cta.deudaTotal else 
	(select conversionDOL from tbTipoCambio where CONVERT(VARCHAR(8),fecha,112)=CONVERT(VARCHAR(8),GETDATE(),112))*cta.deudaTotal
	end as deudaTotalSOL
	from tbCuenta cta
	where  idProducto is not null
) reporteDeudaTotal inner join tbProducto pdtoDet on reporteDeudaTotal.idProducto=pdtoDet.id
group by reporteDeudaTotal.idProducto,pdtoDet.nombre



--Agrupado
select idProducto,min(cta.deudaTotal) as minDeudaTotal from tbCuenta cta --inner join tbProducto pdto on cta.idProducto=pdto.id
group by idProducto

--M�xima deuda total en soles por producto

