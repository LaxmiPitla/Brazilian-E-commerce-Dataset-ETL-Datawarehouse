USE BrazilecomDWH;

IF OBJECT_ID('silver.olist_customers_data','U') IS NOT NULL
DROP TABLE silver.olist_customers_data
CREATE TABLE silver.olist_customers_data
(
	customer_id					NVARCHAR(50),
	customer_unique_id			NVARCHAR(50),
	customer_zip_code_prefix	NVARCHAR(50),
	customer_city				NVARCHAR(50),
	customer_state				NVARCHAR(50),
	dwh_create_date     DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.olist_geolocation_data','U') IS NOT NULL
DROP TABLE silver.olist_geolocation_data
CREATE TABLE silver.olist_geolocation_data
(
	geolocation_zip_code_prefix		NVARCHAR(10),
	geolocation_lat					DECIMAL(9,6),
	geolocation_lng					DECIMAL(9,6),
	geolocation_city				NVARCHAR(50),
	geolocation_state				NVARCHAR(50),
	dwh_create_date     DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.olist_order_reviews_data','U') IS NOT NULL
DROP TABLE silver.olist_order_reviews_data
CREATE TABLE silver.olist_order_reviews_data
(
	review_id					NVARCHAR(50),			
	order_id					NVARCHAR(50),
	review_score				INT,
	review_comment_title		NVARCHAR(1000),
	review_comment_message		NVARCHAR(2000),
	review_creation_date		DATETIME2,
	review_answer_timestamp		DATETIME2,
	dwh_create_date     DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.olist_order_payments_data','U') IS NOT NULL
DROP TABLE silver.olist_order_payments_data
CREATE TABLE silver.olist_order_payments_data
(
	order_id				NVARCHAR(50),
	payment_sequential		INT,
	payment_type			NVARCHAR(50),
	payment_installments	INT,
	payment_value			DECIMAL(9,3),
	dwh_create_date     DATETIME2 DEFAULT GETDATE()

);

IF OBJECT_ID('silver.olist_order_items_data','U') IS NOT NULL
DROP TABLE silver.olist_order_items_data
CREATE TABLE silver.olist_order_items_data
(
	order_id				NVARCHAR(50),		
	order_item_id			INT,
	product_id				NVARCHAR(50),
	seller_id				NVARCHAR(50),
	shipping_limit_date		SMALLDATETIME,
	price					DECIMAL(9,5),
	freight_value			DECIMAL(10,2),
	dwh_create_date     DATETIME2 DEFAULT GETDATE()

);

IF OBJECT_ID('silver.olist_product_category_name_translation','U') IS NOT NULL
DROP TABLE silver.olist_product_category_name_translation
CREATE TABLE silver.olist_product_category_name_translation
(
	product_category_name			NVARCHAR(50),
	product_category_name_english	NVARCHAR(50),
	dwh_create_date     DATETIME2 DEFAULT GETDATE()

);

IF OBJECT_ID('silver.olist_sellers_data','U') IS NOT NULL
DROP TABLE silver.olist_sellers_data
CREATE TABLE silver.olist_sellers_data
(
	seller_id					NVARCHAR(50),
	seller_zip_code_prefix		NVARCHAR(50),
	seller_city					NVARCHAR(50),
	seller_state				NVARCHAR(50),
	dwh_create_date     DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.olist_products_data','U') IS NOT NULL
DROP TABLE silver.olist_products_data
CREATE TABLE silver.olist_products_data
(
	product_id						NVARCHAR(50),							
	product_category_name			NVARCHAR(50),
	product_name_length				INT,
	product_description_length		INT,
	product_photos_qty				INT,
	product_weight_g				INT,
	product_length_cm				INT,
	product_height_cm				INT,
	product_width_cm				INT,
	dwh_create_date     DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.olist_orders_data','U') IS NOT NULL
DROP TABLE silver.olist_orders_data
CREATE TABLE silver.olist_orders_data
(
	order_id						NVARCHAR(50),
	customer_id						NVARCHAR(50),
	order_status					NVARCHAR(50),
	order_purchase_timestamp		SMALLDATETIME,
	order_approved_at				SMALLDATETIME,
	order_delivered_carrier_date	SMALLDATETIME,
	order_delivered_customer_date	SMALLDATETIME,
	order_estimated_delivery_date	SMALLDATETIME,
	dwh_create_date     DATETIME2 DEFAULT GETDATE()
);

