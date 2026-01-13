/*
===============================================================================
Data Correctness of bronze layer
===============================================================================
Script Purpose: To check data correctness of bronze layer
===============================================================================
*/
--------------------------------------------------------------------
-- Table: bronze.crm_cust_info
--------------------------------------------------------------------
-- Check for Nulls and duplicates in the primary key
-- Expectation: No Result
SELECT 
cst_id,
count(*)
FROM bronze.crm_cust_info
group by cst_id
HAVING count(*) > 1 OR cst_id is NULL

-- check the unwanted space
-- Expectation: No Result
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

-- check data standardisation and consistency
-- Aim: in our dwh we aim to store clear and meaningful values rather than using abbreviated terms
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info

--------------------------------------------------------------------
-- Table: bronze.crm_prd_info
--------------------------------------------------------------------
SELECT * FROM bronze.crm_prd_info
-- Check for Nulls and duplicates in the primary key
-- Expectation: No Result

SELECT 
prd_id,
count(*)
FROM bronze.crm_prd_info
group by prd_id
HAVING count(*) > 1 OR prd_id is NULL

-- check the unwanted space
-- Expectation: No Result

SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for NULLS or negative numbers
-- Expectation: No Result

SELECT prd_key,prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost is null or prd_cost < 0

-- check data standardisation and consistency
-- Aim: in our dwh we aim to store clear and meaningful values rather than using abbreviated terms
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

-- Check for invalid date orders
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt

--------------------------------------------------------------------
-- Table: bronze.crm_sales_details
--------------------------------------------------------------------
-- check for invalid dates
SELECT NULLIF(sls_order_dt,0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

-- Checks for invalid date orders
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check data consistency: Between Sales, Quantity and Price
-- >> Sales = Quantity * Price
-- >> Values must not be negative, zero or NULL

SELECT DISTINCT
	sls_sales as old_sls_sales,
	sls_quantity,
	sls_price as old_sls_price,
	CASE 
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales 
	END sls_sales,
	CASE 
		WHEN sls_price IS NULL or sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity,0)
		ELSE sls_price
	END sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price 
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales < 0 OR sls_quantity < 0 OR sls_price < 0
ORDER BY sls_sales, sls_price
--------------------------------------------------------------------
-- Table: bronze.erp_cust_az12
--------------------------------------------------------------------
-- Identify Out of range dates
SELECT 
bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- check data standardisation and consistency
SELECT
	DISTINCT gen
FROM bronze.erp_cust_az12
--------------------------------------------------------------------
-- Table: bronze.erp_loc_a101
--------------------------------------------------------------------
-- check data standardisation and consistency
SELECT
	DISTINCT cntry
FROM bronze.erp_loc_a101
--------------------------------------------------------------------
-- Table: bronze.erp_px_cat_g1v2
--------------------------------------------------------------------
-- check the unwanted space
-- Expectation: No Result
SELECT * 
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- check data standardisation and consistency
SELECT
	DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2
