
--=====TRIGERS=====--


--Trigger oficina--
create or replace NONEDITIONABLE TRIGGER disparador_oficina 
before insert or update
on office
for each row 
begin
    if inserting then
        if :new.city is null then
            RAISE_APPLICATION_ERROR(-20000, 'El nom de la ciutat de l’oficina ha de ser d’entrada obligatòria.');
        end if;
        if :new.office_objective<:new.office_sales then
             RAISE_APPLICATION_ERROR(-20001, 'Els objectius de vendes de l’oficina no poden ser més petit que les vendes de l’oficina');
        end if;
    end if;

    if updating then
        if :new.city is null then
            RAISE_APPLICATION_ERROR(-20002, 'El nom de la ciutat de l’oficina ha de ser d’entrada obligatòria.');
        end if;
        if :new.office_objective<:new.office_sales then
             RAISE_APPLICATION_ERROR(-20003, 'Els objectius de vendes de l’oficina no poden ser més petit que les vendes de l’oficina');
        end if;
        if :new.OFFICE_DIRECTOR is null then
            RAISE_APPLICATION_ERROR(-20004, 'El codi del director de l’oficina ha de ser d’entrada obligatòria.');
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
        if :new.CUSTOMER_CODE is null then
            RAISE_APPLICATION_ERROR(-20000, 'El codi del client ha de ser d’entrada obligatòria.');
        end if;
        if :new.SUPPLIER_CODE is null then
            RAISE_APPLICATION_ERROR(-20001, 'El codi del vendedor ha de ser d’entrada obligatòria.');
        end if;
        if :new.PRODUCT_CODE is null then
            RAISE_APPLICATION_ERROR(-20002, 'El codi del producte ha de ser d’entrada obligatòria.');
        end if;
        --En cas de no posar data de comanda, ha d’agafar la de sistema.
        if :new.ORDER_DATE is null then
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
             RAISE_APPLICATION_ERROR(-20009, 'La quantitat no pot ser mes petita que la existent.');
        end if;
    end if;
    --La quantitat no pot ser negativa.
    if :new.QUANTITY<0 then
             RAISE_APPLICATION_ERROR(-20003, 'La quantitat no pot ser negativa.');
    end if;
end;
