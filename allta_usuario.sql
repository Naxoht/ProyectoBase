create or replace procedure alta_usuari(cod_usuari varchar2,usuari varchar2,nom varchar2,cognom varchar2,contrasenya varchar2)
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
