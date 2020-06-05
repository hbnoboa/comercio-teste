create database comercio_stage
go

use comercio_stage

-- Cliente
-- Vendedor
-- Categoria
--Fornecedor
-- Produto
-- Forma Pagamento
-- Regiao

-- Fato -- As medias do negocio

-- Total
-- Quantidade
-- Lucro
-- Custo

create table ST_Cliente
(
	IDCliente int default null,
	Nome varchar(100),
	Sexo varchar(20) default null,
	Nascimento date default null,
	Cidade varchar(100) default null,
	Estado varchar(10) default null,
	Regiao varchar(10) default null
)
go

create table ST_Vendedor
(
	IDVendedor int default null,
	Nome varchar(50) default null,
	Sexo varchar(20) default null,
	IDGerente int default null
)
go

create table ST_Categoria
(
	IDCategoria int default null,
	Nome varchar(50) default null
)
go

create table ST_Fornecedor
(
	IDFornecedor int default null,
	Nome varchar(100) default null
)
go

create table ST_Produto
(
	IDProduto int default null,
	Nome varchar(50) default null,
	Valor_Unitario numeric(10,2) default null,
	Custo_Medio numeric(10,2) default null,
	ID_Categoria int default null
)
go

create table ST_Nota
(
	IDnota int default null
)
go

create table ST_Forma
(
	IDForma int default null,
	Forma varchar(50) default null
)
go

create table ST_fato
(
	IDCliente int default null,
	IDVendedor int default null,
	IDProduto int default null,
	IDFornecedor int default null,
	IDNota int default null,
	IDForma int default null,
	Quantidade int default null,
	Total_Item numeric(10,2) default null,
	Data date default null,
	Custo_Total numeric(10,2) default null,
	Lucro_Total numeric(10,2) default null
)
go

alter table [dbo].[ST_Cliente]
add Email varchar(100)
go

