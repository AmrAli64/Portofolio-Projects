/*

Cleaning Data in SQL Queries

*/

Select *
from NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate
from NashvilleHousing

Alter table NashvilleHousing
Alter column saledate date

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
from NashvilleHousing
where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress,b.propertyaddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

update a
set PropertyAddress =  isnull(a.propertyaddress,b.propertyaddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(propertyaddress, 1, CHARINDEX(',',Propertyaddress)-1) as address,
SUBSTRING(propertyaddress, CHARINDEX(',',Propertyaddress) + 1, LEN(PropertyAddress)) as address
from NashvilleHousing

 
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',',Propertyaddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',',Propertyaddress) + 1, LEN(PropertyAddress))

select *
from NashvilleHousing

select OwnerAddress
from NashvilleHousing

select
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(owneraddress,',','.'),3)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(owneraddress,',','.'),2)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(owneraddress,',','.'),1)

select *
from NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'NO'
Else SoldAsVacant
End
from NashvilleHousing

update NashvilleHousing
Set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'NO'
Else SoldAsVacant
End
from NashvilleHousing




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


With RowNumCTE as(
Select *,
 ROW_NUMBER() over (
 partition by ParcelID,
 propertyaddress,
 saleprice,
 saledate,
 legalreference
 order by uniqueid) row_num
from NashvilleHousing
--order by parcelid
)
--Delete
select *
from RowNumCTE
where row_num > 1
--order by propertyaddress



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
from NashvilleHousing


Alter Table NashvilleHousing
Drop Column Owneraddress, taxdistrict, propertyaddress,saledate



-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
