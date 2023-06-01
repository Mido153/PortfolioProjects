/*

Cleaning Data in SQL Queries

*/


Select *
From NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select saleDateconverted , CONVERT(date , SaleDate)
From NashvilleHousing

-- adding new column
alter Table NashvilleHousing 
add saleDateconverted date

update NashvilleHousing 
set saleDateconverted = CONVERT(date , SaleDate)


--alter table NashvilleHousing 
--drop column SaleDate


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select PropertyAddress , ParcelID
from NashvilleHousing


select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress , b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

where a.PropertyAddress is null 



-- update the new values 
update a
set PropertyAddress =  ISNULL(a.PropertyAddress , b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

where a.PropertyAddress is null 





--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress 
from NashvilleHousing


select SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress)-1) address,
SUBSTRING(PropertyAddress ,CHARINDEX(',' , PropertyAddress)+1  , LEN(PropertyAddress)) address2
from NashvilleHousing


alter table NashvilleHousing
add addressName nvarchar(255)

alter table NashvilleHousing
add cityName nvarchar(255)



update NashvilleHousing
set addressName = SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress)-1) ,
cityName = SUBSTRING(PropertyAddress ,CHARINDEX(',' , PropertyAddress)+1  , LEN(PropertyAddress))



select OwnerAddress from NashvilleHousing

select PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 3) ,
PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 2) ,
PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 1) 
from NashvilleHousing


alter table NashvilleHousing
add ownerAddressName nvarchar(255)

alter table NashvilleHousing
add ownerCityName nvarchar(255)

alter table NashvilleHousing
add ownerStateName nvarchar(255)



update NashvilleHousing
set ownerAddressName = PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 3) ,
ownerCityName = PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 2) ,
ownerStateName = PARSENAME(REPLACE(OwnerAddress , ',' , '.') , 1) 


select * from NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant) , COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2



--select SoldAsVacant,
--case 
--	when SoldAsVacant = 'Y' then 'Yes'
--	when SoldAsVacant = 'N' then 'No'
--	else SoldAsVacant
--end 
--from NashvilleHousing


update NashvilleHousing
set SoldAsVacant = 
case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end 





-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


with RowNumCte as (
select *,
ROW_NUMBER() over (partition by ParcelID , PropertyAddress , SalePrice , saleDateconverted , LegalReference order by [UniqueID ]) row_num
from NashvilleHousing
)

select *
from RowNumCte
where row_num > 1


-- the delete  them 


  



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select * from NashvilleHousing


alter table NashvilleHousing
drop column PropertyAddress , ownerAddressName

























