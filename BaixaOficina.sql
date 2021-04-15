/*Baixa oficina: donar de baixa l’oficina que l’usuari desitgi, tenint en compte si existeix o no. 
En cas d’existir s’ha d’anar en compte si està relacionat en una altra taula, i per tant, s’ha de 
donar el missatge corresponent de què no es pot esborrar.*/

create or replace procedure baixaoficina(odemanda in office.code_office%type)as
    contador number;
    no_esta exception;
begin
    select count(code_office) into contador from office 
    where code_office = odemanda;

    if contador = 0 then
        raise no_esta;
    else
        --No hay ninguna relacion de esta tabla con una fk
        DELETE FROM office WHERE code_office = odemanda;
        DBMS_OUTPUT.PUT_LINE('Se ha borrado exitosamente los campos de la oficina ' || odemanda);
    end if;

exception
    when no_esta then
        DBMS_OUTPUT.PUT_LINE('El codigo de oficina que has puesto no esta');

end;

--Quitar esto cuando se entregue el proyecto
set serveroutput on;
declare
begin
    baixaoficina('OFHO1');
end;