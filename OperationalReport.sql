WITH OrderDetails_Dec AS (
    -- Data for December 2021
    SELECT
        r.Region,
        a.State,
        a.City,
        cat.Category,
        o.Order_ID,
        SUM(od.Quantity) AS `Total Quantity Sold`,
        SUM(od.Sales) AS `Total Sales`,
        SUM(od.Profit) AS `Total Profit`,
        CASE 
            WHEN COALESCE(SUM(rt.Returned_Sales), 0) > 0 THEN SUM(od.Sales)
            ELSE COALESCE(SUM(rt.Returned_Sales), 0) 
        END AS `Total Returns`,
        SUM(od.Sales) - 
        CASE 
            WHEN COALESCE(SUM(rt.Returned_Sales), 0) > 0 THEN SUM(od.Sales)
            ELSE COALESCE(SUM(rt.Returned_Sales), 0) 
        END AS `Net Sales Revenue`,
        'December' AS `Month`
    FROM gbc_superstore.region r
        JOIN gbc_superstore.address a ON r.PK_Region_ID = a.FK_Region_ID
        JOIN gbc_superstore.order_table o ON a.PK_Address_ID = o.FK_Address_ID
        JOIN gbc_superstore.order_details od ON o.PK_Order_ID = od.FK_Order_ID
        JOIN gbc_superstore.product p ON p.PK_Product_ID = od.FK_Product_ID
        JOIN gbc_superstore.sub_category sc ON sc.PK_Sub_Category_ID = p.FK_Sub_Category_ID
        JOIN gbc_superstore.category cat ON cat.PK_Category_ID = sc.FK_Category_ID
    LEFT JOIN (
        SELECT 
            o.PK_Order_ID,
            SUM(od.Sales) AS Returned_Sales
        FROM return_table rt
        JOIN gbc_superstore.order_table o ON rt.FK_Order_ID = o.PK_Order_ID
        JOIN gbc_superstore.order_details od ON o.PK_Order_ID = od.FK_Order_ID
        GROUP BY o.PK_Order_ID
    ) rt ON o.PK_Order_ID = rt.PK_Order_ID
    WHERE
        MONTH(o.Order_Date) = 12
        AND YEAR(o.Order_Date) = 2021
        AND r.Region = 'East'
    GROUP BY
        r.Region, a.State, a.City, cat.Category, o.Order_ID
),
OrderDetails_Nov AS (
    -- Data for November 2021
    SELECT
        r.Region,
        a.State,
        a.City,
        cat.Category,
        o.Order_ID,
        SUM(od.Quantity) AS `Total Quantity Sold`,
        SUM(od.Sales) AS `Total Sales`,
        SUM(od.Profit) AS `Total Profit`,
        CASE 
            WHEN COALESCE(SUM(rt.Returned_Sales), 0) > 0 THEN SUM(od.Sales)
            ELSE COALESCE(SUM(rt.Returned_Sales), 0) 
        END AS `Total Returns`,
        SUM(od.Sales) - 
        CASE 
            WHEN COALESCE(SUM(rt.Returned_Sales), 0) > 0 THEN SUM(od.Sales)
            ELSE COALESCE(SUM(rt.Returned_Sales), 0) 
        END AS `Net Sales Revenue`,
        'November' AS `Month`
    FROM gbc_superstore.region r
        JOIN gbc_superstore.address a ON r.PK_Region_ID = a.FK_Region_ID
        JOIN gbc_superstore.order_table o ON a.PK_Address_ID = o.FK_Address_ID
        JOIN gbc_superstore.order_details od ON o.PK_Order_ID = od.FK_Order_ID
        JOIN gbc_superstore.product p ON p.PK_Product_ID = od.FK_Product_ID
        JOIN gbc_superstore.sub_category sc ON sc.PK_Sub_Category_ID = p.FK_Sub_Category_ID
        JOIN gbc_superstore.category cat ON cat.PK_Category_ID = sc.FK_Category_ID
    LEFT JOIN (
        SELECT 
            o.PK_Order_ID,
            SUM(od.Sales) AS Returned_Sales
        FROM return_table rt
        JOIN gbc_superstore.order_table o ON rt.FK_Order_ID = o.PK_Order_ID
        JOIN gbc_superstore.order_details od ON o.PK_Order_ID = od.FK_Order_ID
        GROUP BY o.PK_Order_ID
    ) rt ON o.PK_Order_ID = rt.PK_Order_ID
    WHERE
        MONTH(o.Order_Date) = 11
        AND YEAR(o.Order_Date) = 2021
        AND r.Region = 'East'
    GROUP BY
        r.Region, a.State, a.City, cat.Category, o.Order_ID
)

-- Final SELECT to combine and add November's Net Sales Revenue as an additional column
SELECT
    dece.Region,
    dece.State,
    dece.City,
    dece.Category,
    SUM(dece.`Total Quantity Sold`) AS `Dec Total Quantity Sold`,
    SUM(dece.`Total Sales`) AS `Dec Total Sales`,
    SUM(dece.`Total Returns`) AS `Dec Total Returns`,
    SUM(dece.`Net Sales Revenue`) AS `Dec Net Sales Revenue`,
    COALESCE(nov.`Net Sales Revenue`, 0) AS `Nov Net Sales Revenue`, -- Add November's Net Sales Revenue
    CASE 
        WHEN COALESCE(nov.`Net Sales Revenue`, 0) = 0 THEN 
            NULL -- To handle division by zero
        ELSE 
            ROUND(((SUM(dece.`Net Sales Revenue`) - COALESCE(nov.`Net Sales Revenue`, 0)) / COALESCE(nov.`Net Sales Revenue`, 0)) * 100, 2)
    END AS `Current vs Previous Period`
FROM OrderDetails_Dec dece
LEFT JOIN (
    -- Aggregating November data for the matching categories and locations
    SELECT 
        Region,
        State,
        City,
        Category,
        SUM(`Net Sales Revenue`) AS `Net Sales Revenue`
    FROM OrderDetails_Nov
    GROUP BY Region, State, City, Category
) nov ON dece.Region = nov.Region
    AND dece.State = nov.State
    AND dece.City = nov.City
    AND dece.Category = nov.Category
GROUP BY 
    dece.Region, dece.State, dece.City, dece.Category, nov.`Net Sales Revenue`
ORDER BY
    dece.Region, dece.State, dece.City, dece.Category;
