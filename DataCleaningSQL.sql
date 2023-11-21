--"hd" is the name of the table in the database SQLDataCleaning

Select * from SQLDataCleaning..hd

-- Standardize the date format

Select SaleDateCorrected from SQLDataCleaning..hd

Alter Table hd
add SaleDateCorrected Date;
Update hd
set SaleDateCorrected = convert(date, SaleDate)
-- --------------------------------------------------------

-- Populating the property address field/populating all the null cells.

Select count(*) from SQLDataCleaning..hd
where PropertyAddress is NULL

Select propertyAddress from SQLDataCleaning..hd
where propertyAddress is NULL


Select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
from SQLDataCleaning..hd a
JOIN SQLDataCleaning..hd b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
where a.propertyAddress is NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from SQLDataCleaning..hd a
JOIN SQLDataCleaning..hd b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
where a.propertyAddress is NULL
-- --------------------------------------------------------
--Dividing Address into different (individual) columns; address, city, state. (Owner and property address)

Select PropertyAddress from SQLDataCleaning..hd

Select substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,  charindex(',',PropertyAddress)+1, len(PropertyAddress))
from SQLDataCleaning..hd

Alter table SQLDataCleaning..hd 
Add PropertySplitAddress Nvarchar(250)

update SQLDataCleaning..hd
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1)

Alter table SQLDataCleaning..hd 
Add PropertySplitCity Nvarchar(250)

update SQLDataCleaning..hd
set PropertySplitCity = substring(PropertyAddress,  charindex(',',PropertyAddress)+1, len(PropertyAddress))


Select * from SQLDataCleaning..hd



Select parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1) from SQLDataCleaning..hd

Alter table SQLDataCleaning..hd 
Add OwnerHomeAddress Nvarchar(250)
update SQLDataCleaning..hd
set OwnerHomeAddress = parsename(replace(OwnerAddress, ',', '.'), 3)


Alter table SQLDataCleaning..hd 
Add OwnerCity nvarchar(250)
update SQLDataCleaning..hd
set OwnerCity = parsename(replace(OwnerAddress, ',', '.'), 2)


Alter table SQLDataCleaning..hd 
Add OwnerState Nvarchar(250)
update SQLDataCleaning..hd
set OwnerState = parsename(replace(OwnerAddress, ',', '.'), 1)

Select * from SQLDataCleaning..hd

-----------------------------------------------------------------

--Replacing all the Y and Ns with Yes and No respectively in the SoldAsVacant column

Select distinct(SoldAsVacant), count(SoldAsVacant) from SQLDataCleaning..hd
group by SoldAsVacant 
order by 2


Select SoldAsVacant,
Case When SoldAsVacant = 'Y' then 'Yes'
     When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
from SQLDataCleaning..hd

update SQLDataCleaning..hd
set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
     When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End

----------------------------------------------------------------------------
--Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From SQLDataCleaning..hd
--order by ParcelID
)

delete 
From RowNumCTE
Where row_num > 1

------------------------------------------------------------------------------
--Deleting Useless Columns

Alter Table SQLDataCleaning..hd
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select * from SQLDataCleaning..hd

Select count( DISTINCT UniqueID) from SQLDataCleaning..hd 