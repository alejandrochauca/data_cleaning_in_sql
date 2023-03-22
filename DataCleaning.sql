--Estandarizar Formato de Fecha

SELECT SaleDate2, CAST(SaleDate as date)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate=CAST(SaleDate as date)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDate2 Date;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate2=CAST(SaleDate as date)

--Poblar Columna Property Adress: Remplazar NULLS por PropertyAdress que tengan el mismo ParcelID
SELECT a.PropertyAddress,a.ParcelID,b.PropertyAddress,b.ParcelID, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Dividir PropertyAdress en columnas individuales (SUBSTRING)

SELECT
PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Adress,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Adress2


FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


-- Dividir OwnerAddress (PARSE)
SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
	
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Normalizar SoldAsVacant
select SoldAsVacant, count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE When SoldAsVacant ='Y' THEN 'Yes'
       When SoldAsVacant ='N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from PortfolioProject.dbo.NashvilleHousing


UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant=CASE When SoldAsVacant ='Y' THEN 'Yes'
       When SoldAsVacant ='N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Eliminar Duplicados: identificamos las filas que tengan el mismo ParcelID,PropertyAddress,SalesPrice,SaleDate,LegalReference. 
		--Necesitamos crear un CTE o una tabla temporal para poder operar con la colummna creada
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID) row_num

FROM PortfolioProject.DBO.NashvilleHousing
--order by ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num>1

--Eliminar columnas no usadas
ALTER TABLE PortfolioProject.DBO.NashvilleHousing
DROP COLUMN	 OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


SELECT *
FROM PortfolioProject.DBO.NashvilleHousing