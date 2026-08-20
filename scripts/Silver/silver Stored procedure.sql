==================================================================================================================
	/*Inserting cleaned and transformed data from bronze layer to silver layer 
Script Purpose: Truncating the silver tables then inserting the data , Loading data into silver stored procedure
	It includes time taken to load each table and complete SP 

Stored Procedure can be executed with : EXEC silver.load_silver
*/
===================================================================================================================
--EXEC silver.load_silver;
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME,@end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY 
		SET @batch_start_time = GETDATE();
		PRINT '******************************************';
		SET @start_time = GETDATE();
		PRINT'Truncating Table: silver.olist_customers_data';
		TRUNCATE TABLE silver.olist_customers_data ;
		PRINT'Inserting into Table: silver.olist_customers_data';
		INSERT INTO  silver.olist_customers_data 
			(
			customer_id,
			customer_unique_id,
			customer_zip_code_prefix,
			customer_city,
			customer_state
			)
		select 
			customer_id,
			customer_unique_id,
			CAST(customer_zip_code_prefix AS NVARCHAR(10)) AS customer_zip_code_prefix,
			customer_city,
			customer_state
			from bronze.olist_customers_data;
		SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '******************************************';
		SET @start_time = GETDATE();
		PRINT 'Truncating table: silver.olist_geolocation_data';
		TRUNCATE TABLE silver.olist_geolocation_data;
		PRINT 'Inserting into table: silver.olist_geolocation_data';
		;WITH CTE AS
		(
			SELECT
				*,
				ROW_NUMBER() OVER
				(
					PARTITION BY
						geolocation_zip_code_prefix,
						geolocation_lat,
						geolocation_lng,
						geolocation_city,
						geolocation_state
					ORDER BY (SELECT NULL)
				) AS rn
			FROM bronze.olist_geolocation_data
		)
		INSERT INTO silver.olist_geolocation_data
		(
			geolocation_zip_code_prefix,
			geolocation_lat,
			geolocation_lng,
			geolocation_city,
			geolocation_state
		)
		SELECT
			REPLACE(geolocation_zip_code_prefix,'"','') AS geolocation_zip_code_prefix,
			geolocation_lat,
			geolocation_lng,
			TRIM(
				TRANSLATE(
					geolocation_city,
					'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
					'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC'
				)
			) AS geolocation_city,

			RIGHT(geolocation_state, 2) AS geolocation_state
		FROM CTE
		WHERE rn = 1;
		SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '******************************************';
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table:silver.olist_order_items_data';
		TRUNCATE TABLE silver.olist_order_items_data;
		PRINT '>>Inserting into table: silver.olist_order_items_data';
		INSERT INTO silver.olist_order_items_data
		(
			order_id,
			order_item_id,
			product_id,
			seller_id,
			shipping_limit_date,
			price,
			freight_value
		)
		select 
			TRIM(REPLACE(order_id,'"','')) AS order_id,
			order_item_id,
			TRIM(REPLACE(product_id,'"','')) AS product_id,
			TRIM(REPLACE(seller_id,'"','')) AS seller_id,
			shipping_limit_date,
			price,
			freight_value
		from bronze.olist_order_items_data;
		SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';

		PRINT '******************************************';
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.olist_order_payments_data';
		TRUNCATE TABLE silver.olist_order_payments_data;
		PRINT '>>Inserting into table: silver.olist_order_payments_data';
		INSERT INTO silver.olist_order_payments_data(
			order_id,
			payment_sequential,
			payment_type,
			payment_installments,
			payment_value
			)
		select
			REPLACE(order_id,'"','') AS order_id,
			payment_sequential,
			payment_type,
			payment_installments,
			payment_value
		from bronze.olist_order_payments_data;
		SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '******************************************';
		SET @start_time = GETDATE();
		PRINT 'Truncating table: silver.olist_order_reviews_data';
		TRUNCATE TABLE silver.olist_order_reviews_data;
		PRINT 'Truncating table: silver.olist_order_reviews_data';
		INSERT INTO silver.olist_order_reviews_data
			(
			review_id,
			order_id,
			review_score,
			review_comment_title,
			review_comment_message,
			review_creation_date,
			review_answer_timestamp
			)
		SELECT 
			review_id,
			 order_id,
			CASE 
				WHEN len(REPLACE(review_id,'"',''))<>32 and review_score IS NULL 
				THEN TRY_CONVERT(INT,TRIM(review_comment_message)) 
				ELSE review_score
			END AS review_score,
			review_comment_title,
			review_comment_message,
			review_creation_date,
			review_answer_timestamp
		from bronze.olist_order_reviews_data 
		where  not (len(REPLACE(review_id,'"',''))<>32) and review_id like '"%';
		SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';

		PRINT '******************************************';
		SET @start_time = GETDATE();
		PRINT'Truncating table : silver.olist_orders_data';
		TRUNCATE TABLE silver.olist_orders_data;
		PRINT'Inserting into table : silver.olist_orders_data';
		INSERT INTO silver.olist_orders_data
		(
			order_id,
			customer_id,
			order_status,
			order_purchase_timestamp,
			order_approved_at,
			order_delivered_carrier_date,
			order_delivered_customer_date,
			order_estimated_delivery_date
		)
		select 
			REPLACE(order_id,'"','') AS order_id,
			REPLACE(customer_id,'"','') AS
			customer_id,
			order_status,
			order_purchase_timestamp,
			order_approved_at,
			order_delivered_carrier_date,
			order_delivered_customer_date,
			order_estimated_delivery_date
		from bronze.olist_orders_data;
		SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		
		PRINT '******************************************';
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.olist_product_category_name_translation';
		TRUNCATE TABLE silver.olist_product_category_name_translation;
		PRINT '>> Inserting Table: silver.olist_product_category_name_translation';
		INSERT INTO silver.olist_product_category_name_translation
			(
			product_category_name,
			product_category_name_english
			)
		select 
			TRIM(product_category_name) AS product_category_name,
			TRIM(product_category_name_english) AS product_category_name_english
			from bronze.olist_product_category_name_translation;
		SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';

		PRINT '******************************************';
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.olist_products_data';
		TRUNCATE TABLE silver.olist_products_data;
		PRINT '>>Inserting into table: silver.olist_products_data ';
		INSERT INTO silver.olist_products_data
			(
			product_id,
			product_category_name,
			product_name_length,
			product_description_length,
			product_photos_qty,
			product_weight_g,
			product_length_cm,
			product_height_cm,
			product_width_cm
			)
		select 
			product_id,
			TRIM(product_category_name) AS product_category_name,
			product_name_length,
			product_description_length,
			product_photos_qty,
			product_weight_g,
			product_length_cm,
			product_height_cm,
			product_width_cm
			from bronze.olist_products_data
			where 
			  NOT (
				product_name_length IS  NULL
				AND product_description_length IS  NULL
				AND product_photos_qty IS  NULL
				AND product_category_name IS  NULL
				AND  product_weight_g IS NULL
				AND product_length_cm is null
				AND product_height_cm is null 
				AND product_width_cm is null 
			  );
			  SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '******************************************';
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.olist_sellers_data';
		TRUNCATE TABLE silver.olist_sellers_data;
		PRINT '>>Inserting into table: silver.olist_sellers_data';
		INSERT INTO silver.olist_sellers_data
			(
			seller_id,
			seller_zip_code_prefix,
			seller_city,
			seller_state
			)
		SELECT 
			REPLACE(seller_id,'"','') AS seller_id,
			REPLACE(seller_zip_code_prefix,'"','') AS seller_zip_code_prefix,
			CASE
				WHEN PATINDEX('%[-/@]%',seller_city)>0 THEN LEFT(seller_city,PATINDEX('%[-/@]%',seller_city)-1)
				WHEN seller_city like '%[0-9]%'  THEN  'NULL' 
				WHEN seller_city like '"%' THEN REPLACE(seller_city,'"','')
				ELSE seller_city
			END AS seller_city,
			RIGHT(seller_state,2) AS seller_state
		FROM bronze.olist_sellers_data;
		SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		SET @batch_end_time = GETDATE();
		PRINT '********************************************';
		PRINT 'Load duration of batch is ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '**********************************************************************';
		END TRY
		BEGIN CATCH
	---create log table,add messages
		PRINT '==================================================';
		PRINT 'Error occured during loading silver layer';
		PRINT ' ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT ' ERROR MESSAGE' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT ' ERROR MESSAGE' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '==================================================';
	END CATCH 
END 

