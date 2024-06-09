WITH RecursiveSubdivisions AS (
    -- Начальный уровень (подразделение "Сотрудник 1")
    SELECT 
        id, 
        name, 
        parent_id,
        0 AS sub_level
    FROM 
        subdivisions
    WHERE 
        id = (SELECT subdivision_id FROM collaborators WHERE id = 710253)
    
    UNION ALL
    
    -- Рекурсивное объединение для получения всех нижестоящих подразделений
    SELECT 
        s.id, 
        s.name, 
        s.parent_id,
        rs.sub_level + 1
    FROM 
        subdivisions s
    INNER JOIN 
        RecursiveSubdivisions rs ON s.parent_id = rs.id
),
FilteredEmployees AS (
    -- Получение сотрудников всех нижестоящих подразделений
    SELECT 
        c.id,
        c.name,
        c.subdivision_id,
        rs.name AS sub_name,
        rs.sub_level
    FROM 
        collaborators c
    INNER JOIN 
        RecursiveSubdivisions rs ON c.subdivision_id = rs.id
    WHERE 
        c.age < 40
        AND c.subdivision_id NOT IN (100055, 100059)
),
SubdivisionsCount AS (
    -- Подсчет количества сотрудников в каждом подразделении
    SELECT 
        c.subdivision_id,
        COUNT(*) AS colls_count
    FROM 
        collaborators c
    GROUP BY 
        c.subdivision_id
)
-- Формирование итоговой таблицы
SELECT 
    fe.id,
    fe.name,
    fe.sub_name,
    fe.subdivision_id AS sub_id,
    fe.sub_level,
    sc.colls_count
FROM 
    FilteredEmployees fe
INNER JOIN 
    SubdivisionsCount sc ON fe.subdivision_id = sc.subdivision_id
ORDER BY 
    fe.sub_level ASC;
