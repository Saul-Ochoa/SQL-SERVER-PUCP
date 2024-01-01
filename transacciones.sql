create database regalos
use regalos
go

create table cliente (
idCliente int primary key,
nombre varchar(50),
direccion varchar(50),
telefono varchar(21)
);

create table cuenta (
idCuenta int primary key,
monto int,
fk_cliente int foreign key references cliente(idCliente)
);


insert into cliente 
(idCliente,nombre,direccion,telefono) values
(1,'Blanca','Av. Adolfo','956211371'),
(2,'Javier','Av. Bolivia','956211486'),
(3,'Dalet','Av. Cucardas','956485486'),
(4,'Roller','Av. Sirenas','9565652421');

select * from cliente


insert into cuenta (idCuenta,monto,fk_cliente) values 
(1,1000,1),(2,1250,2),(3,1450,3),(4,1150,4);


select * from cuenta

-- Creacion de una transaccion
declare @montodepositado int;
set @montodepositado = 1125
begin tran deposito --comenzamos la transaciones y despues su nombre
	update cuenta -- un update de la tabla que queremos actualizar
	set monto = monto + @montodepositado  -- un set para cambiar el valor
	where fk_cliente = 1 -- la condicion donde el cliente sea el numero 1
	save tran P1 -- save point por si algo falla se guarda en este punto
	rollback tran P1
	commit tran deposito;
-- Parte 2 crear una funcion
go




-- Crear el procedimiento almacenado
CREATE PROCEDURE DepositarEnCuenta
(
    @idCliente INT,
    @montoDepositado INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @resultado INT; -- Declarar la variable @resultado

    BEGIN TRY
        BEGIN TRAN deposito -- Comienza la transacción
            UPDATE cuenta
            SET monto = monto + @montoDepositado
            WHERE fk_cliente = @idCliente;

            -- Opcional: Puedes guardar un punto de restauración (save point) aquí
            -- SAVE TRAN P1;

        COMMIT TRAN deposito; -- Confirma la transacción si todo está bien
        SET @resultado = 0; -- Éxito
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN deposito; -- Revierte la transacción en caso de error
        SET @resultado = 1; -- Indica que ha habido un error
    END CATCH;

    SELECT @resultado AS resultado; -- Devolver el resultado
END;

go

DECLARE @resultado INT;

-- Supongamos que el id del cliente es 1 y el monto a depositar es 125
EXEC DepositarEnCuenta @idCliente = 2, @montoDepositado = 1125;

-- Obtener el resultado
SELECT @resultado AS resultado;


select * from cuenta




--retiro del dinero
declare @montoretiro int;
set @montoretiro = 1125
begin tran retiro
	update cuenta
	set monto = monto - @montoretiro
	where fk_cliente=1 and monto>=0
	save tran P1
	rollback tran P1
	commit tran retiro

select * from cuenta;

go


CREATE PROCEDURE RetiroCuenta
(
    @idCliente INT,
    @montoRetirado INT
)
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @resultado BIT; -- Utilizando un tipo de datos más específico
    
    BEGIN TRY
        BEGIN TRAN retiro;
        
        UPDATE cuenta
        SET monto = monto - @montoRetirado
        WHERE fk_cliente = @idCliente AND monto >= @montoRetirado;
        
        IF @@ROWCOUNT > 0
        BEGIN
            COMMIT TRAN retiro;
            SET @resultado = 0; -- Éxito
        END
        ELSE
        BEGIN
            ROLLBACK TRAN retiro;
            SET @resultado = 1; -- Error: Fondos insuficientes
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN retiro;
        SET @resultado = 2; -- Error desconocido
    END CATCH;

    SELECT @resultado AS resultado;
END;

go

DECLARE @resultado BIT;

-- Supongamos que el id del cliente es 1 y el monto a depositar es 125
EXEC RetiroCuenta @idCliente = 2, @montoRetirado = 1125;

-- Obtener el resultado
SELECT @resultado AS resultado;


select * from cuenta;


