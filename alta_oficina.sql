create or replace procedure alta_oficina(cod_oficina varchar2,ciudad varchar2,provincia varchar2,obj_ofcina number,ventas_oficina number,director_oficina number)
as
cod_null exception;
cod_incorrecto exception;
cod_existente exception;
dir_no_existe exception;
cont_dir number;
cont_of number;

BEGIN
select count(code_office) into cont_of from office
where code_office = cod_oficina;
select count(supplier_code) into cont_dir from supplier
where supplier_code = director_oficina;
if cont_of = 0 then
    if cod_oficina is null then
        raise cod_null;
    elsif substr(cod_oficina,1,2) != 'OF' then
        raise cod_incorrecto;
    end if;
else
    raise cod_existente;
end if;

if cont_dir = 0 then
    raise dir_no_existe;
end if;
insert into office values(cod_oficina,ciudad ,provincia ,obj_ofcina ,ventas_oficina ,director_oficina);
dbms_output.put_line('Oficina dada de alta');
EXCEPTION
    when cod_existente then
        dbms_output.put_line('El codigo de la oficina ya existe');
    when cod_null then
        dbms_output.put_line('El codigo de la oficina no puede ser nulo');
    when cod_incorrecto then
        dbms_output.put_line('Los dos primeros caracteres del codigo de la oficina han de ser OF');
    when dir_no_existe then
        dbms_output.put_line('El director de la oficina ha de existir');
END;

set serveroutput on
BEGIN
    alta_oficina('OFDO2','CORNELLA DE LLOBREGAT','BARCELONA',300000,2000,2);
END;
select * from supplier;