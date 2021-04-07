# ProyectoBase
-- Modificacion Oficina Victor
create or replace NONEDITIONABLE procedure modificacio_oficina(cod_oficce in office.code_office%TYPE,option_ in number,modificacion in number) 
is
    comprobacion_cod number;
    obj office.office_objective%TYPE;
    vent office.office_sales%TYPE;
    direct office.office_director%TYPE;
begin
    --Primero comprobamos que exista en codigo
    select count(code_office) INTO comprobacion_cod from office where code_office = cod_oficce;
    if comprobacion_cod=0 then
        dbms_output.put_line('El codigo que has puesto  no existe');

    else
        if option_ <1 or option_>3 then
            dbms_output.put_line('La opcion que has puesto no existe');

        else
            if option_ = 1 then
                obj := modificacion; 
                update office set office_objective = modificacion where code_office =  cod_oficce;
            elsif option_ = 2 then
                vent := modificacion; 
                update office set office_sales = modificacion where code_office =  cod_oficce;
            elsif option_ = 3 then
                direct := modificacion; 
                update office set office_director = modificacion where code_office =  cod_oficce;
            end if;

        end if;

    end if;

end;
set serveroutput on;
declare
    cod_oficce office.code_office%TYPE := &Introduce_codigo_office;
    
    option_ number := &;
    modificacion number := &Introduce;
begin
    dbms_output.put_line('Que elemento de esta oficina quieres modificar?');
    dbms_output.put_line('1-Ojectius oficina');
    dbms_output.put_line('2-Vendes oficina');
    dbms_output.put_line('3-Director oficina');
    modificacio_oficina(cod_oficce,option_,modificacion);
    
    
    dbms_output.put_line('==Datos modificados correctamente');
        
    
    
end;
/
