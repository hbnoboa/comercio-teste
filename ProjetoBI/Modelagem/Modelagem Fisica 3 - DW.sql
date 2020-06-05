create database comercio_dw
go

use comercio_dw
go

create table DIM_Vendedor
(
	IDSK int primary key identity,
	IDVendedor int,
	Inicio datetime,
	Fim datetime,
	Nome varchar(100),
	sexo varchar(20),
	IDGerente int
)
go

create table DIM_Nota
(
	IDSK int primary key identity,
	IDNota int,
)
go

create table DIM_Forma
(
	IDSK int primary key identity,
	IDForma int,
	Forma varchar(30)
)
go

create table DIM_Cliente
(
	IDSK int primary key identity,
	IDCliente int,
	Inicio Datetime,
	Fim datetime,
	Nome varchar(100),
	Sexo varchar(100),
	Email varchar(50),
	Nascimento date,
	Cidade varchar(100),
	Estado varchar(30),
	Regiao varchar(30)
)
go

create table Categoria
(
	IDCategoria int primary key,
	Nome varchar(50)
)
go

create table DIM_Produto
(
	IDSK int primary key identity,
	IDProduto int,
	Inicio datetime,
	Fim datetime,
	Nome varchar(100),
	Valor_Unitario numeric(10,2),
	Custo_Medio numeric (10,2),
	ID_Categoria int
)
go

create table DIM_Fornecedor
(
	IDSK int primary key identity,
	IDFornecedor int,
	Inicio datetime,
	Fim datetime,
	Nome varchar(50)
)
go

create table DIM_Tempo
(
	IDSK int primary key identity,
	Data date,
	Dia char(02),
	DiaSemana varchar(10),
	Mes char(02),
	NomeMes varchar(20),
	Quarto tinyint,
	NomeQuarto varchar(20),
	Ano char(4),
	EstacaoAno varchar(20),
	FimSemana char(3),
	DataCompleta varchar(10)
)
go

create table Fato
(
	IDNota int,
	IDCliente int,
	IDVendedor int,
	IDForma int,
	IDProduto int,
	IDFornecedor int,
	IDTempo int,
	Quantidade int,
	Total_Item numeric(10,2),
	Custo_Total numeric(10,2),
	Lucro_Total numeric(10,2)
)
go

alter table DIM_Produto add constraint FK_Produto_Categoria
foreign key(ID_Categoria) references Categoria(IDCategoria)
go

alter table Fato add constraint FK_Fato_Nota
foreign key(IDNota) references DIM_Nota(IDSK)
go

alter table Fato add constraint FK_Fato_Cliente
foreign key(IDCliente) references DIM_Cliente(IDSK)
go

alter table Fato add constraint FK_Fato_Vendedor
foreign key(IDVendedor) references DIM_Vendedor(IDSK)
go

alter table Fato add constraint FK_Fato_Forma
foreign key(IDForma) references DIM_Forma(IDSK)
go

alter table Fato add constraint FK_Fato_Produto
foreign key(IDProduto) references DIM_Produto(IDSK)
go

alter table Fato add constraint FK_Fato_Fornecedor
foreign key(IDFornecedor) references DIM_Fornecedor(IDSK)
go

alter table Fato add constraint FK_Fato_Tempo
foreign key(IDTempo) references DIM_Tempo(IDSK)
go

-----------------------INICIO-----------------------

-- CARREGANDO A DIMENSAO TEMPO --

-- Exibindo a data atual

print convert(varchar,getdate(),113)

-- Alterando o incremento para inicio em 5000
-- Para a possibilidade de datas anteriores

dbcc CheckIdent(DIM_Tempo, Reseed, 5000)

-- Inserção de dados na dimensão

declare
	@DataInicio datetime,
	@DataFim datetime,
	@Data datetime

print getdate()

	select @DataInicio = '1/1/1950'
		, @DataFim = '1/1/2050'

	select @Data = @DataInicio

while @Data < @DataFim

	begin
		
		insert into DIM_Tempo
		(
			Data,
			Dia,
			DiaSemana,
			Mes,
			NomeMes,
			Quarto,
			NomeQuarto,
			Ano
		)

		select @Data as Data, DATEPART(DAY,@Data) as Dia,

			case DATEPART(DW,@Data)

				when 1 then 'Domingo'
				when 2 then 'Segunda'
				when 3 then 'Terça'
				when 4 then 'Quarta'
				when 5 then 'Quinta'
				when 6 then 'Sexta'
				when 7 then 'Sabado'

			end as DiaSemana,

			DATEPART(MONTH, @Data) as Mes,

			case datename(month, @Data)

				when 'January' then 'Janeiro'
				when 'February' then 'Fevereiro'
				when 'March' then 'Março'
				when 'April' then 'Abril'
				when 'May' then 'Maio'
				when 'June' then 'Junho'
				when 'July' then 'Julho'
				when 'August' then 'Agosto'
				when 'September' then 'Setembro'
				when 'October' then 'Outubro'
				when 'November' then 'Novembro'
				when 'December' then 'Dezembro'

			end as NomeMes,

				datepart(qq,@Data) Quarto,

				case datepart(qq,@Data)
					when 1 then 'Primeiro'
					when 2 then 'Segundo'
					when 3 then 'Terceiro'
					when 4 then 'Quarto'
				end as NomeQuarto,

			DATEPART(YEAR,@Data) Ano

		select @Data = dateadd(dd,1,@Data)
	end

update DIM_Tempo
set Dia = '0' + Dia
where LEN(Dia) = 1

update DIM_Tempo
set Mes = '0' + Mes
where LEN(Mes) = 1

update DIM_Tempo
set DataCompleta = Ano + Mes + Dia
go

select * from DIM_Tempo

--FIM DE SEMANA E ESTAÇÃO--

declare C_Tempo cursor for
	select IDSK, DataCompleta, DiaSemana, Ano from DIM_Tempo
declare 
	@ID int,
	@Data varchar(10),
	@DiaSemana varchar(20),
	@Ano char(4),
	@FimSemana char(3),
	@Estacao varchar(15)

open C_Tempo
	fetch next from C_Tempo
	into @ID, @Data, @DiaSemana, @Ano
while @@FETCH_STATUS = 0
	begin
		
		if @DiaSemana in ('Domingo','Sabado')
			set @FimSemana = 'Sim'
		else
			set @FimSemana = 'Não'

		--Atualizando estações

		if @Data between CONVERT(char(4), @Ano) + '0923'
		and CONVERT(char(4), @Ano) + '1220'
			set @Estacao = 'Primavera'

		else if @Data between CONVERT(char(4), @Ano) + '0321'
		and CONVERT(char(4), @Ano) + '0620'
			set @Estacao = 'Outono'

		else if @Data between CONVERT(char(4), @Ano) + '0621'
		and CONVERT(char(4), @Ano) + '0922'
			set @Estacao = 'Inverno'

		else
			set @Estacao = 'Verão'

		-- Atualizando fins de semana

		update DIM_Tempo set FimSemana = @FimSemana
		where IDSK = @ID

		-- Atualizando

		update DIM_Tempo set EstacaoAno = @Estacao
		where IDSK = @ID

	fetch next from C_Tempo
	into @ID, @Data, @DiaSemana, @Ano
end
close C_Tempo
deallocate C_Tempo
go
-------------------------Fim----------------------------------

select * from DIM_Tempo
go

-----------PROCEDURE FATO--------------

create proc Carga_Fato
as
	declare @Final datetime
	declare @Inicial datetime

	select @Final = MAX(Data)
	from comercio_dw.dbo.DIM_Tempo T

	select @Inicial = MAX(Data)
	from comercio_dw.dbo.Fato FT
	join comercio_dw.dbo.DIM_Tempo T
	on (FT.IDTempo = T.IDSK)

	if @Inicial is null

	begin
		
		select @Inicial = MIN(Data)
		from comercio_dw.dbo.DIM_Tempo T

	end

	insert into comercio_dw.dbo.Fato
	(
		IDNota,
		IDCliente,
		IDVendedor,
		IDForma,
		IDFornecedor,
		IDProduto,
		IDTempo,
		Quantidade,
		Total_Item,
		Custo_Total,
		Lucro_Total
	)

	select
		N.IDSK as IDNota,
		C.IDSK as IDCliente,
		V.IDSK as IDVendedor,
		FO.IDSK as IDForma,
		FN.IDSK as IDFornecedor,
		P.IDSK as IDProduto,
		T.IDSK as IDTempo,
		F.Quantidade,
		F.Total_Item,
		F.Custo_Total,
		F.Lucro_Total

	from
		comercio_stage.dbo.ST_fato F

		inner join dbo.DIM_Forma FO
		on (F.IDForma = FO.IDForma)

		inner join dbo.DIM_Nota N
		on (F.IDNota = N.IDNota)

		inner join dbo.DIM_Fornecedor FN
		on 
		(
			F.IDFornecedor = FN.IDFornecedor
			and 
			(
				FN.Inicio < = F.Data
				and 
				(
					FN.Fim >= F.Data
				) 
				or 
				(
					FN.Fim is null
				)
			)
		)
		inner join dbo.DIM_Cliente C
		on 
		(
			F.IDCliente = C.IDCliente
			and 
			(
				C.Inicio < = F.Data
				and 
				(
					C.Fim >= F.Data
				) 
				or 
				(
					C.Fim is null
				)
			)
		)
		inner join dbo.DIM_Vendedor V
		on 
		(
			F.IDVendedor = V.IDVendedor
			and 
			(
				V.Inicio < = F.Data
				and 
				(
					V.Fim >= F.Data
				) 
				or 
				(
					V.Fim is null
				)
			)
		)
		inner join dbo.DIM_Produto P
		on 
		(
			F.IDProduto = P.IDProduto
			and 
			(
				P.Inicio < = F.Data
				and 
				(
					P.Fim >= F.Data
				) 
				or 
				(
					P.Fim is null
				)
			)
		)
		inner join dbo.DIM_Tempo T
		on 
		(
			CONVERT
			(
				varchar, T.Data,102
			) 
			= CONVERT
			(
				varchar,F.Data,102
			)
		)
		where F.Data > @Inicial and F.Data < @Final
go

select * from Fato
go

select * from comercio_oltp.dbo.Relatorio_Vendas
go

select * from Fato
go

exec Carga_Fato
go

select count(*) from comercio_stage.dbo.ST_fato
go

create view V_Analise_Fornecedor as
select 
	FN.Nome as Fornecedor,
	T.Ano as Ano,
	Sum(F.Quantidade) as Quantidade,
	Sum(F.Total_Item) as Total_Vendido

	from comercio_stage.dbo.ST_fato F

	inner join dbo.DIM_Fornecedor FN
	on F.IDFornecedor = FN.IDFornecedor

	inner join dbo.DIM_Tempo T
	on 
	(
		CONVERT
		(
			varchar, T.Data, 102
		) 
		=
		CONVERT
		(
			varchar, F.Data, 102
		)	
	)

	group by FN.Nome, T.Ano
go

select distinct 
	P.Nome as Produto,
	C.Nome as Categoria

	from DIM_Produto P
	inner join Fato FA
	on P.IDSK = FA.IDProduto
	inner join DIM_Fornecedor F
	on F.IDSK = FA.IDFornecedor
	inner join Categoria C
	on IDCategoria = ID_Categoria

	where F.Nome = @Fornecedor
go

select 
	Regiao, 
	Ano,
	sum(Lucro_Total) as Lucro,
	sum(Quantidade) as QTD,
	sum(Total_Item) as Total,
	sum(Custo_Total) as Custo

	from DIM_Cliente
	inner join Fato F
	on IDSK = F.IDCliente
	inner join DIM_Tempo T
	on T.IDSK = IDTempo

	group by Regiao, Ano

	order by 1,2
go