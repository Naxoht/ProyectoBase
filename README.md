# ProyectoBase
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

-- Trigger comanda --
create or replace NONEDITIONABLE TRIGGER disparador_comandas 
before insert or update
on order2
for each row 
begin
    if inserting then
        --El codi del client, del venedor i del producte han de ser d’entrada obligatòria.
        if :new.CUSTOMER_CODE = null then
            RAISE_APPLICATION_ERROR(-20000, 'El codi del client ha de ser d’entrada obligatòria.');
        end if;
        if :new.SUPPLIER_CODE = null then
            RAISE_APPLICATION_ERROR(-20001, 'El codi del vendedor ha de ser d’entrada obligatòria.');
        end if;
        if :new.PRODUCT_CODE = null then
            RAISE_APPLICATION_ERROR(-20002, 'El codi del producte ha de ser d’entrada obligatòria.');
        end if;
        --En cas de no posar data de comanda, ha d’agafar la de sistema.
        if :new.ORDER_DATE = null then
            :new.ORDER_DATE := sysdate;
        end if;
        
    end if;

    if updating then
        --El codi del client, del venedor i del producte no es poden modificar mai.
        if :new.CUSTOMER_CODE != :old.CUSTOMER_CODE  then
            RAISE_APPLICATION_ERROR(-20004, 'El codi del client mai es pot cambiar.');
        end if;
        if :new.SUPPLIER_CODE != :old.SUPPLIER_CODE then
            RAISE_APPLICATION_ERROR(-20005, 'El codi del vendedor mai es pot cambiar.');
        end if;
        if :new.SUPPLIER_CODE != :old.SUPPLIER_CODE then
            RAISE_APPLICATION_ERROR(-20006, 'El codi del producte mai es pot cambiar.');
        end if;
        --La data de contracte no pot ser més gran a l’actual, ni més petita que la que existeix donada d’alta.
        if :new.ORDER_DATE > sysdate then
            RAISE_APPLICATION_ERROR(-20007, 'La data de contracte no pot ser més gran a l’actual.');
        end if;
        if :new.ORDER_DATE < :old.ORDER_DATE then
            RAISE_APPLICATION_ERROR(-20008, 'La data de contracte no pot ser més petita que la que existeix donada d’alta.');
        end if;
        --La quantitat mai pot ser més petit que la que ja existeix.
        if :new.QUANTITY<:old.QUANTITY then
             RAISE_APPLICATION_ERROR(-20003, 'La quantitat no pot ser mes petita que la existent.');
        end if;
    end if;
    --La quantitat no pot ser negativa.
    if :new.QUANTITY<0 then
             RAISE_APPLICATION_ERROR(-20003, 'La quantitat no pot ser negativa.');
    end if;
end;
