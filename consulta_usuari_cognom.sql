create or replace procedure consulta_usuari_cognoms(cognom varchar2)
as
usuari users%rowtype;
BEGIN
select * into usuari from users
where lastname = cognom;

dbms_output.put_line(rpad('CODI_USUARI',15)||rpad('USUARI',17)||rpad('NOM',17)||rpad('COGNOM',17)||'CONTRASENYA');
dbms_output.put_line(rpad(usuari.user_code,15)||rpad(usuari.name,17)||rpad(usuari.firsname,17)||rpad(usuari.lastname,17)||usuari.password);

EXCEPTION
    when no_data_found then
        dbms_output.put_line('No existeix un usuari amb aquest cognom');
END;
