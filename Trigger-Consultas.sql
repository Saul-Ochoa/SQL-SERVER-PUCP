create database inventory
use inventory
create table productos
(
id_Cod int identity primary key,
cod_prod varchar(4) not null,
nombre varchar(50)not null,
existencia int not null,
)
GO
Create table historial
(fecha date,
cod_prod varchar(4),
descripcion varchar(100), 
usuario varchar(20))
GO

create table ventas
(cod_prod varchar(4),
precio money,
cantidad int
)
GO

insert into productos values('A001','MEMORIA USB 32GB',175);
insert into productos values('A002','DISCO DURO 2TB',15);
insert into productos values('A003','AIRE COMPRIMIDO',250);
insert into productos values('A004','ESPUMA LIMPIADORA',300);
insert into productos values('A005','FUNDA MONITOR',500);
insert into productos values('A006','FUNDA TECLADO',700);
insert into productos values('A007','SILLA ERGONÓMICA',11);
insert into productos values('A008','ALFOMBRILLA PARA SILLA',25);
insert into productos values('A009','LÁMPARA ESCRITORIO',7);
insert into productos values('A010','MONITOR LED 18 PULGADAS',45);
insert into productos values('A011','LIBRERO',20);
go
select * from historial
select * from productos
select * from ventas
delete from productos where cod_prod='A005';
update productos set existencia=100 where cod_prod='A001'

-----------------------------------------------------------------------------------------
----------------------------Registro Insertado-------------------------------------------
-----------------------------------------------------------------------------------------
go
alter trigger TR_ProductoInsertado
on productos for insert 
as
set nocount on
declare @cod_prod varchar(4)
select  @cod_prod=cod_prod from inserted
insert into  historial values(GETDATE(),@cod_prod,'registro insertado',SYSTEM_USER)
go
-----------------------------------------------------------------------------------------
----------------------------Registro Eliminado-------------------------------------------
-----------------------------------------------------------------------------------------
create trigger TR_ProductoEliminado
on productos for delete
as
set nocount on
declare @cod_prod varchar(4)
select  @cod_prod=cod_prod from deleted
insert into  historial values(GETDATE(),@cod_prod,'registro eliminado',SYSTEM_USER)
go
-----------------------------------------------------------------------------------------
----------------------------Registro Acutalizado-------------------------------------------
-----------------------------------------------------------------------------------------
create trigger TR_ProductoActualizar
on productos for update
as
set nocount on
declare @cod_prod varchar(4)
select  @cod_prod=cod_prod from inserted
insert into  historial values(GETDATE(),@cod_prod,'registro actualizado',SYSTEM_USER)
go

-----------------------------------------------------------------------------------------
----------------------------Trigger de Ventas--------------------------------------------
-----------------------------------------------------------------------------------------
create trigger TR_Ventas
on ventas for insert 
as 
set nocount on
update productos set productos.existencia=productos.existencia-inserted.cantidad 
from inserted inner join productos on productos.cod_prod=inserted.cod_prod
go
sp_helptrigger ventas;
sp_helptrigger productos;

insert into ventas values ('A002',450,3)
insert into ventas values ('A001',30,2)

-----------------------------------------------------------------------------------------
----------------------------PARTE-2------------------------------------------------------
-----------------------------------------------------------------------------------------
create table tienda1
(n_envio int,
cod_prod varchar(4),
nombre varchar(100),
Cantidad int)

create table tienda2
(n_envio int,
cod_prod varchar(4),
nombre varchar(100),
Cantidad int)


create table tienda3
(n_envio int,
cod_prod varchar(4),
nombre varchar(100),
Cantidad int)


select * from tienda1
select * from tienda2
select * from tienda3
go

create trigger TR_Destinos
on tiendas instead of insert
as
set nocount on
insert into tienda1
select n_envio, cod_prod, nombre, cantidad from inserted where destino='tienda1'
insert into tienda2
select n_envio, cod_prod, nombre, cantidad from inserted where destino='tienda2'
insert into tienda3
select n_envio, cod_prod, nombre, cantidad from inserted where destino='tienda3'
go
insert into tiendas values (1,'1001','MOUSE OPTICO',500,'tienda1')
insert into tiendas values(2, '1002', 'Monitor LED 17 pulgaas', 35, 'tienda3')
insert into tiendas values(2, '1003', 'CABLE HDMI', 50, 'tienda3')
insert into tiendas values(2, '1004', 'AIRE COMPRIMIDO', 45, 'tienda3')
insert into tiendas values(2, '1005', 'PASTA TERMICA', 23, 'tienda3')
insert into tiendas values(3, '1006', 'TECLADO P/TABLET', 100, 'tienda1')
insert into tiendas values(4, '1007', 'FUNDA TECLADO', 230, 'tienda2')
insert into tiendas values(5, '1008', 'MEMORIA MICRO SD 16GB', 700, 'tienda3')
go
select * from tiendas
select * from productos
select * from ventas