

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

