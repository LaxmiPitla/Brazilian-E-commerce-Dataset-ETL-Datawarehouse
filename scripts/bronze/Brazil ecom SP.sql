--EXEC bronze.load_bronze
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME,@end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY 
		SET @batch_start_time = GETDATE();
		PRINT 'Loading Olist Brazil ecom Tables';
		PRINT '===================================';
		SET @start_time = GETDATE();
		PRINT '>>Truncating table: bronze.olist_customers_data ';
		TRUNCATE TABLE bronze.olist_customers_data; 
		PRINT '>> Inserting into table: bronze.olist_customers_data';
		BULK INSERT bronze.olist_customers_data
		FROM 'C:\Users\Lakshmi\Downloads\Olist brazilian ecommerce dataset\datasets\olist_customers_data.csv'
		WITH (
			FORMAT = 'CSV',
			FIELDQUOTE = '"',
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			TABLOCK

		);
		SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '********************************************************************';

		SET @start_time = GETDATE();
		PRINT '>>Truncating table: bronze.olist_geolocation_data';
		TRUNCATE TABLE bronze.olist_geolocation_data;
		PRINT '>> Inserting into table: bronze.olist_geolocation_data ';
		BULK INSERT bronze.olist_geolocation_data
		FROM 'C:\Users\Lakshmi\Downloads\Olist brazilian ecommerce dataset\datasets\olist_geolocation_data.csv'
		WITH (
			FIRSTROW = 2,
			FIELDQUOTE = '"',
			FIELDTERMINATOR = ',',
			ROWTERMINATOR =  '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '********************************************************************';

		SET @start_time = GETDATE();
		PRINT '>>Truncating table: bronze.olist_order_items_data';
		TRUNCATE TABLE bronze.olist_order_items_data;
		PRINT '>> Inserting into table: bronze.olist_order_items_data ';
		BULK INSERT bronze.olist_order_items_data
		FROM 'C:\Users\Lakshmi\Downloads\Olist brazilian ecommerce dataset\datasets\olist_order_items_data.csv'
		WITH (
			FIRSTROW = 2,
			FIELDQUOTE = '"',
			FIELDTERMINATOR = ',',
			ROWTERMINATOR  = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '********************************************************************';

		SET @start_time = GETDATE();
		PRINT '>>Truncating table:bronze.olist_order_payments_data';
		TRUNCATE TABLE bronze.olist_order_payments_data;
		PRINT '>> Inserting into table: bronze.olist_order_payments_data';
		BULK INSERT bronze.olist_order_payments_data
		FROM 'C:\Users\Lakshmi\Downloads\Olist brazilian ecommerce dataset\datasets\olist_order_payments_data.csv'
		WITH (
			FIRSTROW = 2,
			FIELDQUOTE = '"',
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '********************************************************************';

		PRINT '>> Creating #review_staging : A temporary table'
		CREATE TABLE #review_staging 
		(
		review_id					NVARCHAR(MAX),			
		order_id					NVARCHAR(MAX),
		review_score				NVARCHAR(MAX),
		review_comment_title		NVARCHAR(MAX),
		review_comment_message		NVARCHAR(MAX),
		review_creation_date		NVARCHAR(MAX),
		review_answer_timestamp		NVARCHAR(MAX)
		);
		PRINT '>>Truncating table: #review_staging';
		TRUNCATE TABLE #review_staging;
		PRINT '>> Inserting into table: #review_staging ';
		BULK INSERT #review_staging
		FROM 'C:\Users\Lakshmi\Downloads\Olist brazilian ecommerce dataset\datasets\olist_order_reviews_data.csv'
		WITH (
			FIRSTROW = 2,
			FIELDQUOTE = '"',
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			CODEPAGE = '65001',
			TABLOCK
		);
		SET @start_time = GETDATE();
		PRINT '>>Truncating table: bronze.olist_order_reviews_data';
		TRUNCATE TABLE bronze.olist_order_reviews_data;
		PRINT '>> Inserting into table: bronze.olist_order_reviews_data from #review_staging table';
		INSERT INTO bronze.olist_order_reviews_data
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
			TRY_CONVERT(INT,review_score),				
			review_comment_title,		
			review_comment_message,		
			TRY_CONVERT(DATETIME2,review_creation_date,105),	
			TRY_CONVERT(DATETIME2,review_answer_timestamp,105)									
		FROM #review_staging;
		SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '********************************************************************';

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: bronze.olist_orders_data';
		TRUNCATE TABLE bronze.olist_orders_data;
		PRINT '>> Inserting into table: bronze.olist_orders_data ';
		BULK INSERT bronze.olist_orders_data
		FROM 'C:\Users\Lakshmi\Downloads\Olist brazilian ecommerce dataset\datasets\olist_orders_data.csv'
		WITH (
			FIRSTROW =  2,
			FIELDQUOTE = '"',
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '********************************************************************';


		SET @start_time = GETDATE();
		PRINT '>>Truncating table: bronze.olist_product_category_name_translation';
		TRUNCATE TABLE bronze.olist_product_category_name_translation
		PRINT '>> Inserting into table: bronze.olist_product_category_name_translation';
		BULK INSERT bronze.olist_product_category_name_translation
		FROM 'C:\Users\Lakshmi\Downloads\Olist brazilian ecommerce dataset\datasets\olist_product_category_name_translation.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDQUOTE = '"',
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '********************************************************************';

		SET @start_time = GETDATE();
		PRINT '>>Truncating table: bronze.olist_products_data';
		TRUNCATE TABLE bronze.olist_products_data;
		PRINT '>> Inserting into table: bronze.olist_products_data';
		BULK INSERT bronze.olist_products_data
		FROM 'C:\Users\Lakshmi\Downloads\Olist brazilian ecommerce dataset\datasets\olist_products_data.csv'
		WITH (
			FIRSTROW = 2,
			FIELDQUOTE = '"',
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '********************************************************************';


		SET @start_time = GETDATE();
		PRINT '>>Truncating table: bronze.olist_sellers_data';
		TRUNCATE TABLE bronze.olist_sellers_data;
		PRINT '>> Inserting into table: bronze.olist_sellers_data ';
		BULK INSERT bronze.olist_sellers_data
		FROM 'C:\Users\Lakshmi\Downloads\Olist brazilian ecommerce dataset\datasets\olist_sellers_data.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDQUOTE = '"',
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0a',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load duration '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '********************************************************************';
		PRINT '======================================================';
		SET @batch_end_time =  GETDATE();
		PRINT 'Load duration of batch is ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '**********************************************************************';
	END TRY 
	BEGIN CATCH
	---create log table,add messages
		PRINT '==================================================';
		PRINT 'Error occured during loading bronze layer';
		PRINT ' ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT ' ERROR MESSAGE' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT ' ERROR MESSAGE' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '==================================================';
	END CATCH 
END


