-------------------------------------------------------------------------
-- Copy data from .csv file to table
COPY nashville_housing_data(
Unique_ID ,Parcel_ID,Land_Use,Property_Address,Sale_Date,Sale_Price,Legal_Reference,Sold_As_Vacant,Owner_Name,Owner_Address,Acreage,Tax_District,Land_Value,Building_Value,Total_Value,Year_Built,Bedrooms,Full_Bath,Half_Bath
)
FROM 'D:\DataAanlysis\Databases\portfolio-databases\nashville_housing_data.csv' 
DELIMITER ',' CSV HEADER;

-- Select all the data in nashville_housing_data table
select * from nashville_housing_data;

-----------------------------------------------------------------------------
-- Standardize Date Format
alter table nashville_housing_data
add column sale_date_converted date

update nashville_housing_data
set sale_date_converted = date(sale_date)

------------------------------------------------------------------------------
-- Populate Property Address data
select property_address 
from nashville_housing_data
where property_address is null

-- Select the values of Property_Address columns is null
select a.parcel_id, a.property_address, b.parcel_id, b.property_address,
coalesce(a.property_address, b.property_address)
from nashville_housing_data as a
inner join nashville_housing_data as b
on a.parcel_id = b.parcel_id and a.unique_id != b.unique_id
where a.property_address is null

-- Update property_address column
UPDATE nashville_housing_data AS t
SET property_address = COALESCE(t.property_address, b.property_address)
FROM nashville_housing_data AS b
WHERE t.parcel_id = b.parcel_id
  AND t.unique_id != b.unique_id
  AND t.property_address IS NULL;

------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
SELECT 
    CASE 
        WHEN STRPOS(property_address, ',') > 0 
        THEN SUBSTRING(property_address, 1, STRPOS(property_address, ',') - 1)
        ELSE property_address
    END AS address,
    
    CASE 
        WHEN STRPOS(property_address, ',') > 0 
        THEN SUBSTRING(property_address, STRPOS(property_address, ',') + 1)
        ELSE NULL
    END AS city
FROM nashville_housing_data;

-- Add two column property_split_address and property_split_city
ALTER TABLE nashville_housing_data
ADD COLUMN property_split_address varchar(255),
ADD COLUMN property_split_city varchar(255);

-- Update two column just added
UPDATE nashville_housing_data AS t
SET property_split_address = CASE 
                      WHEN STRPOS(property_address, ',') > 0 
                      THEN SUBSTRING(property_address, 1, STRPOS(property_address, ',') - 1)
                      ELSE property_address
                    END,
    property_split_city   = CASE 
                      WHEN STRPOS(property_address, ',') > 0 
                      THEN SUBSTRING(property_address, STRPOS(property_address, ',') + 1)
                      ELSE NULL
                    END;
					
-- Show the splited values of the owner_address column 
select split_part(owner_address, ',', 1) as address,
split_part(owner_address, ',', 2) as city,
split_part(owner_address, ',', 3) as statee
from nashville_housing_data

-- Add 3 new columns
alter table nashville_housing_data
add column owner_split_address varchar(250),
add column owner_split_city varchar(250),
add column owner_split_state varchar(250);

-- Update table
update nashville_housing_data
set owner_split_address = split_part(owner_address, ',', 1),
	owner_split_city = split_part(owner_address, ',', 2),
	owner_split_state = split_part(owner_address, ',', 3)

-----------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(sold_as_vacant), count(sold_as_vacant) 
from nashville_housing_data
group by sold_as_vacant
order by count(sold_as_vacant)

-- Change 'N' to 'No', 'Y' to 'Yes'
select sold_as_vacant, 
case when sold_as_vacant = 'N' then 'No'
	 when sold_as_vacant = 'Y' then 'Yes'
	 else sold_as_vacant
end
from nashville_housing_data

-- Update table 
update nashville_housing_data
set sold_as_vacant = 
case when sold_as_vacant = 'N' then 'No'
	 when sold_as_vacant = 'Y' then 'Yes'
	 else sold_as_vacant
end

-------------------------------------------------------------------
-- Remove Duplicates
select *, 
row_number() over(
partition by parcel_id, property_address, sale_price, sale_date, legal_reference
order by unique_id
) as row_num
from nashville_housing_data
order by parcel_id

-- Use cte
with row_num_cte as (
select *, 
row_number() over(
partition by parcel_id, property_address, sale_price, sale_date, legal_reference
order by unique_id
) as row_num
from nashville_housing_data
)
select *
from row_num_cte
where row_num > 1
order by parcel_id

--
with row_num_cte as (
select *, 
row_number() over(
partition by parcel_id, property_address, sale_price, sale_date, legal_reference
order by unique_id
) as row_num
from nashville_housing_data
)
delete from nashville_housing_data t
using row_num_cte c
where t.unique_id = c.unique_id
  and c.row_num > 1;