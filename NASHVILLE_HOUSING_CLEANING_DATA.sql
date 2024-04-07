select * from NashvilleHousing

-- Standarize Date Format
select SaleDate, CONVERT(Date, SaleDate) from NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- Populate Property Address Data

select * from NashvilleHousing
where PropertyAddress is null
or ParcelID = '025 07 0 031.00'
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) from NashvilleHousing a
JOIN NashvilleHousing b 
    on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
    on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


-- Breaking out address into individual columns (ADDRESS, CITY, STATE)
select PropertyAddress from NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,0,CHARINDEX(',',PropertyAddress)) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,LEN(PropertyAddress)) as City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,0,CHARINDEX(',',PropertyAddress))

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,LEN(PropertyAddress))

SELECT * FROM NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1);

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState  FROM NashvilleHousing

-- Chaneg Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing
Group By SoldAsVacant
order by 2



UPDATE NashvilleHousing
SET SoldAsVacant = 'Yes'
WHERE SoldAsVacant = 'Y'

UPDATE NashvilleHousing
SET SoldAsVacant = 'No'
WHERE SoldAsVacant = 'N'


-- Remove Duplicates

WITH RowNumCTE as (
SELECT *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY 
                    UniqueiD
                    ) row_num
FROM NashvilleHousing
)
DELETE FROM RowNumCTE
WHERE row_num > 1
-- Order by PropertyAddress


-- delete unused columns



SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate



-- Practicing partition by

SELECT * FROM NashvilleHousing

SELECT UniqueID, ParcelID, SoldAsVacant, PropertySplitCity ,
    SUM(case when SoldAsVacant like '%Yes%' then 1 else 0 end) OVER (
    PARTITION BY PropertySplitCity )
                as TotalVacants
FROM NashvilleHousing

SELECT * 
FROM NashvilleHousing
WHERE PropertySplitCity LIKE '%NOLENSVILLE%'
AND SoldAsVacant = 'Yes'
-- GROUP BY PropertySplitCity