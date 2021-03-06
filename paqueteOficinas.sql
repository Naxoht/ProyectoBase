create or replace package gestion_oficines is
    --DML
    
    procedure  alta_oficina(cod_oficina varchar2,ciudad varchar2,provincia varchar2,obj_ofcina number,ventas_oficina number,director_oficina number);
    procedure baixaoficina(odemanda  office.code_office%type);
    procedure modificacio_oficina(cod_oficce office.code_office%TYPE,option_ number,modificacion number);
    
    --Query
    PROCEDURE  consulta_oficina_codi (CODI OFFICE.CODE_OFFICE%TYPE);
    PROCEDURE CONSULTA_OFICINES;
    PROCEDURE CONSULTA_OFICINA_OBJECTIUS (OBJETIVO OFFICE.CODE_OFFICE%TYPE);
    PROCEDURE CONSULTA_OFICINES_CAP(DIRECTOR NUMBER);
end gestion_oficines;

create or replace package body gestion_oficines is
    --Alta
    procedure alta_oficina(cod_oficina varchar2,ciudad varchar2,provincia varchar2,obj_ofcina number,ventas_oficina number,director_oficina number)
    as
    cod_null exception;
    cod_incorrecto exception;
    cod_existente exception;
    dir_no_existe exception;
    cont_dir number;
    cont_of number;
    
    BEGIN
    select count(code_office) into cont_of from office
    where code_office = cod_oficina;
    select count(supplier_code) into cont_dir from supplier
    where supplier_code = director_oficina;
    if cont_of = 0 then
        if cod_oficina is null then
            raise cod_null;
        elsif substr(cod_oficina,1,2) != 'OF' then
            raise cod_incorrecto;
        end if;
    else
        raise cod_existente;
    end if;
    
    if cont_dir = 0 then
        raise dir_no_existe;
    end if;
    insert into office values(cod_oficina,ciudad ,provincia ,obj_ofcina ,ventas_oficina ,director_oficina);
    dbms_output.put_line('Oficina dada de alta');
    EXCEPTION
        when cod_existente then
            dbms_output.put_line('El codigo de la oficina ya existe');
        when cod_null then
            dbms_output.put_line('El codigo de la oficina no puede ser nulo');
        when cod_incorrecto then
            dbms_output.put_line('Los dos primeros caracteres del codigo de la oficina han de ser OF');
        when dir_no_existe then
            dbms_output.put_line('El director de la oficina ha de existir');
    END alta_oficina;
    --Baja
    procedure baixaoficina(odemanda office.code_office%type)as
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
    
    end baixaoficina;
    
    --Modificacion
    procedure modificacio_oficina(cod_oficce  office.code_office%TYPE,option_  number,modificacion  number) 
    is
        comprobacion_cod number;
        obj office.office_objective%TYPE;
        vent office.office_sales%TYPE;
        direct office.office_director%TYPE;
        error_contador exception;
        error_opcion exception;
        cont_dir number;
        dir_no_existe exception;
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
                    select count(supplier_code) into cont_dir from supplier
                    where supplier_code = direct;
                    if cont_dir = 0 then
                        raise dir_no_existe;
                    end if;
                    update office set office_director = modificacion where code_office =  cod_oficce;
                end if;
    
            end if;
    
        end if;
    exception 
        when error_contador then
            dbms_output.put_line('El codigo que has puesto  no existe');
        when error_opcion then
            dbms_output.put_line('La opcion que has puesto no existe');
        when dir_no_existe then
            dbms_output.put_line('No existe un director con ese codigo');
            
    end modificacio_oficina;
    
    --Consultas
    --1--
    PROCEDURE  consulta_oficina_codi (CODI OFFICE.CODE_OFFICE%TYPE)
    AS
    
    OFFI OFFICE%ROWTYPE;

    BEGIN
    
    SELECT * INTO OFFI FROM OFFICE O
    WHERE CODI = O.CODE_OFFICE;
    
    DBMS_OUTPUT.PUT_LINE('CODIGO OFICINA: '||OFFI.CODE_OFFICE||' CIUDAD: '||OFFI.CITY||' PROVINCIA: '||OFFI.PROVINCE||' OBJETIVO OFICINA: '||OFFI.OFFICE_OBJECTIVE||' VENTAS OFICINA: '||OFFI.OFFICE_SALES||' DIRECTOR: '||OFFI.OFFICE_DIRECTOR);
    EXCEPTION    
        when  no_data_found then
            dbms_output.put_line('No existe una oficina con ese codigo');
    END consulta_oficina_codi;

    --2--
    
    PROCEDURE CONSULTA_OFICINES
    AS
        DIFERENCIA NUMBER;
        CURSOR EX2 IS
        SELECT * FROM OFFICE ORDER BY CODE_OFFICE ASC;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('OFICINA       DIFERENCIA');
        FOR I IN EX2 LOOP
             DIFERENCIA := I.OFFICE_OBJECTIVE-I.OFFICE_SALES;
            DBMS_OUTPUT.PUT_LINE (I.CODE_OFFICE||'         '||DIFERENCIA);
        END LOOP;
    
    END CONSULTA_OFICINES;
    
    --3--
    PROCEDURE CONSULTA_OFICINA_OBJECTIUS (OBJETIVO OFFICE.CODE_OFFICE%TYPE)
    AS
        
        CURSOR EX3 
        IS
        SELECT * FROM OFFICE
        WHERE OFFICE.OFFICE_OBJECTIVE >= OBJETIVO;
        
    BEGIN
        
        FOR I IN EX3 LOOP
            IF OBJETIVO > 0 THEN
                DBMS_OUTPUT.PUT_LINE('CODIGO OFICINA: '||I.CODE_OFFICE||' CIUDAD: '||I.CITY||' PROVINCIA: '||I.PROVINCE||' OBJETIVO OFFICINA: '||I.OFFICE_OBJECTIVE||' VENTAS OFICINA: '||I.OFFICE_SALES||' DIRECTOR: '||I.OFFICE_DIRECTOR);
            ELSE
                DBMS_OUTPUT.PUT_LINE('INTRODUCE UN VALOR POSITIVO');
            END IF;
        END LOOP;
    END CONSULTA_OFICINA_OBJECTIUS;
    
    --4--
    PROCEDURE CONSULTA_OFICINES_CAP(DIRECTOR NUMBER)
    AS
    
    CURSOR EX4 IS
    SELECT * FROM OFFICE O
    WHERE DIRECTOR = O.OFFICE_DIRECTOR;
    
    DIRECT_CONT NUMBER;
    
    BEGIN
    SELECT COUNT(OFFICE_DIRECTOR)INTO DIRECT_CONT FROM OFFICE O
    WHERE O.OFFICE_DIRECTOR = DIRECTOR;
    IF  DIRECT_CONT != 0 THEN
        DBMS_OUTPUT.PUT_LINE('OFICINA      DIRECTOR');
        FOR I IN EX4 LOOP
            DBMS_OUTPUT.PUT_LINE(I.CODE_OFFICE||'        '||I.OFFICE_DIRECTOR);
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('NO EXISTEN OFICINAS CON ESE DIRECTOR');
    END IF;  
    END CONSULTA_OFICINES_CAP;
    
    
end gestion_oficines;
