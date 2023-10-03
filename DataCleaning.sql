Select *
From DataCleaning..NashvilleHausing

-- Standardazing date format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From DataCleaning..NashvilleHausing

Update NashvilleHausing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHausing
Add SaleDateConverted Date;

Update NashvilleHausing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address data

Select *
From DataCleaning..NashvilleHausing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaning..NashvilleHausing a
JOIN DataCleaning..NashvilleHausing b 
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaning..NashvilleHausing a
JOIN DataCleaning..NashvilleHausing b 
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out address into individual columns (address, city, state)


Select PropertyAddress
From DataCleaning..NashvilleHausing
--Where PropertyAddress is null
--order by ParcelID

--delimiter

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From DataCleaning..NashvilleHausing

ALTER TABLE NashvilleHausing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHausing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE NashvilleHausing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHausing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From DataCleaning..NashvilleHausing

--PARSENAME

Select OwnerAddress
From DataCleaning..NashvilleHausing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From DataCleaning..NashvilleHausing


ALTER TABLE NashvilleHausing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHausing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHausing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHausing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHausing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHausing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



--  Changing Y and N to Yes and No

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DataCleaning..NashvilleHausing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From DataCleaning..NashvilleHausing



Update NashvilleHausing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


-- Removing Duplicates

WITH RowNumCTE AS (
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
					
From DataCleaning..NashvilleHausing
--order by ParcelID
)

--DELETE
--From RowNumCTE
--Where row_num > 1 
--Order by PropertyAddress

Select *
From RowNumCTE
Where row_num > 1 
Order by PropertyAddress


-- Delete unused columns

Select *
From DataCleaning..NashvilleHausing

ALTER TABLE DataCleaning..NashvilleHausing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE DataCleaning..NashvilleHausing
DROP COLUMN SaleDate