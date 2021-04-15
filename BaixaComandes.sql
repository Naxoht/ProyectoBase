/*Baixa comanda: donar de baixa la comanda que l’usuari desitgi, tenint en compte 
si existeix o no. En cas d’existir s’ha d’anar en compte si està relacionat en una
altra taula, i per tant, s’ha de donar el missatge corresponent de què no es pot esborrar.
En aquest cas no s’esborrarà la comanda directament, sinó que es canviarà el camp
comanda baixa de NO (N) per SI (S).*/

create or replace procedure baixacomanda(ocomanda in order2.order_code%type)as
    contador number;
    no_esta exception;
begin
    select count(order_code) into contador from order2 
    where order_code = ocomanda;

    if contador = 0 then
        raise no_esta;
    else
        --No hay ninguna relacion de esta tabla con una fk
        DELETE FROM order2 WHERE order_code = ocomanda;
        DBMS_OUTPUT.PUT_LINE('Se ha borrado exitosamente los campos de la comanda ' || ocomanda);
    end if;

exception
    when no_esta then
        DBMS_OUTPUT.PUT_LINE('El codigo de comanda que has puesto no esta');

end;


--Quitar esto cuando se entregue el proyecto
set serveroutput on;
begin
    baixacomanda(1);
end;
