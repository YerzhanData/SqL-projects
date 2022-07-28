--Cleaning Data in SQL Queries

SELECT *
FROM Project..NashvilleHousing

---------------------------------------------------------------

--Standardize Data Format 

SELECT SaleDateConverted,CONVERT(Date,SaleDate)
FROM Project..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing 
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)
s

---------------------------------------------------------------

--Populate Property Address Data  

SELECT *
FROM Project..NashvilleHousing
--Where PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyAddress,b.PropertyAddress)
FROM Project..NashvilleHousing a
JOIN Project..NashvilleHousing b
    on a.ParcelID  =  b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
--WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.propertyAddress,b.PropertyAddress)
FROM Project..NashvilleHousing a
JOIN Project..NashvilleHousing b
    on a.ParcelID  =  b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null


---------------------------------------------------------------

--Breaking out Address into Individual Columns (Address,City,State)

SELECT PropertyAddress
FROM Project..NashvilleHousing
--Where PropertyAddress is null
--ORDER BY ParcelID


SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as Address

FROM Project..NashvilleHousing

 ALTER TABLE NashvilleHousing 
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing 
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity =SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))



SELECT OwnerAddress
FROM Project..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Project..NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress =PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing 
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


---------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant"  field

SELECT Distinct(SoldAsVacant),COUNT(SoldAsVacant)
FROM Project..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2		


SELECT SoldAsVacant
,CASE when  SoldAsVacant = 'Y' THEN  'Yes'
      when SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM Project..NashvilleHousing
FROM Project..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE when  SoldAsVacant = 'Y' THEN  'Yes'
      when SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


---------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
	PARTITION BY ParcelId,
                 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				    UniqueID
					) row_num
FROM Project..NashvilleHousing
--ORDER BY ParcelID
)
DELETE 
FROM RowNumCTE
WHERE row_num>1


---------------------------------------------------------------

--dELETE Unused Columns

SELECT *
FROM Project..NashvilleHousing

ALTER TABLE Project..NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE Project..NashvilleHousing
DROP COLUMN SaleDate