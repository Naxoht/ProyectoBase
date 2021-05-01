create or replace package gestio_usuaris as

procedure alta_usuari(cod_usuari varchar2,usuari varchar2,nom varchar2,cognom varchar2,contrasenya varchar2);
procedure baixa_usuari(cod_usuari varchar2);
procedure consulta_usuaris;

end gestio_usuaris;

create or replace package body gestio_usuaris as

--Procedimiento alta usuario
procedure alta_usuari(cod_usuari varchar2,usuari varchar2,nom varchar2,cognom varchar2,contrasenya varchar2)
as
cont_us_cod number;
cont_us number;
usuario_existe_cod exception;
usuario_existe exception;

BEGIN
select count(*) into cont_us_cod from users
where user_code = cod_usuari;

if cont_us_cod != 0 then
    raise usuario_existe_cod;
end if;

select count(*) into cont_us from users
where name = usuari;

if cont_us != 0 then
    raise usuario_existe;
end if;

insert into users values(cod_usuari,usuari,nom,cognom,contrasenya);
dbms_output.put_line('Usuario donat de alta correctament');

EXCEPTION    
    when usuario_existe_cod then
        dbms_output.put_line('Ya existe un usuario con ese codigo');
    when usuario_existe then
        dbms_output.put_line('Ya existe este usuario');
END;


--Procedimiento baja usuario
procedure baixa_usuari(cod_usuari varchar2)
as
cont_us_cod number;
usuario_no_existe exception;

BEGIN
select count(*) into cont_us_cod from users
where user_code = cod_usuari;

if cont_us_cod = 0 then
    raise usuario_no_existe;
end if;

delete from users where user_code = cod_usuari;
dbms_output.put_line('Usuari donat de baixa correctament');

EXCEPTION    
    when usuario_no_existe then
        dbms_output.put_line('No existeix un usuari amb aquest codi');
END;


--Consultas de los usuarios
procedure consulta_usuari_cognoms(cognom varchar2)
as

cursor usuari is
select * from users
where lastname = cognom;
cont_usuari_cog number;
BEGIN
select count(*) into cont_usuari_cog from users
where lastname = cognom;
if cont_usuari_cog != 0 then
    dbms_output.put_line(rpad('CODI_USUARI',15)||rpad('USUARI',17)||rpad('NOM',17)||rpad('COGNOM',17)||'CONTRASENYA');
    for i in usuari loop
        dbms_output.put_line(rpad(i.user_code,15)||rpad(i.name,17)||rpad(i.firsname,17)||rpad(i.lastname,17)||i.password);
    end loop;
else
    dbms_output.put_line('No existeix un usuari amb aquest cognom');
end if;
END;

procedure consulta_usuaris
as
cursor usuaris is 
select * from users;
BEGIN
dbms_output.put_line(rpad('CODI_USUARI',15)||rpad('USUARI',17)||rpad('NOM',17)||rpad('COGNOM',17)||'CONTRASENYA');
for i in usuaris loop
    dbms_output.put_line(rpad(i.user_code,15)||rpad(i.name,17)||rpad(i.firsname,17)||rpad(i.lastname,17)||i.password);
end loop;
END;

end gestio_usuaris;
