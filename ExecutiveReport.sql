SELECT
	s.region,
    s.state,
    s.State_Profit_November_2021 AS 'Total State Profit November 2021',
    s.State_Profit_December_2021 AS 'Total State Profit December 2021',
    s.State_November_vs_December_2021 AS 'November 2021 vs December 2021 (%)',
    s.State_Profit_December_2020 AS 'Total State Profit December 2020',
    s.State_December_2020_vs_December_2021 AS 'December 2020 vs December 2021 (%)',
	rg.Region_Profit_December_2020 AS 'Total Region Profit December 2020',
    (State_Profit_December_2020 / Region_Profit_December_2020 * 100) AS 'Percent Participation December 2020 (%)',
    rg.Region_Profit_December_2021 AS 'Total Region Profit December 2021',
    (State_Profit_December_2021 / Region_Profit_December_2021 * 100) AS 'Percent Participation December 2021 (%)'
FROM (
	SELECT
		r.Region,
		a.State,
        SUM(CASE WHEN DATE_FORMAT(o.Order_Date, '%Y-%m') = '2021-11' THEN od.Profit ELSE 0 END) AS State_Profit_November_2021,
		SUM(CASE WHEN DATE_FORMAT(o.Order_Date, '%Y-%m') = '2021-12' THEN od.Profit ELSE 0 END) AS State_Profit_December_2021,
		IFNULL((SUM(CASE WHEN DATE_FORMAT(o.Order_Date, '%Y-%m') = '2021-12' THEN od.Profit ELSE 0 END) - SUM(CASE WHEN DATE_FORMAT(o.Order_Date, '%Y-%m') = '2021-11' THEN od.Profit ELSE 0 END)) / (SUM(CASE WHEN DATE_FORMAT(o.Order_Date, '%Y-%m') = '2021-11' THEN od.Profit ELSE 0 END)) * 100, 100) AS State_November_vs_December_2021,
		SUM(CASE WHEN DATE_FORMAT(o.Order_Date, '%Y-%m') = '2020-12' THEN od.Profit ELSE 0 END) AS State_Profit_December_2020,
		IFNULL((SUM(CASE WHEN DATE_FORMAT(o.Order_Date, '%Y-%m') = '2021-12' THEN od.Profit ELSE 0 END) - SUM(CASE WHEN DATE_FORMAT(o.Order_Date, '%Y-%m') = '2020-12' THEN od.Profit ELSE 0 END)) / (SUM(CASE WHEN DATE_FORMAT(o.Order_Date, '%Y-%m') = '2020-12' THEN od.Profit ELSE 0 END)) * 100, 100) AS State_December_2020_vs_December_2021
    FROM region r
	JOIN address a ON r.PK_Region_ID = a.FK_Region_ID
	JOIN order_table o ON a.PK_Address_ID = o.FK_Address_ID
	JOIN order_details od ON o.PK_Order_ID = od.FK_Order_ID
	WHERE DATE_FORMAT(o.Order_Date, '%Y-%m') IN ('2021-11', '2021-12', '2020-12')
    GROUP BY r.Region, a.State
) s

JOIN (
	SELECT
		r.Region,
        SUM(CASE WHEN DATE_FORMAT(o.Order_Date, '%Y-%m') = '2021-11' THEN od.Profit ELSE 0 END) AS Region_Profit_November_2021,
		SUM(CASE WHEN DATE_FORMAT(o.Order_Date, '%Y-%m') = '2021-12' THEN od.Profit ELSE 0 END) AS Region_Profit_December_2021,
		(SUM(CASE WHEN DATE_FORMAT(o.Order_Date, '%Y-%m') = '2021-11' THEN od.Profit ELSE 0 END) - SUM(CASE WHEN DATE_FORMAT(o.Order_Date, '%Y-%m') = '2021-12' THEN od.Profit ELSE 0 END)) AS Region_November_vs_December_2021,
		SUM(CASE WHEN DATE_FORMAT(o.Order_Date, '%Y-%m') = '2020-12' THEN od.Profit ELSE 0 END) AS Region_Profit_December_2020,
		(SUM(CASE WHEN DATE_FORMAT(o.Order_Date, '%Y-%m') = '2020-12' THEN od.Profit ELSE 0 END) - SUM(CASE WHEN DATE_FORMAT(o.Order_Date, '%Y-%m') = '2021-12' THEN od.Profit ELSE 0 END)) AS Region_December_2020_vs_December_2021
    FROM region r
	JOIN address a ON r.PK_Region_ID = a.FK_Region_ID
	JOIN order_table o ON a.PK_Address_ID = o.FK_Address_ID
	JOIN order_details od ON o.PK_Order_ID = od.FK_Order_ID
	WHERE DATE_FORMAT(o.Order_Date, '%Y-%m') IN ('2021-11', '2021-12', '2020-12')
    GROUP BY r.Region
) rg

ON s.Region = rg.Region

GROUP BY s.region, s.state
ORDER BY s.region