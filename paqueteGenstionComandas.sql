create or replace package gestionarComandes is
    --DML
    procedure alta_comanda(cod_comanda number,fecha_comanda date,cod_cliente number,cod_vendedor number,cod_producto varchar2,cantidad number,salida_comanda varchar2);
    procedure baixacomanda(ocomanda  order2.order_code%type);
    procedure modificacio_comanda(comanda_id  order2.order_code%TYPE,option_  number,modificacion  number) ;
end gestionarComandes;

create or replace package body gestionarComandes is
    --Alta
    procedure alta_comanda(cod_comanda number,fecha_comanda date,cod_cliente number,cod_vendedor number,cod_producto varchar2,cantidad number,salida_comanda varchar2)
    as
    fecha_null exception;
    vendedor_no_existe exception;
    cod_existente exception;
    cliente_no_existe exception;
    producto_no_existe exception;
    
    cod_null exception;
    
    cantidad_invalida exception;
    
    cont_comanda number(8);
    cont_cliente number(8);
    cont_vendedor number(8);
    cont_producto number(8);
    precioProducto number(10,2);
    precioTotal number(10,2);
    
    BEGIN
    select count(order_code) into cont_comanda from order2
    where order_code = cod_comanda;
    
    select count(customer.customer_code) into cont_cliente from customer
    inner join order2 on order2.customer_code = customer.customer_code
    where customer.customer_code = cod_cliente;
    
    select count(product.product_code) into cont_producto from product
    inner join order2 on order2.product_code = product.product_code
    where product.product_code = cod_producto;
    
    
    select count(supplier.supplier_code) into cont_vendedor from supplier
    inner join order2 on order2.supplier_code = supplier.supplier_code
    where supplier.supplier_code = cod_vendedor;
    
    if fecha_comanda is null then
        raise fecha_null;
    end if;
    
    if cont_vendedor = 0  then
        raise vendedor_no_existe;
    end if;
    
    if cont_comanda = 0 then
        if cod_comanda is null then
            raise cod_null;
        end if;
    else
        raise cod_existente;
    end if;
    
    if cont_cliente = 0 then
        raise cliente_no_existe;
    end if;
    
    if cont_producto = 0 then
        raise producto_no_existe;
    end if;
    
    if cantidad < 1 then
        raise cantidad_invalida;
    end if;
    
    select prize into precioProducto from product
    where product_code = cod_producto;
    
    precioTotal := cantidad * precioProducto;
    insert into order2 values(cod_comanda,fecha_comanda ,cod_cliente ,cod_vendedor ,cod_producto,cantidad,precioTotal,salida_comanda);
    dbms_output.put_line('Comanda dada de alta');
    
    EXCEPTION
        when cod_existente then
            dbms_output.put_line('El codigo de la comanda ya existe');
        when fecha_null then
            dbms_output.put_line('La fecha de la comanda no puede ser nula');
        when cod_null then
            dbms_output.put_line('El codigo de la comanda no puede ser nulo');
        when cantidad_invalida then
            dbms_output.put_line('La cantidad no puede ser 0 o negativo');
        when vendedor_no_existe then
            dbms_output.put_line('El vendedor no existe');
        when cliente_no_existe then
            dbms_output.put_line('El cliente no existe');
        when producto_no_existe then
            dbms_output.put_line('El producto no existe');
    END alta_comanda;
    --Baja
    procedure baixacomanda(ocomanda in order2.order_code%type)as
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
    
    end baixacomanda;
    --Modificacion
    procedure modificacio_comanda(comanda_id  order2.order_code%TYPE,option_  number,modificacion  number) 
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
    end modificacio_comanda;

end gestionarComandes;
