create or replace procedure baixa_usuari(cod_usuari varchar2)
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
