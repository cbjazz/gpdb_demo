CREATE OR REPLACE FUNCTION func.SellingTop10(beginDate date, endDate date, rankType character varying, OUT rank integer, OUT typeName text, OUT totalValue numeric) RETURNS SETOF record
    AS $$
DECLARE
        SQLString text;
        colName text;
BEGIN
	colName := 'store_id';
	IF upper(rankType) = 'STORE' THEN
		colName := 'store_id';
	ELSEIF upper(rankType) = 'CATEGORY' THEN
		colName := 'product_category_id';
	ELSEIF upper(rankType) = 'PRODUCT' THEN
		colName := 'product_id';
	ELSEIF upper(rankType) = 'CUSTOMER' THEN
		colName := 'customer_id';	
	ELSEIF upper(rankType) = 'STATE' THEN
		colName := 'ship_address_state';
	ELSE
		RAISE EXCEPTION 'Unkown Type: %. Choose one among STORE, CATEGORY, PRODUCT, CUSTOMER and STATE', rankType;
	END IF;

	SQLString := 'SELECT rank
		,      typeName::text
		,      totalValue
	FROM ( SELECT ' ||  colName || ' as typeName, 
		SUM(item_quantity * item_price) as totalValue, 
		row_number() OVER ( ORDER BY sum(item_quantity * item_price) DESC) AS rank
		FROM   retail_demo.order_lineitems
		WHERE  order_datetime between ''' || beginDate || ''' AND ''' ||  endDate || '''
		GROUP BY ' || colName || '
	) AS lineitems
	WHERE rank <= 10
	ORDER BY rank';

	raise notice 'sql : % ', SQLString;

	
	--return SQLString;
  	FOR rank, typeName, totalValue IN EXECUTE SQLString
	loop
	   return next;
 	end loop;
END
$$
LANGUAGE plpgsql;
