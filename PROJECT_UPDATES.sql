ALTER TABLE books
ADD QUANTITY_ON_HAND number(3)
DEFAULT 0;

UPDATE books
SET QUANTITY_ON_HAND = 1;

--to set values so can ship order 1012
UPDATE books
SET QUANTITY_ON_HAND = 2
where isbn=1915762492;

drop table reorder;

CREATE TABLE Reorder (
  REORDER# number(4),
  REORDER_DATE date NOT NULL,
  REORDER_ISBN varchar2(10 BYTE),
  REORDER_QUANTITY number(2) NOT NULL,
  REORDER_RECEIVED date,
  PRIMARY KEY (REORDER#),
  FOREIGN KEY (REORDER_ISBN) REFERENCES BOOKS(ISBN)
);

--create sequence so 
create sequence reorder_seq;

drop sequence reorder_seq;

--Test Ship_order_pp not shipped
BEGIN
  just_lee_pkg.ship_order_pp(1012);
end; 

--reset table
update orders
set shipdate=null
where order#=1012;

--Test Ship_order_pp already shipped
BEGIN
  just_lee_pkg.ship_order_pp(1000);
end;

--test insert reorder 
begin
  just_lee_pkg.INSERT_REORDER_PP('1915762492');
end;
--Test sequence for reorder#
begin
  just_lee_pkg.INSERT_REORDER_PP('0401140733');
end;

--change one reorder to received
update reorder
set reorder_received = null
where reorder# = 1;

--test RECEIVE_REORDER_PP
begin
  just_lee_pkg.RECEIVE_REORDER_PP(1);
end;

/*create or replace PACKAGE BODY JUST_LEE_PKG AS

  PROCEDURE SHIP_ORDER_PP 
(
  P_ORDER# IN NUMBER 
) IS
  lv_shdate DATE := null;
  lv_shipped BOOLEAN := true;
  lv_onhand NUMBER(3);
  CURSOR cur_item IS
      SELECT isbn, quantity
        FROM orderitems
        WHERE order# = p_order#;
      TYPE type_item IS RECORD
        (t_isbn varchar2(10 byte),
        t_quantity number(3));
      rec_item type_item;
  BEGIN
    SELECT shipdate
      INTO lv_shdate
      FROM orders
      where order# = p_order#;
    IF lv_shdate is null THEN
      lv_shipped :=false;
    ELSE 
      RAISE_APPLICATION_ERROR(-20299, 'ERROR - Order# '|| p_order# ||' was shipped on ' || to_char(lv_shdate, 'MM/DD/YYYY'));
    END IF;
    IF lv_shipped = false then
      --DBMS_OUTPUT.PUT_LINE('IN NOT SHIPPED IF STATEMENT');
      OPEN cur_item;
      LOOP
        FETCH cur_item INTO rec_item;
        EXIT WHEN cur_item%NOTFOUND;
        SELECT QUANTITY_ON_HAND
          INTO lv_onhand
          FROM books
          WHERE isbn = rec_item.t_isbn;
          --DBMS_OUTPUT.PUT_LINE(rec_item.t_isbn || ' quantity ordered: ' || rec_item.t_quantity || ' quantity on-hand: ' || lv_onhand);
        IF rec_item.t_quantity > lv_onhand THEN
          RAISE_APPLICATION_ERROR(-20299, 'ERROR - ISBN '|| rec_item.t_isbn ||' is not available.');
          --DBMS_OUTPUT.PUT_LINE('ORDERED GREATER THAN ONHAND');
        END IF;
      END LOOP;  
      CLOSE cur_item;
      --DBMS_OUTPUT.PUT_LINE('order was placed');
      OPEN cur_item ;
      LOOP
        --DBMS_OUTPUT.PUT_LINE('in bottom loop');
        FETCH cur_item INTO rec_item;
        EXIT WHEN cur_item%NOTFOUND;
        SELECT QUANTITY_ON_HAND
          INTO lv_onhand
          FROM books
          WHERE isbn = rec_item.t_isbn;
        lv_onhand := (lv_onhand-rec_item.t_quantity);
        --DBMS_OUTPUT.PUT_LINE('lv_onhand: ' || lv_onhand);
        UPDATE books
        SET quantity_on_hand = lv_onhand
        WHERE isbn = rec_item.t_isbn;
      END LOOP;  
    END IF;
  END SHIP_ORDER_PP;
  

  PROCEDURE INSERT_REORDER_PP
(
  P_ISBN IN VARCHAR2
) AS
  BEGIN
    INSERT INTO reorder
      (reorder#, reorder_date, reorder_isbn, reorder_quantity, reorder_received)
    VALUES
      (reorder_seq.NEXTVAL, sysdate, P_ISBN, 10, null);
  END INSERT_REORDER_PP;


  PROCEDURE RECEIVE_REORDER_PP 
(
  P_REORDER# IN NUMBER 
) AS
  lv_received date := null;
  lv_shipped boolean := true;
  lv_onhand number(3) := 0;
  lv_isbn varchar2(10 byte);
  lv_quantity number(2) :=0;
  BEGIN
    SELECT reorder_received, reorder_isbn, reorder_quantity
      INTO lv_received, lv_isbn, lv_quantity
      FROM reorder
      WHERE reorder# = p_reorder#;
    SELECT quantity_on_hand
      INTO lv_onhand
      FROM books
      WHERE isbn = lv_isbn;
    lv_onhand := (lv_onhand + lv_quantity);
    IF lv_received is null THEN
      lv_shipped := false;
      update books
        set quantity_on_hand = lv_onhand
        where isbn = lv_isbn;
      update reorder
        set reorder_received = sysdate
        where reorder# = p_reorder#;
    ELSE 
      RAISE_APPLICATION_ERROR(-20299, 'ERROR - Re-Order# '|| p_reorder# ||' was shipped on ' || to_char(lv_received, 'MM/DD/YYYY'));
    END IF;
    
  END RECEIVE_REORDER_PP;

END JUST_LEE_PKG;

create or replace TRIGGER BOOKS_QUANTITY_TRG 
BEFORE INSERT OR UPDATE ON BOOKS 
REFERENCING OLD AS "OLD" NEW AS "NEW" 
FOR EACH ROW 
WHEN (NEW.QUANTITY_ON_HAND <= 0) 
BEGIN
  JUST_LEE_PKG.INSERT_REORDER_PP(:NEW.ISBN);
END;*/

Select books.title, publisher.name
from books
full join publisher on publisher.pubid=books.pubid;