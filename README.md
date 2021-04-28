# ProyectoBase
-- Modificaion Oficina --
create or replace NONEDITIONABLE procedure modificacio_oficina(cod_oficce in office.code_office%TYPE,option_ in number,modificacion in number) 
is
    comprobacion_cod number;
    obj office.office_objective%TYPE;
    vent office.office_sales%TYPE;
    direct office.office_director%TYPE;
    error_contador exception;
    error_opcion exception;
begin
    --Primero comprobamos que exista en codigo
    select count(code_office) INTO comprobacion_cod from office where code_office = cod_oficce;
    if comprobacion_cod=0 then
        raise error_contador;

    else
        if option_ <1 or option_>3 then
            raise error_opcion;

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
exception 
    when error_contador then
        dbms_output.put_line('El codigo que has puesto  no existe');
    when error_opcion then
        dbms_output.put_line('La opcion que has puesto no existe');
end;
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

-- Modificacion comanda --

create or replace NONEDITIONABLE procedure modificacio_comanda(comanda_id in order2.order_code%TYPE,option_ in number,modificacion in number) 
is
    comprobacion_cod number;
    quant order2.quantity%TYPE;
    total order2.total_amount%TYPE;
    error_contador exception;
    error_opcion exception;
begin
    --Primero comprobamos que exista en codigo
    select count(*) INTO comprobacion_cod from order2 where order_code = comanda_id;
    if comprobacion_cod=0 then
        raise error_contador;

    else
        if option_ <1 or option_>2 then
            raise error_contador;

        else
            if option_ = 1 then
                quant := modificacion; 
                update order2 set quantity = quant where order_code =  comanda_id;
            elsif option_ = 2 then
                total := modificacion; 
                update order2 set total_amount = total where order_code =  comanda_id;
            end if;

        end if;

    end if;
exception 
    when error_contador then
        dbms_output.put_line('El codigo que has puesto  no existe');
    when error_opcion then
        dbms_output.put_line('La opcion que has puesto no existe');
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

-- Altres gestions --
-- Modifiacion--

create or replace procedure  APLICAR_STOCK_MIN is
    cursor c is select * from product;
    
begin
    for i in c loop
        if i.stock < 5 then
            update product set  prize = prize * 1.05 where product_code = i.product_code;
            dbms_output.put_line('Updateado');
        end if;
    end loop;
    
end APLICAR_STOCK_MIN;

create or replace procedure  DESCOMPTAR_STOCK(id_prod product.product_code%TYPE, num_comprados number) is
    contador number;
    contador_ex exception;
    num_ex exception;
begin
    select count(*) into contador from product where  product_code = id_prod;
    if contador = 0 then
        raise contador_ex;
    else
        if num_comprados<=0 then
            raise num_ex;
        else
            update product set stock = stock - num_comprados where product_code = id_prod;
        end if;
    end if;

exception
    
    when contador_ex then
        dbms_output.put_line('No existe ese codigo de producto');
    when num_ex then
     dbms_output.put_line('No se pueden descontar 0 productos');
        
end DESCOMPTAR_STOCK;

