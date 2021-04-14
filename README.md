-- Modificaion Oficina --

create or replace NONEDITIONABLE function modificacio_oficina(cod_oficce in office.code_office%TYPE) return boolean
is
    option_ number := 4;
    comprobacion_cod number;
    obj office.office_objective%TYPE;
    vent office.office_sales%TYPE;
    direct office.office_director%TYPE;
begin
    --Primero comprobamos que exista en codigo
    select count(cod_office) INTO
    comprobacion_cod from office where cod_office = cod_oficce;
    if comprobacion_cod<1 then
        dbms_output.put_line('El codigo que has puesto  no existe');
        return False ;
    else
        if option_ <1 or option_>3 then
            dbms_output.put_line('La opcion que has puesto no existe');
            return False;
        else
            if option_ = 1 then
                obj := 5; 
                update office set office_objective = obj where code_office =  cod_oficce;
            elsif option_ = 2 then
                vent := 6; 
                update office set office_sales = vent where code_office =  cod_oficce;
            elsif option_ = 3 then
                direct := 7; 
                update office set office_director = direct where code_office =  cod_oficce;
            end if;
            return True;

        end if;

    end if;

end;
set serveroutput on
declare
    cod_oficce office.code_office%TYPE := &Introduce_codigo_office;
    palabra varchar2 := False;
begin
    while palabra = False loop
        dmbs_output.put_line('Que elemento de esta oficina quieres modificar?');
        dmbs_output.put_line('1-Ojectius oficina');
        dmbs_output.put_line('2-Vendes oficina');
        dmbs_output.put_line('3-Director oficina');
        palabra := modificacio_oficina(cod_oficce);
        
        if palabra = True then
            dbms_output.put_line('==Datos modificados correctamente');
        end if;
    end loop;
    
end;
/

-- Trigger de Oficina --
create or replace NONEDITIONABLE TRIGGER disparador_oficina 
before insert or update
on office
for each row 
begin
    if inserting then
        if :new.city = null then
            RAISE_APPLICATION_ERROR(-20000, 'El nom de la ciutat de l’oficina ha de ser d’entrada obligatòria.');
        end if;
        if :new.office_objective<:new.office_sales then
             RAISE_APPLICATION_ERROR(-20001, 'Els objectius de vendes de l’oficina no poden ser més petit que les vendes de l’oficina');
        end if;
    end if;

    if updating then
        if :new.city = '' then
            RAISE_APPLICATION_ERROR(-20002, 'El nom de la ciutat de l’oficina ha de ser d’entrada obligatòria.');
        end if;
        if :new.office_objective<:new.office_sales then
             RAISE_APPLICATION_ERROR(-20003, 'Els objectius de vendes de l’oficina no poden ser més petit que les vendes de l’oficina');
        end if;
        if :new.OFFICE_DIRECTOR = null then
            RAISE_APPLICATION_ERROR(-20004, 'El nom de la ciutat de l’oficina ha de ser d’entrada obligatòria.');
        end if;
    end if;
end;
