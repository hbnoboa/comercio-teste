CREATE PROCEDURE Camel_Case AS
DECLARE C_Nomes CURSOR FOR
SELECT IDProduto, Nome
FROM ST_Produto

DECLARE @IDProduto INT,
		@Palavra VARCHAR(50),
	    @StringTotal VARCHAR(5000),
		@Inicio INT,
		@Fim INT	

OPEN C_Nomes
FETCH NEXT FROM C_Nomes INTO
@IDProduto,@Palavra

WHILE @@FETCH_STATUS = 0

BEGIN

	  SET @Palavra = LOWER(@Palavra)
      SET @Inicio = 2
      SET @Fim = LEN(@Palavra)
      SET @StringTotal = UPPER(LEFT(@Palavra,1))
	  
	  WHILE @Inicio <= @Fim
		
		BEGIN
				IF SUBSTRING(@Palavra,@Inicio,1) = ' '
				BEGIN 
					SELECT @Inicio = @Inicio + 1
					SELECT @StringTotal = @StringTotal + ' ' + 
					UPPER(SUBSTRING(@Palavra,@Inicio,1))
				END
				ELSE
				BEGIN
					SELECT @STRINGTOTAL = @STRINGTOTAL + 
					SUBSTRING(@Palavra,@Inicio,1)
				END
				
				SELECT @Inicio = @Inicio + 1
		END
		
		UPDATE ST_Produto SET NOME = @StringTotal
		WHERE IDProduto = @IDProduto

		FETCH NEXT FROM C_Nomes INTO
		@IDproduto,@Palavra

END
CLOSE C_Nomes
DEALLOCATE C_Nomes
GO

exec Camel_Case
go

