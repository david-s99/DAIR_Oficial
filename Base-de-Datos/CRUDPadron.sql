USE [ProyectoDAIR];
GO

IF OBJECT_ID('[dbo].[CreatePadron]') IS NOT NULL
BEGIN 
    DROP PROC [dbo].[CreatePadron] 
END 
GO
CREATE PROC [dbo].[CreatePadron] 
	@Cedula NVARCHAR(16),
	@Periodo INT
AS
BEGIN
SET NOCOUNT ON
	BEGIN TRY
		DECLARE @Asambleista INT
		SELECT @Asambleista = A.Id
		FROM dbo.Asambleista A
		WHERE A.Cedula = @Cedula
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
		BEGIN TRANSACTION nuevoPadron
			IF NOT EXISTS (SELECT Id FROM dbo.Padron WHERE AsambleistaId = @Asambleista AND PeriodoId = @Periodo)
				BEGIN
					INSERT INTO dbo.Padron(AsambleistaId,
											PeriodoId,
											Validacion)
					SELECT @Asambleista,
							@Periodo,
							1;
					
					SELECT @@Identity Id;
				END
			ELSE
				BEGIN
					SELECT 0;
				END
		COMMIT TRANSACTION nuevoPadron;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT>0
			ROLLBACK TRANSACTION nuevoPadron;
		SELECT -1
	END CATCH
SET NOCOUNT OFF
END
GO

IF OBJECT_ID('[dbo].[ReadPadron]') IS NOT NULL
BEGIN 
    DROP PROC [dbo].[ReadPadron] 
END 
GO
CREATE PROC [dbo].[ReadPadron] 
    @Id INT
AS
BEGIN
SET NOCOUNT ON
	BEGIN TRY
		SELECT Pa.Id,A.Nombre, A.Cedula, D.Nombre AS Departamento, S.Nombre AS Sector, Se.Nombre AS Sede, Pa.Validacion
		FROM dbo.Padron Pa
		INNER JOIN dbo.Asambleista A ON A.Id = Pa.AsambleistaId
		INNER JOIN dbo.Departamento D ON D.Id = A.DepartamentoId
		INNER JOIN dbo.Sector S ON S.Id = A.SectorId
		INNER JOIN dbo.Sede Se ON Se.Id = A.SedeId
		WHERE Pa.[Id] = @Id
	END TRY

	BEGIN CATCH
		SELECT -1
	END CATCH
SET NOCOUNT OFF
END
GO

IF OBJECT_ID('[dbo].[UpdatePadron]') IS NOT NULL
BEGIN 
    DROP PROC [dbo].[UpdatePadron] 
END 
GO
CREATE PROC [dbo].[UpdatePadron]
	@Cedula NVARCHAR(16),
	@Periodo INT,
	@Validacion BIT
AS
BEGIN
SET NOCOUNT ON
	BEGIN TRY
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
		BEGIN TRANSACTION modificarPadron
			DECLARE @AsambleistaId INT
			SELECT @AsambleistaId = Id
			FROM dbo.Asambleista
			WHERE Cedula = @Cedula
			UPDATE dbo.Padron
			SET Validacion = @Validacion
			WHERE AsambleistaId = @AsambleistaId AND PeriodoId = @Periodo
		COMMIT TRANSACTION modificarPadron;
		SELECT 1;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT>0
			ROLLBACK TRANSACTION modificarPadron;
		SELECT -1
	END CATCH
SET NOCOUNT OFF
END
GO

IF OBJECT_ID('[dbo].[InsertarPadron]') IS NOT NULL
BEGIN 
    DROP PROC [dbo].[InsertarPadron] 
END 
GO
CREATE PROC [dbo].[InsertarPadron]
	@PeriodoId INT
AS
BEGIN
SET NOCOUNT ON
	BEGIN TRY
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
		BEGIN TRANSACTION modificarPadron
			UPDATE dbo.Padron
			SET Validacion = 0
			WHERE PeriodoId = @PeriodoId
		COMMIT TRANSACTION modificarPadron;
		SELECT 1;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT>0
			ROLLBACK TRANSACTION modificarPadron;
		SELECT -1
	END CATCH
SET NOCOUNT OFF
END
GO

IF OBJECT_ID('[dbo].[GetPadron]') IS NOT NULL
BEGIN 
    DROP PROC [dbo].[GetPadron] 
END 
GO
CREATE PROC [dbo].[GetPadron] 
    @PeriodoId INT
AS
BEGIN
SET NOCOUNT ON
	BEGIN TRY
		SELECT Pa.Id,A.Nombre, A.Cedula, D.Nombre AS Departamento, S.Nombre AS Sector, Se.Nombre AS Sede
		FROM dbo.Padron Pa
		INNER JOIN dbo.Asambleista A ON A.Id = Pa.AsambleistaId
		INNER JOIN dbo.Departamento D ON D.Id = A.DepartamentoId
		INNER JOIN dbo.Sector S ON S.Id = A.SectorId
		INNER JOIN dbo.Sede Se ON Se.Id = A.SedeId
		WHERE Pa.[PeriodoId] = @PeriodoId AND Pa.Validacion = 1
	END TRY

	BEGIN CATCH
		SELECT -1
	END CATCH
SET NOCOUNT OFF
END
GO