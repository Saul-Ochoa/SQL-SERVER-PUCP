/* Resolucion del examen del curso de SQL Server – Implementación
de Base de datos */
use [BD_CuentaCorriente12];
----------------------------------------------------------------------------
select * from CuentaCorriente
select * from Cliente
select * from Sucursal
select * from TipoPago
select * from Moneda
------------------------------------------------------------------------------
/*Implemente una vista que devuelva los documentos que tengan importe abonado 
(campo: abono) mayor a cero. 
------------------------------------------------------------------------------
La vista deberá mostrar los siguientes campos: Código 
Cliente, Razón Social, RUC, Código Sucursal, Nombre Sucursal, Símbolo de Moneda, 
Tipo de Pago, Nro. Documento, Fecha Emisión, Fecha Vencimiento, Saldo
*/
go
create view vw_Documento_Importado
as
	select cc.CodigoCliente,c.Descripcion as 'Razon Social',c.RUC,s.Descripcion as 'Sucursal',
	m.Simbolo,t.Descripcion as 'Tipo de Pago',cc.NroDocumento,cc.FechaEmision,cc.FechaVencimiento,cc.Saldo from 
	CuentaCorriente as cc
	inner join Cliente as c on  cc.CodigoCliente=c.CodigoCliente 
	inner join Sucursal as s on cc.CodigoSucursal=s.CodigoSucursal 
	inner join Moneda as m on cc.CodigoMoneda=m.CodigoMoneda 
	inner join TipoPago as t on cc.CodigoTipoPago=t.CodigoTipoPago
	where cc.Abono>0;

GO
select*from vw_Documento_Importado;
--------------------------------------------------------------------------------------------------------------------
/*
Implemente un procedimiento almacenado que devuelva el detalle de los documentos 
emitidos en dólares, el Importe Total y el Saldo convertido de Dólares a Soles.

El procedimiento recibirá como parámetro el tipo de cambio y el código del cliente (este 
último es opcional, en caso de no pasar el valor, el procedimiento debe devolver los 
documentos de todos los clientes)

El reporte debe mostrar los siguientes campos: Código Cliente, Razón Social, RUC, El 
total en dólares y el total convertido en soles.
*/
go
create PROCEDURE psu_pregunta_2
( 
	@CodCliente int = 0,
	@TasaDeCambio decimal(11,2)
)

as BEGIN
if (@CodCliente=0)
select cc.CodigoCliente,c.Descripcion as 'Razon Social',
sum(cc.Total) as 'Total Dolares', round(sum(cc.Saldo/@TasaDeCambio),2)
as 'Saldo Convertido Dolares' from CuentaCorriente as 
cc inner join Cliente as c on 
cc.CodigoCliente=c.CodigoCliente inner join Moneda as m on
cc.CodigoMoneda=m.CodigoMoneda where cc.CodigoMoneda=2
group BY cc.CodigoCliente,c.Descripcion,c.RUC
else
select cc.CodigoCliente,c.Descripcion as 'Razon Social',
sum(cc.Total) as 'Total Dolares', round(sum(cc.Saldo/@TasaDeCambio),2)
as 'Saldo Convertido Dolares' from CuentaCorriente as 
cc inner join Cliente as c on 
cc.CodigoCliente=c.CodigoCliente inner join Moneda as m on
cc.CodigoMoneda=m.CodigoMoneda where cc.CodigoMoneda=2 and cc.CodigoCliente=@CodCliente
group BY cc.CodigoCliente,c.Descripcion,c.RUC
end
EXECUTE psu_pregunta_2 4,3.81
EXECUTE psu_pregunta_2 @TasaDeCambio=3.81
go
/* 
Implemente un procedimiento almacenado que actualice el saldo de un documento 
cuando un cliente realice un abono. Considere como parámetro el Nro de Documento y 
el importe que se abona. Si el saldo es negativo, muestre un mensaje que el importe 
abonado excede el saldo.
 */
go
create PROCEDURE Pregunta3
(
	@NroDocumento VARCHAR(20),
	@ImporteAbono decimal(11,2)
)
as BEGIN
if (@ImporteAbono<(select saldo from CuentaCorriente as cc where cc.NroDocumento=@NroDocumento))
UPDATE CuentaCorriente
set Saldo=Saldo-@ImporteAbono where CuentaCorriente.NroDocumento = @NroDocumento
ELSE
PRINT 'El importe abonado excede al saldo'
END
execute Pregunta3 'DDC-0001-0000040042',100
select * from CuentaCorriente where NroDocumento='DDC-0001-0000040042'

/*
Implemente un procedimiento almacenado que retorne el reporte de documentos
vencidos en un mes determinado y por tipo de moneda. El procedimiento almacenado
debe devolver: Código Cliente, Razón Social, RUC, Código Sucursal, Nombre Sucursal,
Símbolo de Moneda, Tipo de Pago, Nro. Documento, Fecha Emisión, Fecha
Vencimiento, Saldo.
*/
go
CREATE PROCEDURE spu_documentos_vencidos
(
@Fecha DATETIME,
@tipomoneda VARCHAR(50)
)
as 
BEGIN
select cc.CodigoCliente,c.Descripcion as 'Razon Social',c.RUC,cc.CodigoSucursal,
s.Descripcion as 'NombreSucursal',m.Simbolo,tp.Descripcion as 'TipoPago',cc.NroDocumento,
cc.FechaEmision,cc.FechaVencimiento,cc.Saldo from CuentaCorriente as cc inner JOIN Cliente as c
on cc.CodigoCliente=c.CodigoCliente inner JOIN Sucursal as s on
s.CodigoSucursal=cc.CodigoSucursal inner JOIN Moneda as m on
m.CodigoMoneda=cc.CodigoMoneda inner JOIN TipoPago as tp on
tp.CodigoTipoPago=cc.CodigoTipoPago 
where FechaVencimiento=@Fecha and m.Descripcion=@tipomoneda
END

EXECUTE spu_documentos_vencidos '2014-05-30', 'Nuevo Sol'