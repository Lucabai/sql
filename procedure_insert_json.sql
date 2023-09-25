declare @j nvarchar(max) = '
{
	"id": 1,
	"colore":"verde",
	"animali" : [
		{"nome" : "birillo",
		"specie" : "gatto"
		},
		{"nome" : "azzurro",
		"specie" : "pesce"
		}
	]
}'

--select @j, ISJSON(@j),
--		JSON_VALUE(@j, '$.colore') as Colore,
--		JSON_query(@j, '$.animali') as Animali,
--		Animali1Nome = JSON_VALUE(@j, '$.animali[0].nome')

--select *
--from openjson(@j)

--create schema its

--create table its.json(
--	id int identity(1,1),
--	j nvarchar(max) not null
--	)

insert into its.json values(@j)

create view its.animali as 

select JSON_VALUE(j, '$.id') as Id,
	JSON_VALUE(j, '$.colore') as Colore,
	JSON_VALUE(animali.value, '$.nome') as Nome,
    JSON_VALUE(animali.value, '$.specie') as Specie
	FROM 
    its.json
    CROSS APPLY OPENJSON(j, '$.animali') as animali

-- SECONDA PARTE DI RIPASSINO 

declare @j nvarchar(max) = '
{
	"id": 2,
	"colore":"blu",
	"animali" : [
		{"nome" : "spillo",
		"specie" : "criceto"
		},
		{"nome" : "giacomina",
		"specie" : "tartaruga"
		}
	]
}'

insert into its.json values(@j)

select * from its.json

update its.json
set j = JSON_MODIFY(j, 'strict $.animali[1].specie', 'piccione')
where id = 2 


alter procedure its.sp_insertJson 
@colore varchar(20),
@animaleNome   varchar(20) = NULL,
@animaleSpecie varchar(20) = NULL
as
IF (@colore is null)
BEGIN
    raiserror('Il parametro @colore non può essere NULL', -1, -1, 'sp_insertJson')
END
ELSE
BEGIN
    declare @id int = (select max(id) + 1 from its.JSON )
    declare @j nvarchar(max), @jAnimali nvarchar(max)    
set @jAnimali = 
        JSON_MODIFY(  
          JSON_MODIFY('{}', '$.nome', @animaleNome), 
           '$.specie', 
           @animaleSpecie 
           ) 
		   --select @jAnimali, JSON_QUERY(@jAnimali)
   set @j = JSON_MODIFY('{}', '$.id', @id) 
   set @j = JSON_MODIFY( 
               JSON_MODIFY(@j , '$.colore', @colore),
                'append $.animali',
                JSON_QUERY(@jAnimali) 
               )
    --select @j
	insert into its.json values (@j)
	print 'La registrazione del JSON è andata a buon fine

Per verifica 
	SELECT TOP 100* 
	FROM its.json 
	ORDER BY id DESC'
END

exec its.sp_insertJson @colore = 'giallo', @animaleNome = 'pluto'

SELECT TOP 100* 
	FROM its.json 
	ORDER BY id DESC