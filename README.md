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
        if i.MINIMUM_STOCK < 5 then
            update product set  prize = prize * 1.05 where product_code = i.product_code;
            dbms_output.put_line('Updateado');
        end if;
    end loop;
    
end APLICAR_STOCK_MIN;

create or replace procedure  DESCOMPTAR_STOCK(id_com order2.ORDER_CODE%TYPE) is
    contador number;
    contador_ex exception;
    cod_prod product.PRODUCT_CODE%TYPE;
    cantidad number;
    
begin
    select count(*) into contador from order2 where  ORDER_CODE = id_com;
    if contador = 0 then
        raise contador_ex;
    else
        select o.QUANTITY, p.product_code into cantidad,cod_prod from order2 o 
        inner join product p on p.product_code = o.product_code
        where o.ORDER_CODE = id_com;
        
        update product set stock = stock - cantidad where product_code = cod_prod;
    end if;

exception
    
    when contador_ex then
        dbms_output.put_line('No existe ese codigo de comanda que has puesto');
    
        
end DESCOMPTAR_STOCK;


--Tractament històrics comandes

create table COMANDA_HISTORIC(  
    ORDER_CODE NUMBER(6,0) not null,
    ORDER_DATE DATE not null,
    CUSTOMER_CODE NUMBER(9,0),
    SUPPLIER_CODE NUMBER(5,0),
    PRODUCT_CODE VARCHAR2(8 BYTE),
    QUANTITY NUMBER(4,0),
    TOTAL_AMOUNT NUMBER(7,2),
    ORDER_DROP VARCHAR2(1 BYTE)

);

create or replace procedure pasar_comanda is
    cursor c is select * from  order2;
    
begin
    for i in c loop
        if i.ORDER_DROP = 'S' then
            insert into COMANDA_HISTORIC values(i.ORDER_CODE,i.ORDER_DATE,i.CUSTOMER_CODE,i.SUPPLIER_CODE,i.PRODUCT_CODE,i.QUANTITY,i.TOTAL_AMOUNT,i.ORDER_DROP);
            delete order2 where order_code=i.order_code;
        end if;
    end loop;
end;

--Copia seguretat--
create table COPIA_CLIENT(
    CUSTOMER_CODE NUMBER(9,0),
    CUSTOMER_NAME VARCHAR2(30 BYTE),
    CUSTOMER_ADDRESS VARCHAR2(30 BYTE),
    CUSTOMER_CP VARCHAR2(5 BYTE),
    BORN_DATE DATE,
    EMAIL VARCHAR2(30 BYTE)
);

create table COPIA_PRODUCT(
    PRODUCT_CODE VARCHAR2(8 BYTE),
    DESCRIPTION VARCHAR2(40 BYTE),
    PRIZE NUMBER(7,2),
    STOCK NUMBER(6,0),
    MINIMUM_STOCK NUMBER(6,0)
);

create table COPIA_VENEDOR(
    SUPPLIER_CODE NUMBER(5,0),
    SUPPLIER_NAME VARCHAR2(50 BYTE),
    HIREDATE DATE,
    SALES_OBJECTIVE NUMBER(9,2),
    REAL_SALES NUMBER(9,2),
    BOSS_CODE NUMBER(5,0)
 
);


create or replace procedure copia_seguridad is
    cursor c_clientes is select * from customer;
    contador_c number;
    cursor c_producto is select * from product;
    contador_p number;
    cursor c_vendedor is select * from supplier;
    contador_v number;
begin
    
    for i in c_clientes loop
        select count(*) into contador_c from customer where CUSTOMER_CODE=i.CUSTOMER_CODE;
        if contador_c != 0 then
            insert into COPIA_CLIENT values(i.CUSTOMER_CODE,i.CUSTOMER_NAME,i.CUSTOMER_ADDRESS,i.CUSTOMER_CP,i.BORN_DATE,i.EMAIL);
        end if;
    end loop;
    
    for j in c_producto loop
        select count(*) into contador_p from product where PRODUCT_CODE=j.PRODUCT_CODE;
        if contador_p != 0 then
            insert into COPIA_PRODUCT values(j.PRODUCT_CODE,j.DESCRIPTION,j.PRIZE,j.STOCK,j.MINIMUM_STOCK);
        end if;
    end loop;
    
    for k in c_vendedor loop
        select count(*) into contador_v from supplier where SUPPLIER_CODE=k.SUPPLIER_CODE;
        if contador_v != 0 then
            insert into COPIA_VENEDOR values(k.SUPPLIER_CODE,k.SUPPLIER_NAME,k.HIREDATE,k.SALES_OBJECTIVE,k.REAL_SALES,k.BOSS_CODE);
        end if;
    end loop;


end;

