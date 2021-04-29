create or replace procedure consulta_usuaris
as
cursor usuaris is 
select * from users;
BEGIN
dbms_output.put_line(rpad('CODI_USUARI',15)||rpad('USUARI',17)||rpad('NOM',17)||rpad('COGNOM',17)||'CONTRASENYA');
for i in usuaris loop
    dbms_output.put_line(rpad(i.user_code,15)||rpad(i.name,17)||rpad(i.firsname,17)||rpad(i.lastname,17)||i.password);
end loop;
END;
